class AddMonthlyGainToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :monthly_gain, :integer
  end
end
