# == Schema Information
#
# Table name: tshirts
#
#  id              :integer          not null, primary key
#  epicenter_id    :integer
#  user_id         :integer
#  access_point_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  membership_id   :integer
#

FactoryGirl.define do
  factory :tshirt do
    epicenter_id 1
    user_id 1
    tshirtkey_id 1
  end
end
