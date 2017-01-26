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

  describe "#success!" do
    let(:attempt) { Fabricate.build(:retrieval_attempt, success: nil, end_time: nil) }
    it "sets the end_time" do
      expect {attempt.success!}.to change{attempt.end_time}
        .from(nil).to(be_within(1.second).of(Time.now))
    end
    it "sets success => true" do
      expect {attempt.success!}.to change{attempt.success}
        .from(nil).to(true)
    end
  end

  describe "#failure!" do
    let(:attempt) { Fabricate.build(:retrieval_attempt, success: nil, end_time: nil) }
    let(:msg) { Faker::Lorem.paragraph }
    it "sets the end_time" do
      expect {attempt.failure!(msg)}.to change{attempt.end_time}
        .from(nil).to(be_within(1.second).of(Time.now))
    end
    it "sets success => false" do
      expect {attempt.failure!(msg)}.to change{attempt.success}
        .from(nil).to(false)
    end
    it "sets error to the given message" do
      expect {attempt.failure!(msg)}.to change{attempt.error}
        .from(nil).to(msg)
    end
  end

end