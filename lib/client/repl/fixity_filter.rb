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
          .successful(:retrieval_attempts)
          .successful(:unpack_attempts)
          .successful(:validate_attempts)
          .select{|flow| !flow.fixity_complete? && !flow.fixity_ongoing?}
      end
    end

  end
end
