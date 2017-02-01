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
          .retrieved
          .unpacked
          .validated
          .fixity_complete
          .received_notified
          .not.stored
          .not.store_ongoing
          .select{|flow| replication.include?(flow.replication_id)}
      end

      private

      def replications
        @replications ||= Set.new(ReplicationTransfer
          .where(to_node: Node.local_node!)
          .where(cancelled: false)
          .where(stored: false)
          .where(store_requested: true)
          .where.not(fixity_value: nil)
          .pluck(:replication_id))
      end
    end

  end
end
