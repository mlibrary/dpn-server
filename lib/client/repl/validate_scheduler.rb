# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class ValidateScheduler
    def schedule
      flows.each do |flow|
        validate_attempt = flow.validate_attempts.create!(start_time: Time.now.utc)
        ValidateJob.perform_later(validate_attempt)
      end
    end

    def flows
      ReplicationFlow
        .retrieved
        .unpacked
        .not.validated
        .not.validate_ongoing
    end
  end

end
