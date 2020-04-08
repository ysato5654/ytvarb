#! /opt/local/bin/ruby
# coding: utf-8

require 'optparse'

require File.expand_path(File.dirname(__FILE__) + '/../lib/ytvarb')

class GetComment
	attr_reader :environment,
				:video_id

	DEFAULT_ENVIRONMENT = 'production'

	def initialize
		opt = OptionParser.new

		params = Hash.new

		opt.on('-e [VAL]', '--environment [VAL]', 'environment (default: production)') { |v| params[:environment] = v }
		opt.on('-v [VAL]', '--video_id [VAL]', 'video id') { |v| params[:video_id] = v }

		opt.parse(ARGV)

		@environment = params.key?(:environment) ? params[:environment] : DEFAULT_ENVIRONMENT
		@video_id = params.key?(:video_id) ? params[:video_id] : ''

		@environment = '' unless Ytvarb::ENVIRONMENT.include?(@environment)
	end

	def run
	end
end

if $0 == __FILE__
	get_comment = GetComment.new

	env = get_comment.environment

	if env.empty?
		STDERR.puts "#{__FILE__}:#{__LINE__}:Error: option error. usage is 'ruby #{File.basename(__FILE__)} --help'"
		exit(0)
	end

	# DEBUG
	video_id = 'NypEG5G1EyM'

	# initialize
	Ytvarb.initialize(env, video_id)

	max_results = 2
	next_page_token = ''

	comment_thread = Ytvarb::YoutubeDataApi::CommentThread.new(max_results)
	pp comment_thread.response

end
