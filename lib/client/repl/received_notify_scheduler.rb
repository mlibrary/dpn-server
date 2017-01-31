# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class ReceivedNotifyScheduler

    def schedule
      flow.each do |flow|
        attempt = flow.received_notified_attempts.create!(start_time: Time.now.utc)
        ReceivedNotifyJob.perform_later(attempt)
      end
    end

    def flows
      ReplicationFlow
        .retrieved
        .unpacked
        .validated
        .fixity_complete
        .not.received_notified
        .not.received_notify_ongoing
    end

  end

end
