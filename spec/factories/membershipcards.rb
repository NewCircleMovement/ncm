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
#  epicenter_id  :integer
#

FactoryGirl.define do
  factory :membershipcard do
    user_id 1
    membership_id 1
  end
end
