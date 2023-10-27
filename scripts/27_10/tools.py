#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 15:32:20 2023

@author: bouchet
"""
import os
import subprocess


from setup import Dict_directory as Dict_directory
from setup import Features_Trx as Features_Trx
from setup import Windows as windows
from setup import Choreograph_each_experiment as Choreograph_each_experiment
from setup import col_names_choreograph as col_names_choreograph
from setup import  Number_column_DAT_Files as Number_column_DAT_Files
from setup import calculate_features as calculate_features

import h5py
import numpy as np 
import pickle 
import json
from tqdm import tqdm 

def normalization(dict1,dict2,norm_type) : 
    
    """ dict1 is the dictionary with the values to normalize, dict2 is the dict with the values needed to normalize the dict1's values.
    
    remind that the inout dict have the following structure : 
        
        
          
             {
                 
                 'larva : 1' : {
                     
                  't': 46.409615873015866,
                  'Number': 1.0,
                  'Good number': 1.0,
                  'Persistence': 133.20000000000002,
                  'Speed': 0.26565273311897103,
                  'Angular speed': 4.991961414790997,
                  'Length': 3.7187777777777775,
                  'Instantaneous length': 0.9917206349206351,
                  'Width': 1.0173492063492064,
                  'Instantaneous width': 0.9108698412698412,
                  'Aspect': 0.28155555555555556,
                  'Instantaneous aspect': 0.9129079365079366,
                  'Midline': 4.096605095541401,
                  'Kink': 30.95414012738854,
                  'Bias': 0.3821656050955414,
                  'Curve': 12.337579617834395,
                  'Consistency': 0.013917460317460316,
                  'X': 78.85699682539682,
                  'Y': 121.54176507936509,
                  'X velocity': -0.09988745980707396,
                  'Y velocity': 0.10991318327974277,
                  'Orientation': 134.25841269841268,
                  'Crab': 0.10350160771704182,
                  'Path length': 1.8433949044585989,
                  'length/midline': 0.9123381789043874
                  
                  },
                 
                 'larva : 2' : 
                     
                     {
                          't': 38.5158256880734,
                          'Number': 1.0,
                          'Good number': 1.0,
                          'Persistence': 32.10000000000001,
                          'Speed': 0.5183846153846153,
                          'Angular speed': 6.636596736596737,
                          'Length': 4.155422018348625,
                          'Instantaneous length': 1.0006697247706422,
                          'Width': 1.5035619266055045,
                          'Instantaneous width': 0.9994128440366972,
                          'Aspect': 0.3943876146788991,
                          'Instantaneous aspect': 0.9989564220183487,
                          'Midline': 5.014816513761468,
                          'Kink': 40.658256880733944,
                          'Bias': 0.30275229357798167,
                          'Curve': 14.149311926605506,
                          'Consistency': 0.029967889908256884,
                          'X': 81.51950458715596,
                          'Y': 97.96488073394498,
                          'X velocity': -0.1443776223776224,
                          'Y velocity': 0.21608158508158512,
                          'Orientation': -27.413302752293575,
                          'Crab': 0.08198368298368298,
                          'Path length': 4.404089449541284,
                          'length/midline': 0.8253650966581596
                         
                         
                         }
                 
                 
                
                 
                 }
   
    
    
    """
    
    if norm_type==0 : 
       
        return dict1
    
    if norm_type==1 : 
           
              """ 1 type : normalization : value.norm=value-mean(value.baseline)"""
                
              for feature in col_names_choreograph.keys() : 
                      
                      list_baseline=list()
                      for larva in dict2.keys() : 
                          
                          list_baseline.append(dict2[larva][feature])
                           
                      mean=np.nanmean(list_baseline)
                      
                      for larva in dict1.keys() : 
                          
                          dict1[larva][feature]= dict1[larva][feature]- mean
                      
              return dict1
                      
    if norm_type==2 : 
        
        
        for feature in col_names_choreograph.keys() : 
                
                list_baseline=list()
                for larva in dict2.keys() : 
                    
                    list_baseline.append(dict2[larva][feature])
                     
                mean=np.nanmean(list_baseline)
                
                for larva in dict1.keys() : 
                    
                    dict1[larva][feature]= (dict1[larva][feature]- mean)/mean
                
        return dict1
            
        
                      
                          
                          
                          
                          
                   
                      
                  
                  
                
        
        
        
    
    