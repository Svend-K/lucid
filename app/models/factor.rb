class Factor < ApplicationRecord
  has_many :cities, through: :cities_factor
  has_many :profiles, through: :profiles_factor

  validates :name, uniqueness: true
end
