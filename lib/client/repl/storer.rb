# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'pairtree'

module Client
  module Repl

    class Storer

      class DefaultMethod
        RSYNC_OPTIONS = ["-r -k --partial -q --copy-unsafe-links"]

        def self.store(source, uuid)
          pairtree = Pairtree.at(Rails.configuration.repo_dir, create: true)
          ppath = pairtree.mk(uuid)
          rsync(File.join(source, "*"), ppath.path)
        end

        def self.rsync(source, destination)
          Rsync.run(source, destination, RSYNC_OPTIONS) do |result|
            result
          end
        end
      end

      Result = Struct.new(:success?, :error)

      def initialize(attempt, store_method = DefaultMethod)
        @attempt = attempt
        @store_method = store_method
      end

      def store
        result = store_bag
        if result.success?
          attempt.success!
          FileUtils.remove_entry_secure attempt.staging_location
          FileUtils.remove_entry_secure attempt.unpacked_location
        else
          attempt.failure!(result.error)
        end
      end

      private

      attr_reader :attempt, :store_method

      def store_bag
        begin
          result = store_method.store(attempt.unpacked_location, attempt.bag)
          Result.new(result.success?, result.error)
        rescue IOError, SystemCallError => e
          Result.new(false, "#{e.message}\n#{e.backtrace}")
        end
      end
    end

  end
end
