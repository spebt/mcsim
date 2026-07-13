#!/bin/bash


box_vscratch=$(sbatch --parsable --export=ALL,RUN_TAG=box par_vscratch.sh)
box_hadd=$(sbatch --parsable --export=ALL,RUN_TAG=box --dependency=afterok:$box_vscratch par_hadd.sh)
box_proj=$(sbatch --parsable --export=ALL,RUN_TAG=box --dependency=afterok:$box_hadd par_projection_data.sh)

