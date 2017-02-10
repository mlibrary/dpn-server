# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe StoreAttempt do
  it_behaves_like "an attempt", [:bag, :staging_location, :unpacked_location] do
    let(:fabricator) { :store_attempt }
    let(:success_args) { [] }
    let(:failure_args) { [] }
  end
end
