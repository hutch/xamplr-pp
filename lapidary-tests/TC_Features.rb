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

class TC_Features < Lapidary::TestCase
  def setup
		@xpp = Xampl_PP.new
  end
  #def tearDown
  #end

  def testInitialState
		# the xpp parser will initialise to the following state
	  assert @xpp.processNamespace
		assert !@xpp.reportNamespaceAttributes
  end

	def testProcessNamespace
		@xpp.processNamespace = false
	  assert !@xpp.processNamespace
		assert !@xpp.reportNamespaceAttributes

		@xpp.processNamespace = true
	  assert @xpp.processNamespace
		assert !@xpp.reportNamespaceAttributes
	end

	def testReportNamespaceAttributes
		@xpp.reportNamespaceAttributes = true
	  assert @xpp.processNamespace
		assert @xpp.reportNamespaceAttributes

		@xpp.reportNamespaceAttributes = false
	  assert @xpp.processNamespace
		assert !@xpp.reportNamespaceAttributes
	end
end


