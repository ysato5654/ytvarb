#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'

require 'pp'

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
	Ytvarb.initialize(environment, video_id)

	youtube_comment = Ytvarb::YoutubeComment.new

	# get comment from youtube video
	unless youtube_comment.get
		return
	end

	# analyze youtube comment
	#youtube_comment.analyze

end

if $0 == __FILE__

	# DEBUG
	video_id = 'NypEG5G1EyM'

	youtube_video_analysis

end
