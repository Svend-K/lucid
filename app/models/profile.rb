class Profile < ApplicationRecord
  has_many :factors, through: :profiles_factor

  validates :name, uniqueness: true
end
