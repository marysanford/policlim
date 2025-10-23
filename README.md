# policlim: Multilingual climate change salience classification for political texts

This repository makes available the training data and main code used to train the classifer described in the following [paper](https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47), published in the British Journal of Political Science:

    "Sanford M, Pianta S, Schmid N, Musto G. Policlim: A Dataset of Climate Change Discourse in the Political Manifestos 
	of Forty-Five Countries from 1990 to 2022. British Journal of Political Science. 2025;55:e131. 
	doi:10.1017/S0007123425100719"
  
If you would like to explore the data or have questions about the code, please get in touch: mary.sanford@cmcc.it 

We fine-tune the multilingual transformer model -- `XLM-RoBERTa` -- to detect climate change salience in political manifestos (in their original languages) across the EU. The manifestos are downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/):

    "Lehmann, Pola; Franzmann, Simon; Al-Gaddooa, Denise; Burst, Tobias; Ivanusch, Christoph; Lewandowski, Jirka; Regel, Sven;
    Riethmüller, Felicia; Zehnter, Lisa (2023): Manifesto Corpus. Version: 2023-1. Berlin: WZB Berlin Social Science Center/Göttingen:
    Institute for Democracy Research (IfDem)"

## The model
The fine-tuned model itself is available via HuggingFace [here](https://huggingface.co/marysanford/policlim). If you use the model or data, please appropriately cite the paper. 

`@article{sanford_policlim_2025,
	title = {Policlim: A Dataset of Climate Change Discourse in the Political Manifestos of Forty-Five Countries from 1990 to 2022},
	volume = {55},
	url = {https://www.cambridge.org/core/journals/british-journal-of-political-science/article/policlim-a-dataset-of-climate-change-discourse-in-the-political-manifestos-of-fortyfive-countries-from-1990-to-2022/6EDB6B14410810A9E57A45F68BB09B47},
	doi = {10.1017/S0007123425100719},
	journal = {British Journal of Political Science},
	author = {Sanford, Mary and Pianta, Silvia and Schmid, Nicolas and Musto, Giorgio},
	year = {2025},
	pages = {e131},
}`

## Data
Upon publication, we will make the dataset available in two formats. Both files will be available for download [here](https://drive.google.com/file/d/1X1kyVL8b3lTrewav8JnJZIG3tJObwoIm/view?usp=drive_link):
* At the **manifesto level**, in which each manifesto is given a score which equals the proportion of sentences in the manifesto that the model labelled climate-relevant. You can also find this here in the data folder of the repo.
* At the **quasi-sentence** level, with a binary variable indicating the prediction for climate-relevance for each quasi-sentence, along with the probability scores of each class. This file is too large to store here but is available for download at the link above.

We also publish the training and post-hoc validation data here in the repo.

## Code
The code required for each stage of the pipeline, from data collection to fine-tuning the model and processing the predictions, are available as either R files or Python notebooks.
* `collect_mpd.R`: R script to collect and download the target individual manifesto files from the Manifesto Project Dataset API
* `compile_mpd_qs.ipynb`: Compile individual manifesto files into single dataframe, cleaning, keyword detection for all keywords used to select the annotation set using utils in `kw_utils.py`
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
