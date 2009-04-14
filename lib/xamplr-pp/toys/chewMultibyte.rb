#!/usr/local/bin/ruby
require "xppMultibyte"

class Chew

	def resolve(name)
		return "fake it"
	end

	def run
		@allFiles = File.new ARGV[1]

		while true do
			fileName = @allFiles.gets
			if nil == fileName then
				break
			end
			fileName.chop!

			@xpp = Xpp.new
			@xpp.input = File.new(fileName)
			@xpp.resolver = self
@xpp.processNamespace = false
@xpp.reportNamespaceAttributes = false
		
			begin
				i = 0
				while not @xpp.endDocument? do
					type = @xpp.nextEvent
					i += 1
				end
				printf("%sPASSED '%s' -- there were %d events\n", (("PASS" == ARGV[0])? " " : "#"), fileName, i)
			rescue RuntimeError => message
				printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
			rescue Exception => message
				printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
			end
		end
	end
end

chew = Chew.new
chew.run

