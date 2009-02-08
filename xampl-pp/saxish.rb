#
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

##
## It may seem strange, but it seems that a good way to demonstrate the use
## of the xampl-pp pull parser is to show how to build a SAX-like XML
## parser. Both pull parsers and SAX parsers are stream based -- they parse
## the XML file bit by bit informing its client of interesting events as
## they are encountered. The whole XML document is not required to be in
## memory. The significant difference between pull parsers and SAX parsers
## is in where the 'main loop' is located: in the client for pull parsers,
## in the parser for SAX parsers. Clients call a method of the pull parser
## to get the next event. SAX parsers call methods of the client to notify
## it of events (so these are 'push parsers').
##
## It turns out to be quite easy to build a SAX-like parser from a pull
## parser.  It is quite a lot harder to build a pull parser from a SAX-like
## parser.
##
## This class demonstrates (most) of the xampl-pp interface by implementing a
## SAX-like parser. No attempt has been made to provide all the functionality
## provided by a good Java SAX parser, though the equivalent of a significant,
## and useful, subset is implemented.
##
## The program text is annotated. Note, that the annotations generally
## follow the code being described.
##


class SAXish

##
## The Ruby implementation of the xampl-pp parser is called Xampl_PP, and
## SAXish will be the name of our SAX-like parser.
##

	attr :handler, true

##
## Sax parsers need an event handler. 'handler' is it. Handler is expected to
## implement the methods defined in the module 'saxishHandler'. SaxishHandler
## is intended to be an adapter (so you can include it in any hander you
## write), so only the event-handlers for those events in which you are
## interested in need to be re-defined. SAXdemo is an implementation of
## SaxishHandler that gathers some statistics.
##
## Xampl-pp requires something it calls a resolver. This is a class that
## implements a method called resolve. There are a number of predefined
## entities in xampl-pp: &amp; &apos; &gt; &lt; and &quot;. It is possible
## to add more entities by adding entries to the entityMap hashtable. If an
## entity is encountered that is not in entityMap then the resolve method on
## the resolver is called. The default resolver returns nil, which causes
## an exception to be thrown. If you specify your own resolver you can do
## anything you like to obtain a value for the entity, or you can return nil
## (and an exception will be thrown). Xampl-pp, by default, is its own
## resolver and simply return nil.
##
## We are going to require that our saxish handler also be the entity
## resolver.  This is reflected in the SaxHandler module, which implements
## a resolve method that always returns nil.
##

	attr :processNamespace, true
	attr :reportNamespaceAttributes, true

##
## This block of comments can be ignored, certainly for the first reading.
## It talks about some control you have over how the xampl-pp works. The
## default behaviour is the most commonly used.
##
## There are two main controls used here: processNamespace, and
## reportNamespaceAttributes.  If processNamespaces is true, then namespaces
## in the XML file being parsed will be processed. Processing means that if
## an element <prefix:name/> is encountered, then four variables will be
## set up in the parser instance: name is 'name', prefix is 'prefix',
## qname is 'prefix:name', and namespace is defined. If the namespace cannot
## be defined an exception is thrown. In addition the xmlns attributes
## are processed. If processNamespace is false then name and qname
## will both be 'prefix:name', and both prefix and namespace undefined.
## If reportNamespaceAttributes is true then the xmlns attributes will be
## reported along with all the other attributes, if false then they will
## be hidden. The default behaviour is to process namespaces but to not
## report the namespace attributes.
##
## There are two other controls that should be mentioned. They are not
## used here.
##
## Pull parsers are pretty low level tools. They are meant to be fast. While
## may wellformedness constraints are enforced, not all are. If the control
## checkWellFormed is true then additional checks are made. Xampl-pp does
## not guarantee that it will parse only well formed XML documents. It
## will parse some XML files that are not well formed without objecting. In
## future releases, it will be possible to have xampl-pp accept only
## well formed documents. If checkWellFormed is false, then the parser
## doesn't go out of its way to notice ill formed documents. The default
## is true.
##
## The fourth control is 'utf8encode'. If this is true, and it defaults to
## true, then an entity like &#1234; is encountered then it will be encoded
## using utf8 rules. Given the current state of the parser, it would be best
## to leave it set to true. If you want to change this then you must either
## never use &#; encodings with numbers greater than 255 (Ruby will throw an
## exception), or you must redefine xampl-pp's encode method to do the right
## thing.
##

	def parse(filename)
		@xpp = Xampl_PP.new
		@xpp.input = File.new(filename)
    @xpp.processNamespace = @processNamespace
    @xpp.reportNamespaceAttributes = @reportNamespaceAttributes
    @xpp.resolver = @handler

		work
	end

	def parseString(string)
		@xpp = Xampl_PP.new
		@xpp.input = string
    @xpp.processNamespace = @processNamespace
    @xpp.reportNamespaceAttributes = @reportNamespaceAttributes
    @xpp.resolver = @handler

		work
	end

#
# Constructing an instance of xampl-pp is pretty straight forward: Xampl_PP.new
#
# Xampl_PP accepts two kinds of input: IO and String. The same method,
# 'input', is used to specify the input. It is possible to set the input
# anytime, but if you do, the current input will be closed if it is of
# type IO, and the parsing will begin at the current location of the input.
#
# The methods parse and parseString illustrate.
#

	def work
		while not @xpp.endDocument? do
			case @xpp.nextEvent
	      when Xampl_PP::START_DOCUMENT
					@handler.startDocument
        when Xampl_PP::END_DOCUMENT
					@handler.endDocument
        when Xampl_PP::START_ELEMENT
					@handler.startElement(@xpp.name,
					                      @xpp.namespace,
																@xpp.qname,
																@xpp.prefix,
																attributeCount,
																@xpp.emptyElement,
																self)
        when Xampl_PP::END_ELEMENT
					@handler.endElement(@xpp.name,
					                    @xpp.namespace,
															@xpp.qname,
															@xpp.prefix)
        when Xampl_PP::TEXT
					@handler.text(@xpp.text, @xpp.whitespace?)
        when Xampl_PP::CDATA_SECTION
					@handler.cdataSection(@xpp.text)
        when Xampl_PP::ENTITY_REF
					@handler.entityRef(@xpp.name, @xpp.text)
        when Xampl_PP::IGNORABLE_WHITESPACE
					@handler.ignoreableWhitespace(@xpp.text)
        when Xampl_PP::PROCESSING_INSTRUCTION
					@handler.processingInstruction(@xpp.text)
        when Xampl_PP::COMMENT
					@handler.comment(@xpp.text)
        when Xampl_PP::DOCTYPE
					@handler.doctype(@xpp.text)
			end
		end
	end

	def attributeCount
  	return @xpp.attributeName.length
	end

	def attributeName(i)
		return @xpp.attributeName[i]
	end

	def attributeNamespace(i)
		return @xpp.attributeNamespace[i]
	end

	def attributeQName(i)
		return @xpp.attributeQName[i]
	end

	def attributePrefix(i)
		return @xpp.attributePrefix[i]
	end

	def attributeValue(i)
		return @xpp.attributeValue[i]
	end

	def depth
  	return @xpp.depth
	end

	def line
		return @xpp.line
	end

	def column
		return @xpp.column
	end


## 
## There is one method used to parse the XML document: nextEvent. It returns
## the type of the event (described below). There are corresponding queries
## defined for each event type. The event is described by variables in the
## xampl-pp instance.
## 
## It is possible to obtain the depth in the XML file (i.e. who many elements
## are currently open) using the xampl-pp method 'depth'. This is made
## available to the saxish client using a method on the sishax parser with the
## same name.
##
## The line and column number of the next unparsed character is available
## using the line and column methods. Note that line is always 1 for
## string input.
##
## There is a method, whitespace?, that will tell you if the current text
## value is whitespace.
##
## The event types are:
## 
## START_DOCUMENT, END_DOCUMENT -- informational
##
## START_ELEMENT -- on this event several features are defined in the parser
## that are pertinent. name, namespace, qname, prefix describe the element
## tag name. emptyElement is true if the element is of the form <element/>,
## false otherwise. And the arrays attributeName, attributeNamespace,
## attributeQName, attributePrefix, and attributeValue contain attribute
## information. The number of attributes is obtained from the length of
## any of these arrays. Attribute information is presented to the sax
## client using six methods: attributeCount, attributeName(i),
## attributeNamespace(i), attributeQName(i), attributePrefix(i),
## attributeValue(i).
##
## END_ELEMENT -- name, namespace, qname, and prefix are defined. NOTE that
## emptyElement will always be false for this event, even though it is called
## for elements of the form <element/>.
##
## TEXT -- upon plain text found in an element. Note that it is
## quite possible that several text events in succession may be made for a
## single run of text in the XML file
##
## CDATA_SECTION -- upon a CDATA section. Note that it is quite possible
## that several CDATA events in succession may be made for a single CDATA
## section.
##
## ENTITY_REF -- for each entity encountered. It will have the
## value in the text field, and the name in the name field.
##
## IGNORABLE_WHITESPACE -- for whitespace that occurs at the document
## level of the XML file (i.e. outside the root element). This whitespace is
## meaningless in XML and so can be ignored (and so the name). If you are
## interested in it, the whitespace is in the text field.
##
## PROCESSING_INSTRUCTION -- upon a processing instruction. The content of
## the processing instruction (with the <? and ?> removed) is provied in
## the text field.
##
## COMMENT -- upon a comment. The content of the comment (with the <!--
## and --> removed) is provied in the text field.
##
## DOCTYPE -- upon encountering a doctype. The content of the doctype
## (with the <!DOCTYPE and trailing > removed) is provided in the text field.
##
## The event query methods are: cdata?, comment?, doctype?, endDocument?,
## endElement?, entityRef?, ignorableWhitespace?, processingInstruction?,
## startDocument?, startElement?, and text?
##

end
