# One thing customers depend on, such as "Shared Hosting" or "DNS".
class Component < ApplicationRecord
  STATUSES = {
    "operational" => "Operational", "degraded" => "Degraded performance", "outage" => "Outage", "maintenance" => "Under maintenance"
  }.freeze
  # Worst first, for working out the overall state.
  SEVERITY_ORDER = %w[ outage degraded maintenance operational ].freeze

  normalizes :name, with: ->(name) { name.to_s.strip }

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES.keys }

  scope :ordered, -> { order(:position, :name) }

  def status_label = STATUSES.fetch(status)

  # The worst status among the given components.
  def self.overall(components = all)
    components.map(&:status).min_by { |status| SEVERITY_ORDER.index(status) } || "operational"
  end
end
