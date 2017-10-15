# == Schema Information
#
# Table name: event_logs
#
#  id           :integer          not null, primary key
#  owner_type   :string
#  owner_id     :integer
#  acts_on_type :string
#  acts_on_id   :integer
#  event_type   :string
#  description  :string
#  details      :json
#  log_level    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :event_log do
    actor_type "MyString"
    actor_id ""
    acts_on_type "MyString"
    acts_on_id ""
    event_type ""
    description "MyString"
    details ""
  end
end
