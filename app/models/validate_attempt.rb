# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ValidateAttempt < ActiveRecord::Base
  extend Forwardable

  belongs_to :replication_flow

  scope :ongoing, -> { where(end_time: nil) }
  scope :successful, -> { where(success: true) }

  def_delegators :replication_flow,
    :unpacked_location

  def success!(validity, validation_errors)
    update!(
      end_time: Time.now.utc,
      success: true,
      bag_valid: validity,
      error: validation_errors.join("\n")
    )
  end

  def failure!(error)
    update!(end_time: Time.now.utc, success: false, error: error)
  end

  def error
    if success?
      nil
    else
      read_attribute(:error)
    end
  end

  def validation_errors
    if success?
      read_attribute(:error).split("\n")
    else
      []
    end
  end

end
