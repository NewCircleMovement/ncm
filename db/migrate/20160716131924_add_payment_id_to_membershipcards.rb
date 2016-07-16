class AddPaymentIdToMembershipcards < ActiveRecord::Migration
  def change
    add_column :membershipcards, :payment_id, :string, :default => nil
  end
end
