class ReplicationFlowsGrid
  include Datagrid

  scope do
    ReplicationFlow.includes(*[
      :retrieval_attempts, :unpack_attempts,
      :validate_attempts, :fixity_attempts,
      :received_notify_attempts, :store_attempts,
      :stored_notify_attempts
    ]).order(:id)
  end

  column(:id)
  column(:from_node, header: "From")
  column(:replication_id, header: "Replication")
  column(:bag)
  column(:r?) {|flow| flow.retrieved? }
  column(:ro?) {|flow| flow.retrieval_ongoing? }
  column(:u?) {|flow| flow.unpacked? }
  column(:uo?) {|flow| flow.unpack_ongoing? }
  column(:v?) {|flow| flow.validated? }
  column(:vo?) {|flow| flow.validate_ongoing? }
  column(:f?) {|flow| flow.fixity_complete? }
  column(:fo?) {|flow| flow.fixity_ongoing? }
  column(:rn?) {|flow| flow.received_notified? }
  column(:rno?) {|flow| flow.received_notify_ongoing? }
  column(:s?) {|flow| flow.stored? }
  column(:so?) {|flow| flow.store_ongoing? }
  column(:sn?) {|flow| flow.stored_notified? }
  column(:sno?) {|flow| flow.stored_notify_ongoing? }

  ["retrieval", "unpack", "validate", "fixity",
    "received_notify", "store", "stored_notify"].each do |t|
    column("#{t}_attempts".to_sym, header: t.capitalize) do |flow|
      flow.public_send("#{t}_attempts".to_sym).order(:id).pluck(:id)
    end
  end
end
