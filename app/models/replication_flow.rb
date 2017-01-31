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

  def receive_notified?
    !receive_notify_attempts.successful.empty?
  end

  def receive_notify_ongoing?
    !receive_notify_attempts.ongoing.empty?
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
    File.join(Rails.configuration.staging_dir.to_s, from_node, bag)
  end

  def unpacked_location
    unpack_attempts.successful.first.unpacked_location
  end

  def valid?
    validate_attempts.successful.first.valid?
  end

  def validation_errors
    validate_attempts.successful.first.error
  end

  def fixity_value
    fixity_attempts.successful.first.value
  end


  scope :retrieved, -> { joins(:retrieval_attempts).where(retrieval_attempts: {success: true}) }
  scope :retrieval_ongoing, -> {
    joins(:retrieval_attempts).where(retrieval_attempts: {end_time: nil} )
  }

  scope :unpacked, -> { joins(:unpack_attempts).where(unpack_attempts: {success: true}) }
  scope :unpack_ongoing, -> {
    joins(:unpack_attempts).where(unpack_attempts: {end_time: nil} )
  }

  scope :validated, -> { joins(:validate_attempts).where(validate_attempts: {success: true}) }
  scope :validate_ongoing, -> {
    joins(:validate_attempts).where(validate_attempts: {end_time: nil} )
  }

  scope :fixity_complete, -> { joins(:fixity_attempts).where(fixity_attempts: {success: true}) }
  scope :fixity_ongoing, -> {
    joins(:fixity_attempts).where(fixity_attempts: {end_time: nil} )
  }

  scope :received_notified, -> {
    joins(:received_notify_attempts).where(received_notify_attempts: {success: true})
  }
  scope :received_notify_ongoing, -> {
    joins(:received_notify_attempts).where(received_notify_attempts: {end_time: nil} )
  }

  scope :stored, -> { joins(:store_attempts).where(store_attempts: {success: true}) }
  scope :store_ongoing, -> {
    joins(:store_attempts).where(store_attempts: {end_time: nil} )
  }

  scope :stored_notified, -> {
    joins(:stored_notify_attempts).where(stored_notify_attempts: {success: true})
  }
  scope :stored_notify_ongoing, -> {
    joins(:stored_notify_attempts).where(stored_notify_attempts: {end_time: nil} )
  }

end
