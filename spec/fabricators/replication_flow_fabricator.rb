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

Fabricator(:retrieved_replication_flow, class_name: :replication_flow) do
  initialize_with do
    Fabricate(:retrieval_attempt, success: true, end_time: Time.now).replication_flow
  end
end

Fabricator(:unpack_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:retrieved_replication_flow)
    flow.unpack_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil)
    flow
  end
end
Fabricator(:unpacked_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:retrieved_replication_flow)
    flow.unpack_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true)
    flow
  end
end

Fabricator(:validate_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:unpacked_replication_flow)
    flow.validate_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil)
    flow
  end
end
Fabricator(:validated_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:unpacked_replication_flow)
    flow.validate_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true, bag_valid: true)
    flow
  end
end

Fabricator(:fixity_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:validated_replication_flow)
    flow.fixity_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil, value: nil)
    flow
  end
end
Fabricator(:fixity_complete_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:validated_replication_flow)
    flow.fixity_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true, value: "somefixity")
    flow
  end
end

Fabricator(:received_notify_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:fixity_complete_replication_flow)
    flow.received_notify_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil)
    flow
  end
end
Fabricator(:received_notified_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:fixity_complete_replication_flow)
    flow.received_notify_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true)
    flow
  end
end

Fabricator(:store_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:received_notified_replication_flow)
    flow.store_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil)
    flow
  end
end
Fabricator(:stored_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:received_notified_replication_flow)
    flow.store_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true)
    flow
  end
end

Fabricator(:stored_notify_ongoing_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:stored_replication_flow)
    flow.stored_notify_attempts.create!(start_time: 1.hour.ago, end_time: nil, success: nil)
    flow
  end
end
Fabricator(:stored_notified_replication_flow, class_name: :replication_flow) do
  initialize_with do
    flow = Fabricate(:stored_replication_flow)
    flow.stored_notify_attempts.create!(start_time: 1.hour.ago, end_time: Time.now, success: true)
    flow
  end
end