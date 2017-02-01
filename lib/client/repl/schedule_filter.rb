# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class RetrievalFilter
      def flows
        replications
          .map{|rep| flow_for_replication(rep)}
          .select{|flow| should_retrieve?(flow)}
      end

      private

      def should_retrieve?(flow)
        !flow.retrieved?  &&
          !flow.retrieval_ongoing? &&
          flow.retrieval_attempts.count < 5
      end


      def flow_for_replication(replication)
        flow = ReplicationFlow.find_by_replication_id(replication.replication_id)
        if flow
          flow
        else
          ReplicationFlow.create!(
            replication_id: replication.replication_id,
            link: replication.link,
            from_node: replication.from_node.namespace,
            bag: replication.bag.uuid
          )
        end
      end


      def replications
        # We define the query here instead of on the model to facilitate
        # moving this functionality to a standalone project.
        ReplicationTransfer
          .where(to_node: Node.local_node!)
          .where(cancelled: false)
          .where(stored: false)
          .includes(:from_node, :bag)
      end
    end

    class UnpackFilter
      def flows
        def flows
          ReplicationFlow
            .includes(:unpack_attempts)
            .retrieved
            .not.unpacked
            .not.unpack_ongoing
        end
      end
    end

    class ValidateFilter
      def flows
        ReplicationFlow
          .includes(:validate_attempts)
          .retrieved
          .unpacked
          .not.validated
          .not.validate_ongoing
      end
    end

    class FixityFilter
      def flows
        ReplicationFlow
          .includes(:fixity_attempts)
          .retrieved
          .unpacked
          .fixityd
          .not.fixity_complete
          .not.fixity_ongoing
      end
    end

    class ReceivedNotifyFilter
      def flows
        ReplicationFlow
          .includes(:received_notify_attempts)
          .retrieved
          .unpacked
          .validated
          .fixity_complete
          .not.received_notified
          .not.received_notify_ongoing
      end
    end

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

    class StoredNotifyFilter
      def flows
        ReplicationFlow
          .includes(:stored_notify_attempts)
          .retrieved
          .unpacked
          .validated
          .fixity_complete
          .received_notified
          .stored
          .not.stored_notified
          .not.stored_notify_ongoing
      end
    end

  end
end
