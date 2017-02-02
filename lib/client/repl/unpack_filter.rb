# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Repl

    class UnpackFilter
      def flows
        ReplicationFlow
          .includes(:unpack_attempts)
          .successful(:retrieval_attempts)
          .select{|flow| !flow.unpacked? && !flow.unpack_ongoing?}
      end
    end

  end
end
