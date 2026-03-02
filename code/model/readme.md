# `policlim` replication package

This repository makes available the `policlim` dataset, as well as the code required to produce all of the summary statistics, tables, and figures in the following paper:

    Sanford, M., Pianta, S., Schmid, N., & Musto, G. (2025). Policlim A Dataset of Climate Change Discourse in the Political Manifestos of 45 Countries from 1990-2022. British Journal of Political Science.

If you have any questions about the data or the code, please get in touch: mary.sanford@cmcc.it

## Data
The policlim data at the **manifesto** level. It contains the climate variable along with the party and date variables from the Manifesto Project. Our variable can be merged with the Manifesto Project Dataset using the merge_with_mpd.R script.

## Code
The primary descriptive results presented in the paper can be found in the `main_descriptives.ipynb` notebook. The notebook contains all of the commands needed to produce all of the reported results. They are commented accordingly for use of understanding. The model performance results are produced by the `model_performance.ipynb` notebook. The figures are all produced by the `figures.Rmd` file and stored in the figures subfolder. 

The model itself is available [here on HuggingFace](https://huggingface.co/marysanford/policlim). The code of the pipeline used to train and validate it is available on [GitHub](https://github.com/marysanford/policlim/tree/main).  
