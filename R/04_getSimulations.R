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

##



## get name of all simulations output

  filesName = c(); count = 1

  for(vital in c('fec', 'mort', 'growth')) {
    for(sp in sp_ids) {
      filesName[count] = paste0(vital, '_', sp, '.RDS')
      count <- count + 1
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
      toLoad = FALSE
    }else {
      print('All simulations are already loaded')
      toLoad = FALSE
    }

  }else {
    print('Loading simulations...')
    system(server_info)
    toLoad = TRUE
  }

##



## Last check if all simulations were available in the server (after loading)

  if(toLoad) {

    Files <- dir('output')

    if(all(filesName %in% Files)) {
      print('All files were correctly loaded')
    }else {
      missingSim <- filesName[!(filesName %in% Files)]
      print('These simulations were not found in the server:')
      print(missingSim)
    }
  }
##
