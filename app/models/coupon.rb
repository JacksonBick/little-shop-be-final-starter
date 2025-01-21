class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: :merchant_id, message: "Coupon code must be unique per merchant." }
  validates :value_type, inclusion: { in: ['percent-off', 'dollar-off'] }
  validates :value, presence: true
  validate :merchant_can_have_max_5_active_coupons, on: :create

  # Scopes
  scope :active, -> { where(activated: true) }
  scope :inactive, -> { where(activated: false) }

  after_initialize :set_default_activated, if: :new_record?
  # Methods
  def toggle_activation
    update(activated: !activated)
  end

  # Custom validation to ensure a merchant has a max of 5 active coupons
  def merchant_can_have_max_5_active_coupons
    if merchant.coupons.active.count >= 5
      errors.add(:base, "A merchant can only have 5 active coupons at a time.")
    end
  end

  def set_default_activated
    self.activated ||= false
  end

  def usage_count
    invoices.count || 0
  end
end
