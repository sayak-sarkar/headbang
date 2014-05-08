class Artist < ActiveRecord::Base
  include Factory
  validates :name, presence: true
  has_many :releases
end
