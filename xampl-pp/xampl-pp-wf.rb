#  xampl-pp : XML pull parser
#  Copyright (C) 2002-2009 Bob Hutchison
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

require "xampl-pp-dtd"

class Xampl_PP
	alias :nextEventBase :nextEvent
	alias :setInputBase :setInput
	alias :encodeBase :encode
	alias :readBase :read

  def nextEvent
    begin
			begin
      	return nextEventBase
			ensure
#IGNORABLE_WHITESPACE
#DOCTYPE
				if nil == @errorMessage then
        	if @unresolvedEntity then
          	raise "unresolvedEntity"
        	end
    			case @type
          	when START_ELEMENT
    					if (0 == @elementName.length) then
      					if @haveRoot then
        					raise "unexpected element"
      					end
    					end
							legalName
      				@haveRoot = true
          	when END_ELEMENT
							legalName
						when COMMENT
							if nil != @text.index(/--/u) then
								raise "illegal '--' in comment"
							end
							legalText
						when TEXT
							if 0 == @elementName.length then
								raise "text at document level"
							end
							legalText
						when CDATA_SECTION
							if 0 == @elementName.length then
								raise "CDATA section at document level"
							end
							legalText
						when ENTITY_REF
							if 0 == @elementName.length then
								raise "entity ref at document level"
							end
							legalText
     				when END_DOCUMENT
							if 0 != @elementName.length then
								raise sprintf("unexpected end of document (%d open elements)",
						                	@elementName.length)
							end
							if !@haveRoot then
								raise "unexpected end of document (no element)"
							end
     				when PROCESSING_INSTRUCTION
							if @pastXMLDecl and parseXMLDecl then
								raise "unexpected XMLDecl"
							end
							legalText
					end
					@pastXMLDecl = true
				end
			end
    rescue Exception => message
      #print message.backtrace.join("\n")
			if nil == @errorMessage then
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
			end
      raise @errorMessage
    end
  end

private

  def setInput(v)
    @haveRoot = false
		@pastXMLDecl = false
		@quickNamePattern = Regexp.new(/^[\x41-\x5A\x61-\x7a_:][\x30-\x39\x41-\x5A\x61-\x7a_:\.\-]*$/, 0, "UTF-8")
		@quickTextPattern = /^[\x09\x0A\x0D\x20-\x7f]*$/mu
		setInputBase(v)
  end

  def legalChar(c)
		if c < 0x20 then
			if (c != 0x9) and (c != 0x0A) and (c != 0x0D) then
				raise "illegal character"
			end
		elsif (0xD7FF < c) and (c < 0xE000) then
				raise "illegal character"
		elsif (0xFFFD < c) and (c < 0x10000) then
				raise "illegal character"
		elsif (0x10FFFF < c) then
				raise "illegal character"
		end
		return c
	end

  def encode(c)
		return encodeBase(legalChar(c))
	end

  def read
		return legalChar(readBase) 
	end

	def legalText
		if nil == @text then
			raise "undefined text"
		end

		return if 0 == @text.index(@quickTextPattern)

		a = @text.unpack('U*')
		start = true
		for c in a
			legalChar(c)
		end
	end

	def legalName
		if nil == @name then
			raise "undefined element name"
		end
		
		return if 0 == @name.index(@quickNamePattern)

		a = @name.unpack('U*')
		start = true
		for c in a
			# NameStart
    	while start do
        break if (0x0041 <= c) and (c <= 0x005A)
        break if (0x0061 <= c) and (c <= 0x007A)
        break if c == ?_
        break if c == ?:
        break if (0x00C0 <= c) and (c <= 0x00D6)
        break if (0x00D8 <= c) and (c <= 0x00F6)
        break if (0x00F8 <= c) and (c <= 0x00FF)
        break if (0x0100 <= c) and (c <= 0x0131)
        break if (0x0134 <= c) and (c <= 0x013E)
        break if (0x0141 <= c) and (c <= 0x0148)
        break if (0x014A <= c) and (c <= 0x017E)
        break if (0x0180 <= c) and (c <= 0x01C3)
        break if (0x01CD <= c) and (c <= 0x01F0)
        break if (0x01F4 <= c) and (c <= 0x01F5)
        break if (0x01FA <= c) and (c <= 0x0217)
        break if (0x0250 <= c) and (c <= 0x02A8)
        break if (0x02BB <= c) and (c <= 0x02C1)
        break if c == 0x0386
        break if (0x0388 <= c) and (c <= 0x038A)
        break if c == 0x038C
        break if (0x038E <= c) and (c <= 0x03A1)
        break if (0x03A3 <= c) and (c <= 0x03CE)
        break if (0x03D0 <= c) and (c <= 0x03D6)
        break if c == 0x03DA
        break if c == 0x03DC
        break if c == 0x03DE
        break if c == 0x03E0
        break if (0x03E2 <= c) and (c <= 0x03F3)
        break if (0x0401 <= c) and (c <= 0x040C)
        break if (0x040E <= c) and (c <= 0x044F)
        break if (0x0451 <= c) and (c <= 0x045C)
        break if (0x045E <= c) and (c <= 0x0481)
        break if (0x0490 <= c) and (c <= 0x04C4)
        break if (0x04C7 <= c) and (c <= 0x04C8)
        break if (0x04CB <= c) and (c <= 0x04CC)
        break if (0x04D0 <= c) and (c <= 0x04EB)
        break if (0x04EE <= c) and (c <= 0x04F5)
        break if (0x04F8 <= c) and (c <= 0x04F9)
        break if (0x0531 <= c) and (c <= 0x0556)
        break if c == 0x0559
        break if (0x0561 <= c) and (c <= 0x0586)
        break if (0x05D0 <= c) and (c <= 0x05EA)
        break if (0x05F0 <= c) and (c <= 0x05F2)
        break if (0x0621 <= c) and (c <= 0x063A)
        break if (0x0641 <= c) and (c <= 0x064A)
        break if (0x0671 <= c) and (c <= 0x06B7)
        break if (0x06BA <= c) and (c <= 0x06BE)
        break if (0x06C0 <= c) and (c <= 0x06CE)
        break if (0x06D0 <= c) and (c <= 0x06D3)
        break if c == 0x06D5
        break if (0x06E5 <= c) and (c <= 0x06E6)
        break if (0x0905 <= c) and (c <= 0x0939)
        break if c == 0x093D
        break if (0x0958 <= c) and (c <= 0x0961)
        break if (0x0985 <= c) and (c <= 0x098C)
        break if (0x098F <= c) and (c <= 0x0990)
        break if (0x0993 <= c) and (c <= 0x09A8)
        break if (0x09AA <= c) and (c <= 0x09B0)
        break if c == 0x09B2
        break if (0x09B6 <= c) and (c <= 0x09B9)
        break if (0x09DC <= c) and (c <= 0x09DD)
        break if (0x09DF <= c) and (c <= 0x09E1)
        break if (0x09F0 <= c) and (c <= 0x09F1)
        break if (0x0A05 <= c) and (c <= 0x0A0A)
        break if (0x0A0F <= c) and (c <= 0x0A10)
        break if (0x0A13 <= c) and (c <= 0x0A28)
        break if (0x0A2A <= c) and (c <= 0x0A30)
        break if (0x0A32 <= c) and (c <= 0x0A33)
        break if (0x0A35 <= c) and (c <= 0x0A36)
        break if (0x0A38 <= c) and (c <= 0x0A39)
        break if (0x0A59 <= c) and (c <= 0x0A5C)
        break if c == 0x0A5E
        break if (0x0A72 <= c) and (c <= 0x0A74)
        break if (0x0A85 <= c) and (c <= 0x0A8B)
        break if c == 0x0A8D
        break if (0x0A8F <= c) and (c <= 0x0A91)
        break if (0x0A93 <= c) and (c <= 0x0AA8)
        break if (0x0AAA <= c) and (c <= 0x0AB0)
        break if (0x0AB2 <= c) and (c <= 0x0AB3)
        break if (0x0AB5 <= c) and (c <= 0x0AB9)
        break if c == 0x0ABD
        break if c == 0x0AE0
        break if (0x0B05 <= c) and (c <= 0x0B0C)
        break if (0x0B0F <= c) and (c <= 0x0B10)
        break if (0x0B13 <= c) and (c <= 0x0B28)
        break if (0x0B2A <= c) and (c <= 0x0B30)
        break if (0x0B32 <= c) and (c <= 0x0B33)
        break if (0x0B36 <= c) and (c <= 0x0B39)
        break if c == 0x0B3D
        break if (0x0B5C <= c) and (c <= 0x0B5D)
        break if (0x0B5F <= c) and (c <= 0x0B61)
        break if (0x0B85 <= c) and (c <= 0x0B8A)
        break if (0x0B8E <= c) and (c <= 0x0B90)
        break if (0x0B92 <= c) and (c <= 0x0B95)
        break if (0x0B99 <= c) and (c <= 0x0B9A)
        break if c == 0x0B9C
        break if (0x0B9E <= c) and (c <= 0x0B9F)
        break if (0x0BA3 <= c) and (c <= 0x0BA4)
        break if (0x0BA8 <= c) and (c <= 0x0BAA)
        break if (0x0BAE <= c) and (c <= 0x0BB5)
        break if (0x0BB7 <= c) and (c <= 0x0BB9)
        break if (0x0C05 <= c) and (c <= 0x0C0C)
        break if (0x0C0E <= c) and (c <= 0x0C10)
        break if (0x0C12 <= c) and (c <= 0x0C28)
        break if (0x0C2A <= c) and (c <= 0x0C33)
        break if (0x0C35 <= c) and (c <= 0x0C39)
        break if (0x0C60 <= c) and (c <= 0x0C61)
        break if (0x0C85 <= c) and (c <= 0x0C8C)
        break if (0x0C8E <= c) and (c <= 0x0C90)
        break if (0x0C92 <= c) and (c <= 0x0CA8)
        break if (0x0CAA <= c) and (c <= 0x0CB3)
        break if (0x0CB5 <= c) and (c <= 0x0CB9)
        break if c == 0x0CDE
        break if (0x0CE0 <= c) and (c <= 0x0CE1)
        break if (0x0D05 <= c) and (c <= 0x0D0C)
        break if (0x0D0E <= c) and (c <= 0x0D10)
        break if (0x0D12 <= c) and (c <= 0x0D28)
        break if (0x0D2A <= c) and (c <= 0x0D39)
        break if (0x0D60 <= c) and (c <= 0x0D61)
        break if (0x0E01 <= c) and (c <= 0x0E2E)
        break if c == 0x0E30
        break if (0x0E32 <= c) and (c <= 0x0E33)
        break if (0x0E40 <= c) and (c <= 0x0E45)
        break if (0x0E81 <= c) and (c <= 0x0E82)
        break if c == 0x0E84
        break if (0x0E87 <= c) and (c <= 0x0E88)
        break if c == 0x0E8A
        break if c == 0x0E8D
        break if (0x0E94 <= c) and (c <= 0x0E97)
        break if (0x0E99 <= c) and (c <= 0x0E9F)
        break if (0x0EA1 <= c) and (c <= 0x0EA3)
        break if c == 0x0EA5
        break if c == 0x0EA7
        break if (0x0EAA <= c) and (c <= 0x0EAB)
        break if (0x0EAD <= c) and (c <= 0x0EAE)
        break if c == 0x0EB0
        break if (0x0EB2 <= c) and (c <= 0x0EB3)
        break if c == 0x0EBD
        break if (0x0EC0 <= c) and (c <= 0x0EC4)
        break if (0x0F40 <= c) and (c <= 0x0F47)
        break if (0x0F49 <= c) and (c <= 0x0F69)
        break if (0x10A0 <= c) and (c <= 0x10C5)
        break if (0x10D0 <= c) and (c <= 0x10F6)
        break if c == 0x1100
        break if (0x1102 <= c) and (c <= 0x1103)
        break if (0x1105 <= c) and (c <= 0x1107)
        break if c == 0x1109
        break if (0x110B <= c) and (c <= 0x110C)
        break if (0x110E <= c) and (c <= 0x1112)
        break if c == 0x113C
        break if c == 0x113E
        break if c == 0x1140
        break if c == 0x114C
        break if c == 0x114E
        break if c == 0x1150
        break if (0x1154 <= c) and (c <= 0x1155)
        break if c == 0x1159
        break if (0x115F <= c) and (c <= 0x1161)
        break if c == 0x1163
        break if c == 0x1165
        break if c == 0x1167
        break if c == 0x1169
        break if (0x116D <= c) and (c <= 0x116E)
        break if (0x1172 <= c) and (c <= 0x1173)
        break if c == 0x1175
        break if c == 0x119E
        break if c == 0x11A8
        break if c == 0x11AB
        break if (0x11AE <= c) and (c <= 0x11AF)
        break if (0x11B7 <= c) and (c <= 0x11B8)
        break if c == 0x11BA
        break if (0x11BC <= c) and (c <= 0x11C2)
        break if c == 0x11EB
        break if c == 0x11F0
        break if c == 0x11F9
        break if (0x1E00 <= c) and (c <= 0x1E9B)
        break if (0x1EA0 <= c) and (c <= 0x1EF9)
        break if (0x1F00 <= c) and (c <= 0x1F15)
        break if (0x1F18 <= c) and (c <= 0x1F1D)
        break if (0x1F20 <= c) and (c <= 0x1F45)
        break if (0x1F48 <= c) and (c <= 0x1F4D)
        break if (0x1F50 <= c) and (c <= 0x1F57)
        break if c == 0x1F59
        break if c == 0x1F5B
        break if c == 0x1F5D
        break if (0x1F5F <= c) and (c <= 0x1F7D)
        break if (0x1F80 <= c) and (c <= 0x1FB4)
        break if (0x1FB6 <= c) and (c <= 0x1FBC)
        break if c == 0x1FBE
        break if (0x1FC2 <= c) and (c <= 0x1FC4)
        break if (0x1FC6 <= c) and (c <= 0x1FCC)
        break if (0x1FD0 <= c) and (c <= 0x1FD3)
        break if (0x1FD6 <= c) and (c <= 0x1FDB)
        break if (0x1FE0 <= c) and (c <= 0x1FEC)
        break if (0x1FF2 <= c) and (c <= 0x1FF4)
        break if (0x1FF6 <= c) and (c <= 0x1FFC)
        break if c == 0x2126
        break if (0x212A <= c) and (c <= 0x212B)
        break if c == 0x212E
        break if (0x2180 <= c) and (c <= 0x2182)
        break if c == 0x3007
        break if (0x3021 <= c) and (c <= 0x3029)
        break if (0x3041 <= c) and (c <= 0x3094)
        break if (0x30A1 <= c) and (c <= 0x30FA)
        break if (0x3105 <= c) and (c <= 0x312C)
        break if (0x4E00 <= c) and (c <= 0x9FA5)
        break if (0xAC00 <= c) and (c <= 0xD7A3)
        break if (0x0030 <= c) and (c <= 0x0039)
        break if (0x0041 <= c) and (c <= 0x005A)
        break if (0x0061 <= c) and (c <= 0x007A)
        break if c == 0x00B7
        break if (0x00C0 <= c) and (c <= 0x00D6)
        break if (0x00D8 <= c) and (c <= 0x00F6)
        break if (0x00F8 <= c) and (c <= 0x00FF)
        break if (0x0100 <= c) and (c <= 0x0131)
        break if (0x0134 <= c) and (c <= 0x013E)
        break if (0x0141 <= c) and (c <= 0x0148)
        break if (0x014A <= c) and (c <= 0x017E)
        break if (0x0180 <= c) and (c <= 0x01C3)
        break if (0x01CD <= c) and (c <= 0x01F0)
        break if (0x01F4 <= c) and (c <= 0x01F5)
        break if (0x01FA <= c) and (c <= 0x0217)
        break if (0x0250 <= c) and (c <= 0x02A8)
        break if (0x02BB <= c) and (c <= 0x02C1)
        break if c == 0x02D0
        break if c == 0x02D1
        break if (0x0300 <= c) and (c <= 0x0345)
        break if (0x0360 <= c) and (c <= 0x0361)
        break if c == 0x0386
        break if c == 0x0387
        break if (0x0388 <= c) and (c <= 0x038A)
        break if c == 0x038C
        break if (0x038E <= c) and (c <= 0x03A1)
        break if (0x03A3 <= c) and (c <= 0x03CE)
        break if (0x03D0 <= c) and (c <= 0x03D6)
        break if c == 0x03DA
        break if c == 0x03DC
        break if c == 0x03DE
        break if c == 0x03E0
        break if (0x03E2 <= c) and (c <= 0x03F3)
        break if (0x0401 <= c) and (c <= 0x040C)
        break if (0x040E <= c) and (c <= 0x044F)
        break if (0x0451 <= c) and (c <= 0x045C)
        break if (0x045E <= c) and (c <= 0x0481)
        break if (0x0483 <= c) and (c <= 0x0486)
        break if (0x0490 <= c) and (c <= 0x04C4)
        break if (0x04C7 <= c) and (c <= 0x04C8)
        break if (0x04CB <= c) and (c <= 0x04CC)
        break if (0x04D0 <= c) and (c <= 0x04EB)
        break if (0x04EE <= c) and (c <= 0x04F5)
        break if (0x04F8 <= c) and (c <= 0x04F9)
        break if (0x0531 <= c) and (c <= 0x0556)
        break if c == 0x0559
        break if (0x0561 <= c) and (c <= 0x0586)
        break if (0x0591 <= c) and (c <= 0x05A1)
        break if (0x05A3 <= c) and (c <= 0x05B9)
        break if (0x05BB <= c) and (c <= 0x05BD)
        break if c == 0x05BF
        break if (0x05C1 <= c) and (c <= 0x05C2)
        break if c == 0x05C4
        break if (0x05D0 <= c) and (c <= 0x05EA)
        break if (0x05F0 <= c) and (c <= 0x05F2)
        break if (0x0621 <= c) and (c <= 0x063A)
        break if c == 0x0640
        break if (0x0641 <= c) and (c <= 0x064A)
        break if (0x064B <= c) and (c <= 0x0652)
        break if (0x0660 <= c) and (c <= 0x0669)
        break if c == 0x0670
        break if (0x0671 <= c) and (c <= 0x06B7)
        break if (0x06BA <= c) and (c <= 0x06BE)
        break if (0x06C0 <= c) and (c <= 0x06CE)
        break if (0x06D0 <= c) and (c <= 0x06D3)
        break if c == 0x06D5
        break if (0x06D6 <= c) and (c <= 0x06DC)
        break if (0x06DD <= c) and (c <= 0x06DF)
        break if (0x06E0 <= c) and (c <= 0x06E4)
        break if (0x06E5 <= c) and (c <= 0x06E6)
        break if (0x06E7 <= c) and (c <= 0x06E8)
        break if (0x06EA <= c) and (c <= 0x06ED)
        break if (0x06F0 <= c) and (c <= 0x06F9)
        break if (0x0901 <= c) and (c <= 0x0903)
        break if (0x0905 <= c) and (c <= 0x0939)
        break if c == 0x093C
        break if c == 0x093D
        break if (0x093E <= c) and (c <= 0x094C)
        break if c == 0x094D
        break if (0x0951 <= c) and (c <= 0x0954)
        break if (0x0958 <= c) and (c <= 0x0961)
        break if (0x0962 <= c) and (c <= 0x0963)
        break if (0x0966 <= c) and (c <= 0x096F)
        break if (0x0981 <= c) and (c <= 0x0983)
        break if (0x0985 <= c) and (c <= 0x098C)
        break if (0x098F <= c) and (c <= 0x0990)
        break if (0x0993 <= c) and (c <= 0x09A8)
        break if (0x09AA <= c) and (c <= 0x09B0)
        break if c == 0x09B2
        break if (0x09B6 <= c) and (c <= 0x09B9)
        break if c == 0x09BC
        break if c == 0x09BE
        break if c == 0x09BF
        break if (0x09C0 <= c) and (c <= 0x09C4)
        break if (0x09C7 <= c) and (c <= 0x09C8)
        break if (0x09CB <= c) and (c <= 0x09CD)
        break if c == 0x09D7
        break if (0x09DC <= c) and (c <= 0x09DD)
        break if (0x09DF <= c) and (c <= 0x09E1)
        break if (0x09E2 <= c) and (c <= 0x09E3)
        break if (0x09E6 <= c) and (c <= 0x09EF)
        break if (0x09F0 <= c) and (c <= 0x09F1)
        break if c == 0x0A02
        break if (0x0A05 <= c) and (c <= 0x0A0A)
        break if (0x0A0F <= c) and (c <= 0x0A10)
        break if (0x0A13 <= c) and (c <= 0x0A28)
        break if (0x0A2A <= c) and (c <= 0x0A30)
        break if (0x0A32 <= c) and (c <= 0x0A33)
        break if (0x0A35 <= c) and (c <= 0x0A36)
        break if (0x0A38 <= c) and (c <= 0x0A39)
        break if c == 0x0A3C
        break if c == 0x0A3E
        break if c == 0x0A3F
        break if (0x0A40 <= c) and (c <= 0x0A42)
        break if (0x0A47 <= c) and (c <= 0x0A48)
        break if (0x0A4B <= c) and (c <= 0x0A4D)
        break if (0x0A59 <= c) and (c <= 0x0A5C)
        break if c == 0x0A5E
        break if (0x0A66 <= c) and (c <= 0x0A6F)
        break if (0x0A70 <= c) and (c <= 0x0A71)
        break if (0x0A72 <= c) and (c <= 0x0A74)
        break if (0x0A81 <= c) and (c <= 0x0A83)
        break if (0x0A85 <= c) and (c <= 0x0A8B)
        break if c == 0x0A8D
        break if (0x0A8F <= c) and (c <= 0x0A91)
        break if (0x0A93 <= c) and (c <= 0x0AA8)
        break if (0x0AAA <= c) and (c <= 0x0AB0)
        break if (0x0AB2 <= c) and (c <= 0x0AB3)
        break if (0x0AB5 <= c) and (c <= 0x0AB9)
        break if c == 0x0ABC
        break if c == 0x0ABD
        break if (0x0ABE <= c) and (c <= 0x0AC5)
        break if (0x0AC7 <= c) and (c <= 0x0AC9)
        break if (0x0ACB <= c) and (c <= 0x0ACD)
        break if c == 0x0AE0
        break if (0x0AE6 <= c) and (c <= 0x0AEF)
        break if (0x0B01 <= c) and (c <= 0x0B03)
        break if (0x0B05 <= c) and (c <= 0x0B0C)
        break if (0x0B0F <= c) and (c <= 0x0B10)
        break if (0x0B13 <= c) and (c <= 0x0B28)
        break if (0x0B2A <= c) and (c <= 0x0B30)
        break if (0x0B32 <= c) and (c <= 0x0B33)
        break if (0x0B36 <= c) and (c <= 0x0B39)
        break if c == 0x0B3C
        break if c == 0x0B3D
        break if (0x0B3E <= c) and (c <= 0x0B43)
        break if (0x0B47 <= c) and (c <= 0x0B48)
        break if (0x0B4B <= c) and (c <= 0x0B4D)
        break if (0x0B56 <= c) and (c <= 0x0B57)
        break if (0x0B5C <= c) and (c <= 0x0B5D)
        break if (0x0B5F <= c) and (c <= 0x0B61)
        break if (0x0B66 <= c) and (c <= 0x0B6F)
        break if (0x0B82 <= c) and (c <= 0x0B83)
        break if (0x0B85 <= c) and (c <= 0x0B8A)
        break if (0x0B8E <= c) and (c <= 0x0B90)
        break if (0x0B92 <= c) and (c <= 0x0B95)
        break if (0x0B99 <= c) and (c <= 0x0B9A)
        break if c == 0x0B9C
        break if (0x0B9E <= c) and (c <= 0x0B9F)
        break if (0x0BA3 <= c) and (c <= 0x0BA4)
        break if (0x0BA8 <= c) and (c <= 0x0BAA)
        break if (0x0BAE <= c) and (c <= 0x0BB5)
        break if (0x0BB7 <= c) and (c <= 0x0BB9)
        break if (0x0BBE <= c) and (c <= 0x0BC2)
        break if (0x0BC6 <= c) and (c <= 0x0BC8)
        break if (0x0BCA <= c) and (c <= 0x0BCD)
        break if c == 0x0BD7
        break if (0x0BE7 <= c) and (c <= 0x0BEF)
        break if (0x0C01 <= c) and (c <= 0x0C03)
        break if (0x0C05 <= c) and (c <= 0x0C0C)
        break if (0x0C0E <= c) and (c <= 0x0C10)
        break if (0x0C12 <= c) and (c <= 0x0C28)
        break if (0x0C2A <= c) and (c <= 0x0C33)
        break if (0x0C35 <= c) and (c <= 0x0C39)
        break if (0x0C3E <= c) and (c <= 0x0C44)
        break if (0x0C46 <= c) and (c <= 0x0C48)
        break if (0x0C4A <= c) and (c <= 0x0C4D)
        break if (0x0C55 <= c) and (c <= 0x0C56)
        break if (0x0C60 <= c) and (c <= 0x0C61)
        break if (0x0C66 <= c) and (c <= 0x0C6F)
        break if (0x0C82 <= c) and (c <= 0x0C83)
        break if (0x0C85 <= c) and (c <= 0x0C8C)
        break if (0x0C8E <= c) and (c <= 0x0C90)
        break if (0x0C92 <= c) and (c <= 0x0CA8)
        break if (0x0CAA <= c) and (c <= 0x0CB3)
        break if (0x0CB5 <= c) and (c <= 0x0CB9)
        break if (0x0CBE <= c) and (c <= 0x0CC4)
        break if (0x0CC6 <= c) and (c <= 0x0CC8)
        break if (0x0CCA <= c) and (c <= 0x0CCD)
        break if (0x0CD5 <= c) and (c <= 0x0CD6)
        break if c == 0x0CDE
        break if (0x0CE0 <= c) and (c <= 0x0CE1)
        break if (0x0CE6 <= c) and (c <= 0x0CEF)
        break if (0x0D02 <= c) and (c <= 0x0D03)
        break if (0x0D05 <= c) and (c <= 0x0D0C)
        break if (0x0D0E <= c) and (c <= 0x0D10)
        break if (0x0D12 <= c) and (c <= 0x0D28)
        break if (0x0D2A <= c) and (c <= 0x0D39)
        break if (0x0D3E <= c) and (c <= 0x0D43)
        break if (0x0D46 <= c) and (c <= 0x0D48)
        break if (0x0D4A <= c) and (c <= 0x0D4D)
        break if c == 0x0D57
        break if (0x0D60 <= c) and (c <= 0x0D61)
        break if (0x0D66 <= c) and (c <= 0x0D6F)
        break if (0x0E01 <= c) and (c <= 0x0E2E)
        break if c == 0x0E30
        break if c == 0x0E31
        break if (0x0E32 <= c) and (c <= 0x0E33)
        break if (0x0E34 <= c) and (c <= 0x0E3A)
        break if (0x0E40 <= c) and (c <= 0x0E45)
        break if c == 0x0E46
        break if (0x0E47 <= c) and (c <= 0x0E4E)
        break if (0x0E50 <= c) and (c <= 0x0E59)
        break if (0x0E81 <= c) and (c <= 0x0E82)
        break if c == 0x0E84
        break if (0x0E87 <= c) and (c <= 0x0E88)
        break if c == 0x0E8A
        break if c == 0x0E8D
        break if (0x0E94 <= c) and (c <= 0x0E97)
        break if (0x0E99 <= c) and (c <= 0x0E9F)
        break if (0x0EA1 <= c) and (c <= 0x0EA3)
        break if c == 0x0EA5
        break if c == 0x0EA7
        break if (0x0EAA <= c) and (c <= 0x0EAB)
        break if (0x0EAD <= c) and (c <= 0x0EAE)
        break if c == 0x0EB0
        break if c == 0x0EB1
        break if (0x0EB2 <= c) and (c <= 0x0EB3)
        break if (0x0EB4 <= c) and (c <= 0x0EB9)
        break if (0x0EBB <= c) and (c <= 0x0EBC)
        break if c == 0x0EBD
        break if (0x0EC0 <= c) and (c <= 0x0EC4)
        break if c == 0x0EC6
        break if (0x0EC8 <= c) and (c <= 0x0ECD)
        break if (0x0ED0 <= c) and (c <= 0x0ED9)
        break if (0x0F18 <= c) and (c <= 0x0F19)
        break if (0x0F20 <= c) and (c <= 0x0F29)
        break if c == 0x0F35
        break if c == 0x0F37
        break if c == 0x0F39
        break if c == 0x0F3E
        break if c == 0x0F3F
        break if (0x0F40 <= c) and (c <= 0x0F47)
        break if (0x0F49 <= c) and (c <= 0x0F69)
        break if (0x0F71 <= c) and (c <= 0x0F84)
        break if (0x0F86 <= c) and (c <= 0x0F8B)
        break if (0x0F90 <= c) and (c <= 0x0F95)
        break if c == 0x0F97
        break if (0x0F99 <= c) and (c <= 0x0FAD)
        break if (0x0FB1 <= c) and (c <= 0x0FB7)
        break if c == 0x0FB9
        break if (0x10A0 <= c) and (c <= 0x10C5)
        break if (0x10D0 <= c) and (c <= 0x10F6)
        break if c == 0x1100
        break if (0x1102 <= c) and (c <= 0x1103)
        break if (0x1105 <= c) and (c <= 0x1107)
        break if c == 0x1109
        break if (0x110B <= c) and (c <= 0x110C)
        break if (0x110E <= c) and (c <= 0x1112)
        break if c == 0x113C
        break if c == 0x113E
        break if c == 0x1140
        break if c == 0x114C
        break if c == 0x114E
        break if c == 0x1150
        break if (0x1154 <= c) and (c <= 0x1155)
        break if c == 0x1159
        break if (0x115F <= c) and (c <= 0x1161)
        break if c == 0x1163
        break if c == 0x1165
        break if c == 0x1167
        break if c == 0x1169
        break if (0x116D <= c) and (c <= 0x116E)
        break if (0x1172 <= c) and (c <= 0x1173)
        break if c == 0x1175
        break if c == 0x119E
        break if c == 0x11A8
        break if c == 0x11AB
        break if (0x11AE <= c) and (c <= 0x11AF)
        break if (0x11B7 <= c) and (c <= 0x11B8)
        break if c == 0x11BA
        break if (0x11BC <= c) and (c <= 0x11C2)
        break if c == 0x11EB
        break if c == 0x11F0
        break if c == 0x11F9
        break if (0x1E00 <= c) and (c <= 0x1E9B)
        break if (0x1EA0 <= c) and (c <= 0x1EF9)
        break if (0x1F00 <= c) and (c <= 0x1F15)
        break if (0x1F18 <= c) and (c <= 0x1F1D)
        break if (0x1F20 <= c) and (c <= 0x1F45)
        break if (0x1F48 <= c) and (c <= 0x1F4D)
        break if (0x1F50 <= c) and (c <= 0x1F57)
        break if c == 0x1F59
        break if c == 0x1F5B
        break if c == 0x1F5D
        break if (0x1F5F <= c) and (c <= 0x1F7D)
        break if (0x1F80 <= c) and (c <= 0x1FB4)
        break if (0x1FB6 <= c) and (c <= 0x1FBC)
        break if c == 0x1FBE
        break if (0x1FC2 <= c) and (c <= 0x1FC4)
        break if (0x1FC6 <= c) and (c <= 0x1FCC)
        break if (0x1FD0 <= c) and (c <= 0x1FD3)
        break if (0x1FD6 <= c) and (c <= 0x1FDB)
        break if (0x1FE0 <= c) and (c <= 0x1FEC)
        break if (0x1FF2 <= c) and (c <= 0x1FF4)
        break if (0x1FF6 <= c) and (c <= 0x1FFC)
        break if (0x20D0 <= c) and (c <= 0x20DC)
        break if c == 0x20E1
        break if c == 0x2126
        break if (0x212A <= c) and (c <= 0x212B)
        break if c == 0x212E
        break if (0x2180 <= c) and (c <= 0x2182)
        break if c == 0x3005
        break if c == 0x3007
        break if (0x3021 <= c) and (c <= 0x3029)
        break if (0x302A <= c) and (c <= 0x302F)
        break if (0x3031 <= c) and (c <= 0x3035)
        break if (0x3041 <= c) and (c <= 0x3094)
        break if c == 0x3099
        break if c == 0x309A
        break if (0x309D <= c) and (c <= 0x309E)
        break if (0x30A1 <= c) and (c <= 0x30FA)
        break if (0x30FC <= c) and (c <= 0x30FE)
        break if (0x3105 <= c) and (c <= 0x312C)
        break if (0x4E00 <= c) and (c <= 0x9FA5)
        break if (0xAC00 <= c) and (c <= 0xD7A3)
    		raise "illegal name start character"
      end
			start = false
    
    	#while true do
        next if (0x0030 <= c) and (c <= 0x0039)
        next if (0x0041 <= c) and (c <= 0x005A)
        next if (0x0061 <= c) and (c <= 0x007A)
        next if c == ?.
        next if c == ?-
        next if c == ?_
        next if c == ?:
        next if c == 0x00B7
        next if (0x00C0 <= c) and (c <= 0x00D6)
        next if (0x00D8 <= c) and (c <= 0x00F6)
        next if (0x00F8 <= c) and (c <= 0x00FF)
        next if (0x0100 <= c) and (c <= 0x0131)
        next if (0x0134 <= c) and (c <= 0x013E)
        next if (0x0141 <= c) and (c <= 0x0148)
        next if (0x014A <= c) and (c <= 0x017E)
        next if (0x0180 <= c) and (c <= 0x01C3)
        next if (0x01CD <= c) and (c <= 0x01F0)
        next if (0x01F4 <= c) and (c <= 0x01F5)
        next if (0x01FA <= c) and (c <= 0x0217)
        next if (0x0250 <= c) and (c <= 0x02A8)
        next if (0x02BB <= c) and (c <= 0x02C1)
        next if c == 0x02D0
        next if c == 0x02D1
        next if (0x0300 <= c) and (c <= 0x0345)
        next if (0x0360 <= c) and (c <= 0x0361)
        next if c == 0x0386
        next if c == 0x0387
        next if (0x0388 <= c) and (c <= 0x038A)
        next if c == 0x038C
        next if (0x038E <= c) and (c <= 0x03A1)
        next if (0x03A3 <= c) and (c <= 0x03CE)
        next if (0x03D0 <= c) and (c <= 0x03D6)
        next if c == 0x03DA
        next if c == 0x03DC
        next if c == 0x03DE
        next if c == 0x03E0
        next if (0x03E2 <= c) and (c <= 0x03F3)
        next if (0x0401 <= c) and (c <= 0x040C)
        next if (0x040E <= c) and (c <= 0x044F)
        next if (0x0451 <= c) and (c <= 0x045C)
        next if (0x045E <= c) and (c <= 0x0481)
        next if (0x0483 <= c) and (c <= 0x0486)
        next if (0x0490 <= c) and (c <= 0x04C4)
        next if (0x04C7 <= c) and (c <= 0x04C8)
        next if (0x04CB <= c) and (c <= 0x04CC)
        next if (0x04D0 <= c) and (c <= 0x04EB)
        next if (0x04EE <= c) and (c <= 0x04F5)
        next if (0x04F8 <= c) and (c <= 0x04F9)
        next if (0x0531 <= c) and (c <= 0x0556)
        next if c == 0x0559
        next if (0x0561 <= c) and (c <= 0x0586)
        next if (0x0591 <= c) and (c <= 0x05A1)
        next if (0x05A3 <= c) and (c <= 0x05B9)
        next if (0x05BB <= c) and (c <= 0x05BD)
        next if c == 0x05BF
        next if (0x05C1 <= c) and (c <= 0x05C2)
        next if c == 0x05C4
        next if (0x05D0 <= c) and (c <= 0x05EA)
        next if (0x05F0 <= c) and (c <= 0x05F2)
        next if (0x0621 <= c) and (c <= 0x063A)
        next if c == 0x0640
        next if (0x0641 <= c) and (c <= 0x064A)
        next if (0x064B <= c) and (c <= 0x0652)
        next if (0x0660 <= c) and (c <= 0x0669)
        next if c == 0x0670
        next if (0x0671 <= c) and (c <= 0x06B7)
        next if (0x06BA <= c) and (c <= 0x06BE)
        next if (0x06C0 <= c) and (c <= 0x06CE)
        next if (0x06D0 <= c) and (c <= 0x06D3)
        next if c == 0x06D5
        next if (0x06D6 <= c) and (c <= 0x06DC)
        next if (0x06DD <= c) and (c <= 0x06DF)
        next if (0x06E0 <= c) and (c <= 0x06E4)
        next if (0x06E5 <= c) and (c <= 0x06E6)
        next if (0x06E7 <= c) and (c <= 0x06E8)
        next if (0x06EA <= c) and (c <= 0x06ED)
        next if (0x06F0 <= c) and (c <= 0x06F9)
        next if (0x0901 <= c) and (c <= 0x0903)
        next if (0x0905 <= c) and (c <= 0x0939)
        next if c == 0x093C
        next if c == 0x093D
        next if (0x093E <= c) and (c <= 0x094C)
        next if c == 0x094D
        next if (0x0951 <= c) and (c <= 0x0954)
        next if (0x0958 <= c) and (c <= 0x0961)
        next if (0x0962 <= c) and (c <= 0x0963)
        next if (0x0966 <= c) and (c <= 0x096F)
        next if (0x0981 <= c) and (c <= 0x0983)
        next if (0x0985 <= c) and (c <= 0x098C)
        next if (0x098F <= c) and (c <= 0x0990)
        next if (0x0993 <= c) and (c <= 0x09A8)
        next if (0x09AA <= c) and (c <= 0x09B0)
        next if c == 0x09B2
        next if (0x09B6 <= c) and (c <= 0x09B9)
        next if c == 0x09BC
        next if c == 0x09BE
        next if c == 0x09BF
        next if (0x09C0 <= c) and (c <= 0x09C4)
        next if (0x09C7 <= c) and (c <= 0x09C8)
        next if (0x09CB <= c) and (c <= 0x09CD)
        next if c == 0x09D7
        next if (0x09DC <= c) and (c <= 0x09DD)
        next if (0x09DF <= c) and (c <= 0x09E1)
        next if (0x09E2 <= c) and (c <= 0x09E3)
        next if (0x09E6 <= c) and (c <= 0x09EF)
        next if (0x09F0 <= c) and (c <= 0x09F1)
        next if c == 0x0A02
        next if (0x0A05 <= c) and (c <= 0x0A0A)
        next if (0x0A0F <= c) and (c <= 0x0A10)
        next if (0x0A13 <= c) and (c <= 0x0A28)
        next if (0x0A2A <= c) and (c <= 0x0A30)
        next if (0x0A32 <= c) and (c <= 0x0A33)
        next if (0x0A35 <= c) and (c <= 0x0A36)
        next if (0x0A38 <= c) and (c <= 0x0A39)
        next if c == 0x0A3C
        next if c == 0x0A3E
        next if c == 0x0A3F
        next if (0x0A40 <= c) and (c <= 0x0A42)
        next if (0x0A47 <= c) and (c <= 0x0A48)
        next if (0x0A4B <= c) and (c <= 0x0A4D)
        next if (0x0A59 <= c) and (c <= 0x0A5C)
        next if c == 0x0A5E
        next if (0x0A66 <= c) and (c <= 0x0A6F)
        next if (0x0A70 <= c) and (c <= 0x0A71)
        next if (0x0A72 <= c) and (c <= 0x0A74)
        next if (0x0A81 <= c) and (c <= 0x0A83)
        next if (0x0A85 <= c) and (c <= 0x0A8B)
        next if c == 0x0A8D
        next if (0x0A8F <= c) and (c <= 0x0A91)
        next if (0x0A93 <= c) and (c <= 0x0AA8)
        next if (0x0AAA <= c) and (c <= 0x0AB0)
        next if (0x0AB2 <= c) and (c <= 0x0AB3)
        next if (0x0AB5 <= c) and (c <= 0x0AB9)
        next if c == 0x0ABC
        next if c == 0x0ABD
        next if (0x0ABE <= c) and (c <= 0x0AC5)
        next if (0x0AC7 <= c) and (c <= 0x0AC9)
        next if (0x0ACB <= c) and (c <= 0x0ACD)
        next if c == 0x0AE0
        next if (0x0AE6 <= c) and (c <= 0x0AEF)
        next if (0x0B01 <= c) and (c <= 0x0B03)
        next if (0x0B05 <= c) and (c <= 0x0B0C)
        next if (0x0B0F <= c) and (c <= 0x0B10)
        next if (0x0B13 <= c) and (c <= 0x0B28)
        next if (0x0B2A <= c) and (c <= 0x0B30)
        next if (0x0B32 <= c) and (c <= 0x0B33)
        next if (0x0B36 <= c) and (c <= 0x0B39)
        next if c == 0x0B3C
        next if c == 0x0B3D
        next if (0x0B3E <= c) and (c <= 0x0B43)
        next if (0x0B47 <= c) and (c <= 0x0B48)
        next if (0x0B4B <= c) and (c <= 0x0B4D)
        next if (0x0B56 <= c) and (c <= 0x0B57)
        next if (0x0B5C <= c) and (c <= 0x0B5D)
        next if (0x0B5F <= c) and (c <= 0x0B61)
        next if (0x0B66 <= c) and (c <= 0x0B6F)
        next if (0x0B82 <= c) and (c <= 0x0B83)
        next if (0x0B85 <= c) and (c <= 0x0B8A)
        next if (0x0B8E <= c) and (c <= 0x0B90)
        next if (0x0B92 <= c) and (c <= 0x0B95)
        next if (0x0B99 <= c) and (c <= 0x0B9A)
        next if c == 0x0B9C
        next if (0x0B9E <= c) and (c <= 0x0B9F)
        next if (0x0BA3 <= c) and (c <= 0x0BA4)
        next if (0x0BA8 <= c) and (c <= 0x0BAA)
        next if (0x0BAE <= c) and (c <= 0x0BB5)
        next if (0x0BB7 <= c) and (c <= 0x0BB9)
        next if (0x0BBE <= c) and (c <= 0x0BC2)
        next if (0x0BC6 <= c) and (c <= 0x0BC8)
        next if (0x0BCA <= c) and (c <= 0x0BCD)
        next if c == 0x0BD7
        next if (0x0BE7 <= c) and (c <= 0x0BEF)
        next if (0x0C01 <= c) and (c <= 0x0C03)
        next if (0x0C05 <= c) and (c <= 0x0C0C)
        next if (0x0C0E <= c) and (c <= 0x0C10)
        next if (0x0C12 <= c) and (c <= 0x0C28)
        next if (0x0C2A <= c) and (c <= 0x0C33)
        next if (0x0C35 <= c) and (c <= 0x0C39)
        next if (0x0C3E <= c) and (c <= 0x0C44)
        next if (0x0C46 <= c) and (c <= 0x0C48)
        next if (0x0C4A <= c) and (c <= 0x0C4D)
        next if (0x0C55 <= c) and (c <= 0x0C56)
        next if (0x0C60 <= c) and (c <= 0x0C61)
        next if (0x0C66 <= c) and (c <= 0x0C6F)
        next if (0x0C82 <= c) and (c <= 0x0C83)
        next if (0x0C85 <= c) and (c <= 0x0C8C)
        next if (0x0C8E <= c) and (c <= 0x0C90)
        next if (0x0C92 <= c) and (c <= 0x0CA8)
        next if (0x0CAA <= c) and (c <= 0x0CB3)
        next if (0x0CB5 <= c) and (c <= 0x0CB9)
        next if (0x0CBE <= c) and (c <= 0x0CC4)
        next if (0x0CC6 <= c) and (c <= 0x0CC8)
        next if (0x0CCA <= c) and (c <= 0x0CCD)
        next if (0x0CD5 <= c) and (c <= 0x0CD6)
        next if c == 0x0CDE
        next if (0x0CE0 <= c) and (c <= 0x0CE1)
        next if (0x0CE6 <= c) and (c <= 0x0CEF)
        next if (0x0D02 <= c) and (c <= 0x0D03)
        next if (0x0D05 <= c) and (c <= 0x0D0C)
        next if (0x0D0E <= c) and (c <= 0x0D10)
        next if (0x0D12 <= c) and (c <= 0x0D28)
        next if (0x0D2A <= c) and (c <= 0x0D39)
        next if (0x0D3E <= c) and (c <= 0x0D43)
        next if (0x0D46 <= c) and (c <= 0x0D48)
        next if (0x0D4A <= c) and (c <= 0x0D4D)
        next if c == 0x0D57
        next if (0x0D60 <= c) and (c <= 0x0D61)
        next if (0x0D66 <= c) and (c <= 0x0D6F)
        next if (0x0E01 <= c) and (c <= 0x0E2E)
        next if c == 0x0E30
        next if c == 0x0E31
        next if (0x0E32 <= c) and (c <= 0x0E33)
        next if (0x0E34 <= c) and (c <= 0x0E3A)
        next if (0x0E40 <= c) and (c <= 0x0E45)
        next if c == 0x0E46
        next if (0x0E47 <= c) and (c <= 0x0E4E)
        next if (0x0E50 <= c) and (c <= 0x0E59)
        next if (0x0E81 <= c) and (c <= 0x0E82)
        next if c == 0x0E84
        next if (0x0E87 <= c) and (c <= 0x0E88)
        next if c == 0x0E8A
        next if c == 0x0E8D
        next if (0x0E94 <= c) and (c <= 0x0E97)
        next if (0x0E99 <= c) and (c <= 0x0E9F)
        next if (0x0EA1 <= c) and (c <= 0x0EA3)
        next if c == 0x0EA5
        next if c == 0x0EA7
        next if (0x0EAA <= c) and (c <= 0x0EAB)
        next if (0x0EAD <= c) and (c <= 0x0EAE)
        next if c == 0x0EB0
        next if c == 0x0EB1
        next if (0x0EB2 <= c) and (c <= 0x0EB3)
        next if (0x0EB4 <= c) and (c <= 0x0EB9)
        next if (0x0EBB <= c) and (c <= 0x0EBC)
        next if c == 0x0EBD
        next if (0x0EC0 <= c) and (c <= 0x0EC4)
        next if c == 0x0EC6
        next if (0x0EC8 <= c) and (c <= 0x0ECD)
        next if (0x0ED0 <= c) and (c <= 0x0ED9)
        next if (0x0F18 <= c) and (c <= 0x0F19)
        next if (0x0F20 <= c) and (c <= 0x0F29)
        next if c == 0x0F35
        next if c == 0x0F37
        next if c == 0x0F39
        next if c == 0x0F3E
        next if c == 0x0F3F
        next if (0x0F40 <= c) and (c <= 0x0F47)
        next if (0x0F49 <= c) and (c <= 0x0F69)
        next if (0x0F71 <= c) and (c <= 0x0F84)
        next if (0x0F86 <= c) and (c <= 0x0F8B)
        next if (0x0F90 <= c) and (c <= 0x0F95)
        next if c == 0x0F97
        next if (0x0F99 <= c) and (c <= 0x0FAD)
        next if (0x0FB1 <= c) and (c <= 0x0FB7)
        next if c == 0x0FB9
        next if (0x10A0 <= c) and (c <= 0x10C5)
        next if (0x10D0 <= c) and (c <= 0x10F6)
        next if c == 0x1100
        next if (0x1102 <= c) and (c <= 0x1103)
        next if (0x1105 <= c) and (c <= 0x1107)
        next if c == 0x1109
        next if (0x110B <= c) and (c <= 0x110C)
        next if (0x110E <= c) and (c <= 0x1112)
        next if c == 0x113C
        next if c == 0x113E
        next if c == 0x1140
        next if c == 0x114C
        next if c == 0x114E
        next if c == 0x1150
        next if (0x1154 <= c) and (c <= 0x1155)
        next if c == 0x1159
        next if (0x115F <= c) and (c <= 0x1161)
        next if c == 0x1163
        next if c == 0x1165
        next if c == 0x1167
        next if c == 0x1169
        next if (0x116D <= c) and (c <= 0x116E)
        next if (0x1172 <= c) and (c <= 0x1173)
        next if c == 0x1175
        next if c == 0x119E
        next if c == 0x11A8
        next if c == 0x11AB
        next if (0x11AE <= c) and (c <= 0x11AF)
        next if (0x11B7 <= c) and (c <= 0x11B8)
        next if c == 0x11BA
        next if (0x11BC <= c) and (c <= 0x11C2)
        next if c == 0x11EB
        next if c == 0x11F0
        next if c == 0x11F9
        next if (0x1E00 <= c) and (c <= 0x1E9B)
        next if (0x1EA0 <= c) and (c <= 0x1EF9)
        next if (0x1F00 <= c) and (c <= 0x1F15)
        next if (0x1F18 <= c) and (c <= 0x1F1D)
        next if (0x1F20 <= c) and (c <= 0x1F45)
        next if (0x1F48 <= c) and (c <= 0x1F4D)
        next if (0x1F50 <= c) and (c <= 0x1F57)
        next if c == 0x1F59
        next if c == 0x1F5B
        next if c == 0x1F5D
        next if (0x1F5F <= c) and (c <= 0x1F7D)
        next if (0x1F80 <= c) and (c <= 0x1FB4)
        next if (0x1FB6 <= c) and (c <= 0x1FBC)
        next if c == 0x1FBE
        next if (0x1FC2 <= c) and (c <= 0x1FC4)
        next if (0x1FC6 <= c) and (c <= 0x1FCC)
        next if (0x1FD0 <= c) and (c <= 0x1FD3)
        next if (0x1FD6 <= c) and (c <= 0x1FDB)
        next if (0x1FE0 <= c) and (c <= 0x1FEC)
        next if (0x1FF2 <= c) and (c <= 0x1FF4)
        next if (0x1FF6 <= c) and (c <= 0x1FFC)
        next if (0x20D0 <= c) and (c <= 0x20DC)
        next if c == 0x20E1
        next if c == 0x2126
        next if (0x212A <= c) and (c <= 0x212B)
        next if c == 0x212E
        next if (0x2180 <= c) and (c <= 0x2182)
        next if c == 0x3005
        next if c == 0x3007
        next if (0x3021 <= c) and (c <= 0x3029)
        next if (0x302A <= c) and (c <= 0x302F)
        next if (0x3031 <= c) and (c <= 0x3035)
        next if (0x3041 <= c) and (c <= 0x3094)
        next if c == 0x3099
        next if c == 0x309A
        next if (0x309D <= c) and (c <= 0x309E)
        next if (0x30A1 <= c) and (c <= 0x30FA)
        next if (0x30FC <= c) and (c <= 0x30FE)
        next if (0x3105 <= c) and (c <= 0x312C)
        next if (0x4E00 <= c) and (c <= 0x9FA5)
        next if (0xAC00 <= c) and (c <= 0xD7A3)
    
    		raise "illegal name character"
      #end
  	end
	end
end
