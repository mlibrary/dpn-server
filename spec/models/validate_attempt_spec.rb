# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe ValidateAttempt do
  it_behaves_like "an attempt", [:unpacked_location] do
    let(:fabricator) { :validate_attempt }
    let(:success_args) { [[true,false].sample, Faker::Lorem.paragraph.split('p')] }
    let(:failure_args) { [] }
  end


  describe "#success!" do
    let(:attempt) { Fabricate.build(:validate_attempt, success: nil, end_time: nil) }

    context "when valid" do
      let(:validity) { true }
      let(:validation_errors) { [] }
      it "sets bag_valid" do
        expect {attempt.success!(validity, validation_errors)}.to change{attempt.bag_valid}
          .from(nil).to(validity)
      end
      it "sets validation_errors" do
        expect {attempt.success!(validity, validation_errors)}.to_not change{attempt.validation_errors}
      end
    end

    context "when invalid" do
      let(:validity) { false }
      let(:validation_errors) { Faker::Lorem.paragraph.split('p')}
      it "sets bag_valid" do
        expect {attempt.success!(validity, validation_errors)}.to change{attempt.bag_valid}
          .from(nil).to(validity)
      end
      it "sets validation_errors" do
        expect {attempt.success!(validity, validation_errors)}.to change{attempt.validation_errors}
          .from([]).to(validation_errors)
      end
    end
  end


  context "when succeeded" do
    let(:errors) { Faker::Lorem.paragraph.split('i') }
    let(:attempt) { Fabricate.build(:validate_attempt, success: true, error: errors.join("\n")) }
    it "#error is nil" do
      expect(attempt.error).to be_nil
    end
    it "#validtion_errors matches the array" do
      expect(attempt.validation_errors).to eql(errors)
    end
  end

  context "when failed" do
    let(:error) { Faker::Lorem.sentence }
    let(:attempt) { Fabricate.build(:validate_attempt, success: false, error: error)}
    it "#error is the error" do
      expect(attempt.error).to eql(error)
    end
    it "#validation_errors is an empty array" do
      expect(attempt.validation_errors).to eql([])
    end

  end

end
