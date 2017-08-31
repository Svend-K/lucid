class Factor < ApplicationRecord
  has_many :cities, through: :cities_factor

  has_many :profiles_factors
  has_many :profiles, through: :profiles_factors

  validates :name, uniqueness: true
end
