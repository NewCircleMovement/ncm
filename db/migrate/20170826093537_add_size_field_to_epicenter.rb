class AddSizeFieldToEpicenter < ActiveRecord::Migration
  def change
    add_column :epicenters, :size, :string
  end
end
