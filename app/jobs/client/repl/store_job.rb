# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl

    class StoreJob < ActiveJob::Base
      queue_as :repl_store

      def perform(store_attempt)
        Storer.new(store_attempt).store
      end

    end
  end
end
