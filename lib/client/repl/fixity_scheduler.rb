# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client

  class FixityScheduler
    def schedule
      flows.each do |flow|
        fixity_attempt = flow.fixity_attempts.create!(start_time: Time.now.utc)
        FixityJob.perform_later(fixity_attempt)
      end
    end

    def flows
      ReplicationFlow
        .retrieved
        .unpacked
        .fixityd
        .not.fixity_complete
        .not.fixity_ongoing
    end
  end

end
