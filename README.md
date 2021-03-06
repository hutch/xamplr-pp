# xamplr-pp-gem

## INTRODUCTION

This is the Ruby version of the xampl pull parser, xamplr-pp.  The
class name is Xampl_PP.

Both pull parsers and SAX parsers are stream based -- they parse
the XML file bit by bit informing its client of interesting events
as they are encountered. The whole XML document is not required to
be in memory. The significant difference between pull parsers and
SAX parsers is in where the 'main loop' is located: in the client
for pull parsers, in the parser for SAX parsers. Clients call a
method of the pull parser to get the next event. SAX parsers call
methods of the client to notify it of events (so these are 'push
parsers'). You can pass the pull parser around as an argument, and is
similar to IO objects.

As a way of illustrating the use of xamplr-pp a reasonably usable
SAX-like parser (SAXish) is implemented as well. There is a saxdemo.rb
file provided that provides statistics on the parsed XML file. It
can be run using 'make sax' (look in the Makefile to see how it is
used)

## STATUS

xamplr-pp  has been in production use in a SaaS content management system since about 2004. It is an integral component of
xamplr.  Unfortunately documentation is sparse.

xamplr-pp works using Ruby 1.9.1 on OS X and Linux. It has, in the
past, worked under Ruby 1.6.7, 1.8.6, 1.8.7 on Linux and OS X. If
it no longer does, it will be and easy fix -- let me know.

The unit tests require Lapidary (remember that?).  No idea if they still work.

xamplr-pp is not a validating parser, in fact, it
doesn't enforce some wellformedness rules. DOCTYPE definitions are passed
intact to the client program. No attempt is made
to extract any kind of entity definitions from the DOCTYPE. Clever
use of the DOCTYPE event and the resolver method can relieve this
problem.

Some attention has been paid to performance. It is reasonably quick, certainly on the fast side for pure ruby parsers.

## DOCUMENTATION

There isn't much. Fortunately, the API to xamplr-pp is very small
and quite easy to understand.

It turns out to be quite easy to build a SAX-like parser from a
push parser.  It also turns out that doing this pretty much uses
the entire xamplr-pp api. So I've implemented a SAX-like parser
(SAXish) and annotated it. This is pretty much all the documentation
in this release.

SAXish is, in itself, a pretty usable SAX-like parser (of course
the limits to validation and wellformedness checking mentioned above
apply).

## CONFORMANCE

Well, this is an interesting question. Right now, it doesn't do too
well, but it does this in a 'good' way, or at least a manageable
way.

On the Oasis conformance tests xamplr-pp 435 tests pass that should
pass, 188 fail that should fail, 3 failed that should pass, and
1188 passed that should fail. Generally speaking, xamplr-pp is 'permissive'.

However to do this I had to *cheat*.  I defined a resolver that
returns a string rather than nil, this allows xamplr-pp to pretend
that it is dealing with entities defined in the DOCTYPE. In other words, for you to achieve this level of conformance you'll need to supply an entity resolver.

The three that failed that should have passed all involve apparently
legal DOCTYPE declarations that xamplr-pp does not recognise as
legal. It is unlikely that I do anything about these.

The 1188 that passed that should not appear to be due to the
non-enforcement of well-formedness rules. I have not looked at them
all, I assure you of that, but it seems that this most involve
entity definitions. Well, every one that I looked at did, can't say for what I didn't look at.

## LICENCE

xamplr-pp is licensed under the LGPLv3 (see LICENSE/COPYING)

## CONTACT INFORMATION

My email is hutch@xampl.com, feel free to contact me there

## Copyright

Copyright (c) 2002-2010 Bob Hutchison. See LICENSE for details.

