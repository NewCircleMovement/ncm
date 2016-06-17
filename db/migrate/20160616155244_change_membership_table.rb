class ChangeMembershipTable < ActiveRecord::Migration
  def change
    rename_column :memberships, :monthly_fruits, :monthly_fee

    # add new columns
    add_column :memberships, :engagement, :integer, :default => 2
    add_column :epicenters, :monthly_fruits_basis, :integer, :default => 100
    
    # we don't need these anymore
    remove_column :fruitbaskets, :fruits
    remove_column :fruitbaskets, :fruittype_id
  end
end
