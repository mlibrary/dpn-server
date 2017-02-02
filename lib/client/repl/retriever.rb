# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Retriever

      attr_reader :retrieval_attempt, :transfer_method

      SSH_OPTIONS = [
        "-o BatchMode=yes",
        "-o ConnectTimeout=3",
        "-o ChallengeResponseAuthentication=no",
        "-o PasswordAuthentication=no",
        "-o UserKnownHostsFile=/dev/null",
        "-o StrictHostKeyChecking=no",
        "-i #{Rails.configuration.transfer_private_key}"
      ]

      RSYNC_OPTIONS = ["-a --partial -q -k --copy-unsafe-links -e 'ssh #{SSH_OPTIONS.join(" ")}' "]

      Result = Struct.new(:success?, :error)

      def initialize(retrieval_attempt, transfer_method = Rsync)
        @retrieval_attempt = retrieval_attempt
        @transfer_method = transfer_method
      end
      
      def retrieve
        result = transfer(retrieval_attempt.source_location, retrieval_attempt.staging_location)
        if result.success?
          retrieval_attempt.success!
        else
          retrieval_attempt.failure!(result.error)
        end
      end

      # returns a Result
      def transfer(source, destination)
        begin
          FileUtils.mkdir_p(destination) unless File.exist? destination
          transfer_method.run(source, destination, RSYNC_OPTIONS) do |result|
            result
          end
        rescue IOError, SystemCallError => e
          Result.new(false, "#{e.message}\n#{e.backtrace.join("\n")}")
        end
      end

    end
  end
end
