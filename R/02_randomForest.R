########################################
# random forest for the eastern North American tree species
# Will Vieira
# January, 06 2020
########################################


#############
# Steps
# - Import simulation info
# - Run randomForest for growth
# - Run randomForest for survival (tree different model sets)
#############



library(ranger)
library(data.table)
set.seed(0.0)



## Import simulation info (species_id, variables, nTrees and mtry)

  args = commandArgs(trailingOnly=TRUE)

  # species_id mortality and growth data
  sp = args[1]

  # variables
  varsToKeep = as.character(read.table('data/variables.txt')[, 1])
  varsToKeepFec = as.character(read.table('data/variables_fec.txt')[, 1])

  # random forest parameters
  nTrees = 1000
  Mtry = 2

  print(paste('Running job for species: ', sp))

##



## Run randomForest for growth
  print('Running growth model')
  
  # get growth data
  db_sp_growth = readRDS(paste0('rawData/growth_', sp, '.RDS'))
  
  # keep only variables of interest
  db_sp_growth = db_sp_growth[, varsToKeep, with = FALSE]
  
  # perfom random forest
  rf_regression <- ranger::ranger(growth ~ .,
                                  data = db_sp_growth,
                                  num.trees = nTrees,
                                  mtry = Mtry,
                                  importance = 'impurity_corrected',
                                  write.forest = FALSE,
                                  verbose = FALSE)
  
  # save results
  saveRDS(rf_regression,
  file = paste0('output/growth_', sp, '.RDS'))
  
  # clean memory
  rm(list = c('db_sp_growth', 'rf_regression'))

##



## Run randomForest for mortality (set 3)
  print('Running mortality model')
  
  # get mortality data
  db_sp_mort = readRDS(paste0('rawData/mort_', sp, '.RDS'))
  
  # keep only variables of interest
  db_sp_mort = db_sp_mort[, c('mort', varsToKeep), with = FALSE]
  
  #Compute weights to balance the RF
  w <- 1/table(db_sp_mort$mort)
  w <- w/sum(w)
  weights <- rep(0, nrow(db_sp_mort))
  weights[db_sp_mort$mort == 0] <- w['0']
  weights[db_sp_mort$mort == 1] <- w['1']
  
  # perfom random forest
  rf_survival <- ranger::ranger(as.factor(mort) ~ .,
                                 data = db_sp_mort,
                                 case.weights = weights,
                                 num.trees = nTrees,
                                 mtry = Mtry,
                                 importance = 'impurity_corrected',
                                 write.forest = FALSE)
  
  saveRDS(rf_survival,
  file = paste0('output/mort_', sp, '.RDS'))
  
  # clean memory
  rm(list = c('db_sp_mort', 'rf_survival'))

##



## Run randomForest for mortality (set 3)
  print('Running recruitment model')

  # get mortality data
  db_sp_fec = readRDS(paste0('rawData/fec_', sp, '.RDS'))

  # keep only variables of interest
  db_sp_fec = db_sp_fec[, c('nbRecruit', varsToKeepFec), with = FALSE]

  # perfom random forest
  rf_regeneration <- ranger::ranger(nbRecruit ~ .,
                                    data = db_sp_fec,
                                    num.trees = nTrees,
                                    mtry = Mtry,
                                    importance = 'impurity_corrected',
                                    write.forest = FALSE)

  saveRDS(rf_regeneration,
  file = paste0('output/fec_', sp, '.RDS'))

  # clean memory
  rm(list = c('db_sp_fec', 'rf_regeneration'))

##
