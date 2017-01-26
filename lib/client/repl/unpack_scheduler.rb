# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class UnpackScheduler
    def schedule
      flows.each do |flow|
        unpack_attempt = flow.unpack_attempts.create!(start_time: Time.now.utc)
        UnpackJob.perform_later(unpack_attempt)
      end
    end

    def flows
      ReplicationFlow
        .retrieved
        .not.unpacked
        .not.unpack_ongoing
    end
  end

end
