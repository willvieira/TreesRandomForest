########################################
# Prepare data for random forest
# Will Vieira
# January, 09 2020
########################################


#############
# Steps
# - load db
# - save sp_ids
# - split by vital rates, species_id and training data
# - save .RDS
#############


library(data.table)
set.seed(0.0)



## Import datasets

  #mort = readRDS('../Mortality/data/mort_dt.RDS')
  #growth = readRDS('../Mortality/data/growth_dt.RDS')
  mort = readRDS('../../ownCloud/toSave/Bayes-trait-model/cleanProject/data/mort_dt.RDS')
  growth = readRDS('../../ownCloud/toSave/Bayes-trait-model/cleanProject/data/growth_dt.RDS')

##



## Folders

  dir.create('rawData')
  dir.create('data')

##



## Split data by species_id

  # get and save species_id
  sp_ids = unique(mort$species_id)
  write(sp_ids, file = 'rawData/sp_ids.txt')

  # split by vital rate, species id and training/validation data and save it all
  count = 1
  for(vital in c('mort', 'growth'))
  {
    for(sp in sp_ids)
    {
      db_sp = get(vital)[species_id == sp]

      ## get training data
      # Calculate the size of each of the data sets:
      trainingSize <- floor(nrow(db_sp) * 0.7)
      # Generate a random sample of "data_set_size" indexes
      indexes <- sample(1:nrow(db_sp), size = trainingSize)
      # Assign the data to the correct sets
      training <- db_sp[indexes, ]

      # save RDS
      saveRDS(training, file = paste0('data/', vital, '_', sp, '.RDS'))

      cat('   preparing data ', floor((count/(2 * length(sp_ids))) * 100), '%\r')
      count = count + 1

    }
  }

##
