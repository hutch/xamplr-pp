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

require "xampl-pp"

class Xampl_PP

	def parseXMLDecl
		@standalone = false
		return nil != @text.index(/^xml[\n\r\t ]/mu)
	end

	def parseDefinition(defn, internal)
		return if defn.length <= 0

		p = defn.index(/<!ELEMENT/u)
		if 0 == p then
			return parseElementDefinition(defn, internal)
		end

		p = defn.index(/<!ATTLIST/u)
		if 0 == p then
			return parseAttlistDefinition(defn, internal)
		end

		p = defn.index(/<!NOTATION/u)
		if 0 == p then
			return parseNotationDefinition(defn, internal)
		end

		p = defn.index(/<!ENTITY.*%/mu)
		if 0 == p then
			return parseParameterEntityDefinition(defn, internal)
		end

		p = defn.index(/<!ENTITY.*SYSTEM/mu)
		if 0 == p then
			return parseSystemEntityDefinition(defn, internal)
		end

		p = defn.index(/<!ENTITY.*PUBLIC/mu)
		if 0 == p then
			return parsePublicEntityDefinition(defn, internal)
		end

		p = defn.index(/<!ENTITY/u)
		if 0 == p then
			return parseEntityDefinition(defn, internal)
		end
	
		p = defn.index(/<\?.*\?>/mu)
		if 0 == p then
			return parsePIDefinition(defn, internal)
		end
	
		raise sprintf("NOT recognised in the %s subset", (internal ? "internal" : "external"))
	end

	def parseElementDefinition(defn, internal)
		#printf("element '%s' internal? %s\n", defn, internal)
	end

	def parseEntityDefinition(defn, internal)
		if !internal then
			raise "unexpected GEDecl"
		end
#printf("entity '%s' internal? %s\n", defn, internal)
    regex = /<!ENTITY[\n\r\t ]+([^\n\r\t ]+)[\n\r\t ]+"([^"]*)"[\n\r\t ]*>/mu
		match = defn.match(regex).to_a
		if 3 != match.length then
    	regex = /<!ENTITY[\n\r\t ]+([^\n\r\t ]+)[\n\r\t ]+'([^']*)'[\n\r\t ]*>/mu
			match = defn.match(regex).to_a
			if 3 != match.length then
				raise sprintf("invalid GEDecl")
			end
			#raise sprintf("invalid GEDecl '%s'", defn)
		end
		name = match[1]
		value = match[2]
#printf("name [%s] value [%s]\n", name, value)
    entityMap[name] = value
	end

	def parseParameterEntityDefinition(defn, internal)
		#printf("pentity '%s' internal? %s\n", defn, internal)
	end

	def parsePublicEntityDefinition(defn, internal)
		#printf("public entity '%s' internal? %s\n", defn, internal)
	end

	def parseSystemEntityDefinition(defn, internal)
		#printf("system entity '%s' internal? %s\n", defn, internal)
	end

	def parseAttlistDefinition(defn, internal)
		printf("attlist '%s' internal? %s\n", defn, internal)
	end

	def parseNotationDefinition(defn, internal)
		#printf("notation '%s' internal? %s\n", defn, internal)
	end

	def parsePIDefinition(defn, internal)
		if !internal then
			raise "unexpected processing instruction"
		end
		#printf("PI '%s' internal? %s\n", defn, internal)
	end

end
