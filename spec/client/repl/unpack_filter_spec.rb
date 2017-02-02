# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe Client::Repl::UnpackFilter do
  let(:filter) { described_class.new }
  it "ignores fresh" do
    flow = Fabricate(:replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "includes retrieved" do
    flow = Fabricate(:retrieved_replication_flow)
    expect(filter.flows).to include(flow)
  end
  it "ignores unpacked" do
    flow = Fabricate(:unpacked_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores unpack_ongoing" do
    flow = Fabricate(:unpack_ongoing_replication_flow)
    expect(filter.flows).to_not include(flow)
  end
  it "ignores flows with ongoing AND failed attempts" do
    flow = Fabricate(:unpack_ongoing_replication_flow)
    flow.unpack_attempts.create!(start_time: 1.day.ago, end_time: 1.hour.ago, success: false)
    expect(filter.flows).to_not include(flow)
  end
end

