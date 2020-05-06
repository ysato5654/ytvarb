#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'

require File.expand_path(File.dirname(__FILE__) + '/../lib/ytvarb')

DEFAULT_ENVIRONMENT = 'production'

def youtube_video_analysis
	opt = OptionParser.new

	params = Hash.new

	opt.on('-g', '--get', 'get comments from desired video') { |v| params[:get] = v }
	opt.on('-a', '--analyze', 'analyze desired video comments') { |v| params[:analyze] = v }
	opt.on('-e [VAL]', '--environment [VAL]', 'environment (default: production)') { |v| params[:environment] = v }
	opt.on('-v [VAL]', '--video_id [VAL]', 'video id') { |v| params[:video_id] = v }

	begin
		opt.parse(ARGV)
	rescue SystemExit => e
		return
	rescue Exception => e
		#e.class
		# => OptionParser::InvalidOption

		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{e}"
		return
	end

	environment = params.key?(:environment) ? params[:environment] : DEFAULT_ENVIRONMENT
	video_id = params.key?(:video_id) ? params[:video_id] : ''

	environment = '' unless Ytvarb::ENVIRONMENT.include?(environment)

	# check option - environment
	if environment.nil? or environment.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		return
	end

	# check option - video id
	if video_id.nil? or video_id.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		return
	end

	# check option - execution type
	if params[:get].nil? and params[:analyze].nil?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		return
	end

	# initialize
	begin
		Ytvarb.initialize(environment, video_id)
	rescue Exception => e
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: ytvarb initialize error: #{e.message}"
		return
	end

	youtube_comment = Ytvarb::YoutubeComment.new

	# get comment from youtube video
	if params[:get]
		STDOUT.print "get youtube comment"

		begin
			youtube_comment.get
		rescue Ytvarb::ApiFormatError => e
			STDOUT.puts
			STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{e}: need to contact the ytvarb developers"
			return
		rescue Exception => e
			STDOUT.puts
			STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{e.class}: #{e.message}"
			return
		end

		STDOUT.puts
	end

	# analyze youtube comment
	if params[:analyze]
		unless youtube_comment.analyze
			return
		end
	end

end

if $0 == __FILE__

	youtube_video_analysis

end
