# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class FixityGenerator

      class DefaultMethod
        def self.sha256(location)
          DPN::Bagit::Bag.new(location).fixity(:sha256)
        end
      end

      Result = Struct.new(:success?, :value, :error)

      attr_reader :fixity_attempt, :fixity_method

      def initialize(fixity_attempt, fixity_method = DefaultMethod)
        @fixity_attempt = fixity_attempt
        @fixity_method = fixity_method
      end

      def generate
        result = fixity(fixity_attempt.unpacked_location)
        if result.success?
          fixity_attempt.success!(result.value)
        else
          fixity_attempt.failure!(result.error)
        end
      end

      private

      def fixity(bag_location)
        begin
          Result.new(true, fixity_method.sha256(bag_location), nil)
        rescue RuntimeError, IOError, SystemCallError => e
          Result.new(false, nil, "#{e.message}\n#{e.backtrace}")
        end
      end

    end
  end
end
