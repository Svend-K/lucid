class City < ApplicationRecord
  has_many :items, through: :cities_items
  has_many :indices, through: :cities_index
  has_many :factors, through: :cities_factor
end
