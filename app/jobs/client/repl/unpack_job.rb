# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class UnpackJob < ActiveJob::Base
      queue_as :repl_unpack

      def perform(unpack_attempt)
        Unpacker.new(unpack_attempt).unpack
      end

    end
  end
end
