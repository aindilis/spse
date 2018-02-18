#!/usr/bin/make -f

configure: configure-stamp

configure-stamp:
	touch configure-stamp

build: build-stamp
	bibtex icaps-2011-paper
	latex icaps-2011-paper.tex
	dvips icaps-2011-paper.dvi
	ps2pdf icaps-2011-paper.ps
	xpdf icaps-2011-paper.pdf

build-stamp: configure-stamp 
	touch build-stamp

clean:
	(find . | grep '~$$' | xargs rm) || true

etags:
	find . | grep -E '(pm|pl)$$' | etags -

install:


.PHONY: build clean install configure
