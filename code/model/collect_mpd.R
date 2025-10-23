library(manifestoR)
library(dplyr)
library(quanteda)
library(tidytext)
library(tidyverse)
library(devtools)
devtools::install_github("haukelicht/manifestoEnhanceR",force=T)
library(manifestoEnhanceR)

# NEED MANIFESTO APIKEY
#setwd("path/to/directory/with/api_key")
#getwd()
setwd("C:/Users/Sanford/Documents/eiee/capable/manifestos/codebase")
mp_setapikey("manifesto_apikey.txt")

as_tibble.ManifestoCorpus <- function(x) {
  
  if (!inherits(x, "ManifestoCorpus"))
    stop("No `as_tibble()` method implemented for object of class ", sQuote(class(x)[1]))
  
  man_sents <- as_tibble(map_dfr(as.list(x), "content", .id = "manifesto_id"))
  
  man_meta <- as_tibble(map_dfr(map(as.list(x), "meta"), as.data.frame.list, stringsAsFactors = FALSE))
  
  out <- left_join(man_sents, man_meta, by = "manifesto_id")
  
  out <- nest(out, data = names(man_sents)[-1])
  
  return(out)
}

eu_countries <- c(
  "Austria",  "Belgium", "Bulgaria", "Croatia","Cyprus","Czech Republic","Denmark","Estonia","Finland",
  "France","Germany","Greece","Hungary","Ireland","Italy","Latvia","Lithuania","Luxembourg","Malta",
  "Netherlands","Poland","Portugal","Romania","Slovakia","Slovenia","Spain","Sweden",'United Kingdom')

oecd_non_eu_countries <- c("Australia", "Canada","Chile","Colombia",
                           "Costa Rica","Iceland","Israel","Japan",
                           "South Korea","Mexico","New Zealand",
                           "Norway","Switzerland","Turkey","United States")

countries = c("Costa Rica","Colombia")

countries = c("Mexico")

# get CMP party-year data, necessary for metadata merge later
cmp <- mp_maindataset()
# oecd_non_eu_countries
# update countries to include whatever subset you want to look for
for (c in countries) {
  print(c)
  # subset to target configurations: year and percent vote
  configs <- cmp %>%
    filter(countryname == c & date > 199000 ) %>%  #& date > 197000 & pervote >= 5
    relocate(pervote, .after = parfam) %>%
    select(1:11)

   if (length(configs) == 0) {
    next
  }
  #get country manifestos
  man <- mp_corpus(countryname == c & date > 199000 & pervote >= 5, cache = TRUE) # & date > 197000 & pervote >= 5, cache = TRUE
  if (length(man)==0) {
    print(paste(c, ' is empty'))
    next
  }
  # tidy manifestos
  #man_dfs <- manifestoEnhanceR::as_tibble.ManifestoCorpus(man)
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
  
  # update file path as necessary
  write.csv(man_exp, file.path(paste0(c,'_expanded_manifestos.csv')),quote=T)
}

samp = read.csv("per_country/Australia_expanded_manifestos.csv",sep="|")


all_countries <- c(
  "Austria",  "Belgium", "Bulgaria", "Croatia","Cyprus","Czech Republic","Denmark","Estonia","Finland",
  "France","Germany","Greece","Hungary","Ireland","Italy","Latvia","Lithuania","Luxembourg","Malta",
  "Netherlands","Poland","Portugal","Romania","Slovakia","Slovenia","Spain","Sweden",'United Kingdom',
  "Australia", "Canada", "Chile", "Colombia", 
  "Costa Rica", "Iceland", "Israel", "Japan", "South Korea", "Mexico", "New Zealand", "Norway", 
  "Switzerland", "Turkey", "United States", "Argentina", "Bolivia", "Uruguay" 
)
# Make a data frame with info on all documents available for all countries 
results_all <- list()
for (c in all_countries) {
  available_docs <- mp_availability(countryname == c & date > 199000 & pervote >= 5)
  available_docs$country <- c
  results_all[[c]] <- available_docs
}

results_all_df <- do.call(rbind, results_all)
print(results_all_df)

results_all_df <- results_all_df %>%    ## data frame showing the document status in the manifesto project data 
  rename(
    original_pdf  = originals, 
    annotated_txt = annotations 
  )


small = cmp %>%
  filter(countryname %in% all_countries & date > 199000 & pervote >= 5) %>%  #& date > 197000 & pervote >= 5
  relocate(pervote, .after = parfam) %>%
  select(1:11)
