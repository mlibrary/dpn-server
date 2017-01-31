# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


shared_examples "an attempt" do |delegations|

  describe "delegations" do
    let(:attempt) { Fabricate.build(fabricator, replication_flow: Fabricate.build(:replication_flow)) }
    delegations.each do |method|
      it "delegates ##{method} to the ReplicationFlow" do
        expect(attempt.replication_flow).to receive(method)
        attempt.public_send(method)
      end
    end
  end

  describe "::ongoing" do
    it "only returns attempts without an end_time" do
      Fabricate(fabricator, end_time: 1.hour.ago, success: true)
      Fabricate(fabricator, end_time: 2.days.ago, success: false, error: "testing")
      ongoing = Fabricate(fabricator, end_time: nil)
      expect(described_class.ongoing).to contain_exactly(ongoing)
    end
  end

  describe "::successful" do
    it "only returns attempts with success: true" do
      success = Fabricate(fabricator, end_time: 1.hour.ago, success: true)
      Fabricate(fabricator, end_time: 2.days.ago, success: false, error: "testing")
      Fabricate(fabricator, end_time: nil)
      expect(described_class.successful).to contain_exactly(success)
    end
  end

  describe "#success!" do
    let(:attempt) { Fabricate.build(fabricator, success: nil, end_time: nil) }
    it "sets the end_time" do
      expect {attempt.success!(*success_args)}.to change{attempt.end_time}
        .from(nil).to(be_within(1.second).of(Time.now))
    end
    it "sets success => true" do
      expect {attempt.success!(*success_args)}.to change{attempt.success}
        .from(nil).to(true)
    end
  end

  describe "#failure!" do
    let(:attempt) { Fabricate.build(fabricator, success: nil, end_time: nil) }
    let(:msg) { Faker::Lorem.paragraph }
    let(:args) { failure_args + [msg]}
    it "sets the end_time" do
      expect {attempt.failure!(*args)}.to change{attempt.end_time}
        .from(nil).to(be_within(1.second).of(Time.now))
    end
    it "sets success => false" do
      expect {attempt.failure!(*args)}.to change{attempt.success}
        .from(nil).to(false)
    end
    it "sets error to the given message" do
      expect {attempt.failure!(*args)}.to change{attempt.error}
        .from(nil).to(msg)
    end
  end
end