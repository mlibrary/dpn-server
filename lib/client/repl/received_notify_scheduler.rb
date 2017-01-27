# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class ReceivedNotifyScheduler

    def schedule
      replications.each do |replication|
        flow = ReplicationFlow.find_by_replication_id!(replication.replication_id)
        if should_notify?(flow)
          received_notify_attempt = flow.received_notify_attempts.create!(start_time: Time.now.utc)
          ReceivedNotifyJob.perform_later(replication, received_notify_attempt)
        end
      end
    end


    def should_notify?(flow)
      flow.fixity_complete? && flow.validated?
    end


    def replications
      # We define the query here instead of on the model to facilitate
      # moving this functionality to a standalone project.
      ReplicationTransfer
        .where(to_node: Node.local_node!)
        .where(cancelled: false)
        .where(store_requested: false)
        .where(fixity_value: nil)
        .includes(:from_node, :bag)
    end

  end

end
