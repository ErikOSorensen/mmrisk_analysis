#!/bin/bash
mkdir -p logs
nohup Rscript main.R > logs/run_$(date +%Y%m%d_%H%M).log 2>&1 &
