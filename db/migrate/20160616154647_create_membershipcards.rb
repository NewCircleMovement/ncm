class CreateMembershipcards < ActiveRecord::Migration
  def change
    create_table :membershipcards do |t|
      t.integer :user_id
      t.integer :membership_id

      t.timestamps null: false
    end
  end
end
