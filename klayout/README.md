# How to run DRC with KLayout

Note: you can change the tools version by specifying it to the `oseda` command (no arguments == latest release). For checking DRCs with KLayout, use `oseda -2026.04` (current default) or later for a significantly improved runtime with respect to previous versions.

## 1. Generate GDS file from OpenROAD's DEF

```bash
cp ../openroad/out/main_chip.def ./main_chip.def
oseda ./def2gds.sh
```

Note: the `def2gds.sh` script currently assumes the DEF file to be located in the `klayout` directory. If you change the `defpath` variable in the script to a file in a different directory, other files such as the layermap configuration file may not be loaded correctly by KLayout.

## 2. Run DRC with KLayout

```bash
oseda ./run_drc.sh
```
