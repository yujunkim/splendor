class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :current_turn_user_id
      t.integer :winner_id
      t.string :order_user_ids

      t.timestamps
    end
  end
end
