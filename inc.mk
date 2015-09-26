-include $(ms)/perl.def

### Abandoning this as a separate project for now; eventually (if you feel like it) try to _break_ nserc back into a private part and a public part

# Latex
# Do we need case abb, or is the double-paren thing working OK?

######################################################################

autorefs = ../autorefs
-include $(autorefs)/inc.mk

##################################################################

.PRECIOUS: %.tex
%.tex:
	$(PUSH)

# We need a simple link to the tools directory so that latex can find it
.PRECIOUS: tools
tools:
	/bin/ln -s $(nserc_tools) $@

inc.mk: tools
