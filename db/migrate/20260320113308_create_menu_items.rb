class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items, id: :uuid do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :is_available, default: true
      t.references :restaurant, type: :uuid, null: false, foreign_key: true
      t.references :category, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
