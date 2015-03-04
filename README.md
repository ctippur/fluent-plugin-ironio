# Fluent::Plugin::NewRelic

fluent-plugin-ironio is an input plug-in for [Fluentd](http://fluentd.org)

## Installation

These instructions assume you already have fluentd installed. 
If you don't, please run through [quick start for fluentd] (https://github.com/fluent/fluentd#quick-start)

Now after you have fluentd installed you can follow either of the steps below:

Add this line to your application's Gemfile:

    gem 'fluent-plugin-ironio'

Or install it yourself as:

    $ gem install fluent-plugin-ironio

## Usage
Add the following into your fluentd config.

    <source>
      type ironio       # required, chossing the input plugin.
      endpoint       # Optional. 
      projectId # Needed for Ironio
      token # Needed for Ironio
      endpointQueue # Needed for Ironio
      endpointType # Example ironio, kinesis
      oauthId            # authorization key
      interval            # frequency to pull data
      readOnly # True or false to control deletion of message after it is read
    </source>

    <match alert.ironio>
      type stdout
    </match>

Now startup fluentd

    $ sudo fluentd -c fluent.conf &
    
Send a test trap using net-snmp tools
    
    $ cd test; rvmsudo ./ironmq.rb 
  
## To Do
    1. Change the logic to do a get all call so we process a bunch of alerts at a time.
    2. Make delete configurable
