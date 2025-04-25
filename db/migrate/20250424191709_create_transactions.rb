class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.integer :value, null: false
      t.string :transaction_type, null: false, limit: 1
      t.string :description, null: false, limit: 10
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
