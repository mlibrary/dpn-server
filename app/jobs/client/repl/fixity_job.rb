# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class FixityJob < ActiveJob::Base
      queue_as :repl

      def perform(fixity_attempt)
        FixityGenerator.new(fixity_attempt).generate_fixity
      end

    end
  end
end
