class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  
  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update, :activate, :deactivate]

  def index
    render json: CouponSerializer.new(@merchant.coupons)
  end

  def show
    render json: CouponSerializer.new(@coupon)
  end

  def create
    if exceeds_active_coupon_limit?
      return
    else
      @coupon = @merchant.coupons.new(coupon_params)
      @coupon.save!  
      render json: CouponSerializer.new(@coupon), status: :created
    end
  end


  def update
    if exceeds_active_coupon_limit?
      return
    else
      if @coupon.update(coupon_params)
        render json: CouponSerializer.new(@coupon)
      end
    end
  end

  def activate
    if exceeds_active_coupon_limit?
      return
    else
      @coupon.update(status: 'active')
        render json: CouponSerializer.new(@coupon), status: :ok
    end
  end
  
  def deactivate
    @coupon.update(status: 'inactive')
      render json: CouponSerializer.new(@coupon), status: :ok
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
    @coupon = @merchant.coupons.find(params[:id])  
  end

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_value, :discount_type, :status)
  end

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def record_invalid
    render json: { error: 'That is not a valid parameter' }, status: :unprocessable_entity
  end
end