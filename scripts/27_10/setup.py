#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 20 15:50:51 2023

@author: bouchet
"""
import os
import tkinter as tk
from tkinter import ttk
import json 




""" set as True if needed to plot features for each different experiment separately (from the same protocol)"""

Choreograph_each_experiment=True 
statistical_analysis=True

mat_name="trx"
Dict_directory = {
    "main_directory" : "/Volumes/TOSHIBA/data_copy/data",
    "saving_directory" : "/Volumes/TOSHIBA/saving/_6",
    "sh_choreograph" : "/Users/bouchet/Documents/Cours/stage/DGRP/code/DGRP data proessing/choreograph_process.sh",
    "LarvaTagger" : "/Users/bouchet/Documents/Cours/stage/DGRP/code/git_dgrp/dgrp-behavior/LarvaTagger/LarvaTagger",
    "sh_Larvatagger" : "/Users/bouchet/Documents/Cours/stage/DGRP/code/git_dgrp/dgrp-behavior/Adrien_script/Adrien_script/retraining.sh", ##Script to automate 
    "ClassifierName" : "/Users/bouchet/Documents/Cours/stage/DGRP/code/git_dgrp/dgrp-behavior/LarvaTagger/LarvaTagger/models/model20231009" ##Folder specified for retraining the classifier 
    
    
    }



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


dict_control ={ 
    
    
    
    "control_1" : 1, 
    "control_2":  2
    
    }



""" The following dictionnary is used to store the index of each feature in the TRX.mat files  """


Features_Trx ={'id' : 0,                           
    'numero_larva_num':1,            
    't':2,                   
    'x_center':3,                      
    'y_center':4,                     
    'global_state':5,                  
    'S':6,                      
    'S_smooth_5':7,                    
    'S_deriv_smooth_5':8,              
    'head_velocity_norm_smooth_5':9,   
    'motion_velocity_norm_smooth_5':10, 
    'larva_length_smooth_5':11,  
    'larva_length_deriv_smooth_5':12,  
    'global_state_large_state':13,    
    'global_state_small_large_state':14,

}

Windows = {
    "1":[10,58], ###### The first window must be the baseline, because it serves as baseline for normalisation 
    "2":[60,62],
    "3":[30,100], ## Used for ethograms
   # "4" :[30,180],## 
    "5" : [60,70] ,
    "6" : [60,65],
    "7": [60,68]  ##### window used for transition 

    }





""" 

The following dictionary is used to store all the processing informations about each feature. 

column: if column = integer : the index of the column of each feature in the .dat files
        if column = None : This is a calculated feature. 
        warning : - this feature must be defined in the function calculate_features
                  - the name of the calculated feature must be the same in both col_names_choreograph and calculate_features

skipped : set as True if the analysis of this feature must be skipped

normalization : Must be a list of normalization types (EVEN IF THERE IS ONLY 1 TYPE OF NORMALISZATION).
         - 0 : Non normalized 
         - n : normalization-associated number, used in data_process.normalization function 
         


"""

Number_column_DAT_Files=24

Normalization_name={
 
    0:"non-normalized",
    1: "value-mean.baseline",
    2:"ratio[(value-mean.baseline),mean.baseline]"
    
    }

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


def calculate_features(line):
   
  
    Dict_calculated_features = {
        
        #### Setup this dictionnary to calculate a specific feature
    "length/midline": line[col_names_choreograph['Length']['column']]/line[col_names_choreograph['Midline']['column']]
    
        }
    
    l=[]
    # for i in Dict_calculated_features.keys() : 
    #     l.append(Dict_calculated_features[i])
    # return l 
        
    return Dict_calculated_features
        
skiped_features=[
    't',
    'Number',
    'Good number',
    'Persistence',
    'Width',
    'Instantaneous width',
    'Consistency',
    'X',
    'Y',
    'X velocity',
    'Y velocity',
    'Orientation',
    'Path length'
 
    ]



def Group_config() : 
    
    """
    This function is used to setup controls if needed, it uses two  types of controls (1/2), with the number specified in dict_control 
  
    """
    
    dictionary={}
    
    list_genotype = []
    for file in os.listdir(Dict_directory["main_directory"]):
        d = os.path.join(Dict_directory["main_directory"], file)
        if os.path.isdir(d):
            list_genotype.append(file)

    list_genotype.sort()
    list_genotype_remaining=list_genotype
    final_dict=dict() 
    
    def add_genotype(): 
        
        genotype=Combo1.get()
        final_dict[genotype]=dict() 
        
        if dict_control["control_1"] !=0 : 
            list_c1=list()
            for i in range(dict_control["control_1"]): 
                list_c1.append(list_combo2[i].get())
            if '' in list_c1 : 
                del  final_dict[genotype]
                return  ###Avoid giving empty control, use None instead
            final_dict[genotype]["control_1"]=list_c1
        
        if dict_control["control_2"] !=0 : 
             list_c2=list()
             for i in range(dict_control["control_2"]): 
                 list_c2.append(list_combo3[i].get())
                 if '' in list_c2 : 
                     del final_dict[genotype]
                     return
             final_dict[genotype]["control_2"]=list_c2
       
        list_genotype_remaining.remove(genotype)
        Combo1['values']=list_genotype_remaining
        Combo1.set("")
        if dict_control["control_1"] !=0: 
            for i in list_combo2 : 
                i.set("")
        if dict_control["control_2"] !=0:
            for i in list_combo3 : 
                i.set("")
        
    
    root=tk.Tk()  
    Combo1=ttk.Combobox(root,values=list_genotype_remaining)
    Combo1.grid(row=0,column=0)
   
    
    if dict_control["control_1"]!=0 : 
        list_combo2=list() 
        for i in range(dict_control["control_1"]): 
                
            list_combo2.append(ttk.Combobox(root,values=list_genotype+[None]))
            list_combo2[i].grid(row=i,column=2)
        
    if dict_control["control_2"]!=0 : 
        list_combo3=list() 
        for i in range(dict_control["control_2"]): 
                
            list_combo3.append(ttk.Combobox(root,values=list_genotype+[None]))
            list_combo3[i].grid(row=i,column=3)
        
    
    add_button=tk.Button(root, text="add genotype and control",command=add_genotype)
    
    add_button.grid(row=0,column=4)
    
    root.mainloop()
    
    print(final_dict)
    output_file="{}/setup.json".format(Dict_directory["saving_directory"])
    with open(output_file, "w") as fichier:
        json.dump(final_dict, fichier)
    
    
    
