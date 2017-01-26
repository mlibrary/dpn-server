# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Client::Repl::Retriever do
  describe "#source_location" do
    let(:link) { "some@link" }
    let(:retrieval_attempt) { double(:attempt, link: link) }
    it "returns the flow's link" do
      expect(described_class.new(retrieval_attempt).source_location).to eql(link)
    end
  end

  describe "#staging_location" do
    let(:retrieval_attempt) { double(:attempt, from_node: "zip", bag: "someuuid") }
    let(:dest) { File.join(Rails.configuration.staging_dir.to_s, "zip", "someuuid") }
    it "matches /staging_dir/from_node_namespace/bag_uuid" do
      expect(described_class.new(retrieval_attempt).staging_location).to eql(dest)
    end
  end

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












