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

require 'rails_helper'

RSpec.describe EventLog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
