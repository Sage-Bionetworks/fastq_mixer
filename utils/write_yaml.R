require(yaml)
require(purrr)


create_fastq_mixer_yaml <- function(
    yaml_file,
    fastq_files_p1,
    fastq_files_p2,
    sample_fractions,
    seed = NULL,
    output_prefix = NULL){
    
    arg_list = list(
        "fastq_files_p1" = map(fastq_files_p1, file_to_yaml_file),
        "fastq_files_p2" = map(fastq_files_p2, file_to_yaml_file),
        "sample_fractions" = sample_fractions)
    
    option_list = 
        list("seed" = seed,"output_prefix" = output_prefix) %>% 
        purrr::discard(is.null)
    
    yaml::write_yaml(c(arg_list, option_list), yaml_file)
}
    
file_to_yaml_file <- function(file){
    list("path" = file, "class" = "File")
}