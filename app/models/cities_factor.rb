class CitiesFactor < ApplicationRecord
  belongs_to :city
  belongs_to :factor

  validates :city_id, uniqueness: {scope: :factor_id}
end
