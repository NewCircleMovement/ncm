class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.time :day_start
      t.time :day_end
      t.float :module_length
      t.boolean :flexible
      t.string :resource_id

      t.timestamps null: false
    end
  end
end
