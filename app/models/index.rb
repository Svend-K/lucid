class Index < ApplicationRecord

  has_many :cities_index
  has_many :cities, through: :cities_index

  validates :name, uniqueness: true
end
