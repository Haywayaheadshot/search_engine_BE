class CreateSearchLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :search_logs do |t|
      t.references :search_query, null: false, foreign_key: true
      t.json :words, null: false
      t.string :ip, null: false

      t.timestamps
    end
  end
end
