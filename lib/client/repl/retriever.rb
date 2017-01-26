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
        result = rsync(source_location, staging_location)
        if result.success?
          retrieval_attempt.success!
        else
          retrieval_attempt.failure!(result.error)
        end
      end

      def source_location
        retrieval_attempt.link
      end

      # /dpnrepo/production/download_temp/from_node/bag
      def staging_location
        File.join(
          Rails.configuration.staging_dir.to_s,
          retrieval_attempt.from_node,
          retrieval_attempt.bag
        )
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
