# `policlim` replication package

This repository makes available the `policlim` dataset, as well as the code required to produce all of the summary statistics, tables, and figures in the following paper:

    Sanford, M., Pianta, S., Schmid, N., & Musto, G. (2025). Policlim A Dataset of Climate Change Discourse in the Political Manifestos of 45 Countries from 1990-2022. British Journal of Political Science.

If you have any questions about the data or the code, please get in touch: mary.sanford@cmcc.it

## Data
The policlim data is available at the **quasi-sentence** and **manifesto** levels. 

The original quasi-sentence texts were downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/) via their API. However, during data processing, we discovered that not all manifestos for which the Manifesto Project has texts available are returned via the API query. We therefore manually verified the presence of each manifesto and downloaded those which were missing. We also added some manifesto text manually. Further details can be found in the paper.

For the quasi-sentence level data (`policlim_full_qs_2025-06.csv`), we provide a binary variable (`climate`) indicating the prediction for climate-relevance for each quasi-sentence along with the probability rating for climate-relevance. In our calculation of climate relevance per manifesto, we remove from the dataset all quasi-sentences with less than 3 words, all those coded as a 'heading' by the Manifesto Project annotators, and all those identified as uncoded introductory/foreword texts or similarly uncoded text in text boxes (as in, the original Manifesto Project annotators did neither coded nor tokenise them into quasi-sentences). We use a binary variable `keep` (0=discard, 1=keep) to record this. The rest of the variables include:

* `manifesto_id` : a unique identifier for each manifesto, equal to party code_YYYYMM of election 
* `qs_id` : a unique identifier for each quasi-sentence. it is equal to the manifesto_id + a digit corresponding to the position of the quasi-sentence in the manifesto
* `party` : party code of the manifesto
* `country` : country of the manifesto
* `year` : year of election 
* `edate` : date of election, sometimes in YYYYMM or else in YYYY-MM-DD
* `language` : language of manifesto
* `cmp_code_clean` : clean cmp code (including those inferred by the manifestoBERTa model and manually annotated - H, box, intro)
* `cmp_code_orig` : original cmp code where available
* `climate` : whether the quasi-sentence was predicted as climate (1) or not (0) by the model
* `partyname` : name of party 
* `parfam` : party family identifier 
* `parfam_name` : abbreviated name of party family 
* `original_text` : original text of quasi-sentence
* `prob_climate` : probability of climate relevance returned by model, can sometimes be multiple digits due to how the model parses long entries. if any return a value above .5, the quasi-sentence is flagged as climate relevant
* `iso3` : iso3 countrycode 
* `text_en`: English translation where available 
* `word_count` : number of words in each quasi-sentence

For the manifesto-level data (`policlim_full_man_2025-06.csv`), we aggregate the quasi-sentence level data a score which equals the proportion of total usable sentences in the manifesto that the model labelled climate-relevant (also called `climate`). The manifesto-level data also contains all of the relevant metadata from the Manifesto Project master manifesto-level dataset (see codebook [here](https://manifesto-project.wzb.eu/down/data/2024a/codebooks/codebook_MPDataset_MPDS2024a.pdf)). In addition to the `climate` variable, we also add the following:

* `lowe_rile` : Lowe et al. 2011 RILE score
* `std_rile` : standardised Manifesto Project RILE score
* `std_lowe_rile` : standardised Lowe et al. 2011 RILE score  
* `std_diff_rile` : difference between the Lowe et al. 2011 and Manifesto Project RILE scores 
* `iso3` : iso3 countrycode 
* `parfam_name`: abbreviated name of party family
* `year` : year of election 

We also provide the model training data and post-hoc validation datasets.

## Code
The primary descriptive results presented in the paper can be found in the `main_descriptives.ipynb` notebook. The notebook contains all of the commands needed to produce all of the reported results. They are commented accordingly for use of understanding. The model performance results are produced by the `model_performance.ipynb` notebook. The figures are all produced by the `figures.Rmd` file and stored in the figures subfolder. 

The model itself is available [here on HuggingFace](https://huggingface.co/marysanford/policlim). The code of the pipeline used to train and validate it is available on [GitHub](https://github.com/marysanford/policlim/tree/main).  