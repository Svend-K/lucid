class Factor < ApplicationRecord
  has_many :cities, through: :cities_factor
  has_many :users, through: :users_factor
end
