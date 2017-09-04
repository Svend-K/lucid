class ProfilesFactor < ApplicationRecord
  belongs_to :profile
  belongs_to :factor

  validates :profile_id, uniqueness: {scope: :factor_id}
end
