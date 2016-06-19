# == Schema Information
#
# Table name: supports
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  epicenter_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe Support, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
