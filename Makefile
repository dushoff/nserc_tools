
current: target

target pngtarget pdftarget vtarget acrtarget: proposal.pdf 

##################################################################

ms = ../makestuff
nserc_tools = ../nserc_tools
-include $(ms)/git.def
-include local.mk

# make files

Sources = Makefile .gitignore README.md

Sources += test.rmu
test.bib: test.rmu

##################################################################


# File to be read by other directories, with all of the real rules
# As opposed to git-like rules

Sources += inc.mk

-include $(nserc_tools)/inc.mk

##################################################################

# Example stuff. A lot of this needs to go in the project Makefile

Sources += proposal.txt proposal.tmp proposal.fmt

Sources += ms.pl prophead.txt bib.txt 

proposal.tex: prophead.txt proposal.txt bib.txt proposal.tmp proposal.fmt ms.pl

proposal.pdf: proposal.bbl proposal.txt

proposal.bbl: test.bib

##################################################################
##################################################################

parallel += $(ms) $(autorefs)
# parallel += $(nserc_tools)

-include $(ms)/local.mk
-include local.mk
-include $(ms)/git.mk

-include $(ms)/visual.mk
-include $(ms)/oldlatex.mk

