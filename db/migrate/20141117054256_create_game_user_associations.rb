class CreateGameUserAssociations < ActiveRecord::Migration
  def change
    create_table :game_user_associations do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :order, default: 0

      t.timestamps
    end
    add_index :game_user_associations, :user_id
    add_index :game_user_associations, :game_id
    add_index :game_user_associations, :order
  end
end
