# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class ValidateFilter
      def flows
        ReplicationFlow
          .includes(:validate_attempts)
          .retrieved
          .unpacked
          .not.validated
          .not.validate_ongoing
      end
    end

  end
end
