class Profile < ApplicationRecord
  has_many :profiles_factors
  has_many :factors, through: :profiles_factors

  validates :name, uniqueness: true
end
