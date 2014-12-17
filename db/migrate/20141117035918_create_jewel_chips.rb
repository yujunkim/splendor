class CreateJewelChips < ActiveRecord::Migration
  def change
    create_table :jewel_chips do |t|
      t.integer :user_id
      t.integer :game_id
      t.string :jewel_type

      t.timestamps
    end
  end
end
