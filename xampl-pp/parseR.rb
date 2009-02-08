#!/usr/local/bin/ruby
require "rexml/document"
require "rexml/streamlistener"


	class RexmlListener

		attr :count, true

		def initialize
			@count = 0
		end
		def tag_start name, attrs
			@count += 1
		end
		def tag_end name
			@count += 1
		end
		def text text
			@count += 1
		end
		def instruction name, instruction
			@count += 1
		end
		def comment comment
p comment
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
		def entity content
			@count += 1
		end
		def cdata content
			@count += 1
		end
		def xmldecl version, encoding, standalone
			@count += 1
		end
	end

for filename in ARGV do
  source_file = File.new(filename)



  listener = RexmlListener.new

  source = REXML::SourceFactory.create_from source_file
  REXML::Document.parse_stream source, listener
  #source_file.rewind

  source_file.close
	printf("EVENTS: %d\n", listener.count)
end


