#!/usr/local/bin/ruby

pattern = Regexp.compile(".", nil, 'u')

for filename in ARGV do
	printf("file: %s\n", filename)
	file = File.new(filename)
	file.each do
	  | line |
		p = 0
		while true do
			line.index(pattern, p)
			if nil == $& then
				break;
			end
			p += $&.length
			$&.each_byte do
				| c |
				printf("%3x ", c)
			end
			printf("-- '%s'\n", $&);
		end
	end
end

def decode(s)
	r = 0
	$&.each_byte do
		| c |
		if c < 0x80 then
			r += c
		elsif
	end
end


  def encode(c)
    if utf8encode then
      if c < 0x80 then
        @textBuffer << c
       elsif c < 0x0800
         @textBuffer << ((c >> 6) | 0xC0)
         @textBuffer << (c & (0x3F | 0x80))
       elsif c < 0x10000
         @textBuffer << ((c >> 12) | 0xE0)
         @textBuffer << ((c >> 6) & (0x3F | 0x80))
         @textBuffer << (c & (0x3F | 0x80))
       else
         @textBuffer << ((c >> 18) | 0xF0)
         @textBuffer << ((c >> 12) & (0x3F | 0x80))
         @textBuffer << ((c >> 6) & (0x3F | 0x80))
         @textBuffer << (c & (0x3F | 0x80))
      end
    else
      @textBuffer << c
    end
  end

