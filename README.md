# policlim: Multilingual climate change salience classification for political texts

This repository will make available the training data and main code used to train the classifer described in the following [paper](https://osf.io/preprints/osf/bq356), currently under review:

    "Policlim: A Dataset of Climate Change Discourse in EU Political Manifestos from 1990-2022" 
    by Mary Sanford, Silvia Pianta, Nicolas Schmid, & Giorgio Musto.
  
If you would like to explore the data or have questions about the code, please get in touch: mary.sanford@cmcc.it 

We fine-tune the multilingual transformer model -- `XLM-RoBERTa` -- to detect climate change salience in political manifestos (in their original languages) across the EU. The manifestos are downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/):

    "Lehmann, Pola; Franzmann, Simon; Al-Gaddooa, Denise; Burst, Tobias; Ivanusch, Christoph; Lewandowski, Jirka; Regel, Sven;
    Riethmüller, Felicia; Zehnter, Lisa (2023): Manifesto Corpus. Version: 2023-1. Berlin: WZB Berlin Social Science Center/Göttingen:
    Institute for Democracy Research (IfDem)"

## Data
Upon publication, we will make the dataset available in two formats. Both files will be available for download [here]:
* At the **manifesto level**, in which each manifesto is given a score which equals the proportion of sentences in the manifesto that the model labelled climate-relevant. 
* At the **quasi-sentence** level, with a binary variable indicating the prediction for climate-relevance for each quasi-sentence, along with the probability scores of each class.

We will also publish the training data in the zip file at the link above and here in the repo.

## Code
The code required for each stage of the pipeline, from data collection to fine-tuning the model and processing the predictions, will be available as either R files or Python notebooks.
* `collect_mpd.R`: R script to collect and download the target individual manifesto files from the Manifesto Project Dataset API
* `compile_mpd_qs.ipynb`: Compile individual manifesto files into single dataframe, cleaning, keyword detection for all keywords used to select the annotation set using utils in `kw_utils.py`
* `compile_manual_qs.ipynb`: Add manifestos not available directly in quasi-sentences to dataset manually to dataset
* `training_set_1.ipynb`: Select initial training set based on keywords 
* `hyp_fine_tuning.ipynb`: Conduct hyperparameter optimisiation using WandB
* `cross_validation.ipynb`: Run five-fold cross-validation on training set
* `inference.ipynb`: Train final model and apply to rest of dataset to collect predictions of climate change relevance of all remaining quasi-sentences
* `model_performance.ipynb`: Performance in training and post-hoc validation for our model, keyword search, and `ClimateBert`
* `manifestoberta.ipynb`: Run `manifestoberta` model over quasi-sentences missing annotation codes.
* `compile_predictions.ipynb`: Process model predictions and construct final dataset
* `kw_utils.py`: Contains dictionaries and functions for target keywords translated into each language in the dataset
* `plots.ipynb`: Code for plots

## Fine-tuned model
The fine-tuned model itself will be made available via HuggingFace.  

## Pre-trained XLM-RoBERTa

We used the `simpletransformers` library to train, test, and perform inference for the `XLM-RoBERTa` model. For more on how to install the `simpletransformers` library, please see:

https://simpletransformers.ai/docs/installation/

## Questions/Comments
Please contact Mary Sanford at mary.sanford@cmcc.it for requests/questions about the data, code, and/or model.
