class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.string :quoteText
      t.string :author
      t.integer :likes

      t.timestamps
    end
  end
end
