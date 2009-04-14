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

class XppTestNamespace < Xampl_PP
	def doPushText(c)
		pushTextBuffer(c)
	end

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
		@elementQName.push (nil == prefix) ? name : (prefix + ':' + name)
		@elementNamespace.push prefix
	end

	def doPeekType
		peekType
	end
end

class TC_Namespace < Lapidary::TestCase
  def setup
		@xpp = XppTestParse.new

		@xppReporting = XppTestParse.new
		@xppReporting.reportNamespaceAttributes = true
  end
  #def tearDown
  #end

  def testNSDefault
		pp = @xpp
		pp.input = "<start attr1='value1' attr2='value2' xmlns='default-namespace'>"

		eventType = pp.nextEvent
		assert pp.startElement?
		assert 'start' == pp.name
		assert 1 == pp.elementName.length
		assert 1 == pp.elementQName.length
		assert 1 == pp.elementNamespace.length
		assert 1 == pp.elementPrefix.length

		assert 2 == pp.attributeName.length
		assert 2 == pp.attributeQName.length
		assert 2 == pp.attributeNamespace.length
		assert 2 == pp.attributePrefix.length
		assert 2 == pp.attributeValue.length

		assert 'start' == pp.elementName[0]
		assert 'start' == pp.elementQName[0]
		assert 'default-namespace' == pp.elementNamespace[0]
		assert nil == pp.elementPrefix[0]

		assert 'attr1' == pp.attributeName[0]
		assert 'attr1' == pp.attributeQName[0]
		assert nil == pp.attributeNamespace[0]
		assert nil == pp.attributePrefix[0]
		assert 'value1' == pp.attributeValue[0]

		assert 'attr2' == pp.attributeName[1]
		assert 'attr2' == pp.attributeQName[1]
		assert nil == pp.attributeNamespace[1]
		assert nil == pp.attributePrefix[1]
		assert 'value2' == pp.attributeValue[1]
  end

  def testNSDefaultNSReporting
		pp = @xppReporting
		pp.input = "<start attr1='value1' attr2='value2' xmlns='default-namespace'>"

		eventType = pp.nextEvent
		assert pp.startElement?
		assert 'start' == pp.name
		assert 1 == pp.elementName.length
		assert 1 == pp.elementQName.length
		assert 1 == pp.elementNamespace.length
		assert 1 == pp.elementPrefix.length

		assert 3 == pp.attributeName.length
		assert 3 == pp.attributeQName.length
		assert 3 == pp.attributeNamespace.length
		assert 3 == pp.attributePrefix.length
		assert 3 == pp.attributeValue.length

		assert 'start' == pp.elementName[0]
		assert 'start' == pp.elementQName[0]
		assert 'default-namespace' == pp.elementNamespace[0]
		assert nil == pp.elementPrefix[0]

		assert 'attr1' == pp.attributeName[0]
		assert 'attr1' == pp.attributeQName[0]
		assert nil == pp.attributeNamespace[0]
		assert nil == pp.attributePrefix[0]
		assert 'value1' == pp.attributeValue[0]

		assert 'attr2' == pp.attributeName[1]
		assert 'attr2' == pp.attributeQName[1]
		assert nil == pp.attributeNamespace[1]
		assert nil == pp.attributePrefix[1]
		assert 'value2' == pp.attributeValue[1]

		assert nil == pp.attributeName[2]
		assert 'xmlns' == pp.attributeQName[2]
		assert 'http://www.w3.org/2000/xmlns/' == pp.attributeNamespace[2]
		assert 'xmlns' == pp.attributePrefix[2]
		assert 'default-namespace' == pp.attributeValue[2]
  end

  def testNSqualified000
		pp = @xppReporting
		pp.input = "<ns:start attr1='value1' attr2='value2' xmlns='default-namespace' xmlns:ns='ns-namespace'>"

		eventType = pp.nextEvent
		assert pp.startElement?
		assert 'start' == pp.name
		assert 1 == pp.elementName.length
		assert 4 == pp.attributeName.length

		assert 'start' == pp.name
		assert 'ns:start' == pp.qname
		assert 'ns' == pp.prefix
		assert 'ns-namespace' == pp.namespace

		assert 'ns' == pp.attributeName[3]
		assert 'xmlns:ns' == pp.attributeQName[3]
		assert 'ns-namespace' == pp.attributeNamespace[3]
		assert 'xmlns' == pp.attributePrefix[3]
		assert 'ns-namespace' == pp.attributeValue[3]
  end

  def testNSqualified001
		pp = @xppReporting
		pp.input = "<ns:start attr1='value1' ns:attr2='value2' xmlns='default-namespace' xmlns:ns='ns-namespace'>"

		eventType = pp.nextEvent
		assert pp.startElement?
		assert 'start' == pp.name
		assert 1 == pp.elementName.length
		assert 4 == pp.attributeName.length

		assert 'start' == pp.name
		assert 'ns:start' == pp.qname
		assert 'ns' == pp.prefix
		assert 'ns-namespace' == pp.namespace

		assert 'attr2' == pp.attributeName[1]
		assert 'ns:attr2' == pp.attributeQName[1]
		assert 'ns-namespace' == pp.attributeNamespace[1]
		assert 'ns' == pp.attributePrefix[1]
		assert 'value2' == pp.attributeValue[1]
  end

  def testNSqualifiedNonExistant
		pp = @xppReporting
		pp.input = "<ns:start attr1='value1' x:attr2='value2' xmlns='default-namespace' xmlns:ns='ns-namespace'>"
		assertRaises( RuntimeError ) { eventType = pp.nextEvent }

		pp = @xppReporting
		pp.input = "<x:start attr1='value1' ns:attr2='value2' xmlns='default-namespace' xmlns:ns='ns-namespace'>"
		assertRaises( RuntimeError ) { eventType = pp.nextEvent }
  end

end

