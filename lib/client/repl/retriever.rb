# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class Retriever

      attr_reader :retrieval_attempt

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

      def initialize(retrieval_attempt)
        @retrieval_attempt = retrieval_attempt
      end
      
      def retrieve
        result = rsync(retrieval_attempt.source_location, retrieval_attempt.staging_location)
        if result.success?
          retrieval_attempt.success!
        else
          retrieval_attempt.failure!(result.error)
        end
      end

      # returns a Result
      def rsync(source, destination)
        FileUtils.mkdir_p(destination) unless File.exist? destination
        Rsync.run(source, destination, RSYNC_OPTIONS) do |result|
          result
        end
      end

    end
  end
end
