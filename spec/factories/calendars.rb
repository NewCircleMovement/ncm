# == Schema Information
#
# Table name: calendars
#
#  id            :integer          not null, primary key
#  day_start     :time
#  day_end       :time
#  module_length :float
#  flexible      :boolean
#  resource_id   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :calendar do
    day_start "2017-07-23 13:50:47"
    day_end "2017-07-23 13:50:47"
    module_length 1.5
    flexible false
    resource_id "MyString"
  end
end
