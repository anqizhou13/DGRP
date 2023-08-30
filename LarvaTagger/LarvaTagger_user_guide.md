## LarvaTagger user guide
Dependencies: [Docker Desktop](https://www.docker.com/) and [julia](https://julialang.org/)
To isntall, follow the [instructions](https://gitlab.pasteur.fr/nyx/larvatagger.jl)
All commands for LarvaTagger must be inputted from your terminal

# Open a file in LarvaTagger
```
cd LarvaTagger
scripts/larvatagger open path/to/trx/file --browser
```
As seen on the LarvaTagger documentation page, we can visualize all larvae from a specific experiment on our local browser. The outline of each larva is coloured by the action assigned from the classifer. With this interface, you can easily record true postives/negatives and false positive/negatives by hand to compute error rate of classification. 

# Retrain a classifier
If you see actions that are misclassified, follow the instructions to correct the tags, and save the new tracks as `YYMMDD.label`, corresponding to the date of the experiment. Then, in your `LarvaTagger` folder, create a new folder to store your training data. Inside, create each folder, named `YYMMDD`, and move the new `YYMMDD.label` file as well as the `trx.mat` files from which you annotated the tags to the folder. LarvaTagger is sensitive, usually, around 5 experiments and total of 50 corrected tags can sufficiently improve classification.

To train the classifier, in your LarvaTagger directory
```
scripts/larvatagger.sh train /path/to/training/data/folder NewClassiferName
```
This creates a `NewClassifierName` folder containing metadata and information of the new model

# Predict using a newly trained classifier
The most flexible way to train a modular dataset would be to create a list of all trx files that you will analyze and pass the path of that list to LarvaTagger. In terminal,
```
(cd /root/to/all/data && find . -name trx.mat -print0 | xargs -0 -I% bash -c 'echo "data/%"' > $(pwd)/files.txt)
```
This converts all full path of trx files to relative paths needed by LarvaTagger. Check that the file names are in the format
```
data/./20230227_144514/trx.mat
data/./20230228_135207/trx.mat
```
Then, run the following command to predict labels:
```
scripts/larvatagger.sh predict /root/to/all/data/files.txt --model-instance models/NewClassifierName
```
This generates a `predicted.label` file for each `trx.mat` file inputted.

# Replacing old labels with newly predicted labels
Edit `driver_batchUpdateLarvaTaggerLabels.m` with corresponding paths to dataset, then run the script.