class City < ApplicationRecord

  has_many :cities_items
  has_many :items, through: :cities_items

  has_many :cities_index
  has_many :indices, through: :cities_index

  has_many :cities_factor
  has_many :factors, through: :cities_factor

  validates :name, uniqueness: true

end
