class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 1
      t.boolean :activated, default: false
      t.datetime :activated_at

      t.timestamps
    end
  end
end
