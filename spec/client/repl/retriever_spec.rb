# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::Retriever do
  let(:source) { "source" }
  let(:dest) { "dest" }
  let(:attempt) do
    double(:attempt,
      source_location: source, staging_location: dest,
      success!: nil, failure!: nil
    )
  end
  let(:transfer_method) { double(:transfer_method, run: result) }
  let(:retriever) { described_class.new(attempt, transfer_method)}

  context "success" do
    let(:result) { double(:result, :success? => true )}
    it "tries to copy from source to destination" do
      retriever.retrieve
      expect(transfer_method).to have_received(:run)
        .with(source, dest, anything)
    end
    it "calls success! on the attempt" do
      retriever.retrieve
      expect(attempt).to have_received(:success!).with(no_args)
    end
  end

  context "failure" do
    let(:error) { "some\n\n\nlong\nerror" }
    let(:result) { double(:result, :success? => false, error: error) }
    it "tries to copy from source to destination" do
      retriever.retrieve
      expect(transfer_method).to have_received(:run)
        .with(source, dest, anything)
    end
    it "calls failure! on the attempt with the error" do
      retriever.retrieve
      expect(attempt).to have_received(:failure!).with(error)
    end
  end

  context "Errno:ENOENT" do
    let(:transfer_method) { double(:transfer_method) }
    before(:each) { allow(transfer_method).to receive(:run).and_raise(Errno::ENOENT) }
    it "catches the error" do
      expect {retriever.retrieve}.to_not raise_error
    end
    it "calls failure! on the attempt with the exception's message" do
      retriever.retrieve
      expect(attempt).to have_received(:failure!)
        .with(a_string_matching(/No such file or directory.*/))
    end
  end

end












