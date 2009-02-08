#!/usr/local/bin/ruby
require "xampl-pp-wf"

class Listener

	attr :count, false

	def parse(filename)
		@xpp = Xampl_PP.new
		@xpp.input = File.new(filename)

		@count = 0

		while not @xpp.endDocument? do
			event = @xpp.nextEvent
			case event
			#case @xpp.nextEvent
	      when Xampl_PP::START_DOCUMENT
					@count += 1
        when Xampl_PP::END_DOCUMENT
					@count += 1
        when Xampl_PP::START_ELEMENT
					@count += 1
        when Xampl_PP::END_ELEMENT
					@count += 1
        when Xampl_PP::TEXT
					@count += 1
        when Xampl_PP::CDATA_SECTION
					@count += 1
        when Xampl_PP::ENTITY_REF
					@count += 1
        when Xampl_PP::IGNORABLE_WHITESPACE
					@count += 1
        when Xampl_PP::PROCESSING_INSTRUCTION
					@count += 1
        when Xampl_PP::COMMENT
					@count += 1
        when Xampl_PP::DOCTYPE
					@count += 1
			end
		end
	end

end

start = Time.now
for filename in ARGV do
	listener = Listener.new
	listener.parse(filename)
	#printf("EVENTS: %d\n", listener.count)
end
puts "Time: #{Time.now - start}"



