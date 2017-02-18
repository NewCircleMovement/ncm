class AddYieldToFruittree < ActiveRecord::Migration
  def change
    add_column :fruittrees, :yield, :integer, :default => 0
  end
end
