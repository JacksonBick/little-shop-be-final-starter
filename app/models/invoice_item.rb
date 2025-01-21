class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  belongs_to :coupon, optional: true
end