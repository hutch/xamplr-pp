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
require "Lapidary/TestCase"
require "xampl-pp"

class XppTestParse < Xampl_PP
	def doParseText(delimiter, resolve)
		parseText(delimiter, resolve)
	end

	def getTextBuffer
		@textBuffer
	end

	def clearTextBuffer
		@textBuffer = ''
	end

	def makeStart
		@type = START_ELEMENT
	end

	def deeper(prefix, name)
		@elementPrefix.push prefix
		@elementName.push name
		@elementQName.push ((nil == prefix) ? name : (prefix + ':' + name))
		@elementNamespace.push prefix
	end

	def doPeekType
		peekType
	end
end

class TC_Parse < Lapidary::TestCase
  def setup
		@xpp = XppTestParse.new
  end
  #def tearDown
  #end

	def testParseText
		@xpp.input = "dummy'"
		@xpp.doParseText(?', true) # for vim: '
		assert "dummy" == @xpp.getTextBuffer

		@xpp.input = "dummy<start>"
		@xpp.doParseText(?<, true)
		assert "dummy" == @xpp.getTextBuffer

		@xpp.input = "dummy&lt;dummy"
		@xpp.doParseText(?', true) # for vim: '
		assert "dummy<dummy" == @xpp.getTextBuffer

		@xpp.input = "dummy&lt;dummy'"
		@xpp.doParseText(?', false) # for vim: '
		assert "dummy" == @xpp.getTextBuffer

		@xpp.input = "dummy&junk;dummy'"
		@xpp.doParseText(?', false) # for vim: '
		assert "dummy" == @xpp.getTextBuffer

		@xpp.input = "dummy&junk;dummy'"
		assertRaises( RuntimeError ) {
			@xpp.doParseText(?', true) # for vim: '
		}
	end

  def testEndDocumentPeekType
		@xpp.input = ""
		assert Xampl_PP::END_DOCUMENT == @xpp.doPeekType
		@xpp.input = "\000"
		assert Xampl_PP::END_DOCUMENT == @xpp.doPeekType
  end

  def testEntityRefPeekType
		@xpp.input = "&lt;"
		assert Xampl_PP::ENTITY_REF == @xpp.doPeekType
  end

  def testTextPeekType
		@xpp.input = "text"
		assert Xampl_PP::TEXT == @xpp.doPeekType
  end

  def testEndElementPeekType
		@xpp.input = "</end>"
		assert Xampl_PP::END_ELEMENT == @xpp.doPeekType
  end

  def testCdataSectionPeekType
		@xpp.input = "<![CDATA[blah]]>"
		assert Xampl_PP::UNDECIDED_TYPE == @xpp.doPeekType
  end

  def testProcessingPeekType
		@xpp.input = "<?do something?>"
		assert Xampl_PP::UNDECIDED_TYPE == @xpp.doPeekType
  end

  def testCommentPeekType
		@xpp.input = "<!-- comment -->"
		assert Xampl_PP::UNDECIDED_TYPE == @xpp.doPeekType
  end

  def testStartElementPeekType
		@xpp.input = "<start>"
		assert Xampl_PP::START_ELEMENT == @xpp.doPeekType
  end

  def testEndDocumentNextEvent
			@xpp.input = ""
			#@xpp.checkWellFormed = false
			eventType = @xpp.nextEvent
			assert @xpp.endDocument?

			@xpp.input = "\000"
			eventType = @xpp.nextEvent
			assert @xpp.endDocument?
  end

  def testEntityRefNextEvent
		@xpp.input = "&lt;"
		#@xpp.checkWellFormed = false
		eventType = @xpp.nextEvent
		assert @xpp.entityRef?
		assert !@xpp.unresolvedEntity
		assert 'lt' == @xpp.name
		assert '<' == @xpp.text

		@xpp.input = "&blah;"
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }

		@xpp.input = "&#x20;"
		eventType = @xpp.nextEvent
		assert @xpp.entityRef?
		assert !@xpp.unresolvedEntity
		assert '#x20' == @xpp.name
		assert 0x20 == @xpp.text[0]

		@xpp.input = "&#32;"
		eventType = @xpp.nextEvent
		assert @xpp.entityRef?
		assert !@xpp.unresolvedEntity
		assert '#32' == @xpp.name
		assert 32 == @xpp.text[0]
  end

  def testEndElementNextEvent
		# no start element...
		@xpp.input = "</end>"
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }

		# fake a start element, illegal name
		@xpp.input = "</*>"
		@xpp.deeper(nil, "*")
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }

		# fake a start element. This should work. make sure that we don't have
		# and unresolved entity stuff nor anything on the element stacks
		@xpp.input = "</end>"
		@xpp.deeper(nil, 'end')
		eventType = @xpp.nextEvent
		assert @xpp.endElement?
		assert !@xpp.unresolvedEntity
		assert 'end' == @xpp.name
		assert 0 == @xpp.elementName.length
		assert 0 == @xpp.elementQName.length
		assert 0 == @xpp.elementNamespace.length
		assert 0 == @xpp.elementPrefix.length

		# fake a start element, with a namespace
		@xpp.input = "</space:end>"
		@xpp.deeper('space', 'end')
		eventType = @xpp.nextEvent
		assert @xpp.endElement?
		assert !@xpp.unresolvedEntity
		assert 'end' == @xpp.name

		# fake a start element, different from the end
		@xpp.input = "</end>"
		@xpp.deeper(nil, 'start')
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }
  end

  def testStartElementNextEvent
		@xpp.input = "<start>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assert !@xpp.unresolvedEntity
		assert 1 == @xpp.elementName.length
		assert 'start' == @xpp.name
		assert !@xpp.emptyElement
		assert 1 == @xpp.elementName.length
		assert 1 == @xpp.elementQName.length
		assert 1 == @xpp.elementNamespace.length
		assert 1 == @xpp.elementPrefix.length
		assert 0 == @xpp.attributeName.length
		assert 0 == @xpp.attributeQName.length
		assert 0 == @xpp.attributeNamespace.length
		assert 0 == @xpp.attributePrefix.length
		assert 0 == @xpp.attributeValue.length

		assert 'start' == @xpp.elementName[0]
		assert 'start' == @xpp.elementQName[0]
		assert nil == @xpp.elementNamespace[0]
		assert nil == @xpp.elementPrefix[0]

		@xpp.input = "<start/>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assert !@xpp.unresolvedEntity
		assert 0 == @xpp.elementName.length
		assert 'start' == @xpp.name
		assert @xpp.emptyElement
		assert 0 == @xpp.elementName.length
		assert 0 == @xpp.elementQName.length
		assert 0 == @xpp.elementNamespace.length
		assert 0 == @xpp.elementPrefix.length
		assert 0 == @xpp.attributeName.length
		assert 0 == @xpp.attributeQName.length
		assert 0 == @xpp.attributeNamespace.length
		assert 0 == @xpp.attributePrefix.length
		assert 0 == @xpp.attributeValue.length
		eventType = @xpp.nextEvent
		assert @xpp.endElement?

		@xpp.input = "<start"
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }

		@xpp.input = "<start <>"
		assertRaises( RuntimeError ) { eventType = @xpp.nextEvent }

		@xpp.input = "<start attr='value'/>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assert !@xpp.unresolvedEntity
		assert 0 == @xpp.elementName.length
		assert 'start' == @xpp.name
		assert @xpp.emptyElement
		assert 0 == @xpp.elementName.length
		assert 0 == @xpp.elementQName.length
		assert 0 == @xpp.elementNamespace.length
		assert 0 == @xpp.elementPrefix.length
		assert 1 == @xpp.attributeName.length
		assert 1 == @xpp.attributeQName.length
		assert 1 == @xpp.attributeNamespace.length
		assert 1 == @xpp.attributePrefix.length
		assert 1 == @xpp.attributeValue.length
		assert 'attr' == @xpp.attributeName[0]
		assert 'attr' == @xpp.attributeQName[0]
		assert nil == @xpp.attributeNamespace[0]
		assert nil == @xpp.attributePrefix[0]
		assert 'value' == @xpp.attributeValue[0]

  end

  def testNSAttributeCount
		@xpp.input = "<start attr1='value1'>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assert 'start' == @xpp.name
		assert 1 == @xpp.elementName.length
		assert 1 == @xpp.elementQName.length
		assert 1 == @xpp.elementNamespace.length
		assert 1 == @xpp.elementPrefix.length

		assert 1 == @xpp.attributeName.length
		assert 1 == @xpp.attributeQName.length
		assert 1 == @xpp.attributeNamespace.length
		assert 1 == @xpp.attributePrefix.length
		assert 1 == @xpp.attributeValue.length

		assert 'start' == @xpp.elementName[0]
		assert 'start' == @xpp.elementQName[0]
		assert nil == @xpp.elementNamespace[0]
		assert nil == @xpp.elementPrefix[0]

		assert 'attr1' == @xpp.attributeName[0]
		assert 'attr1' == @xpp.attributeQName[0]
		assert nil == @xpp.attributeNamespace[0]
		assert nil == @xpp.attributePrefix[0]
		assert 'value1' == @xpp.attributeValue[0]

		@xpp.input = "<start attr1='value1' attr2='value2'>"
		#@xpp.checkWellFormed = false

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assert 'start' == @xpp.name
		assert 1 == @xpp.elementName.length
		assert 1 == @xpp.elementQName.length
		assert 1 == @xpp.elementNamespace.length
		assert 1 == @xpp.elementPrefix.length

		assert 2 == @xpp.attributeName.length
		assert 2 == @xpp.attributeQName.length
		assert 2 == @xpp.attributeNamespace.length
		assert 2 == @xpp.attributePrefix.length
		assert 2 == @xpp.attributeValue.length

		assert 'start' == @xpp.elementName[0]
		assert 'start' == @xpp.elementQName[0]
		assert nil == @xpp.elementNamespace[0]
		assert nil == @xpp.elementPrefix[0]

		assert 'attr1' == @xpp.attributeName[0]
		assert 'attr1' == @xpp.attributeQName[0]
		assert nil == @xpp.attributeNamespace[0]
		assert nil == @xpp.attributePrefix[0]
		assert 'value1' == @xpp.attributeValue[0]

		assert 'attr2' == @xpp.attributeName[1]
		assert 'attr2' == @xpp.attributeQName[1]
		assert nil == @xpp.attributeNamespace[1]
		assert nil == @xpp.attributePrefix[1]
		assert 'value2' == @xpp.attributeValue[1]
  end

  def testNSStartEnd000
		@xpp.input = "<start></start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?
	end

  def testNSStartEnd001
		@xpp.input = "<start  ></start  >"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?
	end

  def testAttributeEncoding
		@xpp.input = "<start attr=' this&#x0d;&#x0a; also  gets&#x20; normalized '/>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		assert 1 == @xpp.attributeName.length
		assert 1 == @xpp.attributeQName.length
		assert 1 == @xpp.attributeNamespace.length
		assert 1 == @xpp.attributePrefix.length
		assert 1 == @xpp.attributeValue.length

		assert 'attr' == @xpp.attributeName[0]
		assert 'attr' == @xpp.attributeQName[0]
		assert nil == @xpp.attributeNamespace[0]
		assert nil == @xpp.attributePrefix[0]
		assert " this\x0d\x0a also  gets  normalized " == @xpp.attributeValue[0]

		eventType = @xpp.nextEvent
		assert @xpp.endElement?
	end

  def testNSEmpty
		@xpp.input = "<root><start/><start/><start><start/></start></root>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?

		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?
		eventType = @xpp.nextEvent
		assert @xpp.endElement?

		eventType = @xpp.nextEvent
		assert @xpp.endElement?
	end

	def testNSSample
		s = <<END
<feeds xmlns:auth='http://www.recursive.ca/portal/authorization'
       xmlns='http://www.recursive.ca/feeds'>
  <feed id='generation purpose only'
				userContributionsAllowed='false'
				name='this is not supposed to be used'
				maxCount='15'
	      style='news'>
		<auth:excludeRole id='member'/>
  </feed>
</feeds>
END
		@xpp.input = s
		type = @xpp.nextEvent
		while not @xpp.endDocument? do
			if @xpp.startElement? then
			elsif @xpp.endElement? then
			end
			type = @xpp.nextEvent
		end
	end

	def testNSSample
		s = <<END
<feeds
xmlns:auth='http://www.recursive.ca/portal/authorization'
xmlns='http://www.recursive.ca/feeds'
>
<feed
id='generation purpose only'
userContributionsAllowed='false'
name='this is not supposed to be used'
maxCount='15'
style='news'
>
<auth:excludeRole
id='member'
/>
</feed
>
</feeds
>
END
		@xpp.input = s
		type = @xpp.nextEvent
		while not @xpp.endDocument? do
			if @xpp.startElement? then
			elsif @xpp.endElement? then
			end
			type = @xpp.nextEvent
		end
	end

  def testNSStartEndError000
		@xpp.input = "<start></end>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assertRaises( RuntimeError ) {
			eventType = @xpp.nextEvent
		}
	end

  def testNSStartEndError001
		@xpp.input = "<ns:start xmlns:ns='my-namespace'></start>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assertRaises( RuntimeError ) {
			eventType = @xpp.nextEvent
		}
	end

  def testNSStartEndError002
		@xpp.input = "<ns:start\n \t xmlns:ns='my-namespace'></start>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assertRaises( RuntimeError ) {
			eventType = @xpp.nextEvent
		}
	end

  def testNSStartEndError003
		#@xpp.input = '<ns:start\t \t xmlns:ns=\'my-namespace\'></start>'
		@xpp.input = "<ns:start\n \t xmlns:ns=\"my-namespace\"></start>"
		eventType = @xpp.nextEvent
		assert @xpp.startElement?
		assertRaises( RuntimeError ) {
			eventType = @xpp.nextEvent
		}
	end

  def testTextNextEvent000
		@xpp.input = "text"
		#@xpp.checkWellFormed = false
		eventType = @xpp.nextEvent
		assert @xpp.text?

		@xpp.input = "<start>blah</start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'blah' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.endElement?
  end

  def testTextNextEvent001
		@xpp.input = "<start>bl&lt;ah</start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'bl' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.entityRef?
		assert '<' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'ah' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.endElement?
  end

  def testTextNextEvent002
		@xpp.input = "<start a1='v1'\na2='v2'>blah</start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'blah' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.endElement?
  end

  def testTextNextEvent003
		@xpp.input = "<start><![CDATA[blah]]></start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.cdata?
		assert 'blah' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.endElement?

		@xpp.input = "<start>aaaa<![CDATA[bbbb]]>cccc</start>"

		eventType = @xpp.nextEvent
		assert @xpp.startElement?

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'aaaa' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.cdata?
		assert 'bbbb' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.text?
		assert 'cccc' == @xpp.text

		eventType = @xpp.nextEvent
		assert @xpp.endElement?


  end


  def testCdataSectionNextEvent
		#@xpp.checkWellFormed = false
		@xpp.input = "<![CDATA[blah]]>"
		eventType = @xpp.nextEvent
		assert @xpp.cdata?
		assert 'blah' == @xpp.text
  end

  def testProcessingNextEvent
		@xpp.input = "<?do something?>"
		eventType = @xpp.nextEvent
		assert @xpp.processingInstruction?
		assert 'do something' == @xpp.text
  end

  def testCommentNextEvent
		@xpp.input = "<!-- comment -->"
		eventType = @xpp.nextEvent
		assert @xpp.comment?
		assert ' comment ' == @xpp.text
  end

	def testDoctype
		@xpp.input = "<!DOCTYPE something 'else'>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " something 'else'" == @xpp.text

		@xpp.input = '<!DOCTYPE something "else">'
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert ' something "else"' == @xpp.text

		@xpp.input = "<!DOCTYPE <something 'else'>>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " <something 'else'>" == @xpp.text

		@xpp.input = "<!DOCTYPE something 'e<lse'>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " something 'e<lse'" == @xpp.text

		@xpp.input = "<!DOCTYPE something 'e>lse'>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " something 'e>lse'" == @xpp.text

		@xpp.input = "<!DOCTYPE <!-- quote ' in comment -->something else>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " <!-- quote ' in comment -->something else" == @xpp.text

		@xpp.input = "<!DOCTYPE <!-- quote ' in comment --><!-- another ' -->something else>"
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert " <!-- quote ' in comment --><!-- another ' -->something else" == @xpp.text

		@xpp.input = File.new("TC_Parse000.data")
		eventType = @xpp.nextEvent
		assert @xpp.doctype?
		assert "\n<!-- quote ' in comment -->\n<!-- another ' -->\nsomething\nelse\n" == @xpp.text
		assert 6 == @xpp.line
		assert 1 == @xpp.column

	end

end
