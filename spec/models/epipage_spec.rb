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

require 'rails_helper'

RSpec.describe Epipage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
