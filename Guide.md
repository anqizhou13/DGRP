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
   






