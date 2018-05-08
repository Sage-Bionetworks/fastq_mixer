library(doMC)
library(plyr)
library(purrr)
library(stringr)

doMC::registerDoMC(cores = detectCores() -1)

yamls <- list.files() %>% 
    purrr::keep(str_detect(., ".yaml$")) 

log_files <- stringr::str_replace(yamls, "yaml", "log")

logs <- plyr::llply(
    yamls, 
    function(yaml) 
        system2(
            "cwltool", 
            args = c("fastq_mixer/fastq_mixer.cwl", yaml), 
            stderr = T),
    .parallel = T)

purr::walk2(logs, log_files, writeLines)