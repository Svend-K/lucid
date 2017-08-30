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

    # purchasing_power_incl_rent_index
    local_purch_pow_index = Index.find_by(name: 'purchasing_power_incl_rent_index')

    @current_city_local_purch_pow = get_index_for_city(@current_city, local_purch_pow_index)
    @destination_city_local_purch_pow = get_index_for_city(@destination_city, local_purch_pow_index)

    # @current_city_prices = get_prices_for_city(@current_city)
  end

  private

  def get_indices(city)
    indices_url = "/api/indices?api_key=#{NUMBEO_API_KEY}&query=#{city.name}"
    indices_json = get_json_from(indices_url)
  end

  def get_prices(city)
    prices_url = "/api/city_prices?api_key=#{NUMBEO_API_KEY}&query=#{city.name}"
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

  def get_index_for_city(city, index)
    city_local_purch_pow_index = CitiesIndex.find_by(city_id: city.id, index_id: index.id)
    if city_local_purch_pow_index.nil?
      city_indices = get_indices(city)
      city_local_purch_pow = CitiesIndex.create!(city_id: city.id, index_id: index.id, score: city_indices['purchasing_power_incl_rent_index'])
    else
      city_local_purch_pow = city_local_purch_pow_index
    end
  end

  # def get_prices_for_city(city)
  #   @cities_items = []

  #   prices = get_prices(city)['prices']
  #   prices.each do |p|

  #     if Item.find_by(name: p['item_name']).nil?
  #       current_item = Item.create!(name: p['item_name'])
  #     else
  #       current_item = Item.find_by(name: p['item_name'])
  #     end

  #     @cities_items << CitiesItem.create!(city_id: city.id, item_id: current_item.id, price: p['average_price'])
  #   end
  # end

end
