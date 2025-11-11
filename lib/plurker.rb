# frozen_string_literal: true

require 'json'
require 'time'

# For Plurk API errors
class PlurkApiError < StandardError
end

# Class that actually does the plurking.
class Plurker
  ERROR_KEY = 'error_text'

  def initialize(periods:)
    @periods = periods
  end

  def do_plurk(client)
    now = Time.now

    period = period_of(now)
    unless period
      puts 'Current time is not within any period.'
      return
    end

    since = since_period_start(period, now)

    res = client.get('/APP/Timeline/getPlurks?filter=my&limit=1')
    json = JSON.parse(res.body)
    check_error(json)

    last_plurk_time_str = json['plurks'].first&.dig('posted')

    # Could be nil if user has never posted before.
    if last_plurk_time_str
      last_plurk_time = Time.parse(last_plurk_time_str)
      if now - last_plurk_time <= since
        puts 'Already plurked within this period.'
        return
      end
    end

    msg = period.msg

    puts "Plurking #{msg} ..."

    res = client.post('/APP/Timeline/plurkAdd', content: msg, qualifier: '')

    json = JSON.parse(res.body)
    check_error(json)

    puts res.body
  end

  private

  # Plurk API calls don't seem to generate proper HTTP error codes when they fail. Instead there is an error_text field in the JSON result. So we check for that instead.
  def check_error(json_resp)
    raise PlurkApiError, json_resp[ERROR_KEY] if json_resp.key?(ERROR_KEY)
  end

  def period_of(time)
    hour = time.hour
    @periods.each { |period|
      hstart = period.start
      hend = period.end
      within_period = if hstart > hend
                        # This is for the period that spans midnight.
                        hour >= hstart || hour < hend
                      else
                        hour >= hstart && hour < hend
                      end
      return period if within_period
    }
    nil
  end

  def since_period_start(period, time)
    date = time.to_date
    hstart = period.start
    period_start = Time.new(date.year, date.month, date.day, hstart)
    if period_start > time
      date -= 1
      period_start = Time.new(date.year, date.month, date.day, hstart)
    end
    time - period_start
  end
end

__END__
