# deploying report
SI=$SERVER_INFO
echo $SI > _server.yml

Rscript R/04_getSimulations.R
