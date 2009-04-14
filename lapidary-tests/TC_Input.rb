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

class XppTestInput < Xampl_PP
	def input
		@input
	end

	def inputBuffer
		@inputBuffer
	end

	def doSkipWhitespace
		skipWhitespace
	end

	def doRead
		read
	end

	def doExpect(c)
		expect(c)
	end

	def doPeekAt0
		peekAt0
	end

	def doPeekAt1
		peekAt1
	end

	#def peek
		#@peek
	#end
end

class TC_Input < Lapidary::TestCase
  def setup
		@xpp = XppTestInput.new
  end
  #def tearDown
  #end

  def testInitialStateWithStringSource
		@xpp.input = "hello"

		assert @xpp.input == nil
		assert @xpp.inputBuffer == "hello"
		assert @xpp.column == 0

		assert @xpp.startDocument?

		assert @xpp.line == 1
		assert @xpp.column == 0
		assert @xpp.elementName.length == 0

		assert @xpp.name == nil
		assert @xpp.namespace == nil
		assert @xpp.prefix == nil

		assert @xpp.attributeName.length == 0
		assert @xpp.attributeNamespace.length == 0
		assert @xpp.attributePrefix.length == 0
		assert @xpp.attributeValue.length == 0
  end

  def testInitialStateWithIOSource
		@xpp.input = STDIN

		assert @xpp.input == STDIN
		assert @xpp.inputBuffer == nil
		assert @xpp.column == 0

		assert @xpp.startDocument?

		assert @xpp.line == 0
		assert @xpp.column == 0
		assert @xpp.elementName.length == 0

		assert @xpp.name == nil
		assert @xpp.namespace == nil
		assert @xpp.prefix == nil

		assert @xpp.attributeName.length == 0
		assert @xpp.attributeNamespace.length == 0
		assert @xpp.attributePrefix.length == 0
		assert @xpp.attributeValue.length == 0
  end

	def testPeekAtStringSource
		@xpp.input = "1_2"
		assert ?1 == @xpp.doPeekAt0
		@xpp.doRead
		assert ?2 == @xpp.doPeekAt1
		@xpp.doRead
		@xpp.doRead
		assert nil == @xpp.doPeekAt0
	end

	def testPeekAtIOSource000
		@xpp.input = File.new("TC_Input000.data")
		assert ?1 == @xpp.doPeekAt0
		@xpp.doRead
		assert ?2 == @xpp.doPeekAt1
		@xpp.doRead
		@xpp.doRead
		assert nil == @xpp.doPeekAt1 # have to get by the end of line
	end

	def testReadStringSource
		@xpp.input = "12345"
		assert ?1 == @xpp.doRead
		assert 1 == @xpp.column
		assert ?2 == @xpp.doRead
		assert 2 == @xpp.column
		assert ?3 == @xpp.doRead
		assert 3 == @xpp.column
		assert ?4 == @xpp.doRead
		assert 4 == @xpp.column
		assert ?5 == @xpp.doRead
		assert 5 == @xpp.column
		assert nil == @xpp.doRead
		assert 0 == @xpp.column

		assert 2 == @xpp.line
		assert 0 == @xpp.elementName.length
	end

	def testReadIOSource
		@xpp.input = File.new("TC_Input001.data")
		assert ?1 == @xpp.doRead
		assert 1 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 2 == @xpp.column
		assert ?2 == @xpp.doRead
		assert 3 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 4 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 5 == @xpp.column
		assert ?3 == @xpp.doRead
		assert 6 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 7 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 8 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 9 == @xpp.column
		assert ?4 == @xpp.doRead
		assert 10 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 11 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 12 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 13 == @xpp.column
		assert ?_ == @xpp.doRead
		assert 14 == @xpp.column
		assert ?5 == @xpp.doRead
		assert 15 == @xpp.column

		assert 1 == @xpp.line
		assert ?\n == @xpp.doRead
		assert 16 == @xpp.column
		assert 1 == @xpp.line
		assert nil == @xpp.doRead
		assert 0 == @xpp.column

		assert 0 == @xpp.elementName.length
	end

	def testMulipleInputRead000
		# read the input until complete
		for i in 1..3 do
			@xpp.input = "12345"
			s = ""
			c = @xpp.doRead
			while nil != c do
				s = s << c
				c = @xpp.doRead
			end
			assert "12345" == s
		end
	end

	def testMulipleInputRead
		# read part of the input only
		for i in 1..3 do
			@xpp.input = "12345"
			s = ""
			s = s << @xpp.doRead
			s = s << @xpp.doRead
			s = s << @xpp.doRead
			assert "123" == s
		end
	end

	def testExpectRead
		@xpp.input = "12345"
		assertNothingThrown { @xpp.doExpect(?1) }
		assertRaises( RuntimeError ) { @xpp.doExpect(?1) }
	end

	def testSkipWhitespace
		@xpp.input = "12345"
		@xpp.doSkipWhitespace
		assertNothingThrown { @xpp.doExpect(?1) }

		@xpp.input = "  12345"
		@xpp.doSkipWhitespace
		assertNothingThrown { @xpp.doExpect(?1) }

		@xpp.input = "  \n  \r\n  12345"
		@xpp.doSkipWhitespace
		assertNothingThrown { @xpp.doExpect(?1) }

		@xpp.input = "  \00012345"
		@xpp.doSkipWhitespace
		assertNothingThrown { @xpp.doExpect(0) }
	end

end
