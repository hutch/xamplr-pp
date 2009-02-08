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
require 'Lapidary/TestSuite'
require 'Lapidary/UI/Console/TestRunner'

require 'TC_EventTypes'
require 'TC_Features'
require 'TC_Misc'
require 'TC_Input'
require 'TC_Parse'
require 'TC_Namespace'

class TS_xpp
  def TS_xpp.suite()
    suite = Lapidary::TestSuite.new()
    suite.add(TC_EventTypes.suite())
    suite.add(TC_Features.suite())
    suite.add(TC_Misc.suite())
    suite.add(TC_Input.suite())
    suite.add(TC_Parse.suite())
    suite.add(TC_Namespace.suite())
    return suite
  end
end 
  
if (__FILE__ == $0)
  Lapidary::UI::Console::TestRunner.run(TS_xpp)
end


