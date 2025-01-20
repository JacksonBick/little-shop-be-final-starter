module Api
  module V1
    class CouponsController < ApplicationController
      before_action :set_coupon, only: [:show, :update, :destroy, :toggle_activation]

      def index
        @coupons = Coupon.all
        render json: @coupons
      end

      def show
        render json: @coupon
      end

      def create
        @coupon = Coupon.new(coupon_params)
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
        @coupon = Coupon.find(params[:id])
      end

      def coupon_params
        params.require(:coupon).permit(:name, :code, :value_type, :value, :merchant_id)
      end
    end
  end
end