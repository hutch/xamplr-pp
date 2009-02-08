#!/usr/local/bin/ruby
require "xampl-pp-wf"
#require "xampl-pp"

class Chew

	def resolve(name)
		@resolveRequest = true
#		if not @xpp.standalone then
#			# for the purposes of conformance, accept this since we don't
#			# know if the external subset defines something
#			return "fake it"
#		else
#			return nil
#		end
	end

	def run
		@allFiles = File.new ARGV[1]

		while true do
			fileName = @allFiles.gets
			if nil == fileName then
				break
			end
			fileName.chop!

			@xpp = Xampl_PP.new
			@xpp.input = File.new(fileName)
@xpp.resolver = self
@resolveRequest = false
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
				#print message.backtrace.join("\n")
				if @resolveRequest then
					printf("ENTITY [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
				else
					printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
				end
			rescue Exception => message
				#print message.backtrace.join("\n")
				if @resolveRequest then
					printf("ENTITY [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
				else
					printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, fileName)
				end
			end
		end
	end
end

chew = Chew.new
chew.run
