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
library(survival)
library(data.table)
set.seed(0.0)



## Import simulation info (species_id, variables, nTrees and mtry)

  args = commandArgs(trailingOnly=TRUE)

  # species_id mortality and growth data
  sp = args[1]

  # variables
  var = args[2]
  varsToKeep = as.character(read.table(paste0('data/variables', var, '.txt'))[, 1])

  # random forest parameters
  nTrees = as.numeric(args[3])
  Mtry = as.numeric(args[4])

  print('Running job:');print(paste(sp, var, nTrees, Mtry, sep = '.'))

  # Save forest for all species when var == 2 and mtry == 6
  writeForest <- ifelse(var == 2 & Mtry == 6, TRUE, FALSE)

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
                                  write.forest = writeForest,
                                  verbose = FALSE)

  # save results
  saveRDS(rf_regression,
  file = paste0('output/growth_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

  # clean memory
  rm(list = c('db_sp_growth', 'rf_regression'))

##



## Run randomForest for mortality (set 3)
  print('Running mortality model')

  # get mortality data
  db_sp_mort = readRDS(paste0('rawData/mort_', sp, '.RDS'))

  # keep only variables of interest
  db_sp_mort = db_sp_mort[, c('mort', varsToKeep), with = FALSE]

  # perfom random forest
  rf_survival <- ranger::ranger(as.factor(mort) ~ .,
                                 data = db_sp_mort,
                                 num.trees = nTrees,
                                 mtry = Mtry,
                                 importance = 'impurity_corrected',
                                 write.forest = writeForest)

  saveRDS(rf_survival,
  file = paste0('output/mort_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

  # clean memory
  rm(list = c('db_sp_mort', 'rf_survival'))

##
