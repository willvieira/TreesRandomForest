########################################
# Run randomForestExplainer for all species_id
# Will Vieira
# February, 6 2020
########################################


#############
# Steps
# - Load simulation variables
# - Prepare database and simulation files
# - Run forest Explainer
# - Edit html title to insert species_id and vital rate as subtitles
#############



library(randomForestExplainer)
library(data.table)
set.seed(0.0)



## Simulation variables

  # read species_id
  sp_ids = as.character(read.table('data/sp_ids.txt')[, 1])

  # read species information (for scientific name)
  sp_info <- read.table('data/sp_info.txt')

  # predictors variables (3 sets)
  variables = 2
  varsToKeep = as.character(read.table(paste0('data/variables', variables, '.txt'))[, 1])

  # number of trees
  nbTrees = 1000

  # number of variables selected at each division of the trees
  nbMtry = 6

##



##

  for(vital in c('growth', 'mort')) {

    for(sp in sp_ids) {

      # load db to be used in the explain function
      db_sp_vital = readRDS(paste0('rawData/', vital, '_', sp, '.RDS'))

      db_sp_vital = db_sp_vital[, varsToKeep, with = FALSE]

      # load random forest output
      sim <- readRDS(paste0('output/growth_', sp, '_var', variables, '_nTrees', nbTrees, '_Mtry', nbMtry, '.RDS'))

      # explain rf
      explain_forest(sim, path = paste0(getwd(), '/', sp, '_', vital), interactions = TRUE, data = db_sp_vital)
    }
  }

##



## Edit html title to insert species_id and vital rate as subtitles

  for(vital in c('growth', 'mort')) {

    for(sp in sp_ids) {

      nameHtmlFile <- paste0(sp, '_', vital, '.html')

      patternToFind <- '<h1 class="title toc-ignore">A graphical summary of your random forest</h1>'

      htmlFile <- readLines(nameHtmlFile)

      titleIndex <- grep(patternToFind, htmlFile)

      subtitleText <- paste0(vital, ' rate for species <i>',
                      sp_info$latin[which(sp_info$species_id == sp)], '</i>')

      lineToAdd <- paste0('<h1 class="subtitle toc-ignore">', subtitleText, '</h1>')

      # insert line in the html file
      htmlFile <- append(htmlFile, lineToAdd, after = titleIndex)

      # save html
      writeLines(htmlFile, nameHtmlFile)
    }
  }

##
