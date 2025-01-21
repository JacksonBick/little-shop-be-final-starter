class FixNullActivatedInCoupons < ActiveRecord::Migration[7.1]
  def up
    Coupon.where(activated: nil).update_all(activated: false)
  end

  def down
    Coupon.update_all(activated: nil)
  end
end
