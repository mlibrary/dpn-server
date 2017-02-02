# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::Storer do
  let(:location) { "unpacked_location" }
  let(:uuid) { SecureRandom.uuid }
  let(:attempt) do
    double(:attempt,
      unpacked_location: location,
      bag: uuid,
      success!: nil, failure!: nil
    )
  end
  let(:store_method) { double(:store_method, store: result) }
  let(:storer) { described_class.new(attempt, store_method)}
  
  context "success" do
    let(:result) { double(:result, success?: true, error: nil)}
    it "stores" do
      storer.store
      expect(store_method).to have_received(:store).with(location, uuid)
    end
    it "calls success! on the attempt with validity, errors" do
      storer.store
      expect(attempt).to have_received(:success!).with(no_args)
    end
  end

  context "failure" do
    let(:error) { "some\n\nlong\n\terror" }
    let(:result) { double(:result, success?: false, error: error)}
    it "stores" do
      storer.store
      expect(store_method).to have_received(:store).with(location, uuid)
    end
    it "calls failure! on the attempt with error" do
      storer.store
      expect(attempt).to have_received(:failure!).with(error)
    end
  end

  context "Errno:ENOENT" do
    let(:store_method) { double(:store_method) }
    before(:each) { allow(store_method).to receive(:store).and_raise(Errno::ENOENT) }
    it "catches the error" do
      expect {storer.store}.to_not raise_error
    end
    it "calls failure! on the attempt with the exception's message" do
      storer.store
      expect(attempt).to have_received(:failure!)
        .with(a_string_matching(/No such file or directory.*/))
    end
  end

end












