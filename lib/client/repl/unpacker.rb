# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Unpacker

      attr_reader :unpack_attempt

      def initialize(unpack_attempt)
        @unpack_attempt = unpack_attempt
      end

      def unpack
        result = unpack_bag(unpack_attempt.staging_location)
        if result.success?
          unpack_attempt.success!(result.path)
        else
          unpack_attempt.failure!(result.error)
        end
      end

      # @param path [String] bag location
      # @return Result that responds to #success?
      def unpack_bag(path)
        return Struct.new(path: path, success?: true) if File.directory?(path)
        case File.extname path
        when ".tar"
          unpack_tar(path)
        else
          Struct.new(success?: false, error: "Unrecognized file type")
        end
      end

      # @param file [String] location of a serialized bag (.tar file)
      def unpack_tar(file)
        begin
          serialized_bag = DPN::Bagit::SerializedBag.new(file)
          bag = serialized_bag.unserialize!
          Struct.new(path: bag.location, success?: true)
        rescue RuntimeError, IOError => e
          Struct.new(success?: false, error: "#{e.message}\n#{e.stacktrace}")
        end
      end


    end
  end
end
