# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::StoredNotifier do

  let(:replication) { Fabricate(:replication_transfer, stored: true) }
  let(:attempt) do
    double(:attempt,
      replication: replication,
      success!: nil, failure!: nil
    )
  end
  let(:notify_method) { double(:notify_method, notify: result) }
  let(:notifier) { described_class.new(attempt, notify_method) }
  let(:body) do
    body = ReplicationTransferAdapter.from_model(replication).to_public_hash
    body[:stored] = true
    body
  end
  let(:query) { Client::Query.new(:update_replication, body) }

  context "success" do
    let(:result) { double(:result, success?: true, error: nil)}
    it "notifies" do
      notifier.notify
      expect(notify_method).to have_received(:notify).with(query)
    end
    it "calls success! on the attempt with validity, errors" do
      notifier.notify
      expect(attempt).to have_received(:success!).with(no_args)
    end
  end

  context "failure" do
    let(:error) { "some\n\nlong\n\terror" }
    let(:result) { double(:result, success?: false, error: error)}
    it "notifies" do
      notifier.notify
      expect(notify_method).to have_received(:notify).with(query)
    end
    it "calls failure! on the attempt with error" do
      notifier.notify
      expect(attempt).to have_received(:failure!).with(error)
    end
  end

end












