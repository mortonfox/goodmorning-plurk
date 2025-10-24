# frozen_string_literal: true

require 'optparse'

# Parse cmdline arguments
class Cmdline
  DEFAULT_TOKEN_FILE = '~/.gmplurk.token'
  DEFAULT_CONFIG_FILE = '~/.gmplurk.conf'

  DEFAULT_OPTIONS = {
    token_file: DEFAULT_TOKEN_FILE,
    config_file: DEFAULT_CONFIG_FILE,
    force_login: false
  }.freeze

  Options = Struct.new(*DEFAULT_OPTIONS.keys)

  def parse_cmdline
    options = Options.new(**DEFAULT_OPTIONS)

    opts = OptionParser.new

    opts.banner = <<~BANNER
      Post good morning, good afternoon, etc, to Plurk depending on time of day.

      Usage: #{File.basename($PROGRAM_NAME)} [options]"
    BANNER

    opts.separator('')

    opts.on('-h', '-?', '--help', 'Show this help.') {
      puts opts
      exit
    }

    opts.on('-l', '--login', 'Ignore saved token and force a new login') {
      options.force_login = true
    }

    opts.on('--token-file=FILENAME', "Set name of token file. Default: #{DEFAULT_TOKEN_FILE}") { |fname|
      options.token_file = fname
    }

    opts.on('--config-file=FILENAME', "Set name of config file. Default: #{DEFAULT_CONFIG_FILE}") { |fname|
      options.config_file = fname
    }

    begin
      opts.parse!
    rescue StandardError => e
      warn "Error from option parser: #{e}\n\n#{opts}"
      exit 1
    end

    options
  end
end

__END__
