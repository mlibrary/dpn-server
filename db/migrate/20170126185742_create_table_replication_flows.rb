class CreateTableReplicationFlows < ActiveRecord::Migration
  def change
    create_table :replication_flows do |t|
      t.string :replication_id, null: false
      t.string :link,           null: false
      t.string :from_node,      null: false
      t.string :bag,            null: false
    end
    add_index :replication_flows, :replication_id, unique: true

  end
end
