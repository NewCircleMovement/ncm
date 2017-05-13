class AddFieldsToAccessPoints < ActiveRecord::Migration
  def change
    add_column :access_points, :menu_item, :boolean
    add_column :access_points, :menu_title, :string
    add_column :access_points, :profile, :text
  end
end
