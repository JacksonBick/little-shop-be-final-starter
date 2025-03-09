class Api::V1::Merchants::CouponsController < ApplicationController
  
  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update]

  def index
    render json: CouponSerializer.new(@merchant.coupons)
  end

  def show
    render json: CouponSerializer.new(@coupon)
  end

  def create
    if @merchant.coupons.active.count >= 5 && coupon_params[:status] == true
      render json: { error: "A merchant can only have a maximum of 5 active coupons at a time." }, status: :unprocessable_entity
    else
      @coupon = @merchant.coupons.new(coupon_params)

      if @coupon.save
        render json: CouponSerializer.new(@coupon), status: :created
      else
        render json: @coupon.errors, status: :unprocessable_entity
      end
    end
  end

  def update
    if coupon_params[:status] == true && @merchant.coupons.active.count >= 5
      render json: { error: "A merchant can only have a maximum of 5 active coupons at a time." }, status: :unprocessable_entity
    else
      if @coupon.update(coupon_params)
        render json: CouponSerializer.new(@coupon)
      else
        render json: @coupon.errors, status: :unprocessable_entity
      end
    end
  end

  def activate
    if @coupon.update(status: true)
      render json: CouponSerializer.new(@coupon), status: :ok
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end

  def deactivate
    if @coupon.update(status: false)
      render json: CouponSerializer.new(@coupon), status: :ok
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end


  private

  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def set_coupon
    @coupon = @merchant.coupons.find(params[:id])
  end

  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_value, :discount_type, :status)
  end
end