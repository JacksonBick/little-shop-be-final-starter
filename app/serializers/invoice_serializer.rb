class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :customer_id, :status
  belongs_to :coupon
end