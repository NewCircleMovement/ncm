# == Schema Information
#
# Table name: admissioncards
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  admission_id :integer
#  charge_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Admissioncard < ActiveRecord::Base
  belongs_to :user
  belongs_to :admission

end
