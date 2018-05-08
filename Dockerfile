FROM ubuntu:17.10
RUN apt-get update && apt-get install 

RUN apt-get -y install wget r-base
RUN apt-get -y install tar

RUN wget https://homes.cs.washington.edu/~dcjones/fastq-tools/fastq-tools-0.8.tar.gz
RUN tar -xzvf fastq-tools-0.8.tar.gz
RUN rm fastq-tools-0.8.tar.gz

RUN cd fastq-tools-0.8 && ./configure && make install



RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages(c('stringr', 'dplyr', 'purrr', 'magrittr', 'argparse'))"

COPY bin/fastq_mixer.R /usr/local/bin/
RUN chmod a+x /usr/local/bin/fastq_mixer.R