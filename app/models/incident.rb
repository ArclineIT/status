# Something that went wrong, told as a series of updates.
class Incident < ApplicationRecord
  STATUSES = %w[ investigating identified monitoring resolved ].freeze
  SEVERITIES = %w[ minor major critical ].freeze
  HISTORY_WINDOW = 90.days

  has_many :updates, -> { order(posted_at: :desc, id: :desc) }, class_name: "IncidentUpdate", dependent: :destroy

  normalizes :title, with: ->(title) { title.to_s.strip }

  validates :title, :started_at, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :severity, inclusion: { in: SEVERITIES }

  scope :active, -> { where.not(status: "resolved").order(started_at: :desc) }
  scope :history, ->(now = Time.current) { where(status: "resolved", started_at: (now - HISTORY_WINDOW)..).order(started_at: :desc) }
  scope :recent, -> { order(started_at: :desc) }

  # Opens an incident with its first update.
  def self.open!(title:, severity:, body:, status: "investigating", started_at: Time.current)
    transaction do
      create!(title: title, severity: severity, status: status, started_at: started_at).tap do |incident|
        incident.updates.create!(status: status, body: body, posted_at: started_at)
      end
    end
  end

  def resolved? = status == "resolved"

  # Posts an update and moves the incident to the update's status.
  def post_update!(status:, body:, posted_at: Time.current)
    transaction do
      update = updates.create!(status: status, body: body, posted_at: posted_at)
      update!(status: status, resolved_at: status == "resolved" ? posted_at : nil)
      update
    end
  end

  def duration
    (resolved_at || Time.current) - started_at
  end
end
