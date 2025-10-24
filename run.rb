#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/cmdline'
require_relative 'lib/plurkapi'
require_relative 'lib/plurker'

options = Cmdline.new.parse_cmdline

client = PlurkAPI.new(
  force_login: options.force_login,
  token_file: options.token_file,
  config_file: options.config_file
)

Plurker.new(config_file: options.config_file).do_plurk(client)

__END__
