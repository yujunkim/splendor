class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :auth_token
      t.string :name
      t.string :color
      t.string :home
      t.boolean :robot, default: false

      t.timestamps
    end
    add_index :users, :auth_token
    add_index :users, :robot
  end
end
