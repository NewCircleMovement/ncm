class AddEpicenterIdToFruittype < ActiveRecord::Migration
  def change
  	add_column :fruittypes, :epicenter_id, :integer
  end
end
