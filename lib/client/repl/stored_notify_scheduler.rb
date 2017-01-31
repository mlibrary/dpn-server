# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class StoredNotifyScheduler

    def schedule
      flows.each do |flow|
        attempt = flow.stored_notify_attempts.create!(start_time: Time.now.utc)
        StoredNotifyJob.perform_later(attempt)
      end
    end

    def flows
      ReplicationFlow
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
