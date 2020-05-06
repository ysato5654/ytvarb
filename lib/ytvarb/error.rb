#! /opt/local/bin/ruby
# coding: utf-8

module Ytvarb
	class NotFound < StandardError
		attr_reader :message

		def initialize file
			@message = 'No such file or directory' + ' - ' + file
		end
	end

	class ApiFormatError < StandardError; end
end
