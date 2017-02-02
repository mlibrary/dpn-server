# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::FixityFilter do
  let(:filter) { described_class.new }
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
  it "includes validated" do
    flow = Fabricate(:validated_replication_flow)
    expect(filter.flows).to include(flow)
  end
  it "ignores fixity_complete" do
    flow = Fabricate(:fixity_complete_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores fixity_ongoing" do
    flow = Fabricate(:fixity_ongoing_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores flows with ongoing AND failed" do
    flow = Fabricate(:fixity_ongoing_replication_flow)
    flow.fixity_attempts.create!(start_time: 1.day.ago, end_time: 1.hour.ago, success: false)
    expect(filter.flows).to_not include(flow)
  end
end

