#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/plurkapi'
require_relative 'lib/plurker'
require 'optparse'

DEFAULT_TOKEN_FILE = '~/.gmplurk.token'
DEFAULT_CONF_FILE = '~/.gmplurk.yml'

def parse_cmdline
  options = {}
  options[:force_login] = false
  options[:token_file] = DEFAULT_TOKEN_FILE
  options[:conf_file] = DEFAULT_CONF_FILE

  optp = OptionParser.new

  optp.banner = "Usage: #{$PROGRAM_NAME} [options]"

  optp.separator <<~ENDS

    Post good morning, good afternoon, etc, to Plurk depending on time of day.

  ENDS

  optp.on('-h', '-?', '--help', 'Option help') {
    puts optp
    exit
  }

  optp.on('-l', '--login', 'Ignore saved token and force a new login') {
    options[:force_login] = true
  }

  optp.on('--token-file=FILENAME', "Set name of token file. Default: #{DEFAULT_TOKEN_FILE}") { |fname|
    options[:token_file] = fname
  }

  optp.on('--conf-file=FILENAME', "Set name of config file. Default: #{DEFAULT_CONF_FILE}") { |fname|
    options[:conf_file] = fname
  }

  optp.parse!

  options
end

options = parse_cmdline

client = PlurkAPI.new(
  force_login: options[:force_login],
  token_file: options[:token_file],
  conf_file: options[:conf_file]
)

Plurker.new(conf_file: options[:conf_file]).do_plurk(client)

__END__
