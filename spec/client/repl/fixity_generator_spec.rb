# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::FixityGenerator do
  let(:location) { "unpacked_location" }
  let(:attempt) do
    double(:attempt,
      unpacked_location: location,
      success!: nil, failure!: nil
    )
  end
  let(:fixity_method) { double(:fixity_method, sha256: fixity_value) }
  let(:generator) { described_class.new(attempt, fixity_method)}

  context "success" do
    let(:fixity_value) { "somefixity" }
    it "generates fixity(sha256)" do
      generator.generate
      expect(fixity_method).to have_received(:sha256)
        .with(location)
    end
    it "calls success! on the attempt with validity, errors" do
      generator.generate
      expect(attempt).to have_received(:success!).with(fixity_value)
    end
  end

  context "Errno:ENOENT" do
    let(:fixity_method) { double(:fixity_method) }
    before(:each) { allow(fixity_method).to receive(:sha256).and_raise(Errno::ENOENT) }
    it "catches the error" do
      expect {generator.generate}.to_not raise_error
    end
    it "calls failure! on the attempt with the exception's message" do
      generator.generate
      expect(attempt).to have_received(:failure!)
        .with(a_string_matching(/No such file or directory.*/))
    end
  end

end












