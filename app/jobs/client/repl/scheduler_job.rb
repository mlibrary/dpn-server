# expect(jobclass).to receive(:perform_later).twice
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class SchedulerJob < ActiveJob::Base
      queue_as :repl

      def perform(jobclass, filterclass, attempt_type)
        Scheduler.new(jobclass, filterclass.new, attempt_type).schedule
      end
    end

  end
end
