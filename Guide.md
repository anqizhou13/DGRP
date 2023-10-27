# User guide to Adrien's scripts

This program can be used to : 
 - Analyse data from trx.mat files 
- Analyse data from 


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

This program is based on classes (definided in **data_process.py**). Most of the functions need tak _Protocol objects input. 
Before starting, we need to instantiate all _Protocol objects and store them in a list.

To do this, you can run **quick_start** function : 
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

Doing this, you can access to all _protocol objects calling list_protocol elements: 

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











