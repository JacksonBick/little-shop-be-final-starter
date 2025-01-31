class InvoiceSerializer
  include JSONAPI::Serializer
  attributes :id, :merchant_id, :customer_id, :status, :coupon_id

  attribute :coupon do |invoice|
    if invoice.coupon.present?
      {
        id: invoice.coupon.id,
        name: invoice.coupon.name,
        code: invoice.coupon.code,
        value_type: invoice.coupon.value_type,
        value: invoice.coupon.value
      }
    else
      nil
    end
  end
  belongs_to :coupon, optional: true
end