# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class ReceivedNotifier
      include Common

      attr_reader :attempt, :replication

      def initialize(attempt, replication)
        @attempt = attempt
        @replication = replication
      end

      def notify
        if attempt.valid?
          send_notification(update_query)
        else
          send_notification(cancel_query)
        end
      end

      def cancel_query
        replication.cancelled = true
        replication.fixity_value = attempt.fixity_value
        replication.cancel_reason = 'bag_invalid'
        replication.cancel_reason_detail = attempt.validation_errors
        Query.new(:update_replication, ReplicationTransferAdapter.from_model(replication).to_public_hash)
      end

      def update_query
        replication.fixity_value = attempt.fixity_value
        Query.new(:update_replication, ReplicationTransferAdapter.from_model(replication).to_public_hash)
      end

      def send_notification(query)
        remote_client.execute query do |response|
          if response.success?
            attempt.success!
          else
            attempt.failure!(response.body)
          end
        end
      end

    end
  end
end
