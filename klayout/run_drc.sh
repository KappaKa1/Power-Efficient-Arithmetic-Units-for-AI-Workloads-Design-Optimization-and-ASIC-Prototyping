#! /bin/csh -f

# v1.0 Zerun Thu 29 Feb 16:16:23 CET 2024
# - klayout batch mode running drc
source ../setPDK.csh
### set your gds and topcell ###
set gds_path = ./out/main_chip.gds
set topcell  = main_chip
################################

#usage: 
#    run_drc.py (--help | -h)
#    run_drc.py --path=<file_path>
#            [--table=<table_name>]... [--mp=<num_cores>] [--run_dir=<run_dir_path>]
#            [--topcell=<topcell_name>] [--run_mode=<mode>] [--drc_json=<json_path>]
#            [--precheck_drc] [--disable_extra_rules] [--no_feol] [--no_beol] [--no_density]
#            [--density_thr=<density_threads>] [--density_only] [--antenna]
#            [--antenna_only] [--no_offgrid] [--no_recommended]


### keep the version to 2025.03 for drc running at the moment, because other version run time is 20 times longer

rm ./drc/out/croc_*

time oseda -2026.04 python3 ./drc/tech/run_drc.py \
 --path=$gds_path \
 --topcell=$topcell \
 --run_dir ./drc/out \
 --no_recommended \
 --no_density \
 --antenna \
 --no_feol \
 --no_offgrid \
 --mp 10

#time oseda -2026.04 python3 $IHP_TECH/klayout/tech/drc/run_drc.py \
#  --path=$gds_path \
#  --topcell=$topcell \
#  --run_dir ./drc/out \
#  --no_recommended \
#  --no_density \
#  --antenna \
#  --mp 10

