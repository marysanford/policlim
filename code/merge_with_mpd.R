---
title: "merge_with_mpd"
author: 'Mary Sanford'
last_updated: "2026-02-12"
---


# IMPORTANT NOTICES -------------------------------------------------------

# Be sure to cite the Manifesto Project Dataset and the policlim dataset if you use this data.
# Remember to note which version of the Manifesto Project Dataset you download and cite this according
# to the instructions from the Manifesto Project, which can be found on their website: https://manifesto-project.wzb.eu/datasets

# The citation for the 2024-1 Version of the dataset is: 
# Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / 
# Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / 
# Weßels, Bernhard / Zehnter, Lisa (2024): The Manifesto Data Collection. 
# Manifesto Project (MRG/CMP/MARPOR). Version 2024a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / 
# Göttingen: Institut für Demokratieforschung (IfDem). https://doi.org/10.25522/manifesto.mpds.2024a

# The citation for the 2024-1 Version of the corpus is:
# Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / 
# Ivanusch, Christoph / Lewandowski, Jirka / Regel, Sven / Riethmüller, 
# Felicia / Zehnter, Lisa (2024): Manifesto Corpus. Version: 2024-1. 
# Berlin: WZB Berlin Social Science Center/Göttingen: Institute for Democracy Research (IfDem).

# Citation for the 2025 Codebook:
# Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch,
# Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / Weßels, Bernhard / Zehnter, Lisa (2025): 
# The Manifesto Project Dataset- Codebook. Manifesto Project (MRG/CMP/MARPOR).Version2025a. 
# Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem)


# Load packages  ----------------------------------------------------------

library(manifestoR)
library(dplyr)
library(quanteda)
library(tidytext)
library(tidyverse)
library(devtools)

# Load data and api key ---------------------------------------------------

# Set WD 
setwd("policlim_replication")

# Set api key -- USER MUST REGISTER AND GENERATE THIS (NOT INCLUDED IN REP PACKAGE)
mp_setapikey("manifesto_apikey.txt")

# Read policlim dataset 
policlim = read.csv('data/policlim_2025_share.csv')

# Download MPD meta-dataset ----------------------------------------------------

# Collect dataset -- defaults to most recent version so need to specify version
mp_use_corpus_version("2024-1")
mpds <- mp_maindataset()
View(mpds)

# Check version  - 2024-01
mp_which_corpus_version()

# Merge -------------------------------------------------------------------

# policlim contains the following columns:
names(policlim)

# and the mpds:
names(mpds)

# party and date can be joined to create a manifesto_id
policlim = policlim %>% 
  mutate(
    manifesto_id = paste(party,date,sep='_')
  )

# manifesto_id can also be created for the MPDS
mpds = mpds %>% 
  mutate(
    manifesto_id = paste(party,date,sep='_')
  )

# now merge the two  
merged_data <- policlim %>%
  left_join(mpds, by = "manifesto_id")

# Now you have a merged dataset ready for analysis with all the MPD variables.

# Use this to get the parfam names based on parfam variable in MPD
# Parfam information from the Manifesto Project Codebook: https://manifesto-project.wzb.eu/down/data/2025a/codebooks/codebook_MPDataset_MPDS2025a.pdf
parfam_name_dict <- c(
  `10` = 'ECO',
  `20` = 'LEF',
  `30` = 'SOC',
  `40` = 'LIB',
  `50` = 'CHR',
  `60` = 'CON',
  `70` = 'NAT',
  `80` = 'AGR',
  `90` = 'ETH',
  `95` = 'SIP',
  `98` = 'DIV',
  `999` = 'MI'
)

merged_data$parfam_name <- parfam_name_dict[as.character(merged_data$parfam)]

# Save for replication and export if needed 
mp_save_cache(file = "policlim_mpds_merge.RData")

# The merged data containing the MPD variables CANNOT go online 
write.csv(merged_data, 'data/policlim_mpds_2024-1.csv')
