FROM rocker/rstudio:4.0.4

RUN sudo apt-get update -y
RUN sudo apt-get install -y libxml2-dev
RUN sudo apt-get install -y libcairo2-dev

RUN install2.r --error \
    --deps TRUE \
    devtools \
    rlang \
    optparse \
    docstring \
    plotly \
    heatmaply \
    RColorBrewer \
    ggsci \
    pROC \
    openxlsx \
    readxl \
    googledrive

RUN R -e "BiocManager::install('cowplot')"

RUN R -e "devtools::install_github('kassambara/ggpubr')"

ADD ./ /home/rstudio/repo_files
RUN chmod a+rwx -R /home/rstudio
ADD ./.Rprofile /home/rstudio/.Rprofile
ENV R_PROFILE_USER /home/rstudio/.Rprofile
