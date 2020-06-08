class CreateCheckouts < ActiveRecord::Migration[6.0]
  def change
    create_table :checkouts do |t|
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :pay_processor, null: false
      t.string :token
      t.string :redirect_url
      t.string :status
      t.string :message
      t.string :customer
      t.text :raw_status
      t.string :uid
      t.belongs_to :member, foreign_key: true, null: true
      t.belongs_to :payment, foreign_key: true, null: true

      t.timestamps
    end
  end
end
