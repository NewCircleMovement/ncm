class CreateLoggings < ActiveRecord::Migration
  def change
    create_table :loggings do |t|
      t.integer :id_1
      t.integer :id_2
      t.string :type_1
      t.string :type_2
      t.string :event
      t.string :text

      t.timestamps null: false
    end
  end
end
