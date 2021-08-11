class CreateAuditingTables < ActiveRecord::Migration[7.0]
  def change
    create_table :console1984_audits do |t|
      t.integer :status, default: 0, null: false
      t.text :notes
      t.references :session, null: false
      t.references :auditor, null: false

      t.timestamps
    end
  end
end
