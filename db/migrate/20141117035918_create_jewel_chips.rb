class CreateJewelChips < ActiveRecord::Migration
  def change
    create_table :jewel_chips do |t|
      t.integer :user_id
      t.integer :game_id
      t.string :jewel_type

      t.timestamps
    end
    add_index :jewel_chips, :user_id
    add_index :jewel_chips, :game_id
    add_index :jewel_chips, :jewel_type
  end
end
