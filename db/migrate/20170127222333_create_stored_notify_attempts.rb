class CreateStoredNotifyAttempts < ActiveRecord::Migration
  def change
    create_table :stored_notify_attempts do |t|
      t.belongs_to :replication_flow, null: false
      t.datetime :start_time,         null: false
      t.datetime :end_time,           null: true
      t.boolean :success,             null: true, default: nil
      t.text :error,                  null: true
    end
    add_foreign_key :stored_notify_attempts, :replication_flows
  end
end
