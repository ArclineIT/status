# Planned work. Its state follows the clock: scheduled, in progress, completed.
class Maintenance < ApplicationRecord
  normalizes :title, :body, with: ->(value) { value.to_s.strip }

  validates :title, :starts_at, :ends_at, presence: true
  validate :ends_after_it_starts

  scope :upcoming, ->(now = Time.current) { where(ends_at: now..).order(:starts_at) }
  scope :past, ->(now = Time.current) { where(ends_at: ...now).order(starts_at: :desc) }

  def status(now = Time.current)
    if now < starts_at then "scheduled"
    elsif now <= ends_at then "in_progress"
    else "completed"
    end
  end

  private
    def ends_after_it_starts
      errors.add(:ends_at, "must be after the start") if starts_at && ends_at && ends_at <= starts_at
    end
end
