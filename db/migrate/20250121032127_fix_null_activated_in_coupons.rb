class FixNullActivatedInCoupons < ActiveRecord::Migration[7.1]
  def up
    # Update all coupons with null activated field to false
    Coupon.where(activated: nil).update_all(activated: false)
  end

  def down
    # You might not need to reverse this action, but in case, you can revert to null.
    # You could revert only if it's absolutely necessary.
    Coupon.update_all(activated: nil)
  end
end
