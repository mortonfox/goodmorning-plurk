# gmplurk - Post good morning, afternoon, evening, night to Plurk

## Introduction

Gmplurk is a Ruby script that posts good morning, good afternoon, good
evening, goodnight, or any time-based phrases you configure (see [Config
file](#config-file) below) to [Plurk](https://www.plurk.com/).

## Installation

1. Run ``bundle install`` to install the required Ruby gems.
1. Set up the config file. (See [below](#config-file))

## Usage

```sh
$ bundle exec ruby run.rb -h
Usage: run.rb [options]

Post good morning, good afternoon, etc, to Plurk depending on time of day.

    -h, -?, --help                   Option help
    -l, --login                      Ignore saved token and force a new login
        --token-file=FILENAME        Set name of token file. Default: ~/.gmplurk.token
        --conf-file=FILENAME         Set name of config file. Default: ~/.gmplurk.yml
```

Run the script without any options, i.e. ``bundle exec ruby run.rb``, and it
will do its thing. If this is the first time you are using the script, it will
launch the Plurk login page in a browser so you can get an authentication
code.

## Config file

The gmplurk config file is a YAML file. By default, gmplurk will read
``.gmplurk.yml`` in your home directory for its configuration.

An example config file follows:

```yaml
plurk_api:
    consumer_key: KEY
    consumer_secret: SECRET
periods:
    -
        start: 21
        end: 3
        msg: Goodnight
    -
        start: 3
        end: 12
        msg: Good morning
    -
        start: 12
        end: 17
        msg: Good afternoon
    -
        start: 17
        end: 21
        msg: Good evening
```

KEY and SECRET need to be filled in with the app key and app secret from the
app that you set up in [My Plurk Apps](https://www.plurk.com/PlurkApp/).

* Go to My Plurk Apps and click on "Create a new Plurk App".
* At a minimum, fill in the app name, organization, website, and description.
* Click on "Register App". Plurk should take you back to My Plurk Apps.
* Click on "edit" for the app you just added. Then copy the app key and app
  secret to the config file.

The periods section in the config file sets up a list of time periods and the
message that will be posted to Plurk in each period. In the above example, the
script will post "Good morning" to Plurk at or after 3am and before noon. Note
that the start hour can be greater than the end hour if the time period
crosses midnight. In the above example, the script posts "Goodnight" from
9pm to 3am.
