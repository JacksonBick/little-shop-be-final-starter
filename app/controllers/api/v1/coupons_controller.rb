module Api
  module V1
    class CouponsController < ApplicationController
      before_action :set_coupon, only: [:show, :update, :destroy, :toggle_activation]

      def index
        @coupons = Coupon.all
        render json: @coupons
      end

      def show
        render json: {
      data: {
        id: @coupon.id,
        type: 'coupon',
        attributes: {
          name: @coupon.name,
          code: @coupon.code,
          value_type: @coupon.value_type,
          value: @coupon.value,
          activated: @coupon.activated,
          merchant_id: @coupon.merchant_id,
          usage_count: @coupon.usage_count # Shows how many invoices are using this coupon
        }
      }
    }
      end

      def create
        @coupon = Coupon.new(coupon_params)
        @coupon.activated = false 
    
        if @coupon.save
          render json: @coupon, status: :created
        else
          render json: @coupon.errors, status: :unprocessable_entity
        end
      end

      def update
        if @coupon.update(coupon_params)
          render json: @coupon
        else
          render json: @coupon.errors, status: :unprocessable_entity
        end
      end

      def destroy
        render json: { message: 'Cannot delete a coupon. Only deactivate it.' }, status: :forbidden
      end

      def toggle_activation
        @coupon.toggle_activation
        render json: @coupon
      end

      private

      def set_coupon
        @coupon = Coupon.find_by(id: params[:id])
        render json: { error: "Coupon not found" }, status: :not_found unless @coupon
      end

      def coupon_params
        params.require(:coupon).permit(:name, :code, :value_type, :value, :merchant_id)
      end

      def coupon_attributes(coupon)
        {
          name: coupon.name,
          code: coupon.code,
          value_type: coupon.value_type,
          value: coupon.value,
          activated: coupon.activated,
          merchant_id: coupon.merchant_id,
          usage_count: coupon.usage_count 
        }
      end
    end
  end
end