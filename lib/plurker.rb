# frozen_string_literal: true

require 'json'
require 'time'
require 'yaml'

# Class that actually does the plurking.
class Plurker
  def initialize(conf_file:)
    @conf_file = File.expand_path(conf_file)

    load_config
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
    last_plurk_time_str = json['plurks'].first&.dig('posted')

    # Could be nil if user has never posted before.
    if last_plurk_time_str
      last_plurk_time = Time.parse(last_plurk_time_str)
      if now - last_plurk_time <= since
        puts 'Already plurked within this period.'
        return
      end
    end

    msg = period['msg']

    puts "Plurking #{msg} ..."

    res = client.post('/APP/Timeline/plurkAdd', content: msg, qualifier: '')
    puts res.body
  end

  private

  def load_config
    config = YAML.load_file(@conf_file)

    raise "periods section is missing from configuration file #{@conf_file}" unless config.key?('periods')

    @periods = config['periods']
  end

  def period_of(time)
    hour = time.hour
    @periods.each { |period|
      hstart = period['start']
      hend = period['end']
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
    hstart = period['start']
    period_start = Time.new(date.year, date.month, date.day, hstart)
    if period_start > time
      date -= 1
      period_start = Time.new(date.year, date.month, date.day, hstart)
    end
    time - period_start
  end
end

__END__
