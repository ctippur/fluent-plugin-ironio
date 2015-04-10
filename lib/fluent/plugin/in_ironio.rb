module Fluent

# Read  trap messages as events in to fluentd
  class IronioInput < Input
    Fluent::Plugin.register_input('ironio', self)

    # Define default configurations
    config_param :tag, :string, :default => "alert.ironio"
    config_param :endpoint, :string, :default => "" # Optional
    config_param :projectId, :string, :default => ""
    config_param :token, :string, :default => ""
    config_param :endpointType, :string, :default => "ironio"
    config_param :oauthId, :string, :default => ""
    config_param :endpointQueue, :string, :default => ""
    config_param :interval, :string, :default => "5"
    config_param :readOnly, :string, :default => "true"


    # Initialize and bring in dependencies
    def initialize
      super
      require 'json'
      require 'daemons'
      require 'iron_mq'
      require 'pp'
    end # def initialize

    # Load internal and external configs
    def configure(conf)
      super
      @conf = conf
      # TO DO Add code to choke if config parameters are not there
    end # def configure
    
    def start
      super
      @loop = Coolio::Loop.new
      timer_trigger = TimerWatcher.new(@interval, true, &method(:input))
      timer_trigger.attach(@loop)
      @thread = Thread.new(&method(:run))
      $log.info "starting ironio poller, interval #{@interval}"
    end

    # Stop Listener and cleanup any open connections.
    def shutdown
      super
      @loop.stop
      @thread.join
    end

    def run
      @loop.run
      $log.info "Running Ironio Input"
    end

    # Start SNMP Trap listener
    def input
        @ironmq = IronMQ::Client.new(token: @token, project_id: @projectId) # do |event|
        # Get a Queue object
        @queue = @ironmq.queue(@endpointQueue)
  
        # Put a message on the queue
	#msg = @queue.post("hello world!")

	# Get a message
	msg = @queue.get()

	# Convert to a proper json
	#rawMsg=CGI::unescape(msg.raw.to_json).gsub(/"alert=/,'').gsub(/}","timeout/, '},"timeout')
	#rawMsg=CGI::unescape(jsonhtmlencodedraw).gsub(/"alert=/,'').gsub(/}","timeout/, '},"timeout')

	# Convert to hash
	#jsonhtmlencodedraw=JSON.parse(rawMsg, :quirks_mode => false) # => "50's & 60's"
	jsonhtmlencodedraw=JSON.parse(URI.decode((msg.body.split("="))[1]))
	#argosHash=Hash.new {}
	#argosHash['newraw']=jsonhtmlencodedraw
	# Add raw json
	jsonhtmlencodedraw.merge!('newraw'=>URI.decode((msg.body.split("="))[1]))

	#jsonhtmlencodedraw.store('newraw', jsonhtmlencodedraw)
	#pp argosHash

	# Add evet_type, intermediary_source, received_time

	#tag = @tag 
	timestamp = Engine.now # Should be received_time_input

	jsonhtmlencodedraw['receive_time_input']=timestamp.to_s
	jsonhtmlencodedraw['event_type']=@tag.to_s
	jsonhtmlencodedraw['intermediary_source']=jsonhtmlencodedraw['alert_url']
	#jsonhtmlencodedraw.each do |key, value|
	#	jsonhtmlencodedraw[:key]='"' + value + '"'
	#end

	$log.info "Incoming message  #{jsonhtmlencodedraw}"
	# Try catch
	#record = {"value"=> jsonhtmlencodedraw,  argosHash.to_json,"tags"=>{"type"=>"alert","application_name"=>jsonhtmlencodedraw["body"]["application_name"]}}
	begin
		#Engine.emit('"' + @tag.to_s + '"', '"' + timestamp.to_s + '"' , jsonrawstr)
		Engine.emit( @tag.to_s ,  timestamp.to_i , jsonhtmlencodedraw)
	rescue Exception => e
		puts e.message 
		puts e.backtrace.inspect
	end

	# Delete the message. Make this configurable
	if @readOnly == "false" 
	  res = msg.delete # or @queue.delete(msg.id)
        end
    end # def Input

  end # End Input class

  class TimerWatcher < Coolio::TimerWatcher
	def initialize(interval, repeat, &callback)
	  @callback = callback
	  super(interval, repeat)
	end

	def on_timer
	  @callback.call
	end
  end

end # module Fluent

