#!/usr/local/bin/ruby
require "xampl-pp"

class Listener

	attr :count, false

	def parse(filename)
		@xpp = Xampl_PP.new
		@xpp.input = File.new(filename)

		@count = 0

#printf("__________________________________")
		while not @xpp.endDocument? do
			event = @xpp.nextEvent
if(0 == (@count % 10001)) then
  printf("count: %d\n", count)
end
#printf("\nEVENT: %s\n", event)
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

for filename in ARGV do
	listener = Listener.new
	listener.parse(filename)

	printf("EVENTS: %d\n", listener.count)
end



