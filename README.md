# climate_party_manifestos

This repository makes available the training data and main code used to train the classifer described in the following [paper](UPDATE):

    "Measuring Climate Change Salience in Political Manifestos: A Computational Text Analysis Approach" 
    by Mary Sanford, Silvia Pianta, Nicolas Schmid, & Giorgio Musto.
  
We fine-tune the multilingual transformer model -- `XLM-RoBERTa` -- to detect climate change salience in political manifestos (in their original languages) across the EU. The manifestos are downloaded from the [Manifesto Project Dataset](https://manifesto-project.wzb.eu/):

    "Lehmann, Pola; Franzmann, Simon; Al-Gaddooa, Denise; Burst, Tobias; Ivanusch, Christoph; Lewandowski, Jirka; Regel, Sven;
    Riethmüller, Felicia; Zehnter, Lisa (2023): Manifesto Corpus. Version: 2023-1. Berlin: WZB Berlin Social Science Center/Göttingen:
    Institute for Democracy Research (IfDem)"

## Data
We make the data available in two formats: 
* At the **manifesto level**, in which each manifesto is given a score which equals the proportion of sentences in the manifesto that the model labelled climate-relevant.
* At the **quasi-sentence** level, with a binary variable indicating the prediction for climate-relevance for each quasi-sentence, along with the probability scores of each class (only available upon request for the moment as it is very large).

## Fine-tuned model
The fine-tuned model itself will be made avaiable via the Hugging Face library.  

## Pre-trained XLM-RoBERTa

We used the fantastic `simpletransformers` library to train, test, and perform inference for the RoBERTa side of our model. For more on how to install the `simpletransformers` library, please see:

https://simpletransformers.ai/docs/installation/

## Questions/Comments
Please contact Mary Sanford at mary.sanford@cmcc.it for requests/questions about the data, code, and/or model.
