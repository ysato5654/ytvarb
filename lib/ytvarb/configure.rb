#! /opt/local/bin/ruby
# coding: utf-8

module Ytvarb
	module Configure
		CONFIG = [
			:environment, 
			:api_key, 
			:client_id, 
			:client_secret, 
			:time_zone, 
			:year, 
			:month, 
			:day, 
			:video_id
		].freeze

		attr_accessor(*CONFIG)

		def self.extended(base)
			base.reset
		end

		def configure
			yield self
		end

		def reset
			self.environment   = ''
			self.api_key       = ''
			self.client_id     = ''
			self.client_secret = ''
			self.time_zone     = 'Tokyo'
			self.year          = ''
			self.month         = ''
			self.day           = ''
			self.video_id      = ''
			self
		end
	end
end
