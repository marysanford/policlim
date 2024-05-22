library(manifestoR)
library(dplyr)
library(quanteda)
library(tidytext)
library(tidyverse)
library(devtools)
#devtools::install_github("haukelicht/manifestoEnhanceR",force=T)
#library(manifestoEnhanceR)

# NEED MANIFESTO APIKEY
setwd("path/to/directory/with/api_key")
mp_setapikey("manifesto_apikey.txt")

eu_countries <- c(
  "Austria",  "Belgium", "Bulgaria", "Croatia","Cyprus","Czech Republic","Denmark","Estonia","Finland",
  "France","Germany","Greece","Hungary","Ireland","Italy","Latvia","Lithuania","Luxembourg","Malta",
  "Netherlands","Poland","Portugal","Romania","Slovakia","Slovenia","Spain","Sweden",'United Kingdom')

# get CMP party-year data
cmp <- mp_maindataset(south_america = FALSE)

countries = c('United Kingdom')
for (c in eu_countries) {
  print(c)
  # subset to target configurations: year and percent vote
  configs <- cmp %>%
    filter(countryname == c & date > 197000 & pervote >= 5) %>%  #& date > 197000 & pervote >= 5
    relocate(pervote, .after = parfam) %>%
    select(1:11)

   if (length(configs) == 0) {
    next
  }
  #get country manifestos
  man <- mp_corpus(countryname == c & date > 197000 & pervote >= 5, cache = TRUE) # & date > 197000 & pervote >= 5, cache = TRUE
  if (length(man)==0) {
    print(paste(c, ' is empty'))
    next
  }
  # tidy manifestos
  man_dfs <- as_tibble.ManifestoCorpus(man)
  man_dfs$country = c

  # merge with party data
  man_sents <- man_dfs %>%
    left_join(
      configs %>%
        transmute(manifesto_id = paste0(party, "_", date), party, partyname, partyabbrev, parfam, pervote) %>%
        unique()
    )

  # expand to get sentences
  man_exp = man_sents %>%
    unnest(cols = data) %>%
    select(-has_eu_code, -may_contradict_core_dataset, -md5sum_text, -md5sum_original,  -url_original, -is_copy_of, -annotations, -id, -eu_code)

  #man_exp = man_exp %>%
  #  select(-has_eu_code, -may_contradict_core_dataset, -md5sum_text, -md5sum_original,  -url_original, -is_copy_of, -annotations, -id)

  write.csv(man_exp, file.path('per_country',paste0(c,'_expanded_manifestos.csv')))
}
