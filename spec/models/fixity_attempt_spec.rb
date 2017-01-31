# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe FixityAttempt do
  it_behaves_like "an attempt", [:unpacked_location] do
    let(:fabricator) { :fixity_attempt }
    let(:success_args) { "somefixityvalue" }
    let(:failure_args) { [] }
  end

  describe "#success!" do
    let(:attempt) { Fabricate.build(:fixity_attempt, success: nil, end_time: nil) }
    let(:fixity) { "somefixity" }
    it "sets the unpacked_location" do
      expect {attempt.success!(fixity)}.to change{attempt.value}
        .from(nil).to(fixity)
    end
  end

end
