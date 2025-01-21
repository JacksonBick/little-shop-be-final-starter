module Api
  module V1
    class CouponsController < ApplicationController
      before_action :set_coupon, only: [:show, :update, :destroy, :toggle_activation, :activate, :deactivate]
      before_action :set_merchant, only: [:index, :create]  # Add this line to set the merchant

      # GET /api/v1/merchants/:merchant_id/coupons
      def index
        if params[:status].present?
          if params[:status] == 'active'
            @coupons = @merchant.coupons.active
          elsif params[:status] == 'inactive'
            @coupons = @merchant.coupons.inactive
          else
            render json: { error: "Invalid status parameter. Use 'active' or 'inactive'." }, status: :unprocessable_entity
            return
          end
        else
          @coupons = @merchant.coupons
        end
      
        # Return the filtered list of coupons
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
        @coupon.activated = false  
        
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
          render json: { error: "Coupon cannot be deactivated because it has been used" }, status: :unprocessable_entity
        else
          @coupon.update(activated: false)
          render json: { data: coupon_json(@coupon) }, status: :ok
        end
      end

      
      def activate
        @coupon.update(activated: true)
        render json: { data: coupon_json(@coupon) }, status: :ok
      end

      
      private

      def set_coupon
        @coupon = Coupon.find_by(id: params[:coupon_id])
        render json: { error: "Coupon not found" }, status: :not_found unless @coupon
      end


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

      
    