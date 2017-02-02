# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class StoreFilter
      def flows
        ReplicationFlow
          .includes(:store_attempts)
          .successful(:retrieval_attempts)
          .successful(:unpack_attempts)
          .successful(:validate_attempts)
          .successful(:fixity_attempts)
          .successful(:received_notify_attempts)
          .select{|flow| !flow.stored? && !flow.store_ongoing?}
          .select{|flow| replications.include?(flow.replication_id)}
      end

      private

      def replications
        @replications ||= Set.new(ReplicationTransfer
          .where(to_node: Node.local_node!)
          .where(cancelled: false)
          .where(stored: false)
          .where(store_requested: true)
          .pluck(:replication_id))
      end
    end

  end
end
