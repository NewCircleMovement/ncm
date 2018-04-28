class CreateAdmissions < ActiveRecord::Migration
  def change
    create_table :admissions do |t|
      t.string :name
      t.text :description
      t.integer :price
      t.datetime :start_t
      t.datetime :end_t
      t.integer :epicenter_id
      t.integer :n_max
      t.integer :n_actual, :default => 0

      t.timestamps null: false
    end
  end
end
