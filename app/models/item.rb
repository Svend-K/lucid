class Item < ApplicationRecord

  has_many :cities_items
  has_many :cities, through: :cities_items

  validates :name, uniqueness: true
end
