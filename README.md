# Analysing crossing behaviour of a pedestrian with an automated car and other pedestrian in the traffic scene
This project defines a framework for the analysis of crossing behaviour in the interaction between a pedestrian and an automated vehicle with a textual eHMI using a crowdsourcing approach. The jsPsych framework is used to for the frontend. In the description below, it is assumed that the repo is stored in the folder `text-crowdsourced`. Terminal commands lower assume macOS.

## Citation
If you use the framework for academic work please cite the following paper.

> Bazilinskyy, P., Dodou, D., & De Winter, J. C. F. (2022). Crowdsourced assessment of the suitability of 227 textual eHMIs for a crossing scenario. Proceedings of AHFE 2022. Available at TBC

## Setup
Code for creation of stimuli and QA is written in Python. The project is tested with Python 3.8.5. To setup the environment run these two commands in a parent folder of the downloaded repository (replace `/` with `\` and possibly add `--user` if on Windows:
- `pip install -e text-crowdsourced` will setup the project as a package accessible in the environment.
- `pip install -r text-crowdsourced/requirements.txt` will install required packages.

For QA, the API key of appen needs to be places in file `text-crowdsourced/secret`. The file needs to be formatted as `text-crowdsourced/default.secret`.

## Analysis
Code for analysis is written in MATLAB. No configuration is needed. To run the analysis code, a config file needs to be created (as described [lower](https://github.com/bazilinskyy/text-crowdsourced#configuration-of-analysis)) and file `text-crowdsourced/analysis/analysis.m` need to be run. The project was tested with MATLAB 2021b.

## Implementation on heroku
We use [heroku](https://www.heroku.com/) to host the node.js implementation. The demo of the implementation may be viewed [here](https://text-crowdsourced.herokuapp.com/?debug=1&save_data=0). Implementation supports images.

## Crowdsourcing job on appen
We use [appen](http://appen.com) to run a crowdsourcing job. You need to create a client account to be able to create a launch crowdsourcing job. Preview of the appen job used in this experiment is available [here](https://view.appen.io/channels/cf_internal/jobs/1884388/editor_preview?token=65NVm9aKVsyz_jlitEr3bA).

### Filtering of appen data
Data from appen is filtered based on the following criteria:
1. People who did not read instructions.
2. People who are younger than 18 years of age.
3. People who completed the study in under 300 s.
4. People who completed the study from the same IP more than once (the 1st data entry is retained).
5. People who used the same `worker_code` multiple times. One of the disadvantages of crowdsourcing is having to deal with workers that accept and do crowdsourcing jobs just for money (i.e., `cheaters`). The framework offers filtering mechanisms to remove data from such people from the dataset used for the analysis. Cheaters can be reported from the `textehmi.analysis.QA` class. It also rejects rows of data from cheaters in appen data and triggers appen to acquire more data to replace the filtered rows.

### Anonymisation of data
Data from appen is anonymised in the following way:
1. IP addresses are assigned to a mask starting from `0.0.0.0` and incrementing by 1 for each unique IP address (e.g., the 257th IP address would be masked as `0.0.0.256`).
2. IDs are anonymised by subtracting the given ID from `config.mask_id`.

### Output
Figures are saved in `text-crowdsourced/_output/figures`.

![median willingness to cross response time](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/median-cross-response-time.jpg?raw=true)
Median willingness to cross over median response time. Colours denote the type of eHMIs: black=allocentric, green=egocentric, red=other.

![ehmis in english and spanish](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/median-cross-en-es.jpg?raw=true)
Median willingness to cross for eHMIs presented in both English and Spanish.

![median willingness to cross](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/median-cross.jpg?raw=true)
Median willingness to cross. Colours show stimuli that were presented in both English and Spanish.

![mean willingness to cross](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/mean-cross.jpg?raw=true)
Mean willingness to cross. Colours show stimuli that were presented in both English and Spanish.

![sd willingness to cross](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/sd-cross.jpg?raw=true)
Standard deviation of willingness to cross. Colours show stimuli that were presented in both English and Spanish.

![response willingness to cross for usa and ven](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/response-time-usa-ven.jpg?raw=true)
Median response time for participants from USA and Venezuela.

![response willingness over number of characters](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/response-time-num-chars.jpg?raw=true)
Median willingness related to the length of the eHMI.

![correlation plot](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/corrplot.jpg?raw=true)
Correlation plot.

CSV files with eHMIs sorted by median/mean/STD willingness to cross are saved in `text-crowdsourced/_output`.

### Configuration of analysis
Configuration of analysis needs to be defined in `text-crowdsourced/config`. Please use the `default.config` file for the required structure of the file. If no custom config file is provided, `default.config` is used. The config file has the following parameters:
* `appen_job`: ID of the appen job.
* `mask_id`: number for masking worker IDs in appen data.
* `file_cheaters`: CSV file with cheaters for flagging.
* `file_heroku`: file with data from heroku.
* `file_appen`: file with data from appen.
* `path_stimuli`: path with stimuli.
* `mapping`: CSV file with mapping of stimuli.
* `path_output`: path for output (figures, CSV files).
* `path_figures_readme`: path for outputting figures in the JPG format.
* `save_figures`: flag for saving figures as EPS and JPG files.
