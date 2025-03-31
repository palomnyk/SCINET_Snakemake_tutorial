# Tutoral to demonstrate Snakemake to SCINET fellows
## Holds files for demonstrating how snakemake can be used for automating data analysis on Ceres.
Snakemake is a python retooling of the old UNIX tool called "Make". The driver of action in Snakemake is the "rule". At minimum, a rule will have an input, which are files that trigger Snakemake to run the rule. Most rules will also have an output too, which will allow Snakemake to make a chain of actions based on inputs and outputs. A rule can run a command in the commandline or it can run python.

## Summary of what this pipeline does
### Rules
This pipeline can best be described by summarizing the rules, in the order that their actions are triggered:
![rulegraph 1](workflow\reports\rulegraph.png "Flow of rules")
* **rule create_test_rf_dataset**
    This rule will download the "Cars" dataset using R. From that dataset, it will make a table of response variables that includes "mpg" as numeric values and "good_mileage" as a categorical variable. The predictor and response tables are saved to the data/unit_test directory.
* **rule rf_test_dataset:**
    Reads in the response columns one at a time to the random forest. The random forest makes a pdf graphic, saved to output/unit_test/graphics and and a table of the scikit learn scores (r squared for mgp and accuracy for good_milage) in output/unit_test/tables. 
* **rule aggregate_rf_tables_test_data:**
    This rule tells Snakemake to look for the later output and then aggregates all the scores into a single file.
* **rule Complete**
    This is the final rule that only has input. It is used to call all the other rules. If you have multiple chains of rules, the end product will go here. Note that there is a convention to name this rule "all".
### Wildcards
![directed acyclic graph](workflow/reports/dag.png "Rules with wildcards")
Wildcards enable Snakemake to identify different files in the workflow. In the case of this pipeline, line 13 tells Snakemake what the different columns that we need to look for are:
`response_cols = ["mpg","good_milage","car_name"]`

## Description of files
All of the Snakemake related files are found in the "workflow" directory.
Snakemake can be configured to be run on a variety of platforms and be customized for ease.
* **workflow/config/config.yaml**
    This file configures the defaults of snakemake. This one is configured to submit jobs to Slurm through the sbatch command. The sbatch for, example, will save the output and error messages to a project level directory called slurmLogs.
* **workflow\env\snk_mk_conda_env.yml**
    This file tells Conda how to build the conda environment that is needed for the jobs in this demo. This project uses a single conda environment, but you could set up different conda envs for different rules.
* **workflow\Snakefile**
    This is the main file that gives the rules that Snakemake is to follow. Snakemake expects this file to be in the workflow directory.
## How to use this repository



## Commands
* `snakemake --rulegraph |dot -Tpng > workflow/reports/rulegraph.png`
    Used to make first graphic that shows order of rule execution.
snakemake --dag |dot -Tpng > workflow/reports/dag.png
    Used to make the 2nd graphic that show a more detailed graphic.
## 
