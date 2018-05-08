library(purrr)
library(dplyr)
library(magrittr)
library(argparse)
library(stringr)

parser = ArgumentParser(description = 'Mix fastq files into new fastqs')

# required args
parser$add_argument(
    "--fastq_files_p1",
    type = "character",
    nargs = "+",
    required = TRUE,
    help = "Path to pair 1 fastq files")

parser$add_argument(
    "--fastq_files_p2",
    type = "character",
    nargs = "+",
    required = TRUE,
    help = "Path to pair 2 fastq files")

parser$add_argument(
    "--sample_fractions",
    type = "double",
    nargs = "+",
    required = TRUE,
    help = "Fractions to sample from each fastq file")

parser$add_argument(
    "--seed",
    type = "integer",
    default = NULL,
    help = "Sets the seed for each sampling, otherwise will set its own seed")

parser$add_argument(
    "--output_prefix",
    type = "character",
    default = "result",
    help = "prefix for output fastqs")

args <- parser$parse_args()

combine_paired_fastq_files <- function(
    df, seed, output_prefix){
    
    parameter_df <- create_parameter_df(df, seed)
    walk(parameter_df$sample_command, system)
    output_file1 <- str_c(output_prefix, "_p1.fastq")
    output_file2 <- str_c(output_prefix, "_p2.fastq")
    merge_input_files(parameter_df$p1_sample_file, output_file1)
    merge_input_files(parameter_df$p2_sample_file, output_file2)
}

merge_input_files <- function(input_files, output_file){
    command <- input_files %>% 
        str_c(collapse = " ") %>% 
        str_c("cat ", ., " > ", output_file)
    system(command)
    walk(input_files, file.remove)
}

create_parameter_df <- function(df, seed){
    df %>% 
        mutate(n_reads = map_int(p1_fastq_file, find_fastq_n_reads)) %>%
        mutate(n_samples = as.integer(mean(n_reads) * fraction)) %>% 
        mutate(prefix = str_c("tmp", 1:nrow(df))) %>% 
        mutate(p1_sample_file = str_c(prefix, ".1.fastq")) %>% 
        mutate(p2_sample_file = str_c(prefix, ".2.fastq")) %>% 
        mutate(sample_command = create_fastq_sample_commands(., seed))
}

find_fastq_n_reads <- function(fastq){
    fastq %>% 
        str_c("wc -l ", .) %>% 
        system(intern = T) %>% 
        str_split(" ") %>% 
        .[[1]] %>% 
        .[[1]] %>% 
        as.integer %>% 
        divide_by(4) %>% 
        as.integer
}

create_fastq_sample_commands <- function(df, seed){
    pmap_chr(
        list(
            df$prefix,
            df$n_samples,
            df$p1_fastq_file,
            df$p2_fastq_file),
        create_fastq_sample_command,
        seed)
}

create_fastq_sample_command <- function(
    prefix, n_samples, fastq_file1, fastq_file2, seed){
    
    args <- c(
        "fastq-sample",
        "-n", as.character(n_samples),
        "-o", prefix,
        "-r")
    if(is.integer(seed)) args <- c(args, "-s", seed)
    args <- c(
        args, 
        fastq_file1,
        fastq_file2)
    command <- str_c(args, collapse = " ")
}

df <- data_frame(
    "fraction" = args$sample_fractions,
    "p1_fastq_file" = args$fastq_files_p1,
    "p2_fastq_file" = args$fastq_files_p2)

print(df)
print(args$seed)
print(args$output_prefix)
combine_paired_fastq_files(df, args$seed, args$output_prefix)

