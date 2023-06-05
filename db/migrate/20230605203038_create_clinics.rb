class CreateClinics < ActiveRecord::Migration[7.0]
  def change
    create_table :clinics do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.float :long
      t.float :lat
      t.timestamps
    end
  end
end
