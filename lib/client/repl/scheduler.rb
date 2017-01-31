# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class Scheduler
      def initialize(jobclass, filter, attempt_type)
        @jobclass = jobclass
        @filter = filter
        @attempt_type = attempt_type
      end

      attr_reader :jobclass, :filter, :attempt_type

      def schedule
        attempts_method = attempt_type.to_s.pluralize.to_sym
        filter.flows
          .map{|flow| flow.public_send(attempts_method).create!(start_time: Time.now.utc)}
          .each{|attempt| jobclass.perform_later(attempt)}
      end
    end

    # We now create a number of subclasses to facilitate ActiveJob creation
    # of schedulers, as ActiveJob does not handle being queued with an object
    # very well.

    class RetrievalScheduler < Scheduler
      def initialize
        super(RetrievalJob, RetrievalFilter, :retrieval_attempt)
      end
    end

    class UnpackScheduler < Scheduler
      def initialize
        super(UnpackJob, UnpackFilter, :unpack_attempt)
      end
    end

    class ValidateScheduler < Scheduler
      def initialize
        super(ValidateJob, ValidateFilter, :validate_attempt)
      end
    end

    class FixityScheduler < Scheduler
      def initialize
        super(FixityJob, FixityFilter, :fixity_attempt)
      end
    end

    class ReceivedNotifyScheduler < Scheduler
      def initialize
        super(ReceivedNotifyJob, ReceivedNotifyFilter, :received_notify_attempt)
      end
    end

    class StoreScheduler < Scheduler
      def initialize
        super(StoreJob, StoreFilter, :store_attempt)
      end
    end

    class StoredNotifyScheduler < Scheduler
      def initialize
        super(StoredNotifyJob, StoredNotifyFilter, :stored_notify_attempt)
      end
    end

  end
end
