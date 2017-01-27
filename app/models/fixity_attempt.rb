# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class FixityAttempt < ActiveRecord::Base
  extend Forwardable

  belongs_to :replication_flow

  scope :ongoing, -> { where(end_time: nil) }
  scope :successful, -> { where(success: true) }

  def_delegators :replication_flow,
    :unpacked_location

  def success!(value)
    update!(end_time: Time.now.utc, success: true, value: value)
  end

  def failure!(error)
    update!(end_time: Time.now.utc, success: false, error: error)
  end

end
