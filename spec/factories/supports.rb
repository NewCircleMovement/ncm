# == Schema Information
#
# Table name: supports
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :support do
    user_id 1
    epicenter_id 1
  end
end
