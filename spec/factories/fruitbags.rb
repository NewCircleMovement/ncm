# == Schema Information
#
# Table name: fruitbags
#
#  id             :integer          not null, primary key
#  amount         :integer
#  fruittype_id   :string
#  fruitbasket_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :fruitbag do
    amount 1
    fruittype_id "MyString"
    fruitbasket_id "MyString"
  end
end
