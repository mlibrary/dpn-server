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

  end
end
