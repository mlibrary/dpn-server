# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class ReceivedNotifier
      class DefaultMethod
        extend Client::Common
        Result = Struct.new(:success?, :error)
        def self.notify(namespace, query)
          result = Result.new(false, "empty")
          remote_client(namespace).execute query do |response|
            result = Result.new(response.success?, response.body)
          end
          return result
        end
      end

      attr_reader :attempt, :notify_method

      def initialize(attempt, notify_method = DefaultMethod)
        @attempt = attempt
        @notify_method = notify_method
      end


      def notify
        if attempt.bag_valid?
          send_notification(update_query(attempt.replication))
        else
          send_notification(cancel_query(attempt.replication))
        end
      end

      private

      def body(replication)
        ReplicationTransferAdapter.from_model(replication).to_public_hash
      end

      def cancel_query(replication)
        body = body(replication)
        body[:cancelled] = true
        body[:fixity_value] = attempt.fixity_value
        body[:cancel_reason] = 'bag_invalid'
        body[:cancel_reason_detail] = [attempt.validation_errors].flatten.join("\n")
        Query.new(:update_replication, body)
      end

      def update_query(replication)
        body = body(replication)
        body[:fixity_value] = attempt.fixity_value
        Query.new(:update_replication, body)
      end

      def send_notification(query)
        result = notify_method.notify(attempt.from_node, query)
        if result.success?
          attempt.success!
        else
          attempt.failure!(result.error)
        end
      end

    end
  end
end
