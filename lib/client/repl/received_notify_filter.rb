# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class ReceivedNotifyFilter
      def flows
        ReplicationFlow
          .includes(:received_notify_attempts)
          .retrieved
          .unpacked
          .validated
          .fixity_complete
          .not.received_notified
          .not.received_notify_ongoing
      end
    end

  end
end
