# User guide to Adrien's scripts

This program can be used to : 
 - Analyse data from trx.mat files 
- Analyse choreograph data

## Global setup 

In order to use this program, you have to configure setup.py.

 - setup the directory dictionary.  

```python
  
  Dict_directory = {
    'main_directory': 'The root of the folder which contains all genotypes folders',
    'saving_directory': 'The root where all the processed data will be saved',
    'sh_choreograph': 'The bash script for ChoreJar automation',
     '...': can be removed
    }

```
### Initialization 

This program is based on classes (definided in **data_process.py**). Most of the functions need _Protocol objects input. 
Before starting, we need to instantiate all _Protocol objects and store them in a list.

To do this, you have to run both **main.py** and **quick_start** function (from main.py) : 
```python

  list_genotype=list()
  list_protocol=list()
  list_experiment=list()


  def quick_start(): 
    
   
      print("init...")
      for file in os.listdir(Dict_directory["main_directory"]): ## creations of genotype instances
       
        d = os.path.join(Dict_directory["main_directory"], file)
       
        if os.path.isdir(d):
            
            GenotypeObject = data_process._genotype(d,file,str())
            
            list_protocol.append(GenotypeObject.auto_protocol())
            list_genotype.append(GenotypeObject)
            

      for protocol in tqdm(list_protocol): 
        
        list_experiment.extend(protocol.auto_experiment())
    

```

Doing this, you can access  all _protocol objects calling list_protocol elements: 

```python 

quick_start() 
init...
100%|██████████| 218/218 [00:00<00:00, 234.76it/s]

#### Then, we try to get informations about the first object of this list : 
object_=list_protocol[0]

(print(object_.Genotype)) 
CSMH_RAL_cont@CSMH_RAL_cont

```  
You can see all the classes' attributes in **data_process.py** script.





## TRX file analysis 


This programm can create : 
 - ethograms 
 - 

### Setup 

If you don't want to visualize choreograph data, you can set : 

```python 
   Choreograph_each_experiment=False
   statistical_analysis=False
```

each TRX file contains classified actions (in **'global_state_large_state'**). If for any reason the action number (in Trx files) does not correspond to the action's name, you can change the following dictionary : 

```python 
Dict_action = {
    
    "crawl" : 1, 
    "head_cast" : 2,
    "stop" : 3,
    "hunch": 4,
    "back_up" : 5,
    "roll" : 6,
    "small_action" : 7,
    "bend" : 8
    
    } 
``` 

Ethograms are created for a specific time window. By default, the time used is 30s --> 100s.
You can change modifying the following dictionary : 
```python 
Windows = {
    "1":[10,58], 
    "2":[60,62],
    "3":[30,100], ## Change this time window to set it up. 
    "4" :[30,180],
    "5" : [60,70] ,
    "6" : [60,65],
    "7": [60,68] 

    }

```  
  
The program finds automaticaly all the trx.mat files from the main directorty.
But, your trx files may have a specific name (after re-prediction for example).

You can set this up modifying this variable (don't write the extension .mat here) : 
```python 
mat_name="trx" 
```  

## Concatenate all the TRX files.

For all genotypes, each protocol-type may contain many experiment folders, with 1 Trx file/experiment.
This program works with concatenated-trx files.
Concatenated files are created running auto_concatenate() method, from _Protocol class. 
To create a file for a specific protocol (from a specific genotype), call the following command : 

```python

list_protocol[i].auto_concatenate() 
## i is the index of the specific protocol(from each genotype) in list_experiment
``` 

To create all the files (for all the genotypes/protocol) at the same time, run : 


```python

for i in list_protocol : 
  list_protocol[i].auto_concatenate() 

``` 
> Don't forget that all the _protocol objects are created running **quick_start()** 


## Ethograms 

> Ethograms are created using concatenated-trx files. You can't create them before calling auto_concatenate() method for each _protocol object.


Ethograms are created running ethogram() function (from **visualization.py). 

In order to create ethograms, you can run the following command : 

```python

ethogram(protocol,window,time_reference,sort_larvae)

``` 

 - **protocol** must be a **list of _protocol objects**. To process all the protocol (or genotypes if 1protocol/genotype), protocol would be **list_protocol** 

 - **window** is the the time window used to create the ethograms. This must be the corresponding key from setup.windows dictionary. 

 - **sort_larvae**  :  each line of the ethogram can be sorted (by first action after time_reference and by duration of irst action) setting sort_larvae as **True**. You can modify the sorting algorithm modifying **sort_by_duration** function (defined in visualization.ethogram function). must be a **boolean (True/False)**

 - **time_reference** : the time (stimulus onset) used to sort all the ethogram lines. Must be an **integer** 


 Basically, you can run the following command : 


```python
ethogram(list_protocol,"3",60,True)
```
##basic start  

**After setting up setup.py**, you can copy/past the following code in **main.py**  (removing the default one, and keeping library imports) 
```python

list_genotype=list()
list_protocol=list()
list_experiment=list()


def quick_start(): 
    
   
    print("init...")
    for file in os.listdir(Dict_directory["main_directory"]): ## creations of genotype instances
       
        d = os.path.join(Dict_directory["main_directory"], file)
       
        if os.path.isdir(d):
            
            GenotypeObject = data_process._genotype(d,file,str())
            
            list_protocol.append(GenotypeObject.auto_protocol())
            list_genotype.append(GenotypeObject)
            

    for protocol in tqdm(list_protocol): 
        
        list_experiment.extend(protocol.auto_experiment())
    
print('auto_concatenate...')
for i in list_protocol : 
  i.auto_concatenate() 

print('ethograms...')
visualization.ethogram(list_protocol,"3",60,True)

```

> check the indentation when you past the code
## Choreograph data analysis

This prrogram can analyse choreograph data.

### setup 

Before starting, you have to setup **setup.py**

You can analyse choreograph data with or without statistical analysis. 
if you don't need statistical analysis, set : 
```python

statistical_analysis=False


```

else, set : 

```python

statistical_analysis=True 

```

If statistical_analysis is set as **True** : 
the program is based on 2 types of control : 
 - the first one is used to compare all the genotypes with the same control.
 - the 2n one is used to compare each genotype with 1 or many specific controls.

You have to specify the number of type-2 control : 

```python

dict_control ={ 
    
    
    
    "control_1" : 1, #### Don't modify this one ! 

    "control_2":  2 ###Here, you can choose the number of type-2 control 
    
    }

```

After this, run the command : 
```python
Group_config() 

```
You should get a tkinter window. 
> if you are working on a IDE, first try to run the function and to close the window. If you can't close it, run the function from the terminal.

you have 3 columns of listbox : 
 - **first column** : Genotype that will be compared to the controls
 - **2nd column** : Type-1 control. **Must be the same for all the genotypes**. Set as **None** if you don't have any type-1 control.
 - **3rd column** : Type-2 control. There is 1 listbox for each subtype of type-2 control. **Be consistent choosing the type-2 control subtypes for each genotype** Set as **None** if any subtype isn't available.

 - Press **add genotype**
 - close the window 

You may have a folder **setup.json** in your specified saving directory : you should check that this dictionary is well defined 

> https://jsonviewer.stack.hu/#http:// is a good tool  to visualize the json file 


Then, configure the col_name_choreograph dictionary.

```python
col_names_choreograph = {
   
    
    
   't': {'column' :0 , 'skipped' : True , 'normalization' : [0,1] },  #0
   
   'Number': {'column' : 1 , 'skipped' : True , 'normalization' : [0,1]},#1
   
   'Good number': {'column' :2  , 'skipped' : True, 'normalization' : [0,1]},#2
   
   'Persistence': {'column' : 3 , 'skipped' : True, 'normalization' : [0,1]},#3
   
   'Speed' :  {'column' : 4 , 'skipped' : False, 'normalization' : [0,1]},#4
   
   'Angular speed': {'column' : 5 , 'skipped' : False, 'normalization' : [0,1]},#5
   
   'Length': {'column' :6  , 'skipped' : False, 'normalization' : [0,1]},#6
   
   'Instantaneous length': {'column' : 7 , 'skipped' : False, 'normalization' : [0,1]},#7
  
   'Width': {'column' : 8  , 'skipped' : False, 'normalization' : [0,1]},#8
   
   'Instantaneous width': {'column' : 9 , 'skipped' : False, 'normalization' : [0,1]},#9
  
   'Aspect': {'column': 10 , 'skipped' : False, 'normalization' : [0,1]},#10
  
   'Instantaneous aspect': {'column' : 11 , 'skipped' : False, 'normalization' : [0,1]},#11
  
   'Midline': {'column' : 12 , 'skipped' : False, 'normalization' : [0,1]},#12
   
   'Kink': {'column' : 13, 'skipped' : False, 'normalization' : [0,1]},#13
   
   'Bias': {'column' :14 , 'skipped' : False, 'normalization' : [0,1]},#14
   
   'Curve': {'column' : 15, 'skipped' : False, 'normalization' : [0,1]},#15
  
   'Consistency': {'column' :16, 'skipped' : False, 'normalization' : [0,1]},#16
   
   'X': {'column' : 17, 'skipped' : True, 'normalization' : [0,1]},#17
  
   'Y': {'column' : 18, 'skipped' : True, 'normalization' : [0,1]},#18
  
   'X velocity': {'column' :19, 'skipped' : True , 'normalization' : [0,1]},#19
  
   'Y velocity': {'column' : 20, 'skipped' : True, 'normalization' : [0,1]},#20
  
   'Orientation': {'column' : 21, 'skipped' : True, 'normalization' : [0,1]},#21
  
    'Crab': {'column' : 22, 'skipped' : False, 'normalization' : [0,1]},#22
   
    'Path length': {'column' :23 , 'skipped' : True, 'normalization' : [0,1]},#23
    
    "length/midline": {'column' : None , 'skipped' : False, 'normalization' : [0,1,2]}
    
    
    
    }
```

This represent all the features stored in the created files.  Each feature is stored as a key in this dictionary.
Each key (Feature) is associated to a dictionary, with the following keys : 

 - **column** : The data are collected in .dat files, stored as arrays. For each larva (each .dat file) : there is 1 column for every feature, and 1 line for every time step.  the value associated to **column** correspond to the index of the column in .dat arrays. If **column** is set as **None**, it means that this feature is calculated from the basic ones (we will se how to create new features after)

 - **skipped**  : set as **True** if you don't need this feature to be plotted. 
 - **normalization** : The type of normalization used to represent the data for each time window. Must be stored as a list, a feature can have many normalization types.


 ## Add a new calculated feature 

 You may need to calculate new features (such as ratios,...).

 firstly, you have to define the calculation in the following function (from **setup.py**)


```python
def calculate_features(line):
   
  
    Dict_calculated_features = {
        
        #### Setup this dictionnary to calculate a specific feature
    "length/midline": line[col_names_choreograph['Length']['column']]/line[col_names_choreograph['Midline']['column']]
    
        }
    
     
        
    return Dict_calculated_features
  
```

To add a new calculated-feature, you have to : 
- add a new key to this dictionary (The name of this feature can't contain / or \ )
- write the calculation. **line** is a line from .dat array, use the syntaxe :  col_names_choreograph[**specific_feature**]['column']

