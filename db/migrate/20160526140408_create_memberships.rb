class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :name
      t.integer :monthly_fruits
      t.integer :epicenter_id

      t.timestamps null: false
    end
  end
end
