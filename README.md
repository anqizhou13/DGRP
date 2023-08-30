# DGRP-Behavior
A computational project to explore how genetic variations contribute to multi-dimensional behavior

**Main goals of this internship**
1. Process all `trx.mat` files related to the dataset, so that each genotype has `dataFiles`.
2. Set up a pipeline to visualize classification results from `dataFiles` for the RAL genotypes.
3. Verify classification accuracy in [LarvaTagger](https://gitlab.pasteur.fr/nyx/larvatagger.jl), and record in the form of confusion matrices. 
4. If needed, use LarvaTagger to correct for misclassified actions, retrain classifer and predict new behavior tags.
5. (Optional) Set up a pipeline to anazlye and visualize tracked metrics using Choreograph.

##  More about the RAL genotypes and data storage structure
The [RAL lines panel](https://www.nature.com/articles/nature10811) are 204 inbred Drosophila lines with sequenced genomes and harbor a wide variety of SNPs and other genetic modifications. On our data server, the wild-type, homozygous RAL lines are denoted as **RAL_#@RAL_#**. These lines are compared to the control genotype named **CSMH_RAL_cont@CSMH_RAL_cont**. In addition, some of the RAL lines that were screened were combined with an Alzheimer's like model. The model uses the GAL4-UAS system to expresse Alzheimer's related peptides inside a cholinergic sensory neuron R61D08. These genotypes are written as **R61D08_Abeta40@RAL_#** or **R61D08_Abeta42@RAL_#**, for the two different types of peptides. There are two controls for this panel of larvae, **R61D08_Abeta42 or Ab40@CSMH_RAL_cont**, which is a negative control for RAL, and **R61D08_Abeta42 or Ab40@R61D08_Abeta42 or Ab40**, a positive control. 

## Process classified behavior data and verify accuracy of classifier
Raw data tracked from [Multiworm Tracker](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0071706), namely `.spine` and `.blobs` files, are transferred to Institut Pasteur's supercomputer for processing and classification. The output is named `trx.mat`, a MATLAB file containing more than 100 fields with computed metrics as well as results for classfication.

Within the `trx.mat` files, each larva is stored as a row. Discrete actions from the classifier are stored in the field `global_state_large_state`. At each timestep, each larva is assigned an integer 1-8, corresponding to the actions listed `[crawl, head cast, stop, hunch, back up, roll, small actions, bend]`. To convert such classification to quantified probabilities, we use in-house MATLAB functions, stored in the MATLAB directory in this repository. The driver code is named `driver_trx_processing.m`, which allows you to input genotypes you want to analyze, and calls other MATLAB functions. Running the driver code produces a folder named `dataFiles` inside each genotype/protocol folder. the `dataFiles` folder contains the following:
1. `trx_concatenated.mat`, the equivalent of hstacking all trx files from all experiments with the same genotype and protocol.
2. `probabilitiesovertime.mat`, a n x t list, where n = number of actions, t = total timesteps in experiment. 
3. `00uncorr_probabilitiesovertime.fig` and `00uncorr_probabilitiesovertime.eps`, the probabilities above plotted in a line plot.
4. `cumulativeProbabilities.mat`, a w x n list, where w = number of windows specificed from the driver code, n = number of actions. 
5. `amplitudes.mat`, stores amplitudes of classified action. This file is rarely used in downstream analyses currently. 
6. `allTransitions.mat`, a n x n matrix, denoting the number of transitions from one action to another that was counted within a specified time window. This file is rarely used in downstream snalyses currently.

The most basic visualization that provides a first look into how animals from a specific genotype behave is to construct an ethogram. You can find this function in my Python package [behavior.py](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/behavior.py). There are also other methods of visualization, such as line plots and bar plots of cumulative probabilities over specific time windows. You can find how I am utilizing the functions in the Jupyter notebook [visualize_trx.ipynb](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/visualize_trx.ipynb).

The combination of ethograms, line plots, and bar plots of all genotypes from the datasets gives us a comprehensive outlook on global behavior 


## Visualizing raw tracked metrics with Choreograph

Larvae are tracked using an adapted in-house software, [Multiworm Tracker](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0071706). To compute and visualize initial metrics that are utilized by the machine learning classifier, such as speed, midline, kink, curve, length, etc etc, use the java program [Choreograph (Chore.jar)](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/Choreograph/Chore.jar) to output metrics measured for each larva.

To run Chore.jar in the command line, you must have [Java 8](https://docs.oracle.com/javase/8/docs/technotes/guides/install/mac_jdk.html). Then, run the following command

```
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0`
java -Xincgc -Xms4000m -Xmx4000m -jar /Volumes/TOSHIBA/Chore.jar -t 20 -p 0.105 --plugin Reoutline::exp --plugin Respine::0.23::tapered=0.28,1,2 --plugin SpinesForward::rebias --minimum-biased 3 -S --plugin LarvaCast::angle -N all -o nNpsSlLwWaAmkbcdxyuvorP /path/to/folder/of/each/experiment
```
The path to each folder follows: /genotype/protocol/date. The command above produces one `.dat` file for each larva tracked within the folder. To batch process `.dat` files for each genotype, check out the Jupyter notebook in directory [Choreograph](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/Choreograph)