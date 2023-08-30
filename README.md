# DGRP-Behavior
A computational project to explore how genetic variations contribute to multi-dimensional behavior

## Process classified behavior data and verify accuracy of classifier
Raw data tracked from [Multiworm Tracker](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0071706), namely `.spine` and `.blobs` files, are transferred to Institut Pasteur's supercomputer for processing and classification. The output is named `trx.mat`, a MATLAB file containing more than 100 fields with computed metrics as well as results for classfication.

Within the `trx.mat` files, each larva is stored as a row. Discrete actions from the classifier are stored in the field `global_state_large_state`. At each timestep, each larva is assigned an integer 1-7, corresponding to the actions listed `[]`.

The most basic visualization that provides a global look into how animals from a specific genotype behave is to construct an ethogram. You can find this function in my Python package [`behavior.py`](). There are also other methods of visualization, such as line plots and bar plots of cumulative probabilities over specific time windows. You can find what I have been working on in the Jupyter notebook [analyze_trx]().


## Visualizing raw tracked metrics with Choreograph

Larvae are tracked using an adapted in-house software, [Multiworm Tracker](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0071706). To compute and visualize initial metrics that are utilized by the machine learning classifier, such as speed, midline, kink, curve, length, etc etc, use the java program [Choreograph (Chore.jar)](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/Choreograph/Chore.jar) to output metrics measured for each larva.

To run Chore.jar in the command line, you must have [Java 8](https://docs.oracle.com/javase/8/docs/technotes/guides/install/mac_jdk.html). Then, run the following command

```
export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0`
java -Xincgc -Xms4000m -Xmx4000m -jar /Volumes/TOSHIBA/Chore.jar -t 20 -p 0.105 --plugin Reoutline::exp --plugin Respine::0.23::tapered=0.28,1,2 --plugin SpinesForward::rebias --minimum-biased 3 -S --plugin LarvaCast::angle -N all -o nNpsSlLwWaAmkbcdxyuvorP /path/to/folder/of/each/experiment
```
The path to each folder follows: /genotype/protocol/date. The command above produces one `.dat` file for each larva tracked within the folder. To batch process `.dat` files for each genotype, check out the Jupyter notebook in directory [Choreograph](https://gitlab.pasteur.fr/anzhou/dgrp-behavior/-/blob/main/Choreograph)