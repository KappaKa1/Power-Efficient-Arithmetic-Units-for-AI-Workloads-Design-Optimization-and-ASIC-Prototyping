#! /bin/csh -f

# v1.0 Zerun Thu 29 Feb 16:16:23 CET 2024
# - klayout batch mode running drc
source ../.setPDK.csh
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

setenv out_dir ./drc/out

rm $out_dir/croc_*

python3 $IHP_TECH/klayout/tech/drc/run_drc.py \
 --path=$gds_path \
 --topcell=$topcell \
 --run_dir $out_dir \
 --no_recommended \
 --no_density \
 --antenna \
 --mp 32

