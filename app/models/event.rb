class Event < ApplicationRecord
  scope :events_in_week, lambda { |date_min, date_max|
                           where(
                             starts_at: date_min..date_max
                           ).or(
                             where(weekly_recurring: true)
                             .where("starts_at <= ?", date_min)
                           )
                         }

  SLOT_DURATION = 30.minutes

  class << self
    def availabilities(date)
      date = date.to_datetime
      date_max = (date + 6.days).end_of_day
      availabilities = create_empty_week(date, date_max)

      events_in_week(date, date_max)
        .group_by do |a|
          # for recurring events : add the weeks offset to date
          a = event_with_offset(a, date_max) unless (date..date_max).cover?(a.starts_at)
          format_date(a.starts_at)
        end
        .each do |day, events_in_day|
          events = format_events(events_in_day)

          day_offset = (day.to_date - date.to_date).to_i
          availabilities[day_offset][:slots] = events[:openings]
                                               .flatten
                                               .difference(events[:appointments].flatten)
        end
      availabilities
    end

    private

    def event_with_offset(event, date_max)
      # computes how many weeks
      weeks_offset = ((date_max.to_datetime - event.starts_at.to_datetime).to_i / 7)
                     .weeks
      event.starts_at = event.starts_at + weeks_offset
      event.ends_at = event.ends_at + weeks_offset
      event
    end

    def format_date(event_datetime)
      event_datetime.to_date.strftime("%Y/%m/%d")
    end

    def create_empty_week(date_min, date_max)
      (date_min.to_i..date_max.to_i)
        .step(1.day)
        .map { |day| { date: format_date(Time.zone.at(day)), slots: [] } }
    end

    # returns the list of opening and appointments starting hours
    def format_events(events_in_day)
      events = { openings: [], appointments: [] }

      events_in_day.each do |event|
        events[event.kind.pluralize.to_sym] <<
          (event.starts_at.to_datetime.to_i..event.ends_at.to_datetime.to_i - 1)
          .step(SLOT_DURATION)
          .map { |s| Time.zone.at(s).strftime("%-k:%M") }
      end
      events
    end
  end
end
