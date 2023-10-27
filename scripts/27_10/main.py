#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 20 15:50:58 2023

@author: bouchet
"""


from setup import Dict_directory as Dict_directory 
import visualization




import data_process
import os 
import multiprocessing 
import time
from tqdm import tqdm 



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
    
    
    
    