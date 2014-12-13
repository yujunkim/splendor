class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :auth_token
      t.string :name
      t.string :color
      t.boolean :robot, default: false

      t.timestamps
    end
  end
end
