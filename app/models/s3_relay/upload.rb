module S3Relay
  class Upload

    include Mongoid::Document

    field :uuid
    field :user_id, type: Integer
    field :parent_type, type: String
    field :parent_id, type: Integer
    field :upload_type, type: String
    field :filename, type: String
    field :content_type, type: String
    field :state, type: String
    field :data, type: Hash, default: Hash.new
    field :pending_at, type: DateTime
    field :imported_at, type: DateTime

    belongs_to :parent, polymorphic: true, optional: true

    validates :uuid,         presence: true, uniqueness: true
    validates :upload_type,  presence: true
    validates :filename,     presence: true
    validates :content_type, presence: true
    validates :pending_at,   presence: true

    after_initialize :finalize
    after_create :notify_parent

    def self.pending
      where(state: "pending")
    end

    def self.imported
      where(state: "imported")
    end

    def pending?
      state == "pending"
    end

    def imported?
      state == "imported"
    end

    def mark_imported!
      update_attributes(state: "imported", imported_at: Time.now)
    end

    def notify_parent
      return unless parent.present?

      if parent.respond_to?(:import_upload)
        parent.import_upload(id)
      end
    end

    def public_url
      S3Relay::PrivateUrl.new(uuid, filename).public_url
    end

    def private_url
      S3Relay::PrivateUrl.new(uuid, filename).generate
    end

    private

    def finalize
      self.state      ||= "pending"
      self.pending_at ||= Time.now
    end

  end
end
