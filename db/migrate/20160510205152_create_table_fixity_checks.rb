# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class CreateTableFixityChecks < ActiveRecord::Migration
  def change
    create_table :fixity_checks do |t|
      t.string :fixity_check_id, null: false
      t.integer :bag_id, null: false
      t.integer :node_id, null: false
      t.boolean :success, null: false
      t.datetime :fixity_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :fixity_checks, :fixity_check_id, unique: true
  end
end
