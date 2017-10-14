# == Schema Information
#
# Table name: resources
#
#  id          :integer          not null, primary key
#  kind        :string
#  bookable    :boolean
#  title       :string
#  body        :text
#  owner_id    :integer
#  owner_type  :string
#  calender_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :resource do
    type ""
    bookable false
    title "MyString"
    body "MyText"
    owner_id ""
    owner_type "MyString"
    calender_id 1
  end
end
