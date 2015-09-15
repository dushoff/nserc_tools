### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: notarget

##################################################################


# make files

Sources = Makefile .gitignore README.md

######################################################################

ms = ../makestuff

-include $(ms)/local.mk
-include local.mk
-include $(ms)/git.mk

-include $(ms)/visual.mk
# -include $(ms)/linux.mk

# -include $(ms)/RR.mk
# -include oldlatex.mk
