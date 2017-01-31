# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class StoreScheduler
    def schedule
      flows.each do |flow|
        if replications.include? flow.replication_id
          attempt = flow.store_attempts.create!(start_time: Time.now.utc)
          StoreJob.perform_later(attempt)
        end
      end
    end

    def flows
      ReplicationFlow
        .retrieved
        .unpacked
        .validated
        .fixity_complete
        .received_notified
        .not.stored
        .not.store_ongoing
    end

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
