require 'open-uri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :result]

  NUMBEO_API_KEY = "tzkq1cec4lcm6h"
  BASE_URL = "https://www.numbeo.com"

  LIFEQUALITY_INDEX_NAMES = [
    "crime_index",
    "traffic_time_index",
    "safety_index",
    "quality_of_life_index",
    "health_care_index",
    "pollution_index"
  ]

  QUANTITATIVE_INDEX_NAMES = [
    "cpi_and_rent_index",
    "purchasing_power_incl_rent_index",
    "restaurant_price_index",
    "cpi_index",
    "rent_index",
    "groceries_index"
  ]

  ITEMS_TO_EXCLUDE = [
    "Toyota Corolla 1.6l 97kW Comfort (Or Equivalent New Car), Transportation",
    "Volkswagen Golf 1.4 90 KW Trendline (Or Equivalent New Car), Transportation",
    "International Primary School, Yearly for 1 Child, Childcare",
    "Average Monthly Net Salary (After Tax), Salaries And Financing",
    "Price per Square Meter to Buy Apartment Outside of Centre, Buy Apartment Price",
    "Price per Square Meter to Buy Apartment in City Centre, Buy Apartment Price",
    "Apartment (1 bedroom) Outside of Centre, Rent Per Month",
    "Apartment (1 bedroom) in City Centre, Rent Per Month",
    "Apartment (3 bedrooms) Outside of Centre, Rent Per Month",
    "Apartment (3 bedrooms) in City Centre, Rent Per Month",
    "Preschool (or Kindergarten), Private, Monthly for 1 Child, Childcare",
  ]

  ITEMS_FOR_WORKER = [
  "Internet (60 Mbps or More, Unlimited Data, Cable/ADSL), Utilities (Monthly)",
  "Cinema, International Release, 1 Seat, Sports And Leisure",
  "Cappuccino (regular), Restaurants",
  "Basic (Electricity, Heating, Water, Garbage) for 85m2 Apartment, Utilities (Monthly)",
  "Apartment (1 bedroom) Outside of Centre, Rent Per Month",
  "Apartment (1 bedroom) in City Centre, Rent Per Month"
  ]

  ITEMS_FOR_FAMILY = [
  "Meal for 2 People, Mid-range Restaurant, Three-course, Restaurants",
  "Monthly Pass (Regular Price), Transportation",
  "Price per Square Meter to Buy Apartment Outside of Centre, Buy Apartment Price",
  "Price per Square Meter to Buy Apartment in City Centre, Buy Apartment Price",
  "Apartment (3 bedrooms) Outside of Centre, Rent Per Month",
  "Apartment (3 bedrooms) in City Centre, Rent Per Month"
   ]

  ITEMS_FOR_STUDENT = [
  "Cappuccino (regular), Restaurants",
  "Domestic Beer (0.5 liter bottle), Markets",
  "McMeal at McDonalds (or Equivalent Combo Meal), Restaurants",
  "Apples (1kg), Markets",
  "Monthly Pass (Regular Price), Transportation",
  "Rice (white), (1kg), Markets"
  ]

  def home
    @current_city = City.new
    @destination_city = City.new
  end

  def result
    @current_city = get_city(params[:current_city])
    @destination_city = get_city(params[:destination_city])
    @user_profile = params[:user_profile]

    # there's no city like that in numbeo db OR cannot add same cities THEN note the user
    if @current_city.nil? || @destination_city.nil? || @current_city == @destination_city
      redirect_to root_path and return
    end

    @current_city_items = get_items_for_city(@current_city)
    @destionation_city_items = get_items_for_city(@destination_city)
    @current_city_items_for_display = get_items_for_display(@current_city_items)
    @destination_city_items_for_display = get_items_for_display(@destionation_city_items)
    @cites_items_for_display = @current_city_items_for_display.zip @destination_city_items_for_display

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

  def get_items_for_display(items)
    items_array = []
    items.each do |item|
      items_array << [item.item.name, item.price.round(1)]
    end
    items_array.select! { |i| get_items_array_for_user_profiles.include? i[0] }
  end

  def get_items_array_for_user_profiles
    user_profile = params['user_profile']
    if user_profile == "worker"
      return ITEMS_FOR_WORKER
    elsif user_profile == "family"
      return ITEMS_FOR_FAMILY
    elsif user_profile == "student"
      return ITEMS_FOR_STUDENT
    end
  end

  def get_indices_for_chart(city_indices, index_names)
    city_hash = get_indices_hash_for_chart(city_indices)

    return index_names.map do |index_name|
      [index_name, city_hash[index_name]]
    end
  end

  def get_indices_hash_for_chart(city_indices)
    city_indices.reduce({}) do |indices, city_index|
      indices[city_index.index.name] = city_index.score

      indices
    end
  end
end
