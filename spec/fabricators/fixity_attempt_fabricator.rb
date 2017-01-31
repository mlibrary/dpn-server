# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:fixity_attempt) do
  replication_flow { Fabricate(:replication_flow) }
  start_time { 2.hours.ago }
  end_time nil
  success nil
  value nil
  error nil
end