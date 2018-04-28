# == Schema Information
#
# Table name: admissions
#
#  id           :integer          not null, primary key
#  name         :string
#  description  :text
#  price        :integer
#  start_t      :datetime
#  end_t        :datetime
#  epicenter_id :integer
#  n_max        :integer
#  n_actual     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Admission < ActiveRecord::Base
  validates :name, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true, numericality: {only_integer: true, greater_than: 10}
  validate :dates_cannot_be_in_past


  def dates_cannot_be_in_past
    if start_t.present? && start_t < Time.now
      errors.add(:start_t, "can't be in the past")
    end
    if end_t.present? && end_t < Time.now
      errors.add(:end_t, "can't be in the past")
    end
    if start_t.present? && end_t.present? && end_t < start_t
      errors.add(:end_t, "can't be before start time")
    end
  end  


  has_many :admissioncards
  has_many :users, :through => :admissioncards
  
  belongs_to :epicenter

end
