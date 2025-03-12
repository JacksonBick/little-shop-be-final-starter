class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_unique_violation

  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update]

  def index #filter by params
    @coupons = Coupon.filter_by_status(params[:status])
      .where(merchant_id: params[:merchant_id])

    render json: @coupons
  end

  def show
    render json: CouponSerializer.new(@coupon)
  end

  def create
    #to make sure inactive coupons can still be made
    if params[:coupon][:status] == "active" && exceeds_active_coupon_limit? 
      return
    else
      @coupon = @merchant.coupons.new(coupon_params)
      @coupon.save!
      render json: CouponSerializer.new(@coupon), status: :created
    end
  end


  def update
    if params[:activate].present?
      if exceeds_active_coupon_limit? 
        return
      else
        @coupon.update(status: 'active')
          render json: CouponSerializer.new(@coupon), status: :ok
      end
    elsif params[:deactivate].present?
      #to make sure coupon is not deactivated if it belongs to invoice
      if @coupon.invoices.empty?
      @coupon.update(status: 'inactive')
      render json: CouponSerializer.new(@coupon), status: :ok
      else
        render json: { error: "The coupon is currently being used on a invoice" }, status: :unprocessable_entity
      end
    else
      if params[:coupon][:status] == "active" && exceeds_active_coupon_limit?
        return
      else
        if @coupon.update(coupon_params)
          render json: CouponSerializer.new(@coupon)
        else
          render json: { error: "not a valid discount type" }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def exceeds_active_coupon_limit?
    if @merchant.coupons.where(status: 'active').count >= 5 
      render json: { error: "A merchant can only have a maximum of 5 active coupons at a time." }, status: :unprocessable_entity
      return true
    end
    false
  end

  def set_merchant
    @merchant = Merchant.find(params[:merchant_id]) 
  end

  def set_coupon
    @coupon = Coupon.find_by(id: params[:id], merchant_id: params[:merchant_id])
    render json: { error: "Coupon not found" }, status: :not_found if @coupon.nil?
  end

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_value, :discount_type, :status)
  end

  def record_invalid
    render json: { error: 'That is not a valid parameter' }, status: :unprocessable_entity
  end

  def handle_unique_violation
    render json: { error: "Coupon code must be unique" }, status: :unprocessable_entity
  end
end