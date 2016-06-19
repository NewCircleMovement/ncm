# == Schema Information
#
# Table name: fruittypes
#
#  id            :integer          not null, primary key
#  name          :string
#  monthly_decay :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  epicenter_id  :integer
#

require 'rails_helper'

RSpec.describe Fruittype, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
