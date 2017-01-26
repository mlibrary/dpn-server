# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe RetrievalAttempt do
  describe "delegations" do
    let(:attempt) { Fabricate.build(:retrieval_attempt, replication_flow: Fabricate.build(:replication_flow)) }
    [:replication_id, :link, :from_node, :bag].each do |method|
      it "##{method}" do
        expect(attempt.public_send(method)).to eql(attempt.replication_flow.public_send(method))
      end
    end
  end

  describe "::ongoing" do
    it "only returns attempts without an end_time" do
      flow = Fabricate(:replication_flow)
      success = Fabricate(:retrieval_attempt, end_time: 1.hour.ago, success: true)
      fail = Fabricate(:retrieval_attempt, end_time: 2.days.ago, success: false, error: "testing")
      current = Fabricate(:retrieval_attempt, end_time: nil)
      flow.retrieval_attempts = [fail, success, current]
      expect(flow.retrieval_attempts.ongoing).to contain_exactly(current)
    end
  end

  describe "::successful" do
    it "only returns attempts success: true" do
      flow = Fabricate(:replication_flow)
      success = Fabricate(:retrieval_attempt, end_time: 1.hour.ago, success: true)
      fail = Fabricate(:retrieval_attempt, end_time: 2.days.ago, success: false, error: "testing")
      current = Fabricate(:retrieval_attempt, end_time: nil)
      flow.retrieval_attempts = [fail, success, current]
      expect(flow.retrieval_attempts.successful).to contain_exactly(success)
    end
  end

end