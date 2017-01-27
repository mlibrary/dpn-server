# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class StoreScheduler

    def schedule
      replications.each do |replication|
        flow = ReplicationFlow.find_by_replication_id(replication.replication_id)
        if should_store?(flow)
          store_attempt = flow.store_attempts.create!(start_time: Time.now.utc)
          StoreJob.perform_later(store_attempt)
        end
      end
    end


    def should_store?(flow)
      !flow.stored? &&
        !flow.store_ongoing?
        !flow.store_attempts.count < 5
    end


    def replications
      # We define the query here instead of on the model to facilitate
      # moving this functionality to a standalone project.
      ReplicationTransfer
        .where(to_node: Node.local_node!)
        .where(cancelled: false)
        .where(stored: false)
        .where(store_requested: true)
        .where.not(fixity_value: nil)
        .includes(:from_node, :bag)
    end

  end

end
