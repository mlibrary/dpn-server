# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class FixityFilter
      def flows
        ReplicationFlow
          .includes(:fixity_attempts)
          .retrieved
          .unpacked
          .fixityd
          .not.fixity_complete
          .not.fixity_ongoing
      end
    end

  end
end
