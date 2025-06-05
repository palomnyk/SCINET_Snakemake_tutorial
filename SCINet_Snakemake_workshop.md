---
title: Introduction to Snakemake
type: workshop
display: basic
no-caldate: true
provider: SCINET
instructor: "Aaron Yerke (SCINET Fellow, Baer Lab)"
date: 2025-06-11
hideprovider: true
description: This workshop provides an overview of Snakemake, and how to set it up for the SCINET HPC.
categories: [2025 Bioinfo]
parent: 
  title: Bioinformatics Workshop Series
  url: /events/2025-bioinfo

layout_type: workshop
has-sessions: true
time: 2 – 4 PM ET
registration:
    url: TODO

tags: bioinformatics, snakemake, conda, Slurm, environemnts, workflow, pipeline, automation

prerequisites:
    - text: Access to the HPC cluster and the /90daydata directory.
    - text: Familiarity with basic tools and navigation on the cluster.
    - text: Familiarity with the concepts of job submission and execution environments.

materials:
  - text: Workshop recording
    url: TODO

subnav:
  - title: Pre-Workshop Instructions
  - title: Tutorial Introduction
  - title: Snakemake Introduction
    url: '#snakemake-introduction'
  - title: Snakemake logic
    url: '#snakemake-logic'
  - title: Run Snakemake
    url: '#run-snakemake'
  - title: Additional resources
---

# Overview
![Snakemake icon](workflow/resources/snakemake_icon.png "Snakemake")

Snakemake is a popular workflow management tool that can help [organize, document, scale, run, and reproduce](https://slides.com/johanneskoester/snakemake-tutorial "Snakemake slides") your workflows.
 Its workflows are described via a human readable, Python based language, but is language agnostic, and can be integrated into the SCINET HPC system via Slurm and CONDA.
In this workshop, Aaron Yerke will introduce the basics of a Snakemake workflow and demonstrate how it runs on the cluster. After attending this workshop, you should be able to integrate Snakemake into your own projects on the SCINET HPC. This repository can also be found at https://github.com/palomnyk/SCINET_Snakemake_tutorial.git.

Note that this tutorial is for Snakemake __versions 8+__, as version 8 introduced breaking changes to previous versions.

## Tutorial Setup Instructions

Steps to prepare for the tutorial session: 

* Login to [Ceres Open OnDemand](http://ceres-ood.scinet.usda.gov/). For more information on login procedures for web-based SCINet access, see the [SCINet access user guide]({{site.baseurl}}/guides/access/web-based-login). 
* Open a command-line session by clicking on “Clusters” -> “Ceres Shell Access” on the top menu. This will open a new tab with a command-line session on Ceres' login node. 
* Request resources on a compute node by running the following command.  

{:.copy-code}
```bash
srun --reservation=wk1_workshop -A scinet_workshop2 -t 05:00:00 -n 1 --mem 8G --pty bash 
```
    {% include reservation-alert reservation="wk1_workshop" project="scinet_workshop2" %}#TODO check this

* Create a workshop working directory by running the following commands. Note: you do not have to edit the commands with your username as it will be determined by the $USER variable.  

{:.copy-code}
```bash
mkdir -p /90daydata/shared/$USER/snakemake_ws 
cd /90daydata/shared/$USER/snakemake_ws
cp -r /project/scinet_workshop1/snakemake/* .
mkdir .conda
```

The final line of that command created a hidden folder that we will use to store a conda environment that we will use when we run snakemake.

We are now ready to setup and run Snakemake. Stay tuned!
-----  

## Snakemake Introduction
[Snakemake](https://snakemake.readthedocs.io/en/stable/index.html "Snakemake") is a python retooling of the old UNIX tool called "Make". It can be used to document and automatically run a pipeline and can help run jobs in parallel. 

The main driver of action in Snakemake is the "rule". At minimum, a rule will have an input, which are files that trigger Snakemake to run the rule. Most rules will also have an output too, which will allow Snakemake to make a chain of actions based on inputs and outputs. A rule can run a command in the commandline or it can run python. Variables that are passed from rule to rule are called wildcards. Wildcards are valueable tools for adding parallel processes to the the workflow. See more at: [Snakemake Logic](#snakemake-logic)

Snakemake can be customized for various types of system infrastructure. In this tutorial, we will set up Snakemake to submit jobs to Slurm and have those jobs run in specific Conda environments. The details of how each job will run are going to be given in a config file (workflow/config/config.yaml) and in the Snakefile file, which directs Snakemake on how to run jobs.

In this sample project, we will download the famous MTCars dataset, organize it, create a predictive model, and organize the output of the model. This will demonstrate how to use Snakemake to process each column of a specific data table is run in parallel. In this tutorial we will use the command line to set up Snakemake and then use Snakemake to run an example pipeline that consists of R and Python scripts. 
    
We will go over the files in this project in the following sections. To see all of them:

{:.copy-code}
```bash
tree
```
When you run that, you should see something like this:
```
.
├── LICENSE
├── README.md
├── SCINet_Snakemake_workshop.md
└── workflow
    ├── Snakefile
    ├── config
    │   └── config.yaml
    ├── env
    │   └── snk_mk_conda_env.yml
    ├── reports
    │   ├── dag.png
    │   └── rulegraph.png
    ├── resources
    │   └── snakemake_icon.png
    └── scripts
        ├── data_org
        │   ├── combine_2_csv.R
        │   ├── combine_rf_data.R
        │   └── make_rf_test_dfs.R
        └── ml
            └── random_forest.py
```

## Snakemake logic

The instructions to Snakemake for running the pipeline are typically found in /workflow/Snakemake. This file contains the rules that Snakemake is meant to follow as well as links to config files.

{:.copy-code}
```bash
cat workflow/Snakefile
```

The rules in the file are prepened by the keyword "rule" and given a unique and descriptive name. Most of them have input and output designations. The inputs and outputs help Snakemake build a Directed Acyclic Graph of the rules in the graph (DAG) to create the workflow.

Wildcards are designated by curly brackets "{}" and the name of the wildcard in the input and output sections of the word. In the shell command section of the rule, the name of the wildcard must be prefixed with "wildcard.".

### Our rules
This pipeline can best be described by summarizing the rules, in the order that their actions are triggered:
![rulegraph 1](workflow\reports\rulegraph.png "Flow of rules")
* **rule create_test_rf_dataset**
    This rule will download the "Cars" dataset using R. From that dataset, it will make a table of response variables that includes "mpg" as numeric values and "good_mileage" as a categorical variable. The predictor and response tables are saved to the data/unit_test directory.
* **rule rf_test_dataset:**
    Reads in the response columns one at a time to the random forest. The random forest makes a pdf graphic, saved to output/unit_test/graphics and and a table of the scikit learn scores (r squared for mgp and accuracy for good_milage) in output/unit_test/tables. 
* **rule aggregate_rf_tables_test_data:**
    This rule tells Snakemake to look for the later output and then aggregates all the scores into a single file. This rule makes use of the expand() helper function, see https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#helpers-for-defining-rules to see all the helper functions.
    In this case, expand() creates a list of file paths for each of the *response_cols* wildcards, see [Our wildcards](#our-wildcards) for a bit more about wildcards.
* **rule all**
    This is the final rule that only has input. It a catch-all rule that holds the final output of all other rule chains. If you have multiple chains of rules, the end product of each chain will go here. Note that there is a convention to name this rule "all", though it is not required by Snakemake.

### Our wildcards
Wildcards enable Snakemake to identify and keep track of different files in the workflow. Our wildcards are defined on line 13 of the Snakefile as 
`response_cols = ["mpg","good_milage","car_name"]`
These wildcards are the column names of data/unit_test/mtc_response.csv that we download in **rule create_test_rf_dataset**. You will notice that intermediate files for this workflow use those wildcards in the filenames.
![directed acyclic graph](workflow/reports/dag.png "Rules with wildcards")

### Configuation

The main file for configuring Snakemake to your system architecture is workflow/config/config.yaml. This file has some features to note:

{:.copy-code}
```bash
cat workflow/config/config.yaml
```

The first 14 lines instruct Snakemake to use the generic cluster executor plug-in to launch jobs with sbatch, which is the Slurm batching command. 
* Line 5 runs before the executor to create a top level directory to store the Slurm log files in a directory called "slurmLogs".
* Lines 10 and 11 tell Slurm to put slurm reports in a subfolder of `slurmLogs` named after the name of the rule. The name of the log file is the name of the rule, followed by wildcards and the Slurm job number.
* Line 14 is commented out, it would tell Slurm where to send notification emails. To use this line, remove the "#" and add your email address where the placeholder address is.

To edit this document, you can open it with the vim editor.
{:.copy-code}
```bash
vim workflow/config/config.yaml
```
After you uncomment the line of code, you can exit Vim by hitting "Esc" and then typing ":wq" and hitting "enter".

The next section (lines 15-20) holds the default parameters. They are currently set for small jobs. As you add Snakemake to your own pipelines you can update these to your own requirements.

### Additional rule components
#### Conda
Snakemake can execute rules in specified conda environments. The environments should be specified for each rule in the optional "conda:" header. 

`conda:"env/snk_mk_conda_env.yml",`

In this tuturial project only one conda environment is used, but as many as needed can be used. Snakemake expects the Conda environment YAML to be found in the workflow/env folder. In order to execute jobs on the cluster, the envrioment that you run snakemake from requires the snakemake snakemake-executor-plugin-cluster-generic from line 16.

{:.copy-code}
```bash
cat workflow/env/snk_mk_conda_env.yml
```
This file holds the conda env that you loaded in [Tutorial Setup Instructions](#tutorial-Setup-Instructions). There are comments at the top and bottom of this file to help you install it when you need to set up your own projects.

#### Resources
Default resources are allocated in workflow/config/config.yaml, but for a given rule, these resources can modified for individual rules with a resources block. In the example below, a custom runtime and memory allotment would be requested when this rule is submitted to Slurm. This can be seen in rule rf_test_dataset from the Snakefile, for example. If this is not specified then the defaule resources are requested.

```
	resources:
		runtime=10, #format: M, M:S, H:M:S, D-H, D-H:M, or D-H:M:S
		mem_mb="8gb"
```

## Run snakemake

### Set up environment
* Load miniconda for access to conda environments.
{:.copy-code}
```bash
module load miniconda
```

* Load the conda environment for Snakemake and the libraries for the pipeline. This env will be available as long the conda files in the .conda dir are available. This env and instructions for creating it can be found at workflow/env/snk_mk_conda_env.yml. 
{:.copy-code}
```bash
source activate snk_mk_conda_env /90daydata/shared/$USER/snakemake_ws/.conda
```

First, we need to do a dry run to see what jobs will run:
{:.copy-code}
```bash
snakemake --profile workflow/config -n
```
This does not submit any jobs to the cluster. If the output looks acceptable, run it again without the "-n" tag.

{:.copy-code}
```bash
snakemake --profile workflow/config
```

This will actually launch the jobs and if you have added your email to line 14 of the config file, you should recieve confirmation as well.

After all of your Slurm jobs have completed, you should see that files have been downloaded into the data folder and output has been generated in the output folder.

{:.copy-code}
```
tree
```

Now you can run Snakemake and integrate it into your own workflows. Give it a try!

## Other useful commands
Snakemake can make diagrams of your workflow, as seen in the two images above. 
* `snakemake --rulegraph |dot -Tpng > workflow/reports/rulegraph.png`
    Used to make first graphic that shows order of rule execution.
* `snakemake --dag |dot -Tpng > workflow/reports/dag.png`
    Used to make the 2nd graphic that show a more detailed graphic.

## Additional resources
Snakemake has an extensive community of users that post their content, as well as several of their own tutorials and detailed documentation. In addition to those, here are some resources that I used to make this workshop:
* https://github.com/jdblischak/smk-simple-slurm/blob/main/simple/config.v8%2B.yaml#L5
* https://github.com/binder-project/example-conda-environment

