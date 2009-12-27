#  xampl-pp : XML pull parser
#  Copyright (C) 2002-2010 Bob Hutchison
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  #Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#


class Xampl_PP
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
  UNDECIDED_TYPE = 'UNDECIDED_TYPE'

  def first_byte(str)
    if "9" == RUBY_VERSION[2..2] then
      str.bytes.first
    else
      str[0]
    end
  end

  # 'Features', acutally just processing options
  attr_accessor  :processNamespace #1.9.1 , true
  attr_accessor  :reportNamespaceAttributes #1.9.1 , true
  attr_accessor  :utf8encode #1.9.1 , true

  # the entities that we will recognise
  attr_accessor  :entityMap #1.9.1 , true
  attr_accessor  :unresolvedEntity
  attr_accessor  :resolver #1.9.1 , true

  # some information about where we are
  attr_accessor  :line
  attr_accessor  :column

  # element information
  attr_accessor  :type
  attr_accessor  :emptyElement
  attr_accessor  :name
  attr_accessor  :qname
  attr_accessor  :namespace
  attr_accessor  :prefix
  attr_accessor  :attributeName
  attr_accessor  :attributeQName
  attr_accessor  :attributeNamespace
  attr_accessor  :attributePrefix
  attr_accessor  :attributeValue

  attr_accessor  :text

  # These are not intended for general use (they are not part of the api)

  # open element information
  attr_accessor  :elementName
  attr_accessor  :elementQName
  attr_accessor  :elementNamespace
  attr_accessor  :elementPrefix

  # some pre-compiled patterns
  attr_accessor  :namePattern #1.9.1 , true
  attr_accessor  :skipWhitespacePattern #1.9.1 , true

  attr_accessor  :elementNamespacePrefixStack
  attr_accessor  :elementNamespaceValueStack
  attr_accessor  :elementNamespaceDefaultStack

  attr_accessor  :standalone

  public

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

  def whitespace?
    nil == @text.index(@skipWhitespacePattern)
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

  def resolve(name)
    raise sprintf("unresolved entity '%s'", name)
  end

  def input=(v)
    setInput(v)
  end

  def setInput(v)
    if (defined? @input) and (nil != @input) then
      @input.close
    end
    if nil == v then
      @input = nil
      @inputBuffer = nil
      @inputBufferLength = 0
      @column = 0
      @line = 0
    elsif v.kind_of? String then
      @input = nil
      @inputBuffer = v
      @inputBufferLength = v.length
      @line = 1
      @column = 0
    elsif v.kind_of? IO then
      @input = v
      @inputBuffer = nil
      @inputBufferLength = 0
      @column = 0
      @line = 0
    else
      raise "illegalInput"
    end
    @nextInputBuffer = nil
    @textBuffer = ''

    @elementNamespacePrefixStack = []
    @elementNamespaceValueStack = []
    @elementNamespaceDefaultStack = []

    @elementName = []
    @elementQName = []
    @elementNamespace = []
    @elementPrefix = []

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

    @errorMessage = nil

    initInput
  end

  def initInput
    # redefine this method if you have some initialisation you need done
  end

  def nextEvent
    begin
      @type = END_DOCUMENT
      if (nil == @inputBuffer) and (nil == @input) then
        return @type
      end

      @unresolvedEntity = false

      @text = nil

      parseNextEvent

      return @type
    rescue Exception => message
      print message.backtrace.join("\n")
      if nil != @inputBuffer then
        @errorMessage = sprintf("parse error: '%s' -- String input, line %d, column %d", message, @line, @column)
      elsif nil != @input then
        if @input.kind_of? File then
          @errorMessage = sprintf("parse error: '%s' -- file '%s', line %d, column %d", message, @input.path, @line, @column)
        else
          @errorMessage = sprintf("parse error: '%s' -- unnamed IO stream, line %d, column %d", message, @line, @column)
        end
      else
        @errorMessage = sprintf("parse error: '%s' -- unknown source, line %d, column %d", message, @line, @column)
      end
      raise @errorMessage
    end
  end

  def depth
    return @elementName.length
  end

  private

  def initialize
    self.processNamespace = true
    self.reportNamespaceAttributes = false
    self.utf8encode = true

    self.input = nil

    self.entityMap = {"amp"=>"&",
                      "apos"=>"'",
                      "gt"=>">",
                      "lt"=>"<",
                      "quot"=>"\""}
    self.namePattern = /[^0-9\x00-\x20=\/>\`\.\-\~\!\@\#\$\%\^\&\*\(\)\+\=\]\[\{\}\\\|\;\'\"\,\<\>\/\?][^\x00-\x20=\/>\`\!\@\#\$\%\^\&\*\(\)\+\=\]\[\{\}\\\|\;\'\"\,\<\>\/\?]*/u
    self.skipWhitespacePattern = /[^\n\r\t ]+/u

    #pre ruby 1.8 needs the Regex.new syntax
    #self.namePattern = Regexp.new(/[^0-9\x00-\x20=\/>\`\.\-\~\!\@\#\$\%\^\&\*\(\)\+\=\]\[\{\}\\\|\;\'\"\,\<\>\/\?][^\x00-\x20=\/>\`\!\@\#\$\%\^\&\*\(\)\+\=\]\[\{\}\\\|\;\'\"\,\<\>\/\?]*/, nil, 'u')
    #old junk... self.skipWhitespacePattern = Regexp.new(/[^\n\r\t ]+|\x00/, nil, 'u')
    #self.skipWhitespacePattern = Regexp.new(/[^\n\r\t ]+/, nil, 'u')
  end

  def getMoreInput
    @column = 0
    @line += 1
    if nil == @input then
      @inputBuffer = nil
      @inputBufferLength = -1
      return nil
    end
    @inputBuffer = @nextInputBuffer
    if nil == @inputBuffer then
      @inputBuffer = @input.gets
      #puts "#{ __FILE__ }:#{ __LINE__ } MORE INPUT: #{ @inputBuffer }"
      @column = 0
      if nil == @inputBuffer then
        @inputBufferLength = -1
        return nil
      end
    end
    @inputBufferLength = @inputBuffer.length
    @nextInputBuffer = @input.gets
    #puts "#{ __FILE__ }:#{ __LINE__ } NEXT INPUT: #{ @nextInputBuffer }"
  end

  def expectold(e)
    c = read
    if c != e then
      msg = sprintf("unexpectedChar:: expect '%s' got '%s' in %s", (''<<e), (''<<c), caller[0])
      raise msg
    end
    return c
  end

  def expect(e)
    if (nil == @inputBuffer) or (@inputBufferLength <= @column) then
      getMoreInput
      if nil == @inputBuffer then
        msg = sprintf("unexpectedChar:: expect '%s' got EOF in %s", (''<<e), caller[0])
        raise msg
      end
    end

    c = @inputBuffer[@column]
    if c.instance_of?(String) then
      if "9" == RUBY_VERSION[2..2] then
        c = c.bytes.first
      else
        c = c[0]
      end
    end
    if e.instance_of?(String) then
      if "9" == RUBY_VERSION[2..2] then
        e = e.bytes.first
      else
        e = e[0]
      end
    end
    @column += 1
    if c == e then
      return c
    end

    #puts "#{ __FILE__ }:#{ __LINE__ } EXPECT CLASS: #{ e.class.name }"
    #puts "#{ __FILE__ }:#{ __LINE__ } GOT    CLASS: #{ c.class.name }"


    msg = sprintf("unexpectedChar:: expect '%s' got '%s' in %s", (''<<e), (''<<c), caller[0])
    raise msg
  end

  def read
    if (nil == @inputBuffer) or (@inputBufferLength <= @column) then
      getMoreInput
      if nil == @inputBuffer then
        return nil
      end
    end

    #puts "#{ __FILE__ }:#{ __LINE__ } READ COLUMN #{ @column } FROM: #{ @inputBuffer }"
    #puts "#{ __FILE__ }:#{ __LINE__ } READ: #{  @inputBuffer[@column] }"
    if "9" == RUBY_VERSION[2..2] then
      c = @inputBuffer[@column].bytes.first # 1.9.1 fixup
    else
      c = @inputBuffer[@column]
    end
    @column += 1
    return c
  end

  def peekAt0
    if nil == @inputBuffer then
      getMoreInput
    end
    if @column < @inputBufferLength then
      return @inputBuffer[@column]
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
    if (@column + 1) < @inputBufferLength then
      return @inputBuffer[@column + 1]
    else
      if @column < @inputBufferLength then
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

    @textBuffer = ''

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
          if nil == @text.index(@skipWhitespacePattern) then
            @type = IGNORABLE_WHITESPACE
          end
        end
      else
        @type = parseUndecided
    end

  end

  def parseUndecided
    # this could be a comment, processing instruction, or CDATA section
    expect ?<

    demand = nil
    delimiter = nil # **first** (not last) character in delimting string

    @text = @textBuffer
    @textBuffer = ''

    c = read
    if first_byte("?") == c then
      result = PROCESSING_INSTRUCTION
      demand = nil
      delimiter = ??
    elsif first_byte("!") == c then
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
      demand.each_byte do | d |
        expect d
      end
    end

    if DOCTYPE == result then
      parseDoctype
    else
      if ?? == delimiter then
        s = Regexp.escape "?>"
        inc = 2
      else
        s = Regexp.escape "" << delimiter << delimiter << '>'
        inc = 3
      end
      regex = /#{s}/u
      p = findOneOfThese(regex)
      @text = @textBuffer
      if nil != p then
        @column += inc
      end
    end

    return result
  end

  def parseXMLDecl
    return nil != @text.index(/^xml/u)
  end

  def parseDoctype
    depth = 1
    quoted = false
    delimiter = nil
    entityDefinitionText = ''
    havePiece = false
    internalSubset = false

    @text = ''

    while true do
      c = read
      case c
        when ?', ?" # for the sake of vim '
          if quoted then
            if c == delimiter then
              quoted = false
              delimiter = nil
            end
          else
            quoted = true
            delimiter = c
          end
        when ?<
          if not quoted then
            if (?! == peekAt0) and (?- == peekAt1) then
              #this is looking like a comment
              @text << c
              @text << (expect ?!)
              @text << (expect ?-)
              c = read
              if ?- == c then
                @text << ?-
                regex = /-->/u
                p = findOneOfThese(regex)
                @text << @textBuffer
                @textBuffer = ''
                @text << (expect ?-)
                @text << (expect ?-)
                c = (expect ?>)
              else
                depth += 1
                entityDefinitionText = ''
              end
            else
              depth += 1
              entityDefinitionText = ''
            end
          end
        when ?>
          if not quoted then
            depth -= 1
            #check right here for an entity definition!!!
            havePiece = true
            #entityDefinitionText = ''
            if 0 == depth then
              return
            end
          end
        when ?[
          if not quoted then
            internalSubset = true
          end
        when nil
          raise sprintf("unexpected EOF in DOCTYPE (depth: %d, quoted: %s)", depth, quoted)
      end
      @text << c
      entityDefinitionText << c
      if havePiece then
        parseDefinition(entityDefinitionText, internalSubset)
        entityDefinitionText = ''
      end
      havePiece = false
    end
  end

  def parseDefinition(defn, internal)
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
            return UNDECIDED_TYPE
          else
            return START_ELEMENT
        end
      else
        return TEXT
    end
  end

  def encode(c)
    if @utf8encode then
#      if c < 0x80 then
#        @textBuffer << c
#       elsif c < 0x0800
#         @textBuffer << ((c >> 6) | 0xC0)
#         @textBuffer << (c & (0x3F | 0x80))
#       elsif c < 0x10000
#         @textBuffer << ((c >> 12) | 0xE0)
#         @textBuffer << ((c >> 6) & (0x3F | 0x80))
#         @textBuffer << (c & (0x3F | 0x80))
#       else
#         @textBuffer << ((c >> 18) | 0xF0)
#         @textBuffer << ((c >> 12) & (0x3F | 0x80))
#         @textBuffer << ((c >> 6) & (0x3F | 0x80))
#         @textBuffer << (c & (0x3F | 0x80))
#      end
      if c < 0x80 then
        @textBuffer << c
      elsif c < 0x0800
        @textBuffer << ((c >> 6) | 0xC0)
        @textBuffer << ((c & 0x3F) | 0x80)
      elsif c < 0x10000
        @textBuffer << ((c >> 12) | 0xE0)
        @textBuffer << (((c >> 6) & 0x3F) | 0x80)
        @textBuffer << ((c & 0x3F) | 0x80)
      else
        @textBuffer << ((c >> 18) | 0xF0)
        @textBuffer << (((c >> 12) & 0x3F) | 0x80)
        @textBuffer << (((c >> 6) & 0x3F) | 0x80)
        @textBuffer << ((c & 0x3F) | 0x80)
      end
    else
      @textBuffer << c
    end
  end

  def parseEntity
    expect ?&

    @name = ''
    while true do
      c = read
      #puts "#{ __FILE__ }:#{ __LINE__ } CLASS OF C: #{ c.class.name }"
      if first_byte(";") == c then
      #if ?; == c then # 1.9.1
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
      encode(c)
    else
      value = entityMap[@name]
      if nil != value then
        @textBuffer << value
      else
        if nil != @resolver then
          value = @resolver.resolve(@name)
        else
          value = resolve(@name)
        end

        if nil != value then
          @textBuffer << value
        else
          @unresolvedEntity = true
        end
      end
    end
  end

  def parseStartElement
    expect ?<

    @qname = readName
    @textBuffer = ''

    multiple = false
    while true do
      hasWhitespace = skipWhitespace

      c = peekAt0
      if nil == c then
        raise "unexpectedEOF"
      end
      if ?/ == c then
        @emptyElement = true

        read
        expect ?>

        break
      end
      if ?> == c then
        @emptyElement = false
        read
        break
      end

      if multiple and !hasWhitespace then
        raise "whitespace is required between attributes"
      end
      multiple = true

      aName = readName
      @textBuffer = ''
      if (nil == aName) or (0 == aName.length) then
        raise "name expected (start element)"
      end

      skipWhitespace
      expect ?=
      skipWhitespace

      delimiter = read
      #TODO optimise this
      if "9" == RUBY_VERSION[2..2] then
        if "'".bytes.first == delimiter then # for vim: '
          value = parseText(?', true) # for vim: '
        elsif '"'.bytes.first == delimiter then # for vim: "
          value = parseText(?", true) # for vim: "
        else
          raise "invalidDelimiter"
        end
      else
        if ?' == delimiter then # for vim: '
          value = parseText(?', true) # for vim: '
        elsif ?" == delimiter then # for vim: "
          value = parseText(?", true) # for vim: "
        else
          raise "invalidDelimiter: '#{ delimiter }'"
        end
      end

      # replaced with above for 1.9.1
      #if ?' == delimiter then # for vim: '
      #  value = parseText(?', true) # for vim: '
      #elsif ?" == delimiter then # for vim: "
      #  value = parseText(?", true) # for vim: "
      #else
      #  raise "invalidDelimiter"
      #end

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
  end

  def parseEndElement
    if 0 == @elementName.length then
      raise "elementStackEmpty"
    end

    expect ?<
    expect ?/

    @qname = readName
    startQName = @elementQName.pop
    if @qname != startQName then
      raise sprintf("unexpectedEndElement wanted '%s' found '%s'", startQName, @qname)
    end
    skipWhitespace
    expect ?>

    @name = @elementName.pop
    @prefix = @elementPrefix.pop
    @namespace = @elementNamespace.pop

    @elementNamespacePrefixStack.pop
    @elementNamespaceValueStack.pop
    @elementNamespaceDefaultStack.pop
  end

  def readName
    @textBuffer = ''
    if @column != @inputBuffer.index(@namePattern, @column) then
      raise "invalid name"
    end
    if nil != $& then
      @textBuffer = $&
      @column += $&.length
    else
      @column = @inputBufferLength
    end
    if 0 == @textBuffer.length then
      raise "name expected (readName)"
    end
    return @textBuffer
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
    if 'xml' == prefix then
      return 'http://www.w3.org/XML/1998/namespace'
    end
    if 'xmlns' == prefix then
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
    raise sprintf("unknown Namespace Prefix '%s' [%s]", prefix, caller[0])
  end

  def parseText(delimiter, resolve)
    s = "&" << delimiter
    regex = /[#{s}|<]/u
    c = findOneOfThese regex
    while (nil != c) and (delimiter != c) do
      if ?< == c then
        raise "illegal character '<'"
      end
      if ?& == c then
        if !resolve then
          break
        end

        parseEntity

        if @unresolvedEntity then
          raise "unresolvedEntity"
        end
      else
        c = read
        @textBuffer << c
      end

      c = findOneOfThese regex
    end

    return @textBuffer
  end

  def skipWhitespace
    foundSome = false
    while nil != @inputBuffer do
      p = @inputBuffer.index(@skipWhitespacePattern, @column)

      if nil != p then
        foundSome = (foundSome or (@column != p))
        @column = p
        return foundSome
      end
      getMoreInput
      foundSome = true
    end
    return foundSome
  end

  def findOneOfThese(regex)
    p = @inputBuffer.index(regex, @column)

    if nil != p then
      if p != @column then
        @textBuffer << @inputBuffer[@column..(p - 1)]
        @column = p
      end
      return @inputBuffer[p]
    end
    @textBuffer << @inputBuffer[@column..-1]
    getMoreInput
    return findOneOfTheseSecond(regex)
  end

  def findOneOfTheseSecond(regex)
    # know we are at the first of a line
    while nil != @inputBuffer do
      @column = @inputBuffer.index(regex)

      if nil != @column then
        @textBuffer << @inputBuffer[0, @column]
        return @inputBuffer[@column]
      end
      @textBuffer << @inputBuffer
      getMoreInput
    end
    return nil
  end

end
