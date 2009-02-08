
_____________________________________________________________________
INTRODUCTION

This is the Ruby version of the xampl pull parser, xampl-pp.  The class
name is Xampl_PP. There will be an implementation of xampl-pp in
SmallEiffel as well.

Both pull parsers and SAX parsers are stream based -- they parse the
XML file bit by bit informing its client of interesting events as
they are encountered. The whole XML document is not required to be in
memory. The significant difference between pull parsers and SAX parsers
is in where the 'main loop' is located: in the client for pull parsers,
in the parser for SAX parsers. Clients call a method of the pull parser
to get the next event. SAX parsers call methods of the client to notify
it of events (so these are 'push parsers').

Xampl-pp is not a validating parser, in fact, in this release it doesn't
enforce wellformedness rules. DOCTYPE definitions are passed intact to the
client program. In this release, no attempt is made to extract any kind
of entity definitions from the DOCTYPE.

As a way of illustrating the use of xampl-pp a reasonably usable
SAX-like parser (SAXish) is implemented as well. There is a saxdemo.rb
file provided that provides statistics on the parsed XML file. It can
be run using 'make sax' (look in the Makefile to see how it is used)

_____________________________________________________________________
STATUS

Though Xampl-pp has been used in several projects already, this is
something of an adventurer's release. For example, there is no installer
provided (that will be coming very soon, but I thought it safer to
keep away from that for now), and documentation is sparse.

Xampl-pp has passed all unit tests using Ruby 1.6.7 on Linux and OS X, and
Ruby 1.7.2 on Mac OS X. It's not been tried on any other combinations so
far.

The unit tests require Lapidary. Run these by typing 'make ut' on
the command line in the installation directory.

Xampl-pp is not a validating parser, in fact, in this release it doesn't
enforce wellformedness rules. DOCTYPE definitions are passed intact to the
client program. In this release, no attempt is made to extract any kind
of entity definitions from the DOCTYPE. Clever use of the DOCTYPE event
and the resolver method can relieve this problem. In future releases
xampl-pp will parse the DOCTYPE looking for entity definitions.

If enforcment of wellformed rules is delayed, I will document, which
wellformedness rules are enforced. Many of the significant rules are
already enforced.

I have some serious reservations about the way that xampl-pp handles
multi-byte characters. It seems to work for UTF8 but I do not have
access to a decent collection of test files (if someone knows where
such a collection might be I'd appreciate a pointer). I am quite sure that
xample-pp will not work reliably with any other multi-byte character
encoding . It will be fairly straight forward to support the encoding Ruby
supports in its regular expression matching, anything else is going to be
a problem. I'll go into this in more detail in the future.

Some attention has been paid to performance. It is reasonably quick. In
my opinion, more can be done here especially around memory use.

_____________________________________________________________________
DOCUMENTATION

There isn't much. Fortunately, the API to xampl-pp is very small and
quite easy to understand.

It turns out to be quite easy to build a SAX-like parser from a push
parser.  It also turns out that doing this pretty much uses the entire
xampl-pp api. So I've implemented a SAX-like parser (SAXish) and
annotated it. This is pretty much all the documentation in this release.

SAXish is, in itself, a pretty usable SAX-like parser (of course the
limits to validation and wellformedness checking mentioned above apply).

_____________________________________________________________________
CONFORMANCE

Well, this is an interesting question. Right now, it doesn't do too
well, but it does this in a 'good' way, or at least a manageable way.

On the Oasis conformance tests xampl-pp 435 tests pass that should pass,
188 fail that should fail, 3 failed that should pass, and 1188 passed
that should fail.

However to do this I had to *cheat*.  I defined a resolver that returns
a string rather than nil, this allows xampl-pp to pretend that it is
dealing with entities defined in the DOCTYPE.

The two results you have to pay attention to are: the ones that didn't 
work as expected.

The three that failed that should have passed all involve apparently legal
DOCTYPE declarations that xampl-pp does not recognise as legal. I'll be
looking into this.

The 1188 that passed that should not appear to be due to the non-enforcement
of well-formedness rules. I have not looked at them all, I assure you of
that, but it seems that this most involve entity definitions.

_____________________________________________________________________
LICENCE

Xampl-pp is licensed under the LGPL (see LICENSE.TXT)

_____________________________________________________________________
CONTACT INFORMATION

My email is hutch@xampl.com, feel free to contact me there, or you can
use the facilities provided by Sourceforge.

