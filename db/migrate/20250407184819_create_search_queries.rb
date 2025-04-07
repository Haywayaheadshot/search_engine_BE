class CreateSearchQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :search_queries do |t|
      t.string :query, null: false
      t.text :content, null: false
      t.integer :count, default: 0, null: false

      t.timestamps
    end

    add_index :search_queries, :query, unique: true
  end
end
