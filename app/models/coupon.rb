class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true
  validates :discount_type, presence: true, inclusion: { in: ['percentage', 'dollar off'] }
  validates :status, presence: true

  #to make true = active and false = inactive
  enum status: { inactive: false, active: true }
  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }

  def usage_count
    invoices.count
  end

  #filter by params
  def self.filter_by_status(status)
    case status
    when 'active'
      active
    when 'inactive'
      inactive
    else
      all 
    end
  end
end
