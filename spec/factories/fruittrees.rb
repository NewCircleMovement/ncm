# == Schema Information
#
# Table name: fruittrees
#
#  id               :integer          not null, primary key
#  owner_id         :integer
#  owner_type       :string
#  fruits_per_month :integer
#  fruittype_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  yield            :integer          default(0)
#

FactoryGirl.define do
  factory :fruittree do
    owner_id 1
    owner_type "MyString"
    fruits_per_month 1
    fruittype_id 1
  end
end
