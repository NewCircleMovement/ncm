class CreateMembershipChanges < ActiveRecord::Migration
  def change
    create_table :membership_changes do |t|
      t.integer :user_id
      t.integer :epicenter_id
      t.integer :old_membership_id
      t.integer :new_membership_id

      t.timestamps null: false
    end
  end
end
