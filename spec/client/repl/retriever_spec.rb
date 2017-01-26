# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Repl::Retriever do
  describe "#rsync" do
    let(:source) { "source" }
    let(:dest) { "dest" }
    let(:result) { double(:result, :success => true )}
    let(:retriever) { described_class.new(double(:attempt))}
    before(:each) do
      allow(Rsync).to receive(:run) { result }
    end

    it "it copies from source to dest" do
      expect(Rsync).to receive(:run).once.with(source, dest, Client::Repl::Retriever::RSYNC_OPTIONS)
      retriever.rsync(source, dest)
    end

    it "returns the result from rsync" do
      expect(retriever.rsync(source, dest)).to eql(result)
    end
  end

  describe "#successful_attempt" do

  end

end












