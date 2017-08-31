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
    @current_city = get_city(params[:current_city])
    @destination_city = get_city(params[:destination_city])

    # there's no city like that in numbeo db OR cannot add same cities THEN note the user
    if @current_city.nil? || @destination_city.nil? || @current_city == @destination_city
      return redirect_to root_path
    end

    get_items_for_city(@current_city)
    get_items_for_city(@destination_city)

    current_city_indices = get_indices_for_city(@current_city)
    destination_city_indices = get_indices_for_city(@destination_city)

    @current_city_graph_lifequality = get_indices_for_chart(current_city_indices).values_at(0, 1, 6, 10, 12, 16)
    @destination_city_graph_lifequality = get_indices_for_chart(destination_city_indices).values_at(0, 1, 6, 10, 12, 16)

    @current_city_graph_quantitative = get_indices_for_chart(current_city_indices).values_at(2, 3, 4, 8, 11, 14)
    @destination_city_graph_quantitative = get_indices_for_chart(destination_city_indices).values_at(2, 3, 4, 8, 11, 14)

    @recommended_city = get_recommended_city(@current_city, @destination_city)
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
    if City.find_by(name: name.downcase)
      city =  City.find_by(name: name.downcase)
    else
      full_url = BASE_URL + "/api/cities?api_key=#{NUMBEO_API_KEY}"
      serialized = open(full_url).read
      json = JSON.parse(serialized)
      json_cities = json['cities']
      if json_cities.any? { |c| name.capitalize == c['city'] }
        city = City.create!(name: name.downcase)
      end
    end
    return city
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

  def get_recommended_city(current_city, destination_city)
    index = Index.find_by(name: "purchasing_power_incl_rent_index")
    current_city_score = CitiesIndex.find_by(index_id: index.id, city_id:current_city.id).score
    destination_city_score = CitiesIndex.find_by(index_id: index.id, city_id:destination_city.id).score

    if current_city_score > destination_city_score
      current_city.name
    else
      destination_city.name
    end
  end

  def get_indices_for_chart(city_indices)
    city_indices.map { |index| [index.index.name, index.score] }
  end
end
