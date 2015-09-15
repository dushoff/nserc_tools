include $(ms)/perl.def

.PRECIOUS: %.tex
%.tex:
	$(PUSH)

# We need a simple link to the tools directory so that latex can find it
.PRECIOUS: tools
tools:
	/bin/ln -s $(nserc_tools) $@

inc.mk: tools
