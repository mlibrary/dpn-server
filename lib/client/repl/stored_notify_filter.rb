# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class StoredNotifyFilter
      def flows
        ReplicationFlow
          .includes(:stored_notify_attempts)
          .retrieved
          .unpacked
          .validated
          .fixity_complete
          .received_notified
          .stored
          .not.stored_notified
          .not.stored_notify_ongoing
      end
    end

  end
end
