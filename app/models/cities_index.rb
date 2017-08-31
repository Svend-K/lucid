class CitiesIndex < ApplicationRecord
  belongs_to :city
  belongs_to :index

  validates :city_id, uniqueness: {scope: :index_id}
end
