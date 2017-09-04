class CitiesItem < ApplicationRecord
  belongs_to :city
  belongs_to :item

  validates :city_id, uniqueness: {scope: :item_id}
end
