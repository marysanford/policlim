---
title: "collect_mpd_2026"
author: 'Mary Sanford'
date: "2026-02-12"
---

# IMPORTANT NOTICES -------------------------------------------------------

# Be sure to cite the Manifesto Project Dataset and Corpus, along with the policlim dataset if you use this data.
# Remember to note which version of the Manifesto Project Dataset or Corpus you download and cite this according
# to the instructions from the Manifesto Project, which can be found on their website: https://manifesto-project.wzb.eu/datasets

# The citation for the 2025-1 Version of the Corpus is: 
# Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / 
# Ivanusch, Christoph / Lewandowski, Jirka / Regel, Sven / Riethmüller, Felicia / 
# Zehnter, Lisa (2025): Manifesto Corpus. Version: 2025-1. 
# Berlin: WZB Berlin Social Science Center/Göttingen: Institute for Democracy Research (IfDem).

# The citation for the 2025-1 Version of the dataset is: 
# Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / 
# Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / 
# Weßels, Bernhard / Zehnter, Lisa (2025): The Manifesto Data Collection. 
# Manifesto Project (MRG/CMP/MARPOR). Version 2025a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / 
# Göttingen: Institut für Demokratieforschung (IfDem). https://doi.org/10.25522/manifesto.mpds.2025a

# You can find the Manifesto Project's Terms of Use for the Dataset and Corpus in the replication package. 


# Load packages -----------------------------------------------------------

library(manifestoR)
library(dplyr)
library(quanteda)
library(tidytext)
library(tidyverse)
library(devtools)


# Load data and api key ---------------------------------------------------

# Set WD 
setwd("C:/Users/Sanford/Documents/eiee/capable/manifestos/rep_package")

# Set api key 
mp_setapikey("data/manifesto_apikey.txt")

# Target countries
countries = c("Argentina","Australia","Austria","Belgium","Bolivia","Brazil","Bulgaria","Canada",
              "Chile","Colombia","Costa Rica","Croatia","Cyprus","Czech Republic","Denmark",
              "Dominican Republic","Ecuador","Estonia","Finland","France","Germany","Greece",
              "Hungary","Ireland","Israel","Italy","Latvia","Lithuania","Luxembourg","Mexico",
              "Netherlands","New Zealand","Norway","Panama","Poland","Portugal","Romania","Slovakia",
              "Slovenia","Spain","Sweden","Switzerland","United Kingdom","United States","Uruguay") 


# Download MPD meta-dataset ----------------------------------------------------

# Specify which version to use
mp_use_corpus_version("2024-1")

# Collect dataset -- version 2024-1
mpds <- mp_maindataset(version = "MPDS2024a")
View(mpds)

# Save -- this cannot be uploaded 
write.csv(mpds,'data/2024-1-mpds.csv')


# Collect unitised manifestos ---------------------------------------------

all_problems = c()
master_dict <- list()

# There is a problem in that not all  manifestos have been unitised into quasi-sentences. 
# These do not export cleanly. So it is necessary to identify them and then download and unitise them 'manually'.

# Iterate over target countries
for (c in countries) {
  print(c)
  
  # Collect all manifestos since 1990  
  my_corpus_df <- mp_corpus(countryname == c & edate >= as.Date("1990-01-01"),
                          as_tibble = TRUE)
  
  # Identify and store the IDs of problem manifestos
  problem_manifestos <- my_corpus_df %>%
    count(manifesto_id) %>%
    filter(n == 1) %>%
    pull(manifesto_id)
  
  all_problems = c(all_problems,problem_manifestos)
  if (length(problem_manifestos) > 0) {
    master_dict[[c]] <- problem_manifestos
  }

  # Remove them from the dataset
  my_corpus_df <- my_corpus_df %>%
    filter(!manifesto_id %in% problem_manifestos)
  
  # Check results
  print(paste("Removed", length(problem_manifestos), "manifesto_ids"))
  print(problem_manifestos)
  
  # Export
  write.csv(my_corpus_df, file.path('data/2024_corpus/normal_unitised',paste0(c,'_unitised_manifestos.csv')),quote=T)
} 


# Collect un-unitised manifestos and fix ----------------------------------
library(tokenizers)

# 2025: 366 manifestos not unitised, 2024: 370
length(all_problems)

# Iterate over the dictionary
for (country in names(master_dict)) {
  problem_list <- master_dict[[country]]
  
  # Do something with country and problem_list
  print(paste("Country:", country))
  print(paste("Number of problems:", length(problem_list)))
  print(problem_list)
}

# Now for each country with text dump manifestos, go back  
for (country in names(master_dict)) {
  print(country)
  problem_list <- master_dict[[country]]#[[1]][1]
  for (prob in problem_list) {
    print(prob)
    party_code <- as.integer(strsplit(prob, "_")[[1]][1])
    print(party_code)
    date <- as.integer(strsplit(prob, "_")[[1]][2])
    print(date)
    bad_corpus_df <- mp_corpus(party == party_code & date == date,
                              as_tibble = TRUE)
    print(nrow(bad_corpus_df))
    
    good_corpus_df <- bad_corpus_df %>%
      mutate(sentence = tokenize_sentences(text)) %>%
      unnest(sentence) %>%
      group_by(across(-sentence)) %>%  # group by all columns except sentence
      mutate(sentence_num = row_number()) %>%
      ungroup() %>% 
      mutate(
        text = sentence
      ) %>% 
      dplyr::select(-sentence) %>%
      filter(manifesto_id == prob)
    
    print(nrow(good_corpus_df))
    country_prob = paste(country,prob,sep='_')
    
    #write.csv(good_corpus_df, file.path('data/2024_corpus/test/',paste0(country_prob,'_post_hoc_unitised_manifestos.csv')),quote=T)
  
  }
}

mp_save_cache(file = "manifesto_cache.RData")


# Reviewing some issues with retrieval ------------------------------------

#22220, 21914
party_code = 21914
date = 199505
sample = mp_corpus(party == party_code & date == date , as_tibble = TRUE)
View(sample)

sample2 = mp_corpus(party == 21914 & date == 199505 , as_tibble = TRUE)
View(sample2)

mp_availability(countryname == 'France' & date > 199000)

d = read.csv('data/2024_corpus/31110_199705.csv')
d$text
