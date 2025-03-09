class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  scope :active, -> { where(status: true) }
end
