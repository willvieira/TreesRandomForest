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

# predictors variables (3 sets)
variables = 1:3

# number of trees
nbTrees = c(100, 200, 400, 500)

# number of variables selected at each division of the trees
nbMtry = c(2, 3, 4)

tSim = length(sp_ids) * length(variables) * length(nbTrees) * length(nbMtry)
print(paste('Generating a total of', tSim, 'simulations'))

##



## For each combination of variables (slurm file + send job)

# create bash with Rscript
job = 1
for(sp in sp_ids) {
  for(var in variables) {
    for(tree in nbTrees) {
      for(mtr in nbMtry) {

        # name of simulation
        simName = paste(which(sp == sp_ids), var, tree, mtr, sep = '.')

        # send me email for all the info for the last simulation
        mail = ifelse(job == tSim, 'ALL', 'FAIL')

# Bash + Rscript
bash <- paste0('#!/bin/bash

#SBATCH --account=def-dgravel
#SBATCH -t 2-00:00:00
#SBATCH --mem=3000
#SBATCH --job-name="', simName, '"
#SBATCH --mail-user=willian.vieira@usherbrooke.ca
#SBATCH --mail-type=', mail, '

Rscript /home/view2301/TreesRandomForest/R/02_randomForest.R ', sp, ' ', var, ' ', tree, ' ', mtr)

      # save sh file
      system(paste0("echo ", "'", bash, "' > sub.sh"))

      # run sh
      system('sbatch sub.sh')

      # remove sh file
      system('rm sub.sh')

      cat('                           - job ', job, 'of', tSim, '\r')
      job <- job + 1
      }
    }
  }
}
#



##
