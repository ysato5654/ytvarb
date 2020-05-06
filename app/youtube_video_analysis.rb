#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'

require File.expand_path(File.dirname(__FILE__) + '/../lib/ytvarb')

DEFAULT_ENVIRONMENT = 'production'

def youtube_video_analysis
	opt = OptionParser.new

	params = Hash.new

	opt.on('-e [VAL]', '--environment [VAL]', 'environment (default: production)') { |v| params[:environment] = v }
	opt.on('-v [VAL]', '--video_id [VAL]', 'video id') { |v| params[:video_id] = v }

	opt.parse(ARGV)

	environment = params.key?(:environment) ? params[:environment] : DEFAULT_ENVIRONMENT
	video_id = params.key?(:video_id) ? params[:video_id] : ''

	environment = '' unless Ytvarb::ENVIRONMENT.include?(environment)

	if environment.nil? or environment.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		return
	end

	if video_id.nil? or video_id.empty?
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
	begin
		unless youtube_comment.get
			return
		end
	rescue Exception => e
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{e}: need to contact the ytvarb developers"
		return
	end

	# analyze youtube comment
	unless youtube_comment.analyze
		return
	end

end

if $0 == __FILE__

	youtube_video_analysis

end
