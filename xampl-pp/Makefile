DIST_FILES_ROOT=\
	LICENSE.TXT \
	README.TXT
DIST_FILES_LIB=\
  saxish.rb \
  saxishHandler.rb \
  xampl-pp.rb
DIST_FILES_TEST=\
  TC_EventTypes.rb \
  TC_Features.rb \
  TC_Input.rb \
  TC_Input000.data \
  TC_Input001.data \
  TC_Misc.rb \
  TC_Namespace.rb \
  TC_Parse.rb \
  TC_Parse000.data \
  TS_xpp.rb
DIST_FILES_EXAMPLES=\
	saxdemo.rb

ut:
	time ruby TS_xpp.rb 2>&1 | tee e1

p:	pinit pgo

pinit:
	cp P_ChewFile.profile.base P_ChewFile.profile

pgo:
	ruby -r rbprof P_ChewFile.rb 2>&1 | tee results.prof

pclean:
	rm -f P_ChewFile.profile
	ruby -r rbprof P_ChewFile.rb 2>&1 | tee results.prof

wclean:
	rm -f P_ChewFile-wf.profile
	ruby -r rbprof P_ChewFile-wf.rb 2>&1 | tee results.prof

base:
	cp P_ChewFile.profile P_ChewFile.profile.base

prof:
	#ruby -r rbprof P_Input.rb 2>&1 | tee results.prof
	cp P_Input.profile.base P_Input.profile
	ruby P_Input.rb 2>&1 | tee results.prof


go:	goXpp

goXpp:
	time ruby xpp.rb


tconf:
	rm -f results.conformance
	./chew.rb PASS pass.files >> results.conformance
	#./chew.rb FAIL not-wf.files >> results.conformance
	#./chew.rb FAIL fail.files >> results.conformance
	#./chew.rb FAIL invalid.files >> results.conformance
	#./chew.rb PASS valid.files >> results.conformance
	##./chew.rb FAIL japanese.files >> results.conformance

conf::
	time ruby conf.rb \
	  xmlconf/xmltest/xmltest.xml \
	  xmlconf/oasis/oasis.xml \
		xmlconf/ibm/ibm_oasis_invalid.xml \
		xmlconf/ibm/ibm_oasis_not-wf.xml \
		xmlconf/ibm/ibm_oasis_valid.xml \
		xmlconf/japanese/japanese.xml \
		xmlconf/sun/sun-error.xml \
		xmlconf/sun/sun-invalid.xml \
		xmlconf/sun/sun-not-wf.xml \
		xmlconf/sun/sun-valid.xml \
	| tee results.conformance
	##rm -f results.conformance
	##./chew.rb PASS pass.files >> results.conformance
	##./chew.rb FAIL not-wf.files >> results.conformance
	##./chew.rb FAIL fail.files >> results.conformance
	##./chew.rb FAIL invalid.files >> results.conformance
	##./chew.rb PASS valid.files >> results.conformance
	##./chew.rb FAIL japanese.files >> results.conformance

rconf:
	rm -f results.conformance
	./chewRexml.rb PASS pass.files >> results.conformance
	./chewRexml.rb FAIL not-wf.files >> results.conformance
	./chewRexml.rb FAIL fail.files >> results.conformance
	#./chewRexml.rb FAIL invalid.files >> results.conformance
	#./chewRexml.rb PASS valid.files >> results.conformance
	##./chewRexml.rb FAIL japanese.files >> results.conformance

rconfpp:
	rm -f results.conformance
	./chewRexmlPP.rb PASS pass.files
	./chewRexmlPP.rb FAIL not-wf.files
	./chewRexmlPP.rb FAIL fail.files
	./chewRexmlPP.rb FAIL invalid.files
	./chewRexmlPP.rb PASS valid.files
	#./chewRexmlPP.rb PASS pass.files >> results.conformance
	#./chewRexmlPP.rb FAIL not-wf.files >> results.conformance
	#./chewRexmlPP.rb FAIL fail.files >> results.conformance
	#./chewRexmlPP.rb FAIL invalid.files >> results.conformance
	#./chewRexmlPP.rb PASS valid.files >> results.conformance
	##./chewRexmlPP.rb FAIL japanese.files >> results.conformance

sax:
	ruby saxdemo.rb testFeeds.xml rexmlDoc.xml test.xml

saxFail:
	ruby saxdemo.rb test0.xml

dist::
	cp $(DIST_FILES_ROOT) dist
	cp $(DIST_FILES_LIB) dist/lib
	cp $(DIST_FILES_TEST) dist/test
	cp $(DIST_FILES_EXAMPLES) dist/examples

prex:
	ruby -r rbprof P_RexmlPP.rb 2>&1 | tee results.prof
