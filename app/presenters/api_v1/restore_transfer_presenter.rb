
module ApiV1
  class RestoreTransferPresenter
    def initialize(restore)
      @restore = restore
    end

    def to_hash
      hash = {
          :restore_id => @restore.id,
          :from_node => @restore.from_node.namespace,
          :to_node => @restore.to_node.namespace,
          :uuid => @restore.bag.uuid,
          :protocol => @restore.protocol.name,
          :status => @restore.restore_status.name,
          :link => @restore.link,
          :created_at => @restore.created_at,
          :updated_at => @restore.updated_at
      }
      return hash
    end

    def to_json
      return self.to_hash.to_json
    end

    private
    attr_reader :restore
  end
end