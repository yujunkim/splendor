class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :current_turn_user_id
      t.integer :winner_id

      t.timestamps
    end
    add_index :games, :current_turn_user_id
    add_index :games, :winner_id
  end
end
