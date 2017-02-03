# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'spec_helper'

describe Client::Repl::ReceivedNotifier do
  let(:replication) { Fabricate(:replication_transfer) }

  let(:fixity) { "somefixityvalue" }
  let(:validation_errors) { ["one", "two", "three"] }
  let(:attempt) do
    double(:attempt,
      fixity_value: fixity,
      bag_valid?: bag_validity,
      validation_errors: validation_errors,
      replication: replication,
      success!: nil, failure!: nil
    )
  end

  let(:update_body) do
    body = ReplicationTransferAdapter.from_model(replication).to_public_hash
    body[:fixity_value] = fixity
    body
  end
  let(:cancel_body) do
    body = ReplicationTransferAdapter.from_model(replication).to_public_hash
    body[:cancelled] = true
    body[:cancel_reason] = 'bag_invalid'
    body[:cancel_reason_detail] = validation_errors.join("\n")
    body[:fixity_value] = fixity
    body
  end
  let(:query) { Client::Query.new(:update_replication, body) }

  let(:notify_method) { double(:notify_method, notify: result) }
  let(:notifier) { described_class.new(attempt, notify_method) }


  shared_examples "received notifier" do
    context "success" do
      let(:result) { double(:result, success?: true, error: nil)}
      it "notifies" do
        notifier.notify # We use the verbose expectation below for better debugging output.
        expect(notify_method).to have_received(:notify) do |arg|
          expect(arg.type).to eql(query.type)
          expect(arg.params).to eql(query.params)
        end
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
        notifier.notify # We use the verbose expectation below for better debugging output.
        expect(notify_method).to have_received(:notify) do |arg|
          expect(arg.type).to eql(query.type)
          expect(arg.params).to eql(query.params)
        end
      end
      it "calls failure! on the attempt with error" do
        notifier.notify
        expect(attempt).to have_received(:failure!).with(error)
      end
    end
  end

  context "attempt.bag_valid? == true" do
    let(:bag_validity) { true }
    it_behaves_like "received notifier" do
      let(:body) { update_body }
    end
  end
  context "attempt.bag_valid? == false" do
    let(:bag_validity) { false }
    it_behaves_like "received notifier" do
      let(:body) { cancel_body }
    end
  end
end












