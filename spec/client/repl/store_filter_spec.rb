# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::StoreFilter do
  let(:filter) { described_class.new }
  before(:each) { Fabricate(:local_node) }
  it "ignores fresh" do
    flow = Fabricate(:replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores retrieved" do
    flow = Fabricate(:retrieved_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores unpacked" do
    flow = Fabricate(:unpacked_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores validated" do
    flow = Fabricate(:validated_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores fixity_complete" do
    flow = Fabricate(:fixity_complete_replication_flow)
    expect(filter.flows).to_not include(flow)
  end

  def build_replication(flow, store_requested)
    Fabricate(:replication_transfer,
      to_node: Node.local_node!,
      replication_id: flow.replication_id,
      store_requested: store_requested,
    )
  end

  context "replication.store_requested==true" do
    it "includes received_notified" do
      flow = Fabricate(:received_notified_replication_flow)
      build_replication(flow, true)
      expect(filter.flows).to include(flow)
    end
    it "ignores stored" do
      flow = Fabricate(:stored_replication_flow)
      build_replication(flow, true)
      expect(filter.flows).to_not include(flow)
    end
    it "ignores store_ongoing" do
      flow = Fabricate(:store_ongoing_replication_flow)
      build_replication(flow, true)
      expect(filter.flows).to_not include(flow)
    end
    it "ignores flows with ongoing AND failed" do
      flow = Fabricate(:store_ongoing_replication_flow)
      flow.store_attempts.create!(start_time: 1.day.ago, end_time: 1.hour.ago, success: false)
      build_replication(flow, true)
      expect(filter.flows).to_not include(flow)
    end
  end


  context "replication.store_requested==false" do
    let(:replication) { Fabricate(:replication_transfer, store_requested: true) }
    it "ignores received_notified" do
      flow = Fabricate(:received_notified_replication_flow)
      build_replication(flow, false)
      expect(filter.flows).to_not include(flow)
    end
    it "ignores stored" do
      flow = Fabricate(:stored_replication_flow)
      build_replication(flow, false)
      expect(filter.flows).to_not include(flow)
    end
    it "ignores store_ongoing" do
      flow = Fabricate(:store_ongoing_replication_flow)
      build_replication(flow, false)
      expect(filter.flows).to_not include(flow)
    end
    it "ignores flows with ongoing AND failed" do
      flow = Fabricate(:store_ongoing_replication_flow)
      flow.store_attempts.create!(start_time: 1.day.ago, end_time: 1.hour.ago, success: false)
      build_replication(flow, false)
      expect(filter.flows).to_not include(flow)
    end
  end
end

