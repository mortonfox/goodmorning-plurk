#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/cmdline'
require_relative 'lib/config'
require_relative 'lib/plurkapi'
require_relative 'lib/plurker'

options = Cmdline.new.parse_cmdline

config = Config.new.load_config(options.config_file)

client = PlurkAPI.new(
  force_login: options.force_login,
  token_file: options.token_file,
  plurk_api: config.plurkapi
)

Plurker.new(periods: config.periods).do_plurk(client)

__END__
