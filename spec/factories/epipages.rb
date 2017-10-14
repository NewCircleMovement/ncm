# == Schema Information
#
# Table name: epipages
#
#  id           :integer          not null, primary key
#  slug         :string
#  menu_title   :string
#  title        :string
#  body         :text
#  kind         :string           default("Info")
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :epipage do
    menu_title "MyString"
  end
end
