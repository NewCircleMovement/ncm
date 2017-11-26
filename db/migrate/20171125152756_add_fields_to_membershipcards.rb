class AddFieldsToMembershipcards < ActiveRecord::Migration
  def change
    add_column :membershipcards, :valid_payment, :boolean, :default => true
    add_column :membershipcards, :valid_supply, :boolean, :default => true
  end
end
