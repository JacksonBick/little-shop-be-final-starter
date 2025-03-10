class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true
  validates :discount_value, presence: true
  validates :discount_type, presence: true
  validates :status, presence: true

  enum status: { inactive: false, active: true }
  scope :active, -> { where(status: true) }

  def usage_count
    invoices.count
  end
end
