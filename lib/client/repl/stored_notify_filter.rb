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
          .successful(:retrieval_attempts)
          .successful(:unpack_attempts)
          .successful(:validate_attempts)
          .successful(:fixity_attempts)
          .successful(:received_notify_attempts)
          .successful(:store_attempts)
          .select{|flow| !flow.stored_notified? && !flow.stored_notify_ongoing?}
      end
    end

  end
end
