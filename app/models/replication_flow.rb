# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ReplicationFlow < ActiveRecord::Base

  has_many :retrieval_attempts, dependent: :destroy
  has_many :unpack_attempts, dependent: :destroy
  has_many :validate_attempts, dependent: :destroy
  has_many :fixity_attempts, dependent: :destroy
  has_many :received_notify_attempts, dependent: :destroy
  has_many :store_attempts, dependent: :destroy
  has_many :stored_notify_attempts, dependent: :destroy

  validates :replication_id,  presence: true, uniqueness: true
  validates :link,            presence: true
  validates :from_node,       presence: true
  validates :bag,             presence: true

  validates :replication_id,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }

  validates :bag,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }

  validates :replication_id,  read_only: true, on: :update
  validates :link,            read_only: true, on: :update
  validates :from_node,       read_only: true, on: :update
  validates :bag,             read_only: true, on: :update

  def retrieved?
    !retrieval_attempts.successful.empty?
  end

  def retrieval_ongoing?
    !retrieval_attempts.ongoing.empty?
  end

  def unpacked?
    !unpack_attempts.successful.empty?
  end

  def unpack_ongoing?
    !unpack_attempts.ongoing.empty?
  end

  def validated?
    !validate_attempts.successful.empty?
  end

  def validate_ongoing?
    !validate_attempts.ongoing.empty?
  end

  def fixity_complete?
    !fixity_attempts.successful.empty?
  end

  def fixity_ongoing?
    !fixity_attempts.ongoing.empty?
  end

  def received_notified?
    !received_notify_attempts.successful.empty?
  end

  def received_notify_ongoing?
    !received_notify_attempts.ongoing.empty?
  end

  def stored?
    !store_attempts.successful.empty?
  end

  def store_ongoing?
    !store_attempts.ongoing.empty?
  end

  def stored_notified?
    !stored_notify_attempts.successful.empty?
  end

  def stored_notify_ongoing?
    !stored_notify_attempts.ongoing.empty?
  end



  def source_location
    link
  end

  def staging_location
    File.join(Rails.configuration.staging_dir.to_s, from_node, File.basename(link))
  end

  def unpacked_location
    unpack_attempts.successful.first&.unpacked_location || ""
  end

  def bag_valid?
    validate_attempts.successful.first&.bag_valid?
  end

  def validation_errors
    validate_attempts.successful.first&.validation_errors || []
  end

  def fixity_value
    fixity_attempts.successful.first&.value || ""
  end

  def self.successful(table)
    joins(table).where(table => {success: true})
  end

  def self.ongoing(table)
    joins(table).where(table => {end_time: nil})
  end
end