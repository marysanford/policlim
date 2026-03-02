# policlim: Multilingual climate change salience classification for political texts

This repository makes available the training data and main code used to train the classifer described in the following [paper](https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47), published in the British Journal of Political Science:

    Sanford M, Pianta S, Schmid N, Musto G. Policlim: A Dataset of Climate Change Discourse in the Political Manifestos 
	of Forty-Five Countries from 1990 to 2022. British Journal of Political Science. 2025;55:e131. 
	doi:10.1017/S0007123425100719

We fine-tune the multilingual transformer model -- `XLM-RoBERTa` -- to detect climate change salience in political manifestos (in their original languages) across 45 countries. The source of manifesto texts that we annotate and train the model on, and then add our variable to, comes from the Manifesto Project. If you want to use the policlim data, *you must also cite the Manifesto Project Dataset and Corpus*. The manifestos are downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/).

If you use our climate variable, you should also cite the Manifesto Project Dataset and Corpus. The required citations are below:

For the dataset, 2024-1: Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / Weßels, Bernhard / Zehnter, Lisa (2025): The Manifesto Data Collection. Manifesto Project (MRG/CMP/MARPOR). Version 2024a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem). https://doi.org/10.25522/manifesto.mpds.2024a

For the corpus, 2024-1: Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Lewandowski, Jirka / Regel, Sven / Riethmüller, Felicia / Zehnter, Lisa (2024): Manifesto Corpus. Version: 2024-1. Berlin: WZB Berlin Social Science Center/Göttingen: Institute for Democracy Research (IfDem).

For the codebook: Lehmann, Pola / Franzmann, Simon / Al-Gaddooa, Denise / Burst, Tobias / Ivanusch, Christoph / Regel, Sven / Riethmüller, Felicia / Volkens, Andrea / Weßels, Bernhard / Zehnter, Lisa (2025): The Manifesto Project Dataset- Codebook. Manifesto Project (MRG/CMP/MARPOR).Version2025a. Berlin: Wissenschaftszentrum Berlin für Sozialforschung (WZB) / Göttingen: Institut für Demokratieforschung (IfDem)

And the 5th version of the handbook (coder instructions) can be found here: https://manifesto-project.wzb.eu/down/papers/handbook_2021_version_5.pdf 

If you have any questions about the policlim data or the code, please get in touch: mary.sanford@cmcc.it

## The model
The fine-tuned model itself is available via HuggingFace [here](https://huggingface.co/marysanford/policlim). If you use the model or data, please appropriately cite the paper. 

	@article{sanford_policlim_2025,
	title = {Policlim: A Dataset of Climate Change Discourse in the Political Manifestos of Forty-Five Countries from 1990 to 2022},
	volume = {55},
	url = {https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47},
	doi = {10.1017/S0007123425100719},
	journal = {British Journal of Political Science},
	author = {Sanford, Mary and Pianta, Silvia and Schmid, Nicolas and Musto, Giorgio},
	year = {2025},
	pages = {e131}}

## Data
In accordance with the Manifesto Project Terms of Use, the policlim data is available at the **manifesto** level. 

The original quasi-sentence texts were downloaded from the Manifesto Project Dataset, version 2024-1, via their API. We cannot put quasi-sentence level climate prediction data online as doing so would violate the Manifesto Project copyright. But full details about the data collection and processing steps be found in the paper and appendix.
 
For the manifesto-level data, we aggregate the quasi-sentence level data a score which equals the proportion of total usable sentences in the manifesto that the model labelled climate-relevant (also called `climate`). Along with this variable, we are allowed to publish the `party` and `date` variables from the Manifesto Project Dataset in order to allow merging of the climate variable with the rest of their metadata. The 2024-1 version of the dataset also includes date and party variables which can be used to create a manifesto identifier (e.g., 'PPPPP_YYYYMM'). This can also be generated from our dataset to then merge with theirs. We show how to do this in `merge_with_mpd.R`.

## Code 
The code required for each stage of the pipeline, from data collection to fine-tuning the model and processing the predictions, are available as either R files or Python notebooks. There is an additional readme in the code folder with further detail on the data and code.
* `collect_mpd.R`: [CURRENTLY BEING UPDATED] R script to collect and download the target individual manifesto files from the Manifesto Project Dataset API
* `compile_mpd_qs.ipynb`: Compile individual manifesto files into single dataframe, some of the cleaning that could be partially automated, keyword detection for all keywords used to select the annotation set using utils in `kw_utils.py`
* `hyp_fine_tuning.ipynb`: Conduct hyperparameter optimisiation using WandB
* `cross_validation.ipynb`: Run five-fold cross-validation on training set
* `inference.ipynb`: Train final model and apply to rest of dataset to collect predictions of climate change relevance of all remaining quasi-sentences
* `model_performance.ipynb`: Performance in training and post-hoc validation for our model, keyword search, and `ClimateBert`
* `kw_utils.py`: Contains dictionaries and functions for target keywords translated into each language in the dataset
* `figures.Rmd`: Code for plots

## Pre-trained XLM-RoBERTa

We used the `simpletransformers` library to train, test, and perform inference for the `XLM-RoBERTa` model. For more on how to install the `simpletransformers` library, please see:

https://simpletransformers.ai/docs/installation/

## Questions/Comments
Please contact Mary Sanford at mary.sanford@cmcc.it for requests/questions about the data, code, and/or model.
