#!/usr/local/bin/ruby
require "rexml/pullparser"

class Chew

	def run
		@allFiles = File.new ARGV[1]

		while true do
			filename = @allFiles.gets
			if nil == filename then
				break
			end
printf("FILE %s\n", filename)
			filename.chop!

			parser = REXML::PullParser.new(File.new(filename))
		
			begin
				i = 0
				while parser.has_next?
					res = parser.next
printf("Eventtype: %s\n", res.event_type)
					i += 1
				end
				printf("%sPASSED '%s' -- there were %d events\n", (("PASS" == ARGV[0])? " " : "#"), filename, i)
			rescue RuntimeError => message
				#print message.backtrace.join("\n")
				if @resolveRequest then
					printf("ENTITY [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
				else
					printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
				end
			rescue Exception => message
				#print message.backtrace.join("\n")
				if @resolveRequest then
					printf("ENTITY [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
				else
					printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
				end
			end
		end
	end
end

chew = Chew.new
chew.run
