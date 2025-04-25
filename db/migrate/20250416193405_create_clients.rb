class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.integer :limit, null: false
      t.integer :balance, null: false, default: 0

      t.timestamps
    end
  end
end
