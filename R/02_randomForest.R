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
  db_sp_mort = readRDS(paste0('rawData/mort_', sp, '.RDS'))
  db_sp_growth = readRDS(paste0('rawData/growth_', sp, '.RDS'))

  # variables
  var = args[2]
  varsToKeep = as.character(read.table(paste0('data/variables', var, '.txt'))[, 1])

  # random forest parameters
  nTrees = args[3]
  Mtry = args[4]

##



## Run randomForest for growth
  print('Running growth model')

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
  file = paste0('output/growth_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

##



## Run randomForest for mortality (set 1)
  print('Running mortality model (set 1)')

  # keep only variables of interest
  db_sp_mort1 = db_sp_mort[, c('mort', 'deltaYear', varsToKeep), with = FALSE]

  # perfom random forest
  rf_survival1 <- ranger::ranger(survival::Surv(deltaYear, mort) ~ .,
                                 data = db_sp_mort1,
                                 num.trees = nTrees,
                                 mtry = Mtry,
                                 importance = 'impurity_corrected',
                                 write.forest = FALSE,
                                 verbose = FALSE)

  saveRDS(rf_survival1,
  file = paste0('output/mort1_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

##



## Run randomForest for mortality (set 2)
  print('Running mortality model (set 2)')

  # keep only variables of interest
  db_sp_mort2 = db_sp_mort[, c('mort', 'year0', 'year1', varsToKeep), with = FALSE]

  # perfom random forest
  rf_survival2 <- ranger::ranger(survival::Surv(year0, year1, mort, type = 'interval') ~ .,
                                 data = db_sp_mort2,
                                 num.trees = nTrees,
                                 mtry = Mtry,
                                 importance = 'impurity_corrected',
                                 write.forest = FALSE,
                                 verbose = FALSE)

  saveRDS(rf_survival2,
  file = paste0('output/mort2_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

##



## Run randomForest for mortality (set 3)
  print('Running mortality model (set 3)')

  # keep only variables of interest
  db_sp_mort3 = db_sp_mort[, c('mort', varsToKeep), with = FALSE]

  # perfom random forest
  rf_survival3 <- ranger::ranger(mort ~ .,
                                 data = db_sp_mort3,
                                 num.trees = nTrees,
                                 mtry = Mtry,
                                 importance = 'impurity_corrected',
                                 write.forest = FALSE)

  saveRDS(rf_survival3,
  file = paste0('output/mort3_', sp, '_var', var, '_nTrees', nTrees, '_Mtry', Mtry, '.RDS'))

##
