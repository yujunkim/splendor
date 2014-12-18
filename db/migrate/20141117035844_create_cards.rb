class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :point, default: 0
      t.integer :diamond, default: 0
      t.integer :sapphire, default: 0
      t.integer :emerald, default: 0
      t.integer :ruby, default: 0
      t.integer :onyx, default: 0
      t.integer :card_grade, default: 1
      t.string :jewel_type
      t.boolean :reserved, default: false
      t.boolean :revealed, default: false

      t.timestamps
    end

    add_index :cards, :user_id
    add_index :cards, :game_id
    add_index :cards, :jewel_type
    add_index :cards, :reserved
    add_index :cards, :revealed
  end
end
