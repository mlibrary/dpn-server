# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationFlow do
  [
    [RetrievalAttempt, :retrieved?, :retrieval_ongoing?],
    [UnpackAttempt, :unpacked?, :unpack_ongoing?],
    [ValidateAttempt, :validated?, :validate_ongoing?],
    [FixityAttempt, :fixity_complete?, :fixity_ongoing?],
    [ReceivedNotifyAttempt, :received_notified?, :received_notify_ongoing?],
    [StoreAttempt, :stored?, :store_ongoing?],
    [StoredNotifyAttempt, :stored_notified?, :stored_notify_ongoing?]
  ].each do |attempt_class, done, ongoing|
    context "when it has a successful #{attempt_class}" do
      let(:flow) { Fabricate(:replication_flow) }
      let(:attempt_fabricator) { attempt_class.to_s.underscore.to_sym }
      let!(:successful_attempt) do
        Fabricate(attempt_fabricator, end_time: Time.now, success: true, replication_flow: flow)
      end
      it "##{done} is true" do
        expect(flow.public_send(done)).to be true
      end
      it "##{ongoing} is not (necessarily) true" do
        expect(flow.public_send(ongoing)).to be false
      end
    end
    context "when it has an ongoing #{attempt_class}" do
      let(:flow) { Fabricate(:replication_flow) }
      let(:attempt_fabricator) { attempt_class.to_s.underscore.to_sym }
      let!(:ongoing_attempt) do
        Fabricate(attempt_fabricator, end_time: nil, success: nil, replication_flow: flow)
      end
      it "##{done} is not (necessarily) true" do
        expect(flow.public_send(done)).to be false
      end
      it "##{ongoing} is true" do
        expect(flow.public_send(ongoing)).to be true
      end
    end
  end

  describe "#source_location" do
    let(:link) { "some@link" }
    let(:flow) { Fabricate.build(:replication_flow, link: link) }
    it "returns the flow's link" do
      expect(flow.source_location).to eql(link)
    end
  end

  describe "#staging_location" do
    let(:bag) { SecureRandom.uuid }
    let(:from_node) { "zip" }
    let(:dest) { File.join(Rails.configuration.staging_dir.to_s, from_node, bag) }
    let(:flow) { Fabricate.build(:replication_flow, from_node: from_node, bag: bag) }
    it "matches /staging_dir/from_node_namespace/bag_uuid" do
      expect(flow.staging_location).to eql(dest)
    end
  end

  describe "#unpacked_location" do
    let(:unpacked_location) { "/some/loca/tion"}
    let(:flow) do
      Fabricate(:replication_flow,
        unpack_attempts: [
          Fabricate(:unpack_attempt,
            end_time: Time.now,
            success: true,
            unpacked_location: unpacked_location
          ),
          Fabricate(:unpack_attempt,
            success: false,
            unpacked_location: "somewhere/else")
        ])
    end
    it "matches the successful unpack attempt" do
      expect(flow.unpacked_location).to eql(unpacked_location)
    end
  end

  describe "validity" do
    let(:validation_errors) { Faker::Lorem.paragraph.split('\n') }
    let(:valid_flow) do
      Fabricate(:replication_flow,
        validate_attempts: [
          Fabricate(:validate_attempt,
            end_time: Time.now,
            success: true,
            bag_valid: true,
            error: nil)
        ])
    end
    let(:invalid_flow) do
      Fabricate(:replication_flow,
        validate_attempts: [
          Fabricate(:validate_attempt,
            end_time: Time.now,
            success: true,
            bag_valid: false,
            error: validation_errors.join('\n'))
        ])
    end
    describe "#bag_valid?" do
      it "is true when the flow has a successful validate_attempt that came back valid" do
        expect(valid_flow.bag_valid?).to be true
      end
      it "is false when the flow lacks a validate_attempt with bag_valid==true" do
        expect(invalid_flow.bag_valid?).to be false
      end
    end
    describe "#validation_errors" do
      it "is [] when the validate attempt checked a valid bag" do
        expect(valid_flow.validation_errors).to eql([])
      end
      it "returns the errors when the bag wasn't valid" do
        expect(invalid_flow.validation_errors).to eql(validation_errors)
      end
    end
  end

  describe "#fixity_value" do
    let(:fixity_value) { "somefixityvalue" }
    let(:flow) do
      Fabricate(:replication_flow,
        fixity_attempts: [
          Fabricate(:fixity_attempt,
            end_time: Time.now,
            success: true,
            value: fixity_value)
        ])
    end
    it "returns the fixity value of a successful fixity_attempt" do
      expect(flow.fixity_value).to eql(fixity_value)
    end
  end

end