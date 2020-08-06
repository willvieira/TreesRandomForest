########################################
# Prepare data for random forest
# Will Vieira
# January, 09 2020
# Last updated: August 3, 2020
########################################


#############
# Steps
# - load db
# - save sp_ids
# - Remove unnecessary variables
# - Remove correlated variables
# - split by vital rates, species_id and training data
# - save .RDS
#############


library(data.table)
set.seed(0.0)



## Folders

  dir.create('rawData')
  dir.create('output')

##



## Import North America datasets

  dataLink <- readLines('_dataLink')[1]
  dataFile <- paste0('rawData/forest_dt.', ifelse(Sys.info()['sysname'] == 'Darwin', 'tar', 'zip'))
	vitalFiles <- paste0('rawData/data/', c('mort', 'growth', 'fec'), '_dt.RDS')

  # Download and unzip file?
  if(!any(file.exists(vitalFiles)))
  {

    # download data
    if(!file.exists(dataFile))
        download.file(dataLink, dataFile, method = 'auto', quiet = TRUE)

    # unzip
    if(Sys.info()['sysname'] == 'Darwin')
    {
      untar(dataFile, exdir = 'rawData')
    }else{
      unzip(dataFile, exdir = 'rawData')
    }
    invisible(file.remove(dataFile))
  }

  mort = readRDS('rawData/data/mort_dt.RDS')
  growth = readRDS('rawData/data/growth_dt.RDS')
  fec = readRDS('rawData/data/fec_dt.RDS')

##



## Import Quebec dataset

  dataLink <- readLines('_dataLink')[2]
  dataFile <- paste0('rawData/forest_quebec_dt.', ifelse(Sys.info()['sysname'] == 'Darwin', 'tar', 'zip'))
	vitalFiles <- paste0('rawData/quebec/', c('mort', 'growth', 'fec'), '_dt.RDS')

  # Download and unzip file?
  if(!any(file.exists(vitalFiles)))
  {
    # download data
    if(!file.exists(dataFile))
        download.file(dataLink, dataFile, method = 'auto', quiet = TRUE)

    # unzip
    if(Sys.info()['sysname'] == 'Darwin')
    {
      untar(dataFile, exdir = 'rawData')
    }else{
      unzip(dataFile, exdir = 'rawData')
    }
    invisible(file.remove(dataFile))
  }

  mort_qc = readRDS('rawData/quebec/mort_dt.RDS')
  growth_qc = readRDS('rawData/quebec/growth_dt.RDS')
  fec_qc = readRDS('rawData/quebec/fec_dt.RDS')

##



## Remove or fix variables

  # All db TODO


  # Quebec db

  # Fill NA of disturbance cols as its information is "notDisturbed"
  growth_qc[is.na(PERTURB2), PERTURB2 := 'notDisturbed']
  growth_qc[is.na(ORIGINE2), ORIGINE2 := 'notDisturbed']
  mort_qc[is.na(PERTURB2), PERTURB2 := 'notDisturbed']
  mort_qc[is.na(ORIGINE2), ORIGINE2 := 'notDisturbed']
  fec_qc[is.na(PERTURB2), PERTURB2 := 'notDisturbed']
  fec_qc[is.na(ORIGINE2), ORIGINE2 := 'notDisturbed']

  # Remove other two disturbance columns
  growth_qc[ ,`:=`(PERTURB = NULL, ORIGINE = NULL)]
  mort_qc[ ,`:=`(PERTURB = NULL, ORIGINE = NULL)]
  fec_qc[ ,`:=`(PERTURB = NULL, ORIGINE = NULL)]

  # Remove cols with too many NAs
  growth_qc[ ,`:=`(ENSOLEIL = NULL, DEFOL_MAX = NULL, CAUS_DEFOL = NULL)]
  mort_qc[ ,`:=`(ENSOLEIL = NULL, DEFOL_MAX = NULL, CAUS_DEFOL = NULL)]
  
  # Remove unnecessary variables
  colToRm <- c('ETAT', 'ETAGE_ARB', 'sp_code', 'SHAPE', 'ecoreg3', 'height', 'nbMeasure', 's_star', 'canopyStatus', 'indBA', 'BA_sp', 'dbh1', 'year0', 'year1')
  growth_qc <- growth_qc[, setdiff(names(growth_qc), colToRm), with = FALSE]
  mort_qc <- mort_qc[, setdiff(names(mort_qc), c(colToRm, 'state')), with = FALSE]
  fec_qc <- fec_qc[, setdiff(names(fec_qc), colToRm), with = FALSE]
  
##



## Remove correlated climate variables

  # All db


  # Quebec db
  # # first get numeric variables only
  # corGrowth <- cor(growth_qc[, grep('bio|cmi', names(growth_qc), value = TRUE), with = FALSE], use = 'complete.obs')
  # corGrowth[lower.tri(corGrowth, diag = TRUE)] <- NA
  
  # # get correlated variables (> 70%)
  # corID <- which(abs(corGrowth) > 0.70, , arr.ind = TRUE)

  # # plot all in one pdf
  # # First change bioclim var names
  # bioClim = c(value5_bio60_01 = 'Annual Mean Temperature',
  #             value5_bio60_02 = 'Mean Diurnal Range',
  #             value5_bio60_03 = 'Isothermality (BIO2/BIO7)',
  #             value5_bio60_04 = 'Temperature Seasonality',
  #             value5_bio60_05 = 'Max Temperature of Warmest Month',
  #             value5_bio60_06 = 'Min Temperature of Coldest Month',
  #             value5_bio60_07 = 'Temperature Annual Range (BIO5-BIO6)',
  #             value5_bio60_08 = 'Mean Temperature of Wettest Quarter',
  #             value5_bio60_09 = 'Mean Temperature of Driest Quarter',
  #             value5_bio60_10 = 'Mean Temperature of Warmest Quarter',
  #             value5_bio60_11 = 'Mean Temperature of Coldest Quarter',
  #             value5_bio60_12 = 'Annual Precipitation',
  #             value5_bio60_13 = 'Precipitation of Wettest Month',
  #             value5_bio60_14 = 'Precipitation of Driest Month',
  #             value5_bio60_15 = 'Precipitation Seasonality',
  #             value5_bio60_16 = 'Precipitation of Wettest Quarter',
  #             value5_bio60_17 = 'Precipitation of Driest Quarter',
  #             value5_bio60_18 = 'Precipitation of Warmest Quarter',
  #             value5_bio60_19 = 'Precipitation of Coldest Quarter')

  # colnames(corGrowth)[colnames(corGrowth) %in% names(bioClim)] <- bioClim
  # rownames(corGrowth)[rownames(corGrowth) %in% names(bioClim)] <- bioClim

  # gqc <- growth_qc
  # names(gqc)[names(gqc) %in% names(bioClim)] <- bioClim
  
  # png(filename = paste0('correlated_vars.png'), height = 5250, res = 400)
  # par(mfrow = c(35, 3), mar = c(3,3,0.5,0.5), mgp = c(1.5, 0.3, 0), tck = -.008, cex = 0.15, bty = 'l')
  # for(i in 1:nrow(corID))
  # {
  #   dt <- gqc[, c(colnames(corGrowth)[corID[i, 1]], colnames(corGrowth)[corID[i, 2]]), with = FALSE]
  #   plot(dt, col = rgb(0.2, 0.3, 0.4, 0.1))
  #   legend('bottomright', legend = paste('R2 =', round(summary(lm(dt))$r.squared, 2), '\nCor =', round(cor(dt)[1, 2], 2)), bty = 'n', cex = 0.8)
  #   cat('   Printing plot ', i, 'of', nrow(corID), '\r')
  # }
  # dev.off()
  # rm(dt, gqc)


  # Final climatic variables to remove
  varsToRm <- c(grep('pcp60', names(growth_qc), value = TRUE),
                grep('cmi60_[0-9]', names(growth_qc), value = TRUE),
                paste0('value5_bio60_', c('02', '05', '06', '07', '10', '11', '12', '13', '16', '17', '18', '19')))


  growth_qc <- growth_qc[, setdiff(names(growth_qc), c(varsToRm, 'relativeBA_sp', 'deltaYear', 'state')), with = FALSE]
  mort_qc <- mort_qc[, setdiff(names(mort_qc), c(varsToRm, 'relativeBA_sp', 'growth')), with = FALSE]
  fec_qc <- fec_qc[, setdiff(names(fec_qc), c(varsToRm, 'growth', 'year_measured')), with = FALSE]

  # save data sets with selected variables only
  saveRDS(growth_qc, file = 'data/growth_qc.RDS')
  saveRDS(mort_qc, file = 'data/mort_qc.RDS')
  saveRDS(fec_qc, file = 'data/fec_qc.RDS')

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



## Split data by (i) species_id and (ii) training/validation
# For each species_id, split data per plot_ids (ID_PE) between 60, 20 and 20% for training and validation
# The idea of spliting at the plot level is to try to control for individual and plot level autocorrelation

  # Before spliting, get species_id for all three vital rates present in at least 100 plots
  nbPlots <- 100
  sp_ids <- Reduce(intersect, list(growth_qc[, length(unique(ID_PE)), by = sp_code2][V1 > nbPlots, sp_code2],
                                   mort_qc[, length(unique(ID_PE)), by = sp_code2][V1 > nbPlots, sp_code2],
                                   fec_qc[, length(unique(ID_PE)), by = sp_code2][V1 > nbPlots, sp_code2]))

  spec <- c(train = .7, validate = .3)
  count = 1
  plotList <- list() # list to save plot_id for each vital rate AND train/test/validate sets
  
  for(vital in c('mort_qc', 'growth_qc', 'fec_qc'))
  {
    
    vitalList <- list()
    for(sp in sp_ids)
    {
      db_sp = get(vital)[sp_code2 == sp]

      # Get plot_id for train/test and validate data sets
      sizeDb <- length(unique(db_sp$ID_PE))
      g <- sample(cut(seq(sizeDb), sizeDb * cumsum(c(0, spec)), labels = names(spec)))
      plot_ids <- split(unique(db_sp$ID_PE), g)

      # append to local list
      vitalList[[sp]] <- plot_ids

      cat('   preparing data ', floor((count/(3 * length(sp_ids))) * 100), '%\r')
      count = count + 1
    }

    # append to global list
    plotList[[vital]] <- vitalList
  }   

  saveRDS(plotList, file = 'data/plotIds_quebec.RDS')

##
