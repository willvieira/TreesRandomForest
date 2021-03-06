########################################
# run RF simulations on the server
# Will Vieira
# January, 12 2020
########################################


#############
# Steps
# - Prepare data (sorce Rscript)
# - Generate all variables to simulate
# - For each combination of variables:
  # - Create a slurm file with the variables
  # - send slurm file to the server
#############



## Prepare data (sorce Rscript)

  print('preparing database')

  source('R/01_data.R')

##



## Generate all variables to simulate

  # read species_id
  sp_ids = as.character(read.table('data/sp_ids.txt')[, 1])

  # read trainingSize of each species id
  trainingSize <- read.table('data/trainingSize_spIds.txt')

  # number of trees
  nbTrees = 1000

  # number of variables selected at each division of the trees
  nbMtry = 2

  tSim = length(sp_ids)
  print(paste('Generating a total of', tSim, 'simulations'))

##



## For each combination of variables (slurm file + send job)

# create bash with Rscript
job = 1
for(sp in sp_ids) {

  # name of simulation
  simName = sp

  # send me email for all the info for the last simulation
  mail = ifelse(job == tSim, 'ALL', 'FAIL')

  # Calculate memory usage depending on training size (factor of 0.08) #TODO
  memory <- 2500

# Bash + Rscript
bash <- paste0('#!/bin/bash

#SBATCH --account=def-dgravel
#SBATCH -t 1-00:00:00
#SBATCH --mem=', memory, '
#SBATCH --job-name="', simName, '"
#SBATCH --mail-user=willian.vieira@usherbrooke.ca
#SBATCH --mail-type=', mail, '

Rscript /home/view2301/TreesRandomForest/R/02_randomForest.R ', sp)

  # save sh file
  system(paste0("echo ", "'", bash, "' > sub.sh"))

  # run sh
  system('sbatch sub.sh')

  # remove sh file
  system('rm sub.sh')

  cat('                     - job ', job, 'of', tSim, '\r')
  job <- job + 1

} 
##
