require 'open-uri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :result]

  NUMBEO_API_KEY = "tzkq1cec4lcm6h"
  BASE_URL = "https://www.numbeo.com"

  API_INDICES_MAPPING = {
    "crime_index" => "Crime Rate",
    "traffic_time_index" => "Traffic",
    "safety_index" => "Safety",
    "quality_of_life_index" => "Lifequality",
    "health_care_index" => "Healthcare",
    "pollution_index" => "Pollution",
    "rent_index" => "Rent Price",
    "purchasing_power_incl_rent_index" => "Money Worth",
    "restaurant_price_index" => "Restaurant Cost",
    "groceries_index" => "Groceries",
    "cpi_index" => "Consumer-Price Index",
  }
  LIFEQUALITY_INDEX_NAMES = [
    "crime_index",
    "traffic_time_index",
    "safety_index",
    "quality_of_life_index",
    "health_care_index",
    "pollution_index"
  ]

  QUANTITATIVE_INDEX_NAMES = [
    "purchasing_power_incl_rent_index",
    "restaurant_price_index",
    "cpi_index",
    "rent_index",
    "groceries_index"
  ]

  def home
    @current_city = City.new
    @destination_city = City.new
  end

  def result
    @current_city = get_city(params[:current_city])
    @destination_city = get_city(params[:destination_city])
    @user_profile = params[:user_profile]
    @spending_in_current_city = params['monthly_spending'].to_i

    # there's no city like that in numbeo db OR cannot add same cities THEN note the user
    if @current_city.nil? || @destination_city.nil? || @current_city == @destination_city
      redirect_to root_path and return
    end

    get_items_for_city(@current_city)
    get_items_for_city(@destination_city)

    @current_city_indices = get_indices_for_city(@current_city)
    @destination_city_indices = get_indices_for_city(@destination_city)

    @current_city_graph_lifequality = get_indices_for_chart(@current_city_indices, LIFEQUALITY_INDEX_NAMES)
    @destination_city_graph_lifequality = get_indices_for_chart(@destination_city_indices, LIFEQUALITY_INDEX_NAMES)

    @current_city_graph_quantitative = get_indices_for_chart(@current_city_indices, QUANTITATIVE_INDEX_NAMES)
    @destination_city_graph_quantitative = get_indices_for_chart(@destination_city_indices, QUANTITATIVE_INDEX_NAMES)

    @recommended_city = get_recommended_city(@current_city, @destination_city)

    @qual_data = [get_qual_data(@current_city), get_qual_data(@destination_city)]
    @qual_data_user_profile = [get_qual_data_user_profile(@current_city, @user_profile), get_qual_data_user_profile(@destination_city, @user_profile)]

    @spending_in_dest_city = get_spending_in_dest_city

    @current_city_image = get_images(@current_city)
    @destination_city_image = get_images(@destination_city)
  end

  private

  def get_spending_in_dest_city
    current_city_cpi_and_rent_score = get_indices_hash_for_chart(@current_city_indices)["cpi_and_rent_index"]
    destination_city_cpi_and_rent_score = get_indices_hash_for_chart(@destination_city_indices)["cpi_and_rent_index"]

    current_spending = params['monthly_spending'].to_i
    return current_spending / current_city_cpi_and_rent_score * destination_city_cpi_and_rent_score
  end

  def get_qual_data(city)
    current_city_hash = {}
    city.cities_factor.each do |cf|
      current_city_hash[cf.factor.name] = cf.score
    end

    current_city_qual_data = { name: city.name, data: current_city_hash }
  end

  def get_qual_data_user_profile(city, user_profile)
    current_city_hash = {}
    user_profile_object = Profile.find_by(name:user_profile)
    user_factor_objects = []
    user_profile_object.profiles_factors.each { |profilefactor| user_factor_objects << profilefactor.factor }
    user_factor_objects.each do |user_factor_object|
      city.cities_factor.where('factor_id = ?', user_factor_object).each do |cf|
        current_city_hash[cf.factor.name] = cf.score
      end
    end
    current_city_qual_data = { name: city.name, data: current_city_hash }
  end


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

  def get_images(city)
    images_url = "https://api.teleport.org/api/urban_areas/slug:#{city.name}/images"
    serialized = open(images_url).read
    json = JSON.parse(serialized)
    json["photos"][0]["image"]["mobile"]
  end

  def get_city(name)
    if City.find_by(name: name.downcase)
      city =  City.find_by(name: name.downcase)
    else
      full_url = BASE_URL + "/api/cities?api_key=#{NUMBEO_API_KEY}"
      serialized = open(full_url).read
      json = JSON.parse(serialized)
      json_cities = json['cities']
      if json_cities.any? { |c| c['city'].downcase.include? name.downcase }
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

  def get_indices_for_chart(city_indices, api_index_names)
    city_hash = get_indices_hash_for_chart(city_indices)

    return api_index_names.map do |api_index_name|
      index_name = API_INDICES_MAPPING[api_index_name]
      [index_name, city_hash[api_index_name]]
    end
  end

  def get_indices_hash_for_chart(city_indices)
    city_indices.reduce({}) do |indices, city_index|
      indices[city_index.index.name] = city_index.score

      indices
    end
  end
end
