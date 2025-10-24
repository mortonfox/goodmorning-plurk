# frozen_string_literal: true

require 'hocon'

# Config file manager
class Config
  PlurkApi = Data.define(:consumer_key, :consumer_secret) do
    def initialize(consumer_key:, consumer_secret:)
      %w[consumer_key consumer_secret].each { |f|
        raise "'#{f}' field is required in plurk_api section" if binding.local_variable_get(f).nil?
      }

      super(consumer_key:, consumer_secret:)
    end
  end

  PeriodRec = Data.define(:start, :end, :msg) do
    def initialize(start:, end:, msg:)
      %w[start end msg].each { |f|
        raise "'#{f}' field is required in period item" if binding.local_variable_get(f).nil?
      }

      super(start:, end:, msg:)
    end
  end

  def load_config(fname)
    raise "Config file #{fname} not found or not readable" unless File.readable?(fname)

    config = Hocon.load(fname)

    @plurkapi = PlurkApi.new(
      **%w[consumer_key consumer_secret].to_h { |f| [f.to_sym, config.dig('plurk_api', f)] }
    )

    @periods = Array(config['periods']).map { |period|
      PeriodRec.new(
        **%w[start end msg].to_h { |f| [f.to_sym, period[f]] }
      )
    }

    self
  end

  attr_reader :plurkapi, :periods
end

if $PROGRAM_NAME == __FILE__
  config_fname = File.expand_path('~/.gmplurk.conf')

  config = Config.new.load_config(config_fname)
  pp config
  pp config.plurkapi
  pp config.periods
end

__END__
