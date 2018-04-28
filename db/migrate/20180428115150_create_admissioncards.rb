class CreateAdmissioncards < ActiveRecord::Migration
  def change
    create_table :admissioncards do |t|
      t.integer :user_id
      t.integer :admission_id
      t.integer :charge_id

      t.timestamps null: false
    end
  end
end
