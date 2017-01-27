# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class RetrievalScheduler

    def schedule
      replications.each do |replication|
        flow = flow_for_replication(replication)
        if should_retrieve?(flow)
          retrieval_attempt = flow.retrieval_attempts.create!(start_time: Time.now.utc)
          RetrievalJob.perform_later(retrieval_attempt)
        end
      end
    end


    def should_retrieve?(flow)
      !flow.retrieved?  &&
        !flow.retrieval_ongoing? &&
        flow.retrieval_attempts.count < 5
    end


    def flow_for_replication(replication)
      ReplicationFlow.find_or_create_by!(
        replication_id: replication.replication_id,
        link: replication.link,
        from_node: replication.from_node.namespace,
        bag: replication.bag.uuid
      )
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
