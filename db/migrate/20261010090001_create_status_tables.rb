class CreateStatusTables < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.string :name, null: false
      t.string :status, null: false, default: "operational"
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :components, :name, unique: true

    create_table :incidents do |t|
      t.string :title, null: false
      t.string :status, null: false, default: "investigating"
      t.string :severity, null: false, default: "minor"
      t.datetime :started_at, null: false
      t.datetime :resolved_at
      t.timestamps
    end
    add_index :incidents, :started_at

    create_table :incident_updates do |t|
      t.references :incident, null: false, foreign_key: { on_delete: :cascade }
      t.string :status, null: false
      t.text :body, null: false
      t.datetime :posted_at, null: false
    end

    create_table :maintenances do |t|
      t.string :title, null: false
      t.text :body, null: false, default: ""
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.timestamps
    end
    add_index :maintenances, :ends_at
  end
end
