# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class Protocol < ActiveRecord::Base
  include Lowercased
  make_lowercased :name

  def self.find_fields
    Set.new [:name]
  end
  
  has_many :supported_protocols, inverse_of: :protocol
  has_many :nodes, through: :supported_protocols
  
  has_many :replication_transfers
  has_many :restore_transfers

  validates :name, presence: true
end
