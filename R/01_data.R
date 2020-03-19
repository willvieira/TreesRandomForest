########################################
# Prepare data for random forest (script for the server)
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

  mort = readRDS('../Mortality/data/mort_dt.RDS')
  growth = readRDS('../Mortality/data/growth_dt.RDS')
  fec = readRDS('../Mortality/data/fec_dt.RDS')

##



## Folders

  dir.create('rawData')
  dir.create('output')

##



## Split data by species_id

  # get and save species_id
  sp_ids = unique(mort$species_id)
  write(sp_ids, file = 'data/sp_ids.txt')

  # vector to save trainingSize for each species id
  trainingSize_spIds = as.data.frame(matrix(NA, ncol = 3, nrow = length(sp_ids) * 2))

  # split by vital rate, species id and training/validation data and save it all
  count = 1
  for(vital in c('mort', 'growth', 'fec'))
  {
    for(sp in sp_ids)
    {
      db_sp = get(vital)[species_id == sp]

      ## get training data (difference between 'growth/mort' and 'fec')
      if(vital == 'fec') {
        # Calculate the size of each of the data sets:
        trainingSize <- floor(length(unique(db_sp$plot_id)) * 0.8)

        # Generate a random sample of "data_set_size" indexes
        plot_ids <- sample(unique(db_sp$plot_id), size = trainingSize)
        # Assign the data to the correct sets
        training <- db_sp[plot_id %in% plot_ids]

      }else {
        # Calculate the size of each of the data sets:
        trainingSize <- floor(nrow(db_sp) * 0.7)
        # Generate a random sample of "data_set_size" indexes
        indexes <- sample(1:nrow(db_sp), size = trainingSize)
        # Assign the data to the correct sets
        training <- db_sp[indexes, ]
      }

      # save trainingSize
      trainingSize_spIds[count, ] <- c(vital, sp, trainingSize)
      # save RDS
      saveRDS(training, file = paste0('rawData/', vital, '_', sp, '.RDS'))

      cat('   preparing data ', floor((count/(2 * length(sp_ids))) * 100), '%\r')
      count = count + 1

    }
  }

  # save training size
  names(trainingSize_spIds) <- c('vital', 'sp', 'trainingSize')
  write.table(trainingSize_spIds, file = 'data/trainingSize_spIds.txt')

##



## Clean up

  rm(list = c('mort', 'growth', 'fec', 'db_sp'))

##
