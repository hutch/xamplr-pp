
require "xpp"

class Xpp
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

	def processingInstruction?
		@type.equal? PROCESSING_INSTRUCTION
	end

	def comment?
		@type.equal? COMMENT
	end

	def doctype?
		@type.equal? DOCTYPE
	end
end

