# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class RetrievalJob < ActiveJob::Base
      queue_as :repl_retrieval

      def perform(retrieval_attempt)
        Retriever.new(retrieval_attempt).retrieve
      end

    end
  end
end
