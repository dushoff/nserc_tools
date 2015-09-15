## /home/dushoff/git/nserc_tools
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: proposal.pdf 

##################################################################

ms = ../makestuff
nserc_tools = ../nserc_tools
-include local.def

# make files

Sources = Makefile .gitignore README.md

Sources += test.rmu
test.bib: test.rmu

##################################################################

# Markdown

Sources += proposal.txt proposal.tmp proposal.fmt

Sources += ms.pl prophead.txt bib.txt 

proposal.tex: prophead.txt proposal.txt bib.txt proposal.tmp proposal.fmt ms.pl

proposal.pdf: proposal.bbl proposal.txt

proposal.bbl: test.bib

##################################################################

# Latex
# Do we need case abb, or is the double-paren thing working OK?

######################################################################

# Crib

WW = 

$(WW):
	/bin/cp /home/dushoff/Dropbox/WorkingWiki-export/NSERC_discovery/$@ .

##################################################################

autorefs = ../autorefs
-include $(autorefs)/inc.mk

##################################################################

# File to be read by other directories, with all of the real rules
# As opposed to git-like rules

Sources += inc.mk

-include $(nserc_tools)/inc.mk

##################################################################

parallel = $(ms) $(autorefs)
# parallel += $(nserc_tools)

-include $(ms)/local.mk
-include local.mk
-include $(ms)/git.mk

-include $(ms)/visual.mk
include $(ms)/oldlatex.mk

# -include $(ms)/RR.mk
