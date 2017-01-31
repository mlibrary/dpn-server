# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class StoredNotifier
      include Common

      attr_reader :attempt

      def initialize(attempt)
        @attempt = attempt
      end


      def notify
        result = send_notification(update_query)
        if result.success?
          attempt.success!
        else
          attempt.failure!(result.error)
        end
      end


      def update_query
        replication = ReplicationTransfer.find_by_replication_id(attempt.replication_id)
        replication.stored = true
        body =  ReplicationTransferAdapter.from_model(replication).to_public_hash
        Query.new(:update_replication, body)
      end


      def send_notification(query)
        remote_client.execute query do |response|
          Struct.new(success?: response.success?, error: response.body)
        end
      end

    end
  end
end
