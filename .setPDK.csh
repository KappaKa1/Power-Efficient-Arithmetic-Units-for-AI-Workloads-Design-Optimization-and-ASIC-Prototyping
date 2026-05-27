# v0.1 Zerun Thu  9 Feb 11:19:51 CET 2023
# - set IHP pdk path 
# - set calibre runsets and run folder


setenv IHP_TECH "/usr/pack/ihp-sg13-kgf/open_ihp_sg13cmos5l/sg13cmos5l_tech/v0.1"
setenv technology "sg13cmos5l"
# Klayout
setenv KLAYOUT_HOME $IHP_TECH/klayout

# Calibre default runsets
setenv MGC_CALIBRE_DRC_RUNSET_FILE "../calibre/runset.drc"
setenv MGC_CALIBRE_LVS_RUNSET_FILE "../calibre/runset.lvs"
#setenv MGC_CALIBRE_PEX_RUNSET_FILE "../calibre/pex/sg13_xrc.runset"

# use the default runset currently, if modification needed copy to calibre folder in the future
#setenv MGC_CALIBRE_DRC_RUNSET_FILE "$IHP_TECH/Calibre/RunSets/sg13_drc.runset"
#setenv MGC_CALIBRE_LVS_RUNSET_FILE "$IHP_TECH/Calibre/RunSets/sg13_lvs.runset"
setenv MGC_CALIBRE_PEX_RUNSET_FILE "$IHP_TECH/Calibre/RunSets/sg13_xrc.runset"
#setenv MGC_CALIBRE_DRC_RUNSET_LIST "$IHP_TECH/Calibre/RunSets/sg13_drc.runSetList"
setenv MGC_CALIBRE_DRC_RUNSET_LIST "$IHP_TECH/../../dz/calibre/ihpsg13g2/sg13_drc.runSetList"
setenv MGC_CALIBRE_CUSTOMIZATION_FILE "$IHP_TECH/Calibre/GUI/gui.drc"


setenv SG13_CALIBRE_DRC_RUN  "../calibre/drc/"
setenv SG13_CALIBRE_FILL_RUN "../calibre/fill/"
setenv SG13_CALIBRE_LVS_RUN  "../calibre/lvs/"
setenv SG13_CALIBRE_PEX_RUN  "../calibre/pex/"
