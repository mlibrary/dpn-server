# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Fabricator(:replication_flow) do
  replication_id { SecureRandom.uuid }
  link { Faker::Internet.url }
  from_node { Faker::Internet.password(10, 20) }
  bag { SecureRandom.uuid }
end