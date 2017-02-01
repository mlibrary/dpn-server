# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::RetrievalFilter do
  before(:each) { Fabricate(:local_node) }
  let(:filter) { described_class.new }
  let!(:cancelled) { Fabricate(:replication_transfer, cancelled: true, to_node: Node.local_node!) }
  let!(:stored) { Fabricate(:replication_transfer, stored: true, to_node: Node.local_node!) }
  let!(:for_other) { Fabricate(:replication_transfer, to_node: Fabricate(:node)) }
  let!(:no_flow) { Fabricate(:replication_transfer, to_node: Node.local_node!) }
  let!(:with_flow) do
    transfer = Fabricate(:replication_transfer, to_node: Node.local_node!)
    Fabricate(:replication_flow, replication_id: transfer.replication_id)
    transfer
  end
  let!(:retrieved) do
    transfer = Fabricate(:replication_transfer, to_node: Node.local_node!)
    Fabricate(:retrieval_attempt, success: true, end_time: Time.now,
      replication_flow: Fabricate(:replication_flow, replication_id: transfer.replication_id))
    transfer
  end
  let!(:retrieval_ongoing) do
    transfer = Fabricate(:replication_transfer, to_node: Node.local_node!)
    Fabricate(:retrieval_attempt,
      replication_flow: Fabricate(:replication_flow, replication_id: transfer.replication_id))
    transfer
  end

  let(:ids) { filter.flows.map{|repl| repl.replication_id} }

  it "ignores cancelled replications" do
    expect(ids).to_not include(cancelled.replication_id)
  end
  it "ignores stored replications" do
    expect(ids).to_not include(stored.replication_id)
  end
  it "ignores replications for others" do
    expect(ids).to_not include(for_other.replication_id)
  end
  it "includes new flows for replications without flows" do
    expect(ids).to include(no_flow.replication_id)
  end
  it "includes flows for replications with existing flows" do
    expect(ids).to include(with_flow.replication_id)
  end
  it "ignores flows that have been retrieved" do
    expect(ids).to_not include(retrieved.replication_id)
  end
  it "ignores flows with an ongoing retrieval" do
    expect(ids).to_not include(retrieval_ongoing.replication_id)
  end

end

