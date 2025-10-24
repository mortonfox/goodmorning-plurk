# frozen_string_literal: true

require 'launchy'
require 'json'
require 'oauth'
require 'yaml'

# Wrapper for Plurk API
class PlurkAPI
  def initialize(token_file:, config_file:, force_login: false)
    @token_file = File.expand_path(token_file)
    @config_file = File.expand_path(config_file)

    load_config

    @consumer = OAuth::Consumer.new(
      @consumer_key, @consumer_secret,
      site: 'https://www.plurk.com',
      scheme: :header,
      http_method: :post,
      request_token_path: '/OAuth/request_token',
      access_token_path: '/OAuth/access_token',
      authorize_path: '/OAuth/authorize'
    )

    @token = nil
    load_token unless force_login

    # If the token file cannot be read or the force_login parameter is true,
    # authenticate with Plurk to get a new access token.
    login if @token.nil?
  end

  def get(*)
    @token.get(*)
  end

  def post(*)
    @token.post(*)
  end

  private

  def load_token
    File.open(@token_file) { |io|
      token_hash = JSON.parse(io.read)
      @token = OAuth::AccessToken.new(
        @consumer,
        token_hash['token'],
        token_hash['secret']
      )
    }
  rescue StandardError
    nil
  end

  def load_config
    config = YAML.load_file(@config_file)

    raise "plurk_api section is missing from configuration file #{@config_file}" unless config.key?('plurk_api')

    plurk_api = config['plurk_api']

    %w[consumer_key consumer_secret].each { |key|
      raise "#{key} is missing from configuration file #{@config_file}" unless plurk_api.key?(key)

      instance_variable_set("@#{key}", plurk_api[key])
    }
  end

  def login
    request_token = @consumer.get_request_token
    url = request_token.authorize_url
    Launchy.open(url)

    print 'Enter verifier code: '
    verifier = gets.strip

    @token = request_token.get_access_token(oauth_verifier: verifier)

    File.write(@token_file, { token: @token.token, secret: @token.secret }.to_json)
  end
end

__END__
