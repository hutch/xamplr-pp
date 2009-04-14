
class Xpp
	# XML 'event' types
	START_DOCUMENT = 'START_DOCUMENT'
  END_DOCUMENT = 'END_DOCUMENT'
  START_ELEMENT = 'START_ELEMENT'
  END_ELEMENT = 'END_ELEMENT'
  TEXT = 'TEXT'
  CDATA_SECTION = 'CDATA_SECTION'
  ENTITY_REF = 'ENTITY_REF'
  IGNORABLE_WHITESPACE = 'IGNORABLE_WHITESPACE'
  PROCESSING_INSTRUCTION = 'PROCESSING_INSTRUCTION'
  COMMENT = 'COMMENT'
  DOCTYPE = 'DOCTYPE'
	LOOK_FURTHER = 'LOOK_FURTHER'

	# 'Features', acutally just processing options
	attr :processNamespace, true
	attr :reportNamespaceAttributes, true

	# the entities that we will recognise
	attr :entityMap, true
	attr :unresolvedEntity

	# some information about where we are
	attr :line
	attr :column

  # is the current text whitespace?
	attr :whitespace

	# element information
	attr :type
	attr :emptyElement
	attr :name
	attr :qname
	attr :namespace
	attr :prefix
	attr :attributeName
	attr :attributeQName
	attr :attributeNamespace
	attr :attributePrefix
	attr :attributeValue

	attr :text

	attr :elementNamespacePrefixStack
	attr :elementNamespaceValueStack
	attr :elementNamespaceDefaultStack

	# open element information
	attr :elementName
	attr :elementQName
	attr :elementNamespace
	attr :elementPrefix

	def startDocument?
		@type.equal? START_DOCUMENT
	end

	def endDocument?
		@type.equal? END_DOCUMENT
	end

	def startElement?
		@type.equal? START_ELEMENT
	end

	def endElement?
		@type.equal? END_ELEMENT
	end

	def text?
		@type.equal? TEXT
	end

	def cdata?
		@type.equal? CDATA_SECTION
	end

	def entityRef?
		@type.equal? ENTITY_REF
	end

	def ignorableWhitespace?
		@type.equal? IGNORABLE_WHITESPACE
	end

	def processingInstruction?
		@type.equal? PROCESSING_INSTRUCTION
	end

	def comment?
		@type.equal? COMMENT
	end

	def doctype?
		@type.equal? DOCTYPE
	end

	def lookFurther?
		@type.equal? LOOK_FURTHER
	end

	#def whitespace?
		#
		# What is this all about -- FIX
		#if text? or ignorableWhitespace? or cdata? then
			#return @whitespace
		#end
		#raise "illegal type for whitespace query"
	#end

	def input=(v)
		if nil == v then
			@input = nil
			@inputBuffer = nil
			@inputBufferLength = 0
		elsif v.kind_of? String then
			@input = nil
			@inputBuffer = v
			@inputBufferLength = v.length
		elsif v.kind_of? IO then
			@input = v
			@inputBuffer = nil
			@inputBufferLength = 0
		else
			raise "illegalInput"
		end
		@nextInputBuffer = nil
		@inputBufferPosition = 0
		@textBuffer = ''

		@line = 1
		@column = 0
		@compactNewLine = false

		@elementNamespacePrefixStack = []
		@elementNamespaceValueStack = []
		@elementNamespaceDefaultStack = []

		@elementName = []
		@elementQName = []
		@elementNamespace = []
		@elementPrefix = []

		@whitespace = true
		@type = START_DOCUMENT
		@unresolvedEntity = false

		@name = nil
		@namespace = nil

		@attributeName = []
		@attributeQName = []
		@attributeNamespace = []
		@attributePrefix = []
		@attributeValue = []

		@emptyElement = false
	end

	def nextEvent
		begin
			if (nil == @inputBuffer) and (nil == @input) then
				raise "no input defined"
			end

			@whitespace = true
			@unresolvedEntity = false

			@text = nil

			parseNextEvent

			return @type
		rescue RuntimeError => message
			if nil != @inputBuffer then
		  	message = sprintf("parse error: '%s' -- String input, line %d, column %d", message, @line, @column)
			elsif nil != @input then
				if @input.kind_of? File then
	  			message = sprintf("parse error: '%s' -- file '%s', line %d, column %d", message, @input.path, @line, @column)
				else
	  			message = sprintf("parse error: '%s' -- unnamed IO stream, line %d, column %d", message, @line, @column)
				end
			else
	  		message = sprintf("parse error: '%s' -- unknown source, line %d, column %d", message, @line, @column)
			end
			raise message
		end
	end

private
	def initialize
		self.processNamespace = true
		self.reportNamespaceAttributes = false

		self.input = nil

		self.entityMap = {"amp"=>"&",
                      "apos"=>"'",
                      "gt"=>">",
                      "lt"=>"<",
                      "quot"=>"\""}
	end

	def expect(e)
		c = read
		if (nil == c) or (c != e) then
			msg = sprintf("unexpectedChar:: expect '%s' got '%s'\n", (''<<e), (''<<c))
			raise msg
		end
		return c
	end

	def read
	  # This is consumes the first thing in the peek buffer.

		result = readFromInput

		if result == ?\n then
			# counting newlines for line count... not great for the mac
			@line += 1
			@column = 1
		else
			@column += 1
		end

		return result
	end

	def readFromInput
		if (nil == @inputBuffer) or (@inputBufferLength <= @inputBufferPosition) then
			getMoreInput
		end

		if nil != @inputBuffer then
			c = @inputBuffer[@inputBufferPosition]
			@inputBufferPosition += 1
			return c
		else
			return nil
		end
	end

	def getMoreInput
		if nil == @input then
			return nil
		end
		@inputBuffer = @nextInputBuffer
		@inputBufferPosition = 0
		if nil == @inputBuffer then
			@inputBuffer = @input.gets
			@inputBufferPosition = 0
			if nil == @inputBuffer then
				@inputBufferLength = 0
				return nil
			end
		end
		@inputBufferLength = @inputBuffer.length
		@nextInputBuffer = @input.gets
	end

	def peekAt0
		if nil == @inputBuffer then
			getMoreInput
		end
		if @inputBufferPosition < @inputBufferLength then
			return @inputBuffer[@inputBufferPosition]
		else
			if (nil != @nextInputBuffer) and (0 < @nextInputBuffer.length) then
				return @nextInputBuffer[0]
			else
				return nil
			end
		end
	end

	def peekAt1
		if nil == @inputBuffer then
			getMoreInput
		end
		if (@inputBufferPosition + 1) < @inputBufferLength then
			return @inputBuffer[@inputBufferPosition + 1]
		else
			if @inputBufferPosition < @inputBufferLength then
				if (nil != @nextInputBuffer) and (0 < @nextInputBuffer.length) then
					return @nextInputBuffer[0]
				else
					return nil
				end
			else
				if (nil != @nextInputBuffer) and (1 < @nextInputBuffer.length) then
					return @nextInputBuffer[1]
				else
					return nil
				end
			end
		end
	end

	def parseNextEvent
		@attributeName.clear
		@attributeQName.clear
		@attributeNamespace.clear
		@attributePrefix.clear
		@attributeValue.clear

		if @emptyElement then
			# the last event was an empty start element like <start/>
			@type = END_ELEMENT
			@emptyElement = false
			return
		end

		@prefix = nil
		@name = nil
		@qname = nil
		@namespace = nil
		@type = peekType

		case @type
			when END_DOCUMENT
				# nothing to do
			when ENTITY_REF
				parseEntity
				@text = @textBuffer
				@textBuffer = ''
			when START_ELEMENT
				parseStartElement
			when END_ELEMENT
				parseEndElement
			when TEXT
				parseText(?<, false)
				@text = @textBuffer
				@textBuffer = ''
				if 0 == @elementName.length then
					if(@whitespace) then
						@type = IGNORABLE_WHITESPACE
					end
				end
			when CDATA_SECTION
printf("\nCDATA... WOW I *am* used\n")
				# how is this ever called?
				@type = parseLookFurther
			else
				@type = parseLookFurther
		end

	end

	def parseLookFurther
		# this could be a comment, processing instruction, or CDATA section
		expect(?<)

		demand = nil
		delimiter = nil # **first** (not last) character in delimting string

		@text = @textBuffer
		@textBuffer = ''

		c = read
		if ?? == c then
			result = PROCESSING_INSTRUCTION
			demand = nil
			delimiter = ??
		elsif ?! == c then
			cc = peekAt0
			if ?- == cc then
				result = COMMENT
				demand = '--'
				delimiter = ?-
			elsif ?[ == cc then
				result = CDATA_SECTION
				demand = '[CDATA['
				delimiter = ?]
			else
				result = DOCTYPE
				demand = 'DOCTYPE'
				delimiter = nil
			end
		else
			# this should never happen because we'll get an illegal name execption
			# first
			raise "illegal <{c}"
		end

		if nil != demand then
			demand.each_byte do
				| d |
				expect d
			end
		end

		if DOCTYPE == result then
			parseDoctype
		else
			while true do
				c = read
				if nil == c then
					raise "unexpectedEOF"
				end


				if ((?? == delimiter) or (c == delimiter)) and
				   (peekAt0 == delimiter) and
					 (peekAt1 == ?>) then
					if ?? == delimiter then
						@text << c
					end
					break
				end
				@text << c
			end

			read
			read
		end

		return result
	end

	def parseDoctype
		depth = 1
		quoted = false

		@text = ''
		
		while true do
			c = read

			case c
				when ?', ?" # for the sake of vim '
					quoted = !quoted
				when ?<
					if not quoted then
						depth += 1
					end
				when ?>
					if not quoted then
						depth -= 1
						if 0 == depth then
							return
						end
					end
				when nil
					raise "unexpectedEOF"
			end
			@text << c
		end
	end

	def peekType
		c = peekAt0
		case c
			when nil, 0
				return END_DOCUMENT
			when ?&
				return ENTITY_REF
			when ?<
				case peekAt1
					when ?/
						return END_ELEMENT
					when ?[
						return CDATA_SECTION
					when ??, ?!
						return LOOK_FURTHER
					else
						return START_ELEMENT
				end
			else
				return TEXT
		end
	end

	def parseEntity
		@compactNewLine = false

		expect(?&)

		@name = ''
		while true do
			c = read
			if ?; == c then
				break
			end
			if nil == c then
				raise "unexpectedEOF"
			end
			@name << c
		end

		if ?\# == @name[0] then
			if ?x == @name[1] then
				c = @name[2..@name.length].hex
			else
				c = @name[1..@name.length].to_i
			end
			@textBuffer << c
			@whitespace &= (c <= ?\s)
		else
			value = entityMap[@name]
			if nil != value then
				@textBuffer << value
				@whitespace = false
			else
				@unresolvedEntity = true
			end
		end
	end

	def parseStartElement
		#read the "<" that got us here
		expect(?<)

		@qname = readName
		@textBuffer = ''

		while true do
			skipWhitespace
			c = peekAt0
			if nil == c then
				raise "unexpectedEOF"
			end
			if ?/ == c then
				@emptyElement = true

				read
				skipWhitespace
				expect(?>)

				break
			end
			if ?> == c then
				@emptyElement = false
				read
				break
			end

			aName = readName
			@textBuffer = ''
			if (nil == aName) or (0 == aName.length) then
				raise "nameExpected"
			end

			skipWhitespace
			expect(?=)
			skipWhitespace

			delimiter = read
			if (?' != delimiter) and (?" != delimiter) then # for vim: '
				raise "invalidDelimiter"
			end

			value = parseText(delimiter, true)
			@textBuffer = ''

			# skip the end delimiter
			read

			if processNamespace then
				@attributeQName.push aName
			else
				@attributeName.push aName
				@attributeQName.push aName
				@attributeNamespace.push nil
				@attributePrefix.push nil
			end
			@attributeValue.push value

		end

		if processNamespace then
			handleNamespaces
		else
			@name = @qname
			@namespace = nil
			@prefix = nil
		end

		if not @emptyElement then
			@elementName.push @name
			@elementQName.push @qname
			@elementNamespace.push @namespace
			@elementPrefix.push @prefix
		end

		#read
	end

	def parseEndElement
		if 0 == @elementName.length then
			raise "elementStackEmpty"
		end

		# read the "</" that we've only had a peek at
		expect(?<)
		expect(?/)

		@qname = readName
		startQName = @elementQName.pop
		if @qname != startQName then
			raise sprintf("unexpectedEndElement wanted '%s' found '%s'", startQName, @qname)
		end
		skipWhitespace
		expect(?>)

		@name = @elementName.pop
		@prefix = @elementPrefix.pop
		@namespace = @elementNamespace.pop

		@elementNamespacePrefixStack.pop
		@elementNamespaceValueStack.pop
		@elementNamespaceDefaultStack.pop
	end

	def readName
		c = peekAt0
		if !nameStartChar(c) then
			raise "nameExpected"
		end
		while true do
			appendToTextBuffer(read)
			c = peekAt0
			if !nameChar(c) then
				break
			end
		end
		return @textBuffer
	end

	# is this method correct?? verify FIX ME
	def nameStartChar(c)
		if ((c < ?A) or (?Z < c)) and ((c < ?a) or (?z < c)) then
			if (c != ?_) and (c != ?:) then
				return false
			end
		end
		return true
	end

	# is this method correct?? verify FIX ME
	def nameChar(c)
		if nil == c then return false end
		if ((?A <= c) and (c <= ?Z)) then return true end
		if ((?a <= c) and (c <= ?z)) then return true end
		if ((?0 <= c) and (c <= ?9)) then return true end
		if (?_ == c) then return true end
		if (?- == c) then return true end
		if (?. == c) then return true end
		if (?: == c) then return true end

		return false
	end

	def handleNamespaces
		# This is called by parseStartElement to deal with namespaces. Updates knows
		# name spaces based on the attributes in this start element. Then sets up
		# the namespaces for this element itself (i.e. process the qname).

		i = 0

		defaultNamespace = @elementNamespaceDefaultStack.last

		qnames = @attributeQName
		@attributeQName = []
		values = @attributeValue
		@attributeValue = []

		prefixList = []
		valueList = []

		while i < qnames.length do
			qname = qnames[i]
			value = values[i]
			i += 1

			if 'xmlns' == qname then
				prefix = 'xmlns'
				name = nil
				namespace = lookupNamespace prefix
				defaultNamespace = value
			else
				pieces = qname.split(':', 2)
				if 2 == pieces.length then
					namespace = value
					prefix = pieces[0]
					name = pieces[1]

					if 0 == prefix.length then
						raise "illegalEmptyAtributePrefix"
					end
					if 0 == name.length then
						raise "illegalEmptyAttributeName"
					end
				else
					# this is a un-prefixed non-xmlns attribute
					@attributeQName.push qname
					@attributeName.push qname
					@attributeNamespace.push nil
					@attributePrefix.push nil
					@attributeValue.push value

					next
				end
			end

			# only prefixed attributes beyond here

			if nil == namespace then
				raise "illegalEmptyNamespace"
			end

			if "xmlns" != prefix then
				anyQualifiedAttributes = true

				@attributeQName.push qname
				@attributeName.push name
				@attributeNamespace.push namespace
				@attributePrefix.push prefix
				@attributeValue.push value
			else
				if (nil != name) and ((nil == namespace) or (0 == namespace.length)) then
					raise "illegalNamespace"
				end

				prefixList.push name
				valueList.push value

				if @reportNamespaceAttributes then
					@attributeQName.push qname
					@attributeName.push name
					@attributeNamespace.push namespace
					@attributePrefix.push prefix
					@attributeValue.push value

#why???
#					anyQualifiedAttributes = true
				end
			end

		end

		@elementNamespacePrefixStack.push prefixList
		@elementNamespaceValueStack.push valueList
		@elementNamespaceDefaultStack.push defaultNamespace
		
		if anyQualifiedAttributes then
			# run over the attributes and make sure we have them qualified
			for i in 0..(@attributeName.length-1) do
				prefix = @attributePrefix[i]

				if nil != prefix then
					@attributeNamespace[i] = lookupNamespace prefix
				end
			end
		end

		# handle namespaces for the element name
		pieces = @qname.split(':', 2)
		if 2 == pieces.length then
			@name = pieces[1]
			@prefix = pieces[0]
			@namespace = lookupNamespace @prefix
		else
			@name = @qname
			@namespace = defaultNamespace
			@prefix = nil
		end
	end

	def lookupNamespace(prefix)
		if nil == prefix then
			raise "illegalPrefix"
		end
		if'xml' == prefix then
			return 'http://www.w3.org/XML/1998/namespace'
		end
		if'xmlns' == prefix then
			return 'http://www.w3.org/2000/xmlns/'
		end

		i = @elementNamespacePrefixStack.length - 1
		while 0 <= i do
			j = @elementNamespacePrefixStack[i].index(prefix)
			if nil != j then
				return @elementNamespaceValueStack[i][j]
			end

			i -= 1
		end
		raise "unknownNamespacePrefix"
	end

	def parseText(delimiter, resolve)
		c = peekAt0
		while (nil != c) and (delimiter != c) do
			if ?& == c then
				if !resolve then
					break
				end

				parseEntity

				if @unresolvedEntity then
					raise "unresolvedEntity"
				end
			else
				appendToTextBuffer(read)
			end

			c = peekAt0
		end

		return @textBuffer
	end

	def appendToTextBuffer(c)
		if ((?\r == c) or (?\n == c)) and startElement? then
			if (?\n == c) and @compactNewLine then
				@compactNewLine = false
				return
			end
			@compactNewLine = (?\r == c)
			c = startElement? ? ?\s : ?\n
		else
			@compactNewLine = false
		end

		@textBuffer << c
		@whitespace &= (c <= ?\s)
		return @textBuffer
	end

	def skipWhitespace
		while true do
			c = peekAt0
			if (nil == c) or (?\s < c) then
				return
			end
			read
		end
	end

end
