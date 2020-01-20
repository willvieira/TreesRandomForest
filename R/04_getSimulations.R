########################################
# Script to get simulations from the server
# Will Vieira
# January, 20 2020
########################################


#############
# Steps
# - Load conf file with server info
# - Load simulation variables
# - get name of all simulations
# - Load all files and save in the output folder
#############



## Load conf file with server info

  server_info <- readLines('_server.yml')

##



## Load simulation variables

  # species_id
  sp_ids = as.character(read.table('data/sp_ids.txt')[, 1])

  # other variables from the simulation file
  rFile <- readLines('R/03_runSimulations.R')

  # variables
  eval(parse(text =
    rFile[which(sapply(rFile, function(x) grep('variables = ', x)) == 1)]))

  # nbTrees
  eval(parse(text =
    rFile[which(sapply(rFile, function(x) grep('nbTrees = ', x)) == 1)]))

  # nbMtry
  eval(parse(text =
    rFile[which(sapply(rFile, function(x) grep('nbMtry = ', x)) == 1)]))

##



## get name of all simulations output

  filesName = c(); count = 1

  for(vital in c('growth', 'mort')) {
    for(sp in sp_ids) {
      for(var in variables) {
        for(tree in nbTrees) {
          for(mty in nbMtry) {
            filesName[count] = paste0(vital, '_', sp, '_var', var, '_nTrees', nbTrees, '_Mtry', mty, '.RDS')
            count <- count + 1
            }
          }
        }
      }
    }
  }

##



## Load all files and save in the output folder

  # check if output folder exists
  if(dir.exists('output'))
  {
    # if exists, check if all simulation are present
    Files <- dir('output')

    if(!all(filesName %in% Files)) {
      missingSim <- filesName[!(filesName %in% Files)]
      print('Not loading simulations because of missing simulations:')
      print(missingSim)
    }else {
      print('All simulations are already loaded')
    }

  }else {
    print('Loading simulations...')
    system(server_info)
  }

##
