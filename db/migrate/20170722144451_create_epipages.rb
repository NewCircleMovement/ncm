class CreateEpipages < ActiveRecord::Migration
  def change
    create_table :epipages do |t|
      t.string :menu_title
      t.integer :epicenter_id

      t.timestamps null: false
    end
  end
end
