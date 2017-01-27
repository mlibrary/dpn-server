# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Validator

      attr_reader :validate_attempt

      def initialize(validate_attempt)
        @validate_attempt = validate_attempt
      end

      def validate
        result = validate_bag(validate_attempt.unpacked_location)
        if result.success?
          validate_attempt.success!(result.validity, result.validation_errors)
        else
          validate_attempt.failure!(result.error)
        end
      end

      def validate_bag(bag_location)
        begin
          bag = DPN::Bagit::Bag.new(bag_location)
          Struct.new(success?: true, valid: bag.valid?, validation_errors: bag.errors)
        rescue RuntimeError, IOError => e
          Struct.new(success?: false, error: "#{e.message}\n#{e.stacktrace}")
        end
      end

    end
  end
end
