# Analysing crossing behaviour of a pedestrian with an automated car and other pedestrian in the traffic scence

This project defines a framework for the analysis of crossing behaviour in the interaction between multiple pedestrians and an automated vehicle, from the perspective of one of the pedestrians using a crowdsourcing approach. The jsPsych framework is used to for the frontend. In the description below, it is assumed that the repo is stored in the folder multiped-crowdsourced. Terminal commands lower assume macOS.

## Setup
Code for creation of stimuli is writtenin Python. The project is tested with Python 3.8.5. To setup the environment run these two commands in a parent folder of the downloaded repository (replace `/` with `\` and possibly add `--user` if on Windows:
- `pip install -e text-crowdsourced` will setup the project as a package accessible in the environment.
- `pip install -r text-crowdsourced/requirements.txt` will install required packages.

Code for analysis is written in MATLAB. No configuration is needed. The project is tested with MATLAB 2021b.

### Visualisation
Visualisations of gazes, heatmaps and histograms and  are saved in `text-crowdsourced/_output`.

![median willingness to cross](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/median-cross.jpg?raw=true)
Mediam willingness to cross.

![sd willingness to cross](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/sd-cross.jpg?raw=true)
Mediam willingness to cross.

![median willingness to cross for usa and ven](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/median-cross-usa-ven.jpg?raw=true)
Median willingness to cross for participants from USA and Venezuela.

![response willingness to cross for usa and ven](https://github.com/bazilinskyy/text-crowdsourced/blob/main/figures/response-time-usa-ven.jpg?raw=true)
Response time for participants from USA and Venezuela.

### Configuration of analysis
Configuration of analysis needs to be defined in `text-crowdsourced/config`. Please use the `default.config` file for the required structure of the file. If no custom config file is provided, `default.config` is used. The config file has the following parameters:
* `file_heroku`: files with data from heroku.
* `file_appen`: file with data from appen.
* `appen_range`: range of data in `file_appen`.
* `path_stimuli`: path with stimuli.
* `mapping_stimuli`: csv file with mapping of stimuli.
* `path_figures`: path for outputting figures in the EPS format.
* `path_figures_readme`: path for outputting figures in the JPG format.