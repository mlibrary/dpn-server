# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe UnpackAttempt do
  it_behaves_like "an attempt", [:staging_location] do
    let(:fabricator) { :unpack_attempt }
    let(:success_args) { "unpacked" }
    let(:failure_args) { [] }
  end

  describe "#success!" do
    let(:attempt) { Fabricate.build(:unpack_attempt, success: nil, end_time: nil) }
    it "sets the unpacked_location" do
      expect {attempt.success!("unpac/ked")}.to change{attempt.unpacked_location}
        .from(nil).to("unpac/ked")
    end
  end

end
