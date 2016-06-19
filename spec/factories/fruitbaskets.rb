# == Schema Information
#
# Table name: fruitbaskets
#
#  id         :integer          not null, primary key
#  owner_id   :integer
#  owner_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :fruitbasket do
    owner_id 1
    owner_type "MyString"
    fruits 1
    fruittype_id 1
  end
end
