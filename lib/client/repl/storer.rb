# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Storer
      def initialize(attempt)
        @attempt = attempt
      end

      def store
        result = store_bag
        if result.success?
          attempt.success!
        else
          attempt.failure!(result.error)
        end
      end

      private

      attr_reader :attempt
      RSYNC_OPTIONS = ["-r -k --partial -q --copy-unsafe-links"]

      def store_bag
        begin
          pairtree = Pairtree.at(Rails.configuration.repo_dir, create: true)
          ppath = pairtree.mk(attempt.bag)
          rsync(File.join(attempt.unpacked_location, "*"), ppath.path)
        rescue IOError, SystemCallError => e
          Struct.new(success?: false, error: "#{e.message}\n#{e.backtrace}")
        end
      end


      def rsync(source, destination)
        Rsync.run(source, destination, RSYNC_OPTIONS) do |result|
          result
        end
      end

    end
  end
end
