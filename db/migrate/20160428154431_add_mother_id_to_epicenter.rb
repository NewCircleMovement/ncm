class AddMotherIdToEpicenter < ActiveRecord::Migration
  def change
    add_column :epicenters, :mother_id, :integer
  end
end
