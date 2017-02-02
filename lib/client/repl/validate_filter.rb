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
          .successful(:retrieval_attempts)
          .successful(:unpack_attempts)
          .select{|flow| !flow.validated? && !flow.validate_ongoing?}
      end
    end

  end
end
