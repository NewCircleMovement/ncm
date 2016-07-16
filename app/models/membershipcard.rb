# == Schema Information
#
# Table name: membershipcards
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  membership_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payment_id    :string
#

class Membershipcard < ActiveRecord::Base

  belongs_to :user
  belongs_to :membership
  
end
