# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ReplicationFlow < ActiveRecord::Base

  has_many :retrieval_attempts, dependent: :destroy
  has_many :unpack_attempts, dependent: :destroy

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

  def source_location
    link
  end

  def staging_location
    File.join(Rails.configuration.staging_dir.to_s, from_node, bag)
  end

  def unpacked_location
    unpack_attempts.successful.first.unpacked_location
  end


  scope :retrieved, -> { joins(:retrieval_attempts).where(retrieval_attempts: {success: true}) }
  scope :retrieval_ongoing, -> {
    joins(:retrieval_attempts).where(retrieval_attempts: {end_time: nil} )
  }
  scope :unpacked, -> { joins(:unpack_attempts).where(unpack_attempts: {success: true}) }
  scope :unpack_ongoing, -> {
    joins(:unpack_attempts).where(unpack_attempts: {end_time: nil} )
  }



end
