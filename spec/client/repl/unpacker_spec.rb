# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::Unpacker do
  let(:location) { "staging_location.tar" }
  let(:unpacked_location) { "unpacked_location" }
  let(:attempt) do
    double(:attempt,
      staging_location: location,
      success!: nil, failure!: nil
    )
  end
  let(:unpacked_bag) { double(:bag, location: unpacked_location) }
  let(:unpack_method) { double(:unpack_method, unpack_tar: result) }
  let(:unpacker) { described_class.new(attempt, unpack_method)}

  context "success" do
    let(:result) { double(:result, success?: true, bag: unpacked_bag, error: nil )}
    it "unpacks" do
      unpacker.unpack
      expect(unpack_method).to have_received(:unpack_tar)
        .with(location)
    end
    it "calls success! on the attempt with the new location" do
      unpacker.unpack
      expect(attempt).to have_received(:success!).with(unpacked_location)
    end
  end

  context "failure" do
    let(:error) { "some\n\n\nlong\nerror" }
    let(:result) { double(:result, success?: false, bag: unpacked_bag, error: error) }
    it "unpacks" do
      unpacker.unpack
      expect(unpack_method).to have_received(:unpack_tar)
        .with(location)
    end
    it "calls failure! on the attempt with the error" do
      unpacker.unpack
      expect(attempt).to have_received(:failure!).with(error)
    end
  end

  context "Errno:ENOENT" do
    let(:unpack_method) { double(:unpack_method) }
    before(:each) { allow(unpack_method).to receive(:unpack_tar).and_raise(Errno::ENOENT) }
    it "catches the error" do
      expect {unpacker.unpack}.to_not raise_error
    end
    it "calls failure! on the attempt with the exception's message" do
      unpacker.unpack
      expect(attempt).to have_received(:failure!)
        .with(a_string_matching(/No such file or directory.*/))
    end
  end

end












