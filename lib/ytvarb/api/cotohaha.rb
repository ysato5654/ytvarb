#! /opt/local/bin/ruby
# coding: utf-8

require 'cotoha'

module Ytvarb
	module Api
		class Cotohaha
			attr_reader :response

			def initialize client_id, client_secret
				@response = Hash.new

				@client = Cotoha::Client.new(client_id: client_id, client_secret: client_secret)

				@client.create_access_token
			end

			def is_error?
				@response[:status] > 0
			end

			def sentiment sentence
				begin
					@response = @client.sentiment(sentence: sentence)

					recursive_symbolize_keys!(@response)

				rescue Exception => e
					message = e.message.split(/\s\-\s/).last.slice(1..-2)

					message.split(/\,\s/).each { |response|
						key = response.split('=>').first
						value = response.split('=>').last

						if key =~ /result/ and value =~ /\{\}/
							@response[:result] = {}
						elsif key =~ /message/
							@response[:message] = value
						elsif key =~ /status/
							@response[:status] = value.to_i
						else
							STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"
							exit(0)
						end
					}
				end
			end

			private
			def recursive_symbolize_keys! hash
				if hash.is_a? Hash
					hash.symbolize_keys!
					hash.values.each {|h| recursive_symbolize_keys! h}
				elsif hash.is_a? Array
					hash.map {|v| recursive_symbolize_keys! v}
				end

				hash
			end
		end
	end
end
