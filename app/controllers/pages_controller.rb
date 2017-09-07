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

  ITEMS_FOR_WORKER = {
  "Internet (60 Mbps or More, Unlimited Data, Cable/ADSL), Utilities (Monthly)" => ["internet", "<strong>Internet</strong> monthly"],
  "Cinema, International Release, 1 Seat, Sports And Leisure" => ["cinema", "<strong>Cinema</strong> ticket"],
  "Cappuccino (regular), Restaurants" => ["coffee", "<strong>Cappuccino</strong> in a restaurant"],
  "Basic (Electricity, Heating, Water, Garbage) for 85m2 Apartment, Utilities (Monthly)" => ["utilities", "Monthly <strong>utilities</strong>"],
  "Apartment (1 bedroom) Outside of Centre, Rent Per Month" => ["suburb", "<strong>Rent apartment</strong> outside of city center <strong>per month</strong>"],
  "Apartment (1 bedroom) in City Centre, Rent Per Month" => ["center", "<strong>Rent apartment</strong> in city center <strong>per month</strong>"]
  }

  ITEMS_FOR_FAMILY = {
  "Meal for 2 People, Mid-range Restaurant, Three-course, Restaurants" => ["mealmidrange", "<strong>Meal</strong> in mid-range restaurant"],
  "Monthly Pass (Regular Price), Transportation" => ["transportpass", "Monthly pass for <strong>public transport</strong>"],
  "Price per Square Meter to Buy Apartment Outside of Centre, Buy Apartment Price" => ["suburb", "<strong>Apartment price per sqm</strong> outside of city center"],
  "Price per Square Meter to Buy Apartment in City Centre, Buy Apartment Price" => ["center", "<strong>Apartment price per sqm</strong> in city center"],
  "Apples (1kg), Markets" => ["apple", "<strong>Apple</strong> 1kg"],
  "Rice (white), (1kg), Markets" => ["rice", "<strong>Rice</strong> 1kg"]
   }

  ITEMS_FOR_STUDENT = {
    "Cappuccino (regular), Restaurants" => ["coffee", "<strong>Cappuccino</strong> in a restaurant"],
    "Domestic Beer (0.5 liter bottle), Markets" => ["beer", "<strong>Beer</strong> 0.5l from shop"],
    "McMeal at McDonalds (or Equivalent Combo Meal), Restaurants" => ["mcmeal", "<strong>McMeal</strong> at McDonalds"],
    "Apples (1kg), Markets" => ["apple", "<strong>Apple</strong> 1kg"],
    "Monthly Pass (Regular Price), Transportation" => ["transportpass", "Monthly pass for <strong>public transport</strong>"],
    "Rice (white), (1kg), Markets" => ["rice", "<strong>Rice</strong> 1kg"]
  }

  EMOJI_FOR_CITY = {
    "berlin" => "&#x1F1E9;&#x1F1EA;",
    "paris" => "&#x1F1EB;&#x1F1F7;",
    "budapest" => "&#x1F1ED;&#x1F1FA;"
  }

  EMOJI_FOR_PROFILE = {
    "worker" => "&#x1F471;&#x1F4BC;",
    "student" => "&#x1F471;&#x1F392;",
    "family" => "&#x1F46A;"
  }

  FACTOR_ICON_NAMES_HASH = {
    "burocracy" => "burocracy",
    "friendly to foreigners" => "trust",
    "fun" => "fun",
    "nightlife" => "nightlife",
    "english speaking" => "english",
    "walkability" => "walkability",
    "free wi-fi accessibility" => "wifi-strength",
    "public transport" => "public-transport",
    "high speed internet availability" => "high-speed-internet",
    "access to rent" => "access-to-rent",
    "quality of education" => "education-qual"
  }

  def home
    @current_city = City.new
    @destination_city = City.new
    @emoji_for_profiles = EMOJI_FOR_PROFILE
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

    @current_city_emoji = get_emoji_for_city(@current_city)
    @destination_city_emoji = get_emoji_for_city(@destination_city)

    @current_city_image = get_images(@current_city)
    @destination_city_image = get_images(@destination_city)
  end

  private

  def get_icon_name_for_qual(name)
    icon_name = FACTOR_ICON_NAMES_HASH.select { |k, v| return v if k == name }
    icon_name.empty? ? "" : icon_name
  end

  def get_emoji_for_city(city)
    emoji_code = EMOJI_FOR_CITY.select { |k, v| return v if k == city.name }
    emoji_code.empty? ? "" : emoji_code
  end

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
        current_factor_icon_name = get_icon_name_for_qual(cf.factor.name)
        current_city_hash[cf.factor.name] = {score: cf.score, icon_name: current_factor_icon_name}
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
    city_pic = json["photos"][0]["image"]["mobile"]
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
      next unless get_items_array_for_user_profiles.has_key?(item.item.name)
      items_array << [get_items_array_for_user_profiles[item.item.name], item.item.name, item.price.round(1)]
    end
    return items_array
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
