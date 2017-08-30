class Index < ApplicationRecord
  has_many :cities, through: :cities_index
end
