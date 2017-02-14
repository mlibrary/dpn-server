# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class StoredNotifyJob < ActiveJob::Base
      queue_as :repl_stored_notify

      def perform(attempt)
        StoredNotifier.new(attempt).notify
      end

    end
  end
end
