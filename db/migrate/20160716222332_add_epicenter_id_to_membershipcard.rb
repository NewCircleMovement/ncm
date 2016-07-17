class AddEpicenterIdToMembershipcard < ActiveRecord::Migration
  def change
    add_column :membershipcards, :epicenter_id, :integer
  end
end
