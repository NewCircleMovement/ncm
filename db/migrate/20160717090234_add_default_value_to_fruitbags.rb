class AddDefaultValueToFruitbags < ActiveRecord::Migration
  def up
    change_column :fruitbags, :amount, :integer, :default => 0
  end

  def down
    change_column :fruitbags, :amount, :integer
  end
end
