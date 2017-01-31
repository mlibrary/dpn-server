class DropBagManRequests < ActiveRecord::Migration
  def change
    drop_table :bag_man_requests
  end
end
