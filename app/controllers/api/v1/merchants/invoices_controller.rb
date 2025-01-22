class Api::V1::Merchants::InvoicesController < ApplicationController
  before_action :set_merchant
  def index
    merchant = Merchant.find(params[:merchant_id])
    if params[:status].present?
      invoices = merchant.invoices_filtered_by_status(params[:status])
    else
      invoices = merchant.invoices
    end
    render json: invoices, status: :ok  
  end
  
  def add_coupon
    invoice = @merchant.invoices.find(params[:invoice_id])

    coupon = Coupon.find_by(code: params[:coupon_code])
    
    if coupon.nil?
      return render json: { error: "Coupon not found" }, status: :not_found
    end

    if !invoice.coupon_id.nil?
      return render json: { error: "Invoice already has a coupon" }, status: :unprocessable_entity
    end

    invoice.update(coupon_id: coupon.id)

    render json: InvoiceSerializer.new(invoice), status: :ok
  end

  def remove_coupon
    invoice = @merchant.invoices.find(params[:invoice_id])

    if invoice.coupon.nil?
      return render json: { error: "No coupon applied to this invoice" }, status: :unprocessable_entity
    end

    invoice.update(coupon: nil)

    render json: InvoiceSerializer.new(invoice), status: :ok
  end

  private

  def set_merchant
    @merchant = Merchant.find_by(id: params[:merchant_id])
        render json: { error: "Merchant not found" }, status: :not_found unless @merchant
  end

  def invoice_json(invoice)
    {
      id: invoice.id,
      type: 'invoice',
      attributes: {
        customer_id: invoice.customer_id,
        merchant_id: invoice.merchant_id,
        coupon_id: invoice.coupon_id,  # Include the coupon_id if used
        status: invoice.status
      }
    }
  end
end