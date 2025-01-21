module Api
  module V1
    class CouponsController < ApplicationController
      before_action :set_coupon, only: [:show, :update, :destroy, :toggle_activation]
      before_action :set_merchant, only: [:index, :create]  # Add this line to set the merchant

      # GET /api/v1/merchants/:merchant_id/coupons
      def index
        # Fetch all coupons belonging to the specific merchant
        @coupons = @merchant.coupons
        render json: { data: @coupons.map { |coupon| coupon_json(coupon) } }
      end

      def show
        render json: {
          data: {
            id: @coupon.id,
            type: 'coupon',
            attributes: coupon_attributes(@coupon)
          }
        }
      end

      def create
        @coupon = Coupon.new(coupon_params)
        @coupon.activated = false  # Ensure this is set correctly
        
        if @coupon.save
          render json: {
            data: {
              id: @coupon.id,
              type: 'coupon',
              attributes: coupon_attributes(@coupon)
            }
          }, status: :created
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

      def deactivate
        if @coupon.usage_count > 0
          render json: { error: "Coupon cannot be deactivated because there are pending invoices." }, status: :unprocessable_entity
        else
          @coupon.update(activated: false)
          render json: {
            data: {
              id: @coupon.id,
              type: 'coupon',
              attributes: coupon_attributes(@coupon)
            }
          }, status: :ok
        end
      end

      private

      def set_coupon
        @coupon = Coupon.find_by(id: params[:id])
        render json: { error: "Coupon not found" }, status: :not_found unless @coupon
      end

      # Set the merchant based on the merchant_id from the URL
      def set_merchant
        @merchant = Merchant.find_by(id: params[:merchant_id])
        render json: { error: "Merchant not found" }, status: :not_found unless @merchant
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

      # Helper method to format the coupon's data for the index action
      def coupon_json(coupon)
        {
          id: coupon.id,
          type: 'coupon',
          attributes: coupon_attributes(coupon)
        }
      end

      
    end
  end
end