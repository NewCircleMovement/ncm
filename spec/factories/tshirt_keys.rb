# == Schema Information
#
# Table name: tshirt_keys
#
#  id          :integer          not null, primary key
#  location_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :tshirt_key do
    location_id 1
  end
end
