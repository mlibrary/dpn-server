class ReplicationTransfersGrid
  include Datagrid


  def self.bag_man_request_status(bag_man_request)
    return nil if bag_man_request.nil?
    if bag_man_request.cancelled?
      "cancelled(#{bag_man_request.cancel_reason})"
    else
      bag_man_request.last_step_completed
    end
  end


  scope do
    ReplicationTransfer
      .includes(:bag_man_request)
      .includes(:bag)
      .where(to_node: Node.local_node!)
      .order(:id)
  end

  filter(:id, :integer)
  filter(:created_at, :date, :range => true)

  column(:id)

  column(:from_node, header: "From") do |asset|
    asset.from_node.namespace
  end

  column(:bag, header: "Bag") do |asset|
    asset.bag.uuid
  end

  column(:status, header: "Status") do |asset|
    if asset.cancelled?
      "cancelled(#{asset.cancel_reason})"
    elsif asset.stored?
      "stored"
    elsif asset.store_requested?
      "store requested"
    elsif asset.fixity_value.blank? == false
      "fixity set"
    else
      "requested"
    end
  end

  column(:bm_id, header: "bm_id") do |asset|
    asset.bag_man_request&.id
  end

  column(:bm_status, header: "bm_status") do |asset|
    bag_man_request_status(asset.bag_man_request)
  end

  column(:bm_err, header: "bm_err") do |asset|
    asset.bag_man_request&.last_error&.slice(0..50)
  end




end
