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
