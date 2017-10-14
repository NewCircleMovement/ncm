class AddFieldsToEpicenters < ActiveRecord::Migration
  def change
    add_column :epicenters, :meeting_day, :string
    add_column :epicenters, :meeting_time, :time
    add_column :epicenters, :meeting_week, :string
    add_column :epicenters, :meeting_address, :string
    add_column :epicenters, :meeting_active, :boolean, :default => false
  end
end
