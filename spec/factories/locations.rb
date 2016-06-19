# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  density    :integer
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :location do
    density 1
    name "MyString"
  end
end
