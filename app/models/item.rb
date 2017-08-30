class Item < ApplicationRecord
  has_many :cities, through: :cities_items
end
