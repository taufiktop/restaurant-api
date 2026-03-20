class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants, id: :uuid do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone
      t.string :opening_hours
      t.string :closing_hours

      t.timestamps
    end
  end
end
