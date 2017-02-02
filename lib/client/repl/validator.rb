# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Validator

      class DefaultMethod
        Result = Struct.new(:valid?, :validation_errors)
        def self.validate_bag(location)
          bag = DPN::Bagit::Bag.new(location)
          Result.new(bag.valid?, bag.errors)
        end
      end

      Result = Struct.new(:success?, :bag_valid?, :validation_errors, :error)

      attr_reader :validate_attempt, :validate_method

      def initialize(validate_attempt, validate_method = DefaultMethod)
        @validate_attempt = validate_attempt
        @validate_method = validate_method
      end

      def validate
        result = validate_bag(validate_attempt.unpacked_location)
        if result.success?
          validate_attempt.success!(result.bag_valid?, result.validation_errors)
        else
          validate_attempt.failure!(result.error)
        end
      end

      private

      def validate_bag(bag_location)
        begin
          result = validate_method.validate_bag(bag_location)
          Result.new(true, result.valid?, result.validation_errors, nil)
        rescue RuntimeError, IOError, SystemCallError => e
          Result.new(false, nil, nil, "#{e.message}\n#{e.backtrace}")
        end
      end

    end
  end
end
