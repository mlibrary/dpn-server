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

  end
end
