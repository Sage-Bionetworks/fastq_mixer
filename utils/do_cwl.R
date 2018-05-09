library(doMC)
library(plyr)
library(purrr)
library(stringr)

yamls <- list.files() %>% 
    purrr::keep(str_detect(., ".yaml$")) 

doMC::registerDoMC(cores = length(yamls))

log_files <- stringr::str_replace(yamls, "yaml", "log")

logs <- plyr::llply(
    yamls, 
    function(yaml) 
        system2(
            "cwltool", 
            args = c("fastq_mixer/fastq_mixer.cwl", yaml), 
            stderr = T),
    .parallel = T)

purrr::walk2(logs, log_files, writeLines)
