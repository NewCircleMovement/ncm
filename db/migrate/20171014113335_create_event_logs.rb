class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :acts_on_type
      t.integer :acts_on_id
      t.string :event_type
      t.string :description
      t.json :details
      t.integer :log_level

      t.timestamps null: false
    end
  end
end
