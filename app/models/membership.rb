# == Schema Information
#
# Table name: memberships
#
#  id           :integer          not null, primary key
#  name         :string
#  monthly_fee  :integer
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  engagement   :integer          default(2)
#  payment_id   :string
#

"""
Every epicenter has at least one membership
Users can obtain a membership of any epicenter through membershipcards
"""

class Membership < ActiveRecord::Base

  has_many :membershipcards
  has_many :users, :through => :membershipcards
  belongs_to :epicenter

  def payment_plan
    begin
      return Stripe::Plan.retrieve(self.payment_id)
    rescue => error
      return nil
    end
  end

end
