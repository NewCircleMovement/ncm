class AddMembershipIdFieldToTshirts < ActiveRecord::Migration
  def change
    add_column :tshirts, :membership_id, :integer
  end
end
