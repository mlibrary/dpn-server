# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class ReceivedNotifyJob < ActiveJob::Base
      queue_as :repl_received_notify

      def perform(attempt)
        ReceivedNotifier.new(attempt).notify
      end

    end
  end
end
