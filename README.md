# policlim: Multilingual climate change salience classification for political texts

This repository makes available the `policlim` variable, as well as instructions required to produce all of the data, summary statistics, tables, and figures in the following [paper](https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47), published in the British Journal of Political Science:

    Sanford M, Pianta S, Schmid N, Musto G. Policlim: A Dataset of Climate Change Discourse in the Political Manifestos 
	of Forty-Five Countries from 1990 to 2022. British Journal of Political Science. 2025;55:e131. 
	doi:10.1017/S0007123425100719

The source of manifesto texts that we annotate and train the model on, and then add our variable to, comes from the Manifesto Project. If you want to use the policlim data, *you must also cite the Manifesto Project Dataset and Corpus*. The required citations are below:

For the dataset, Version 2024-1: Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / Weßels, Bernhard / Zehnter, Lisa (2025): The Manifesto Data Collection. Manifesto Project (MRG/CMP/MARPOR). Version 2024a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem). https://doi.org/10.25522/manifesto.mpds.2024a

For the corpus, Version 2024-1: Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Lewandowski, Jirka / Regel, Sven / Riethmüller, Felicia / Zehnter, Lisa (2024): Manifesto Corpus. Version: 2024-1. Berlin: WZB Berlin Social Science Center/Göttingen: Institute for Democracy Research (IfDem).

For the codebook: 

Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / Weßels, Bernhard / Zehnter, Lisa (2025): The Manifesto Project Dataset- Codebook. Manifesto Project (MRG/CMP/MARPOR).Version2025a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem)

Budge, Ian / Klingemann, Hans-Dieter / Volkens, Andrea / Bara, Judith with Tanenbaum, Eric / Fording, Richard C. / Hearl, Derek J. / Kim, Hee Min / McDonald, Michael / Mendez, Silvia (2001): Mapping Policy Preferences. Estimates for Parties, Electors, and Governments 1945-1998. Oxford: Oxford University Press.

Klingemann, Hans-Dieter / Volkens, Andrea / Bara, Judith / Budge, Ian / McDonald, Michael (2006): Mapping Policy Preferences II. Estimates for Parties, Electors, and Governments in Eastern Europe, the European Union and the OECD, 1990-2003. Oxford: Oxford University Press.

For the handbook: Werner, A., Lacewell, O., Volkens, A., Matthieß, T., Zehnter, L., van Rinsum, L. (2021). Manifesto Project’s Handbook Series. 5th edition. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem). https://manifesto-project.wzb.eu/down/papers/handbook_2021_version_5.pdf

For the manifestoberta model: Burst, Tobias / Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Weßels, Bernhard / Zehnter, Lisa (2023): manifestoberta. Version 56topics.sentence.2023.1.1. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung(IfDem). https://doi.org/10.25522/manifesto.manifestoberta.56topics.sentence.2023.1.1

If you have any questions about the policlim data or the code, please get in touch: mary.sanford@cmcc.it

## Data
In accordance with the Manifesto Project Terms of Use, the policlim variable is available at the **manifesto** level. 

The original quasi-sentence texts were downloaded from the Manifesto Project Dataset, version 2024-1, via their API. We manually verified the presence of each manifesto via their website (the Data Dashboard). We also added some manifesto text manually from the PDFs made available by the Manifesto Project where no machine-read text versions were present. Further details can be found in the paper and appendix. 

As described in the appendix, we initially downloaded all manifestos from EU countries and focused for the initial model training only on those with the text available in quasi-sentences. As the training process progressed, we expanded the set to include also the manifestos that were not already unitised and further cleaned the full dataset. We also expanded the vote-share and geographic scope to include as many European, OECD, and South American countries as possible. Here we show the downloading and cleaning process for all countries we ended up targetting and using the text processing logic (with both manual and automated components) that we developed over months of iteratively getting to know the data and figuring out solutions to various challenges.  

Starting from the quasi-sentence level, we filter from the dataset all quasi-sentences with less than 3 words, all those coded as a 'heading' by the Manifesto Project annotators, and all those that we manually identified as uncoded introductory/foreword texts or similarly uncoded text in text boxes (as in, the original Manifesto Project annotators did neither coded nor tokenise them into quasi-sentences). We also encountered some quasi-sentences that contained errors most likely resulting from challenges of machine-reading the various documents. These included faulty word or sentence parsing, multiple quasi-sentences included as one, empty strings, puncutation errors, etc. We corrected as many of these issues as possible by hand. The process to identify those errors is shown in the 1_wrangle_compile.ipynb script. We cannot put this data online as doing so would violate the Manifesto Project copyright. 

For the manifesto-level data (`policlim_2025_share.csv`), we aggregate the quasi-sentence level data to yield a score which equals the proportion of total usable sentences in the manifesto that the model labelled climate-relevant (also called `climate`). Along with this variable, we are allowed to publish the `party` and `date` variables from the Manifesto Project Dataset in order to allow merging of the climate variable with the rest of their metadata. The 2024-1 version of the Manifesto Project dataset also includes date and party variables which can be used to create a manifesto identifier (e.g., 'PPPPP_YYYYMM'). This can also be generated from our dataset to then merge with theirs. We show how to do this in `merge_with_mpd.R`.

## Code
The replication begins with downloading the data using 0_collect_mpd.R. This script shows how to first download the unitised data and then collect and parse into sentences all manifestos that have not been unitised into quasi-sentences. In order to use this script, you will need to register for an account on the Manifesto Project website and receive an API key. This should the be be saved in a text file within the repository of the script.   

The next step is to compile the quasi-sentences into a single database in `1_combine_wrangle.ipynb`. This is where the auditing and correcting of the quasi-sentences for various errors occurs. Much of this auditing is manual and therefore not easily replicable in a fully automated pipeline. We do our best to make the logic we followed as clear as possible. The data preparation also requires feeding the sentences of the un-unitised manifestos through the Manifesto Project's manifestoberta model. This is done in 1a_manifestoberta.ipynb. 

The next step of the pipeline is the curation of the sample quasi-sentences to annotate. This process unfolded over several manual steps, all of which are documented in the main article text and appendix. 

Once we had the initial annotated training set, we performed hyperparameter fine-tuning (`2_hyp_fine_tuning.ipynb`) cross-validate and train the model (`3_cross_validation.ipynb`). We then apply the model to the full dataset (`4_inference.ipynb`) and afterwards, manually validate a sample of predictions (which were not part of the initial training set). The performance on this set was an F1 score of .712. We were not satisfied with this for the final model so we add the new annotations to expand the training set and then repeat the cross-validation and training. We then apply the model to the full dataset once more and repeat the manual validation on a new sample of predictions. We achieved a validation performance of .935 (F1), a significant increase over the first round. The script to produce those calculations (though none of the quasi-sentence sample data can be shared) is in `5_model_performance.ipynb`.

The primary descriptive results presented in the paper can be found in the `6_main_descriptives.ipynb` notebook. The notebook contains all of the commands needed to produce all of the reported results using the quasi-sentence or manifesto-level data where required. The figures are all produced by the `7_figures.Rmd` file and stored in the figures subfolder. We cannot post any quasi-sentence level data online, or any variables from the Manifesto Project besides the party id and election date, as doing so would violate the data's copyright protection. However, we are authorised to provide a script to merge our climate variable with the Manifesto Project Dataset (`merge_with_mpd.Rmd`) for further analysis and replication of our manifesto-level descriptives.

The model itself is available [here on HuggingFace](https://huggingface.co/marysanford/policlim). It can be applied to additional manifesto texts, as well as other forms of political text. However, it may perform differently on different sources of text. It may also not perform well on certain languages. As noted in the paper, it is important to always validate manually samples of predictions to ensure that the model is performing as you expect it to.   

If you use the policlim model or data, please appropriately cite the paper. 

	@article{sanford_policlim_2025,
	title = {Policlim: A Dataset of Climate Change Discourse in the Political Manifestos of Forty-Five Countries from 1990 to 2022},
	volume = {55},
	url = {https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47},
	doi = {10.1017/S0007123425100719},
	journal = {British Journal of Political Science},
	author = {Sanford, Mary and Pianta, Silvia and Schmid, Nicolas and Musto, Giorgio},
	year = {2025},
	pages = {e131}}

## Pre-trained XLM-RoBERTa

We used the `simpletransformers` library to train, test, and perform inference for the `XLM-RoBERTa` model. For more on how to install the `simpletransformers` library, please see:

https://simpletransformers.ai/docs/installation/

## Questions/Comments
Please contact Mary Sanford at mary.sanford@cmcc.it for requests/questions about the data, code, and/or model.
