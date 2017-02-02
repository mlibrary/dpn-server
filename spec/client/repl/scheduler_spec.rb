# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'spec_helper'

describe Client::Repl::Scheduler do
  let(:attempt1) { double(:attempt1) }
  let(:flow1) do
    double(:flow1,
      test_attempts: double(:flow1c,
        create!: attempt1)
    )
  end
  let(:attempt2) { double(:attempt2) }
  let(:flow2) do
    double(:flow2,
      test_attempts: double(:flow2c,
        create!: attempt2)
    )
  end
  let(:flows) { [flow1, flow2] }
  let(:filter) { double(:filter, flows: flows) }
  let(:jobclass) { double(:job, perform_later: nil)}
  let(:attempt_type) { :test_attempt }


  it "creates an attempt for each flow from the filter" do
    expect(flow1.test_attempts).to receive(:create!).once
    expect(flow2.test_attempts).to receive(:create!).once
    described_class.new(jobclass, filter, attempt_type).schedule
  end

  it "scheduels a job with each attempt" do
    expect(jobclass).to receive(:perform_later).with(attempt1)
    expect(jobclass).to receive(:perform_later).with(attempt2)
    described_class.new(jobclass, filter, attempt_type).schedule
  end
end