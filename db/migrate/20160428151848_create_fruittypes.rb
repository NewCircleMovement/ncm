class CreateFruittypes < ActiveRecord::Migration
  def change
    create_table :fruittypes do |t|
      t.string :name
      t.float :monthly_decay

      t.timestamps null: false
    end
  end
end
