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
#

"""
Every epicenter has at least one membership
Users can obtain a membership of any epicenter through membershipcards
"""

class Membership < ActiveRecord::Base

  has_many :membershipcards
  has_many :users, :through => :membershipcards

end
