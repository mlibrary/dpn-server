# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ReplicationFlow do
  describe "#retrieved?" do
    it "is true when it has a successful RetrievalAttempt" do
      flow = Fabricate(:replication_flow)
      flow.retrieval_attempts << Fabricate(:retrieval_attempt, success: true, end_time: Time.now)
      expect(flow.retrieved?).to be true
    end
    it "is false when it does not have a successful RetrievalAttempt" do
      flow = Fabricate(:replication_flow)
      flow.retrieval_attempts << Fabricate(:retrieval_attempt, success: nil)
      expect(flow.retrieved?).to be false
    end
  end


  describe "#retrieval_ongoing?" do
    it "is true when it has an ongoing RetrievalAttempt" do
      flow = Fabricate(:replication_flow)
      flow.retrieval_attempts << Fabricate(:retrieval_attempt, success: nil, end_time: nil)
      expect(flow.retrieval_ongoing?).to be true
    end
    it "is false otherwise" do
      flow = Fabricate(:replication_flow)
      flow.retrieval_attempts << Fabricate(:retrieval_attempt, success: false, end_time: 1.hour.ago)
      expect(flow.retrieval_ongoing?).to be false
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

end