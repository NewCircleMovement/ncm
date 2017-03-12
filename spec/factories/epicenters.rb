# == Schema Information
#
# Table name: epicenters
#
#  id                   :integer          not null, primary key
#  name                 :string
#  description          :text
#  video_url            :string
#  max_members          :integer          default(1000)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  growing              :boolean          default(FALSE)
#  manifested           :boolean          default(FALSE)
#  location_id          :integer
#  niveau               :integer
#  depth_members        :integer
#  depth_fruits         :integer
#  mother_id            :integer
#  monthly_fruits_basis :integer          default(100)
#  slug                 :string
#

FactoryGirl.define do
  factory :epicenter do
    name "MyString"
    description "MyText"
    video_url "MyString"
    max_members ""
  end
end
