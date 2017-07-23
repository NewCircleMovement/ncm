class CreateEpipages < ActiveRecord::Migration
  def change
    create_table :epipages do |t|
      t.string :slug
      t.string :menu_title
      t.string :title
      t.text :body
      t.string :kind, :default => STR_INFO
      t.integer :epicenter_id

      t.timestamps null: false
    end
  end
end
