class IncidentUpdate < ApplicationRecord
  belongs_to :incident

  normalizes :body, with: ->(body) { body.to_s.strip }

  validates :body, :posted_at, presence: true
  validates :status, inclusion: { in: Incident::STATUSES }
end
