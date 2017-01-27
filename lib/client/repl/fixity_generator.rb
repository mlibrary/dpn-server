# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class FixityGenerator

      attr_reader :fixity_attempt

      def initialize(fixity_attempt)
        @fixity_attempt = fixity_attempt
      end

      def generate
        result = fixity(fixity_attempt.unpacked_location)
        if result.success?
          fixity_attempt.success!(result.value)
        else
          fixity_attempt.failure!(result.error)
        end
      end

      def fixity(bag_location)
        begin
          bag = DPN::Bagit::Bag.new(bag_location)
          Struct.new(success?: true, value: bag.fixity(:sha256))
        rescue RuntimeError, IOError => e
          Struct.new(success?: false, error: "#{e.message}\n#{e.stacktrace}")
        end
      end

    end
  end
end
