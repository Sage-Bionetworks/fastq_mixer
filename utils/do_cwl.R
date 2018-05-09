library(purrr)
library(stringr)

yamls <- list.files() %>% 
    purrr::keep(str_detect(., ".yaml$")) 

logs <- stringr::str_replace(yamls, "yaml", "log")

do_cwl <- function(yaml, log){
    stderr <- system2(
        "cwltool", 
        args = c("fastq_mixer/fastq_mixer.cwl", yaml), 
        stderr = T)
    writeLines(stderr, log)
}

purrr::walk2(yamls, logs, do_cwl)
