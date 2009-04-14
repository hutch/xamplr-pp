#!/usr/local/bin/ruby
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
require "saxish"
require "saxishHandler"

#
# This module uses the saxish api. The saxish api is meant to demonstrate
# the use of Xampl_PP pull parser, while being useful in itself. If you are
# meaning to learn about the Xampl_PP parser, you should look at the
# saxish.rb file -- this one isn't going to help you a lot.
#

class SAXdemo
	include SAXishHandler

  attr :verbose, true

  def resolve(name)
    @resolverCount += 1
    return "fake it"
  end

  def startElement(name, namespace, qname, prefix, attributeCount, isEmpty, saxparser)
    printf("StartElement -- name: '%s'\n", name) if verbose
    printf("                namespace: '%s'\n", namespace) if verbose
    printf("                qname: '%s'\n", qname) if verbose
    printf("                prefix: '%s'\n", prefix) if verbose
    printf("                attributeCount: %d\n", attributeCount) if verbose
    printf("                isEmpty: %s\n", isEmpty) if verbose
    i = 0
    while i < attributeCount do
      printf("  attribute[%d] -- name: '%s'\n", i, saxparser.attributeName(i)) if verbose
      printf("  attribute[%d] -- namespace: '%s'\n", i, saxparser.attributeNamespace(i)) if verbose
      printf("  attribute[%d] -- qname: '%s'\n", i, saxparser.attributeQName(i)) if verbose
      printf("  attribute[%d] -- prefix: '%s'\n", i, saxparser.attributePrefix(i)) if verbose
      printf("  attribute[%d] -- value: '%s'\n", i, saxparser.attributeValue(i)) if verbose
      i += 1
    end
    @startElementEventCount += 1
    @eventCount += 1
		if @maxDepth < saxparser.depth then
			@maxDepth = saxparser.depth
			@maxDepthLine = saxparser.line
			@maxDepthColumn = saxparser.column
		end
  end

  def endElement(name, namespace, qname, prefix)
    printf("EndElement -- name: '%s'\n", name) if verbose
    printf("              namespace: '%s'\n", namespace) if verbose
    printf("              qname: '%s'\n", qname) if verbose
    printf("              prefix: '%s'\n", prefix) if verbose
    @endElementEventCount += 1
    @eventCount += 1
  end

  def entityRef(name, text)
    printf("EntityRef -- name '%s' text '%s'\n", name, text) if verbose
    @entityRefCount += 1
    @eventCount += 1
  end

  def text(text, isWhitespace)
    if not isWhitespace then
      printf("Text -- length: %d\n", text.length) if verbose
      @textEventCount += 1
    else
      printf("Text -- length: %d WHITESPACE\n", text.length) if verbose
      @whitespaceTextEventCount += 1
    end
    @eventCount += 1
  end

  def cdataSection(text)
    printf("CDATA -- length: %s\n", text.length) if verbose
    @cdataEventCount += 1
    @eventCount += 1
  end

  def ignoreableWhitespace(text)
    printf("IgnoreableWhitespace -- length: %s\n", text.length) if verbose
    @ignorableWhitespaceEventCount += 1
    @eventCount += 1
  end

  def processingInstruction(text)
    printf("ProcessingInstruction -- [%s]\n", text) if verbose
    @processingInstructionEventCount += 1
    @eventCount += 1
  end

  def comment(text)
    printf("comment -- [%s]\n", text) if verbose
    @commentEventCount += 1
    @eventCount += 1
  end

  def doctype(text)
    printf("doctype -- [%s]\n", text) if verbose
    @doctypeEventCount += 1
    @eventCount += 1
  end

  def init
    @startElementEventCount = 0
    @endElementEventCount = 0
    @entityRefCount = 0
    @resolverCount = 0
    @textEventCount = 0
    @cdataEventCount = 0
    @whitespaceTextEventCount = 0
    @ignorableWhitespaceEventCount = 0
    @processingInstructionEventCount = 0
    @doctypeEventCount = 0
    @commentEventCount = 0
    @eventCount = 0
    @failureCount = 0
    @successCount = 0
		@maxDepth = -1
	end

	def report
    printf("%5d eventCount\n", @eventCount)
    printf("%5d successCount\n", @successCount)
    printf("%5d maxDepth [%d, %d]\n", @maxDepth, @maxDepthLine, @maxDepthColumn)
    printf("%5d failureCount\n", @failureCount)
    printf("%5d startElementEventCount\n", @startElementEventCount)
    printf("%5d endElementEventCount\n", @endElementEventCount)
    printf("%5d entityRefCount\n", @entityRefCount)
    printf("%5d resolverCount\n", @resolverCount)
    printf("%5d textEventCount\n", @textEventCount)
    printf("%5d cdataEventCount\n", @cdataEventCount)
    printf("%5d whitespaceTextEventCount\n", @whitespaceTextEventCount)
    printf("%5d ignorableWhitespaceEventCount\n", @ignorableWhitespaceEventCount)
    printf("%5d processingInstructionEventCount\n", @processingInstructionEventCount)
    printf("%5d doctypeEventCount\n", @doctypeEventCount)
    printf("%5d commentEventCount\n", @commentEventCount)
	end

  def fileNames(fileNames)
		init

    @saxparser = SAXish.new
    @saxparser.handler = self
    @saxparser.processNamespace = true
    @saxparser.reportNamespaceAttributes = false

    fileNames.each do
      | filename |
      begin
        @saxparser.parse filename
        @successCount += 1
      rescue Exception => message
        @failureCount += 1
        print message.backtrace.join("\n")
        printf("FAILED [%s] '%s'\n", message, filename)
      end
    end

		report
  end

  def string(string)
		init

    @saxparser = SAXish.new
    @saxparser.handler = self
    @saxparser.processNamespace = true
    @saxparser.reportNamespaceAttributes = false

    begin
      @saxparser.parseString string
      @successCount += 1
    rescue Exception => message
      @failureCount += 1
      print message.backtrace.join("\n")
      printf("FAILED [%s] '%s'\n", message, string)
    end

		report
  end
end

string = <<EOS
<root>
	<a>
	</a>
	<b>hello</b>
	<c>hello &there;</c>
</root>
EOS

SAXdemo.new.string(string)
SAXdemo.new.fileNames(ARGV)

