class AddPaymentIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :payment_id, :string, :default => nil
  end
end
