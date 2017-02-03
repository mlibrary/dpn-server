# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class StoredNotifier
      class DefaultMethod
        include Common
        Result = Struct.new(:success?, :error)
        def self.notify(query)
          remote_client.execute query do |response|
            Result.new(response.success?, response.body)
          end
        end
      end

      attr_reader :attempt, :notify_method

      def initialize(attempt, notify_method = DefaultMethod)
        @attempt = attempt
        @notify_method = notify_method
      end


      def notify
        result = notify_method.notify(update_query)
        if result.success?
          attempt.success!
        else
          attempt.failure!(result.error)
        end
      end

      private

      def update_query
        replication = attempt.replication
        body =  ReplicationTransferAdapter.from_model(replication).to_public_hash
        body[:stored] = true
        Query.new(:update_replication, body)
      end

    end
  end
end
