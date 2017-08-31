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

    @current_city_indices_raw = get_indices_for_city(@current_city)
    @destination_city_indices_raw = get_indices_for_city(@destination_city)

    @current_city_prices = get_prices_for_city(@current_city)
    @destination_city_prices = get_prices_for_city(@destination_city)

    @current_city_graph_lifequality = graphing_current_city.values_at(0, 1, 6, 10, 12, 16)
    @destination_city_graph_lifequality = graphing_destination_city.values_at(0, 1, 6, 10, 12, 16)

    @current_city_graph_quantitative = graphing_current_city.values_at(2, 3, 4, 8, 11, 14)
    @destination_city_quantitative = graphing_destination_city.values_at(2, 3, 4, 8, 11, 14)
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
    # check if city already exists, save if not
    downcase_name = name.downcase
    if City.find_by(name: downcase_name).nil?
      city = City.create!(name: downcase_name)
    else
      city = City.find_by(name: downcase_name)
    end
  end

  def get_indices_for_city(city)
    @city_indices = []

    unless CitiesIndex.find_by(city_id: city.id).nil?
      return @city_indices = CitiesIndex.where(city_id: city.id)
    end

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

  def get_prices_for_city(city)
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

  def graphing_current_city
    @cur_indices_array = []
    @current_city_indices_raw.each do |index|
      cur_index_array = Array.new
      cur_index_array << index.index.name
      cur_index_array << index.score
      @cur_indices_array << cur_index_array
    end
    return @cur_indices_array
  end

  def graphing_destination_city
    @dest_indices_array = []
    @destination_city_indices_raw.each do |index|
      dest_index_array = Array.new
      dest_index_array << index.index.name
      dest_index_array << index.score
      @dest_indices_array << dest_index_array
    end
    return @dest_indices_array
  end
end
