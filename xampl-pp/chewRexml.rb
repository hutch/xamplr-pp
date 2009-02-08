#!/usr/local/bin/ruby
require "rexml/sax2parser"
require "rexml/sax2listener"

	class RexmlListener
		include REXML::SAX2Listener

		attr :count, true

		def start_document
			@count += 1
		end
		def end_document
			@count += 1
		end
		def start_prefix_mapping prefix, uri
			@count += 1
		end
		def end_prefix_mapping prefix
			@count += 1
		end
		def start_element uri, localname, qname, attributes
			@count += 1
		end
		def end_element uri, localname, qname
			@count += 1
		end
		def characters text
			@count += 1
		end
		def processing_instruction target, data
			@count += 1
		end
		def doctype name, pub_sys, long_name, uri
			@count += 1
		end
		def attlistdecl content
			@count += 1
		end
		def elementdecl content
			@count += 1
		end
		def entitydecl content
			@count += 1
		end
		def notationdecl content
			@count += 1
		end
		def cdata content
			@count += 1
		end
		def xmldecl version, encoding, standalone
			@count += 1
		end
		def comment comment
			@count += 1
		end
	end


class Chew

	def run
		@allFiles = File.new ARGV[1]

		while true do
			filename = @allFiles.gets
			if nil == filename then
				break
			end
			filename.chop!

			begin
  			source_file = File.new(filename)
  			listener = RexmlListener.new
				listener.count = 0
				parser = REXML::SAX2Parser.new(source_file)
				parser.listen(listener)
				parser.parse
  			source_file.close
		
				printf("%sPASSED '%s' -- there were %d events\n", (("PASS" == ARGV[0])? " " : "#"), filename, listener.count)
			rescue RuntimeError => message
				#print message.backtrace.join("\n")
				printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
			rescue Exception => message
				#print message.backtrace.join("\n")
				begin
					printf("%sFAILED [%s] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), message, filename)
				rescue Exception => donotcare
					printf("%sFAILED [??] '%s'\n", (("FAIL" == ARGV[0])? " " : "#"), filename)
				end
			end
		end
	end
end

chew = Chew.new
chew.run
