class CreateNobles < ActiveRecord::Migration
  def change
    create_table :nobles do |t|

      t.timestamps
    end
  end
end
