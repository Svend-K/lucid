require 'open-uri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :result]

  NUMBEO_API_KEY = "tzkq1cec4lcm6h"
  BASE_URL = "https://www.numbeo.com"

  def home
    @current_city = City.new
    @destination_city = City.new
  end

  def result
    @current_city = get_city(params['current_city'])
    @destination_city = get_city(params['destination_city'])

    # there's no city like that in numbeo db OR cannot add same cities THEN note the user
    if @current_city.nil? || @destination_city.nil? || @current_city == @destination_city
      return redirect_to root_path
    end

    get_indices_for_city(@current_city)
    get_indices_for_city(@destination_city)

    get_items_for_city(@current_city)
    get_items_for_city(@destination_city)
  end

  private

  def get_indices(city)
    indices_url = "/api/indices?api_key=#{NUMBEO_API_KEY}&query=#{city.name}"
    indices_json = get_json_from(indices_url)
  end

  def get_prices(city)
    prices_url = "/api/city_prices?api_key=#{NUMBEO_API_KEY}&query=#{city.name}&currency=EUR"
    prices_json = get_json_from(prices_url)
  end

  def get_json_from(url)
    full_url = BASE_URL + url
    serialized = open(full_url).read
    json = JSON.parse(serialized)
  end

  def get_city(name)
    if City.find_by(name: name.downcase).nil?
      full_url = BASE_URL + "/api/cities?api_key=#{NUMBEO_API_KEY}"
      serialized = open(full_url).read
      json = JSON.parse(serialized)

      json_cities = json['cities']
      json_cities.each do |c|
        if name.capitalize == c['city']
          return City.create!(name: name.downcase)
        end
      end
    else
      return City.find_by(name: name.downcase)
    end
  end

  def get_indices_for_city(city)
    unless CitiesIndex.find_by(city_id: city.id).nil?
      return @city_indices = CitiesIndex.where(city_id: city.id)
    end

    @city_indices = []
    indices = get_indices(city)
    indices.each do |i, v|

      if Index.find_by(name: i).nil?
        current_index = Index.create!(name: i)
      else
        current_index = Index.find_by(name: i)
      end

      current_cities_index = CitiesIndex.create!(city_id: city.id, index_id: current_index.id, score: v)

      @city_indices << current_cities_index
    end
    return @city_indices
  end

  def get_items_for_city(city)
    @city_items = []

    unless CitiesItem.find_by(city_id: city.id).nil?
      return @city_items = CitiesItem.where(city_id: city.id)
    end

    prices = get_prices(city)
    prices['prices'].each do |p|

      if Item.find_by(name: p['item_name']).nil?
        current_item = Item.create!(name: p['item_name'])
      else
        current_item = Item.find_by(name: p['item_name'])
      end

      @city_items << CitiesItem.create!(city_id: city.id, item_id: current_item.id, price: p['average_price'])
    end
    return @city_items
  end
end
