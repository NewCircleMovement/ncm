class AddTypeToInformation < ActiveRecord::Migration
  def change
    add_column :information, :kind, :string
  end
end
