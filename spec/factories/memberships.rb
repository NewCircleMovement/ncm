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

FactoryGirl.define do
  factory :membership do
    name "MyString"
    monthly_fruits 1
    epicenter_id 1
  end
end
