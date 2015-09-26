include $(ms)/perl.def


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
