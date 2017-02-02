# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::Validator do
  let(:location) { "unpacked_location" }
  let(:attempt) do
    double(:attempt,
      unpacked_location: location,
      success!: nil, failure!: nil
    )
  end
  let(:validate_method) { double(:validate_method, validate_bag: result) }
  let(:validator) { described_class.new(attempt, validate_method)}

  context "valid" do
    let(:result) { double(:result, valid?: true, validation_errors: nil)}
    it "validates" do
      validator.validate
      expect(validate_method).to have_received(:validate_bag)
        .with(location)
    end
    it "calls success! on the attempt with validity, errors" do
      validator.validate
      expect(attempt).to have_received(:success!)
        .with(true, nil)
    end
  end

  context "invalid" do
    let(:errors) { Faker::Lorem.paragraph.split("\n") }
    let(:result) { double(:result, valid?: false, validation_errors: errors)}
    it "validates" do
      validator.validate
      expect(validate_method).to have_received(:validate_bag)
        .with(location)
    end
    it "calls success! on the attempt with validity, errors" do
      validator.validate
      expect(attempt).to have_received(:success!)
        .with(false, errors)
    end
  end

  context "Errno:ENOENT" do
    let(:validate_method) { double(:validate_method) }
    before(:each) { allow(validate_method).to receive(:validate_bag).and_raise(Errno::ENOENT) }
    it "catches the error" do
      expect {validator.validate}.to_not raise_error
    end
    it "calls failure! on the attempt with the exception's message" do
      validator.validate
      expect(attempt).to have_received(:failure!)
        .with(a_string_matching(/No such file or directory.*/))
    end
  end

end












