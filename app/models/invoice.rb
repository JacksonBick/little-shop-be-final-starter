class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

  def apply_coupon(coupon)
    if coupon.activated? && !self.coupon
      update(coupon: coupon)
    else
      errors.add(:coupon, "cannot be applied")
    end
  end
end