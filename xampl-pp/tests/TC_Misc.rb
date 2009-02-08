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

class TC_Misc < Lapidary::TestCase
  def setup
		@xpp = Xampl_PP.new
  end
  #def tearDown
  #end

  def testEntityMap
    assert @xpp.entityMap["amp"] == "&"
    assert @xpp.entityMap["apos"] == "'"
    assert @xpp.entityMap["gt"] == ">"
    assert @xpp.entityMap["lt"] == "<"
    assert @xpp.entityMap["quot"] == '"'
  end
end

