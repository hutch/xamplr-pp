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

class XppTestEventTypes < Xampl_PP
	def setType(v)
		@type = v
	end
end

class TC_EventTypes < Lapidary::TestCase
  def setup
		@xpp = XppTestEventTypes.new
  end
  #def tearDown
  #end

  def testSTART_DOCUMENT

		@xpp.setType Xampl_PP::START_DOCUMENT
	  assert @xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testEND_DOCUMENT

		@xpp.setType Xampl_PP::END_DOCUMENT
	  assert !@xpp.startDocument?
	  assert @xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testSTART_ELEMENT

		@xpp.setType Xampl_PP::START_ELEMENT
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert @xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testEND_ELEMENT

		@xpp.setType Xampl_PP::END_ELEMENT
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert @xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testTEXT

		@xpp.setType Xampl_PP::TEXT
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert @xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testCDATA_SECTION

		@xpp.setType Xampl_PP::CDATA_SECTION
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert @xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testENTITY_REF

		@xpp.setType Xampl_PP::ENTITY_REF
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert @xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testIGNORABLE_WHITESPACE

		@xpp.setType Xampl_PP::IGNORABLE_WHITESPACE
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert @xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testPROCESSING_INSTRUCTION

		@xpp.setType Xampl_PP::PROCESSING_INSTRUCTION
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert @xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert !@xpp.doctype?
  end

  def testCOMMENT

		@xpp.setType Xampl_PP::COMMENT
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert @xpp.comment?
	  assert !@xpp.doctype?
  end

  def testDOCUMENT_DECLARATION

		@xpp.setType Xampl_PP::DOCTYPE
	  assert !@xpp.startDocument?
	  assert !@xpp.endDocument?
	  assert !@xpp.startElement?
	  assert !@xpp.endElement?
	  assert !@xpp.text?
	  assert !@xpp.cdata?
	  assert !@xpp.entityRef?
	  assert !@xpp.ignorableWhitespace?
	  assert !@xpp.processingInstruction?
	  assert !@xpp.comment?
	  assert @xpp.doctype?
  end
end

