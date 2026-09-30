class Availability
  SLOT = 15.minutes

  def initialize(stylist:, date:, duration:)
    @stylist = stylist
    @date = date
    @duration = duration
  end

  def open_slots
    window = SalonDay.hours_on(@date) or return []
    busy = @stylist.appointments.booked.on(@date).map { |a| a.starts_at...a.ends_at }

    starts_within(window).reject do |start|
      busy.any? { |range| overlaps?(start...(start + @duration), range) }
    end
  end

  private

  def starts_within(window)
    Enumerator.produce(window.begin) { |t| t + SLOT }
              .take_while { |t| t + @duration <= window.end }
  end

  def overlaps?(a, b)
    a.begin < b.end && b.begin < a.end
  end
end
