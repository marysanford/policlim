# policlim: Multilingual climate change salience classification for political texts

This repository makes available the training data and main code used to train the classifer described in the following [paper](UPDATE):

    "Measuring Climate Change Salience in Political Manifestos: A Computational Text Analysis Approach" 
    by Mary Sanford, Silvia Pianta, Nicolas Schmid, & Giorgio Musto.
  
We fine-tune the multilingual transformer model -- `XLM-RoBERTa` -- to detect climate change salience in political manifestos (in their original languages) across the EU. The manifestos are downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/):

    "Lehmann, Pola; Franzmann, Simon; Al-Gaddooa, Denise; Burst, Tobias; Ivanusch, Christoph; Lewandowski, Jirka; Regel, Sven;
    Riethmüller, Felicia; Zehnter, Lisa (2023): Manifesto Corpus. Version: 2023-1. Berlin: WZB Berlin Social Science Center/Göttingen:
    Institute for Democracy Research (IfDem)"

## Data
We make the classified data available in two formats. Both files are available for download [here](https://drive.google.com/file/d/1NtAzFz7CZ1DxKCY2gN94uqBHbpFr9Mzc/view?usp=drive_link):
* At the **manifesto level**, in which each manifesto is given a score which equals the proportion of sentences in the manifesto that the model labelled climate-relevant. Also available in this repo at `data/variable_creation/manifesto_level_1Aug24.csv`
* At the **quasi-sentence** level, with a binary variable indicating the prediction for climate-relevance for each quasi-sentence, along with the probability scores of each class.

We also publish the training data in the zip file at the link above and here in the repo at `data/variable_creation/training_data.csv`.

## Code
The code required for each stage of the pipeline, from data collection to fine-tuning the model and processing the predictions, are available as either R files or Python notebooks in the `code/variable_creation` folder.
* `collect_mpd.R`: R script to collect and download the target individual manifesto files from the Manifesto Project Dataset API
* `compile_mpd_qs.ipynb`: Compile individual manifesto files into single dataframe, cleaning, keyword detection for all keywords used to select the annotation set using utils in `kw_utils.py`
* TODO: TRAINING SET SELECTION
* `hyp_fine_tuning.ipynb`: Conduct hyperparameter optimisiation using WandB
* `cross_validation.ipynb`: Run five-fold cross-validation on training set
* `inference.ipynb`: Train final model and apply to rest of dataset to collect predictions of climate change relevance of all remaining quasi-sentences
* `model_performance.ipynb`: Performance in training and post-hoc validation for our model, keyword search, and `ClimateBert`
* TODO: `manifestoberta.ipynb`: Run `manifestoberta` model over quasi-sentences missing annotation codes.
* TODO: PREDICTION PROCESSING/FINAL DATASET CURATION
* `kw_utils.py`: Contains dictionaries and functions for target keywords translated into each language in the dataset
* PLOTS CODE 
## Fine-tuned model
**TODO**: The fine-tuned model itself will be made available on the Hugging Face library (or another public zip).  

## Pre-trained XLM-RoBERTa

We used the `simpletransformers` library to train, test, and perform inference for the `XLM-RoBERTa` model. For more on how to install the `simpletransformers` library, please see:

https://simpletransformers.ai/docs/installation/

## Questions/Comments
Please contact Mary Sanford at mary.sanford@cmcc.it for requests/questions about the data, code, and/or model.
