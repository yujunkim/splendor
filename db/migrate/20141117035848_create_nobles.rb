class CreateNobles < ActiveRecord::Migration
  def change
    create_table :nobles do |t|
      t.integer :user_id
      t.integer :game_id
      t.integer :point, default: 0
      t.integer :diamond, default: 0
      t.integer :sapphire, default: 0
      t.integer :emerald, default: 0
      t.integer :ruby, default: 0
      t.integer :onyx, default: 0

      t.timestamps
    end
    add_index :nobles, :user_id
    add_index :nobles, :game_id
  end
end
