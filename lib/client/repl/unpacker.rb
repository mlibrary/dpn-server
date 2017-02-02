# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Unpacker

      Result = Struct.new(:success?, :path, :error)

      class DefaultMethod
        Result = Struct.new(:success?, :bag, :error)

        # @raises RuntimeError, IOError, SystemCallError
        def self.unpack_tar(file)
          bag = DPN::Bagit::SerializedBag.new(file).unserialize!
          Result.new(true, bag, nil)
        end
      end

      attr_reader :unpack_attempt, :unpack_method

      def initialize(unpack_attempt, unpack_method = DefaultMethod)
        @unpack_attempt = unpack_attempt
        @unpack_method = unpack_method
      end

      def unpack
        result = unpack_bag(unpack_attempt.staging_location)
        if result.success?
          unpack_attempt.success!(result.path)
        else
          unpack_attempt.failure!(result.error)
        end
      end

      private

      # @param path [String] bag location
      # @return Result that responds to #success?
      def unpack_bag(path)
        return Result.new(true, path, nil) if File.directory?(path)
        case File.extname path
        when ".tar"
          safe_unpack { unpack_method.unpack_tar(path) }
        else
          Result.new(false, nil, "Unrecognized file type #{File.extname(path)}")
        end
      end

      # @param file [String] location of a serialized bag (.tar file)
      def safe_unpack(&block)
        begin
          result = block.call
          Result.new(result.success?, result.bag&.location, result.error)
        rescue RuntimeError, IOError, SystemCallError => e
          Result.new(false, nil, "#{e.message}\n#{e.backtrace}")
        end
      end


    end
  end
end
