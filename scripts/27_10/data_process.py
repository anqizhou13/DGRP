#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 20 15:50:48 2023

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
from setup import Normalization_name as Normalization_name
from setup import statistical_analysis as statistical_analysis
from setup import mat_name as mat_name


from tools import normalization as normalization 

import h5py
import numpy as np 
import pickle 
import json
from tqdm import tqdm 
from statsmodels.stats.multitest import fdrcorrection
from scipy.stats import norm
from scipy.stats import mannwhitneyu
from scipy.stats import wilcoxon
import subprocess

class _genotype : 
    
    def __init__ (self,Pathway,Genotype,Group) : 
       
        self.Genotype=Genotype
        self.Pathway=Pathway
        self.Group=Group
        
    def auto_protocol(self) : 
        
        for file in os.listdir(self.Pathway):
            d = os.path.join(self.Pathway, file)
            
            if os.path.isdir(d): 
                #self.Protocol.append(file)
                protocol=_protocol(file,self.Pathway,self.Genotype,self.Group)
                #list_protocol.append(protocol)
                return(protocol)
    
    
   
                
class _protocol (_genotype): 
     
     def __init__ (self,name,Pathway,Genotype,Group):
         super().__init__(Pathway,Genotype,Group)
         self.Protocol=name
         self.list_experiment=None

                  
        
     def auto_experiment(self):
           path='{}/{}/'.format(self.Pathway,self.Protocol)
           experiments_list=list()
           experiments_list_name=list()
           for file in os.listdir(path):
               d = os.path.join(path, file)
               
               if os.path.isdir(d): 
                   #self.Protocol.append(file)
                   experiment=_experiment(self.Protocol,self.Pathway,self.Genotype,self.Group,file)
                   #list_protocol.append(protocol)
                   experiments_list.append(experiment)
                   if file !="dataFiles": 
                       experiments_list_name.append(file)
                   self.list_experiment=experiments_list_name
          
           return (experiments_list)
                   
       
     
     def auto_concatenate(self) : 
        
         
        
            """ In this function, all the trx files from each experiment are concatenated in a dictionary : 
                 
                 
                 d= { larva 0 : {
                         
                         "feature 1" :  [...],
                         "feature 2": [...],
                         
                         }
                      larva 1 : {
                          
                          "feature 1" :  [...],
                          "feature 2": [...],
                          
                          }
                     }
            
            --> The names of feature 1, ... are stored in setup.Features_Trx
            
            
                     
            """
            
            
            output_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",self.Genotype)
            output_file_path = "{}/concatenatedTRX.json".format(output_folder)
            
            if not os.path.exists(output_folder):
                 os.makedirs(output_folder)
            
            if os.path.exists(output_file_path) == True:
                print(" Concatenated trx file already exists, skipping genotype {}".format(self.Genotype))
                return     
            trx_files = [] 
            
            for file in os.listdir(self.Pathway+'/'+self.Protocol):
                d = os.path.join(self.Pathway+'/'+self.Protocol, file)
                
                if os.path.isdir(d): 
                    trx_files.append(d+"/{}.mat".format(mat_name))
                    print ("experiment : " + d)
            dict_trx={}
            count_larva=0
           
            for trx_file in trx_files :
                
                try : 
                    f = h5py.File(trx_file,'r')
                    each_trx = f.get('trx')
                   
                    number_larvea = len(each_trx['numero_larva_num'][0])
                    
                    #print('trx file : ', trx_file)  ##diagnostic
                 
                    for i in range(number_larvea): 
                      
                        dict_trx['larva {} :'.format(count_larva)]=dict() 
                        
                        
                        for feature in Features_Trx.keys() : 
                            values=list()
                             
                            
                            values = np.array(f[each_trx[feature][0][i]])
                                
                            
                            if len(values) !=0 : 
                                dict_trx['larva {} :'.format(count_larva)][feature]=values.tolist()
                        count_larva+=1
                       
                except FileNotFoundError:
                  
                      pass
               
                except KeyError : 
                    print("keyerror ( most of the time : KeyError: Unable to open object (object '<HDF5 object reference>' doesn't exist)) ")
                except  : 
                    pass
                
             
               
            with open(output_file_path,'w') as fi:
                     json.dump(dict_trx,fi)
            print("Concatenated file created ")      
                  
           
            
       
         
     def choreograph_process(self,Folder_each_experiment=Choreograph_each_experiment): 
          
         """Choreograph_each_experiment  is a setup variable, set as True by default 
         
         the output has the following structure : 
             
             
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
                 
         The dictionaries are stored in .json files
         
         It would have been much faster to work (/20x)(in termes of processing time) using arrays, but it's far easier to get back the data using keys rather than using indexes, epscially if you want processed data from an other program/language
         
         
         """
         
         
         for window in windows.keys() : 
             
                
            
                 dat_files = [] 
                 
                 Datfiles_each_experiment=dict()
                 
                 
                 for experiment in self.list_experiment: 
                     files=os.listdir("{}/{}/{}/{}".format(Dict_directory["main_directory"],self.Genotype,self.Protocol,experiment))
                     Datfiles_each_experiment[experiment]=list() 
                     for file in files:
                         if file.endswith(".dat"):
                           Datfiles_each_experiment[experiment].append(os.path.join("{}/{}/{}/{}".format(Dict_directory["main_directory"],self.Genotype,self.Protocol,experiment), file))
                          
        
                
        
        
                 dict_data = dict() 
               
                 larva=0
                 for experiment in Datfiles_each_experiment.keys() : 
                     
                     dict_data_experiment= dict() 
                     
                     output_folder_experiment="{}/processed_data/{}/DatConcatenate_experiment/{}s_{}s".format(Dict_directory["saving_directory"],self.Genotype,windows[window][0],windows[window][1])
                     output_file_experiment="{}/{}_DAT_concatenate.json".format( output_folder_experiment,experiment)    
                     
                     if os.path.exists(output_file_experiment) == True:
                         print(" Concatenated trx file already exists, skipping genotype {}".format(self.Genotype))
                         continue   
                    
                     ### Which means that we cannot create global DAT_concatenate file without creating experiment-associated DAT_concatenated file 
                     
                     for chor_file in Datfiles_each_experiment[experiment]:  ## 1 Dat_file/larva for each genotype
            
                         temp = []
                         # open the choreograph file
                         f = open(chor_file, "r")
                         try : 
                           
                        
                           
                             f = f.read()
                             # break down line
                             f = f.split("\n")
                
                             # convert each line from string to array
                             for i in range(len(f)-1):
                                 if len(f[i].split()) == Number_column_DAT_Files:
                                     temp.append(np.array(f[i].split(),dtype = float))
                                     
                                    
                           
                             list_default_columns=list()
                             for i in col_names_choreograph.keys(): 
                                 if col_names_choreograph[i]['column'] != None : 
                                     list_default_columns.append(i)  ###col_names_choreograph contains both default and calculated features, we create a list with the default features only 
                            
                           
                             if len(temp)!=0 : 
                                 dict_eachline_eachlarva={}
                                 for i in  col_names_choreograph.keys(): 
                                     dict_eachline_eachlarva[i]=[]
                                 
                                 
                                 #print(len(temp))
                                 #temp_copy=temp
                                 temp_copy=[]
                                 #temp[0] = temp[0].astype(float)
                                 dict_calculated_features={}
                                 for b in range(len(temp)-2): 
                                            
                                             if (temp[b][0]<windows[window][0] or temp[b][0]>windows[window][1]) : ###In temp[b][0] : time at timestep b 
                                                 #print("faux",temp[b][0])    
                                                 continue 
                                             else : 
                                                 for i in  list_default_columns : 
                                                     
                                                     dict_eachline_eachlarva[i].append(temp[b][col_names_choreograph[i]['column']]) ## Firstly, we add the corresponding (for each feature) to the dictionary (Larva-specific dictionary) 
                                                    
                                                     
                                                 feature_calcul=calculate_features(temp[b]) ### feature_calcul is a dictionary containing the value for each calculated feature, for time step b
                                                 for key in feature_calcul.keys() : 
                                                            
                                                             dict_eachline_eachlarva[key].append(float(feature_calcul[key]))
                                                            
                                                    
                                               
                                  
                               
                             
                                 temp=temp_copy
                                 temp = np.transpose(np.array(temp))
                                 
                                 for key in dict_eachline_eachlarva.keys() : 
                                     list_tempo=[]
                                     for step in range(len(dict_eachline_eachlarva[key])):
                                                if  (np.isnan(dict_eachline_eachlarva[key][step])==False) and (((dict_eachline_eachlarva[key][step]=="NaN")==False)) : ### Remove all nan values
                                                    list_tempo.append(dict_eachline_eachlarva[key][step])
                                     
                                     dict_eachline_eachlarva[key]=np.nanmean(list_tempo) 
                                 c=0
                                 for key in  dict_eachline_eachlarva.keys(): 
                                     if np.isnan(dict_eachline_eachlarva[key]):
                                         c+=1
                                 if c==0 : 
                                     
                                     dict_data_experiment["larva : {}".format(larva)]=dict_eachline_eachlarva
                                     larva+=1
                         except UnicodeDecodeError:  ##Solve this issue 
                                pass            
                                                            
                    
                     
                     if not os.path.exists(output_folder_experiment):
                          os.makedirs(output_folder_experiment)      
                          
                   
                     
                     with open(output_file_experiment,'w') as handle:
                         json.dump(dict_data_experiment,handle)
                     
                     dict_data.update(dict_data_experiment)   
                                
                   
                          
                 output_folder_protocol="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",self.Genotype)
                 folder_each_window_protocol= '{}/{}s_{}s'.format(output_folder_protocol,windows[window][0],windows[window][1])
                 
                 if not os.path.exists( folder_each_window_protocol):
                      os.makedirs(folder_each_window_protocol)      
                      
                 output_file = '{}/DAT_concatenate.json'.format(folder_each_window_protocol)
                 
                 with open(output_file,'w') as handle:
                     json.dump(dict_data,handle)
       
        
       
        
      
     def normalisation_choreograph_metrics(self,window): 
         
         """  
         
         We normalize only global (with all experiment) DAT_concatenate values
         
         """
         
   
         if window=="1" :#### if the window is the baseline : 
             
             input_folder= "{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",self.Genotype)
             folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
             input_file = '{}/DAT_concatenate.json'.format(folder_each_window)
             
             output_file = '{}/DAT_concatenate_normalized_NormType0.json'.format(folder_each_window)
             
             file=open(input_file,'r')
            
             data_file=json.load(file)
             
             with open(output_file,'w') as handle:
                 json.dump(data_file,handle)
                 
         for norm_type in Normalization_name.keys() :
             
             
             
               
              
                input_folder= "{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",self.Genotype)
                folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                input_file = '{}/DAT_concatenate.json'.format(folder_each_window)
                
                output_file = '{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
                
                 
                # if os.path.exists(output_file) == True:
                #          print(" Concatenated trx file already exists, skipping genotype {}".format(self.Genotype))
                #          continue   
                    
               
                file=open(input_file,'r')
               
                data_file=json.load(file)
               
                input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",self.Genotype)
                folder_each_window = '{}/{}s_{}s'.format(input_folder,windows["1"][0],windows["1"][1])
                input_file = '{}/DAT_concatenate.json'.format(folder_each_window)
               
                file=open(input_file,'r')
               
                data_baseline=json.load(file)
               
                
                data_file2=normalization(data_file,data_baseline,norm_type)
                
                
                with open(output_file,'w') as handle:
                    json.dump(data_file2,handle)
      
                
                
           
       
        
       
        
        
       
        
       
        
       
class _experiment(_protocol) : ###il y'a des chances pour que cette classe soit inutile (on ne l'utilise pas penser à l'enlever si jamais )
        
       def __init__ (self,Protocol,Pathway,Genotype,Group,experiment):
            super().__init__(Protocol,Pathway,Genotype,Group)
            self.Experiment= experiment
        
       
            
      
        
       def ChoreJar_autorun(self): ##### Works only on UNIX-based system !
          
            
            script_bash = Dict_directory["sh_choreograph"]
            
           
            dernier_chemin = "{}/{}/{}".format(self.Pathway,self.Protocol,self.Experiment) ## To change this variable name, we also have to modify the bash script 
            
        
            
            commande = [
                "bash",        
                script_bash,   
                dernier_chemin 
            ]
            
            # Exécutez la commande
            process = subprocess.Popen(
            commande,
            stdout=subprocess.PIPE,  
            stderr=subprocess.PIPE,  
            universal_newlines=True,  
            bufsize=1,                
            shell=False               
        )
            for ligne in process.stdout:
                print(ligne, end='')


            process.wait()


            erreur = process.stderr.read()
            if erreur:
                    print("Sortie d'erreur :")
                    print(erreur)

    


def choreograph_testGROUPvsControl1(genotypes,window) : 
    

    
    
    """  We assume that we only have 1 control-1
    
    genotype : must be a list of all the protocol object (class Protocol)
    window : key from the setup.windows dictionary
    
    
    The output has the following structure : 
        
        {
        'RAL_505@RAL_505': {
         't': [520855.0,
          2.301548205124352e-170,
          2.5086875435855435e-168],
         'Number': [269492.5, 1.0, 1.0],
         'Good number': [269492.5, 1.0, 1.0],
         'Persistence': [390764.0, 4.828809954069397e-41, 5.263402849935642e-39],
         'Speed': [241374.0, 0.0018658909076086161, 0.008474254538722465],
         'Angular speed': [198539.0, 4.16814998128293e-15, 9.086566959196786e-14],
         'Length': [190318.0, 1.9649753265424604e-18, 1.4278820706208544e-17],
         'Instantaneous length': [330617.0,
          1.35770396106257e-11,
          3.6997432938955034e-10],
         'Width': [206183.0, 2.4860573551776547e-12, 2.7098025171436435e-11],
         'Instantaneous width': [242240.0,
          0.0025699691495425026,
          0.05602532746002655],
         'Aspect': [255762.0, 0.1287636423830336, 0.6102276965108983],
         'Instantaneous aspect': [223773.0,
          4.2357732540951266e-07,
          1.5389976156545625e-05],
         'Midline': [131752.0, 1.959264378101754e-52, 1.7796651434424264e-51],
         'Kink': [235325.0, 0.0001568229747493983, 0.0008996686446149691],
         'Bias': [212926.5, 3.898535328223975e-10, 1.4164678359213775e-08],
         'Curve': [214476.0, 1.1533177235819436e-09, 1.2571163187043185e-08],
         'Consistency': [265652.0, 0.6709544125293254, 1.0],
         'X': [251876.0, 0.05130539555165272, 0.29433095342790244],
         'Y': [250167.0, 0.03251764792614884, 0.35444236239502236],
         'X velocity': [267907.0, 0.860801634165689, 1.0],
         'Y velocity': [262797.0, 0.458881388775939, 1.0],
         'Orientation': [245386.0, 0.007654835549501652, 0.05562513832637867],
         'Crab': [196806.0, 8.875020872941883e-16, 9.673772751506652e-15],
         'Path length': [324625.0, 1.0644196199525309e-09, 1.1602173857482587e-08],
         'length/midline': [302201.0, 0.00029620729702857696, 0.004035824422014361]},
        ...
        }
        
        where for each feature, we have [statistic (U1),p-value,corrected p-value]
        
        
        """
    
    
    if statistical_analysis==False: 
        print("statistical_analysis==False,set as true if needed")
        return 
    
    setup_file="{}/setup.json".format(Dict_directory["saving_directory"])
    setup=json.load(open(setup_file,"r"))
    
    list_control =list() 
        
    for i in setup.keys(): 
        if ((setup[i]['control_1']) in list_control)==False:  
            list_control.append(setup[i]['control_1'])
            
    if len(list_control) != 1: 
        print("all the genotypes must share the same control_1, verify setup.json")
        return
        
    control_name=list_control[0][0]
    
    
        
    for norm_type in Normalization_name.keys(): 
        
   
    
        input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",control_name)
        folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
        input_file = '{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
        
        control_file=open(input_file,'r')
        data_control=json.load(control_file)
        
             
        dict_p_value={}
          
        
       
        
        data_feature=list() 
        data_featureControl=list()
        for gen in genotypes : ## creation of a dict with only Genotypes (whithout controls) values
            if (gen.Genotype in setup.keys()):
                
                dict_genotype=dict() 
                
                
                input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",gen.Genotype)
                folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                input_file = '{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
                
                
                file=open(input_file,'r')
                
                data_file=json.load(file)
                for feature in col_names_choreograph.keys():      
                    
                    data_feature=list() 
                    data_featureControl=list()
                
                    for larva in data_file.keys(): 
                        data_feature.append(data_file[larva][feature])
                           
                    for larva in data_control.keys(): 
                        data_featureControl.append(data_control[larva][feature])
                     
                    
                    U1, p = mannwhitneyu(data_feature, data_featureControl, method="asymptotic")
                   
                    dict_genotype[feature]=[U1,p]
                             
               
                       
                dict_p_value[gen.Genotype]=dict_genotype 
                 
                
        ###Then we process FDR correction 
        
        
       
    
        for feature in col_names_choreograph.keys(): 
            p_values=list() 
            for i in dict_p_value.keys() : 
                p_values.append(dict_p_value[i][feature][1])
            reject, pvals_corrected = fdrcorrection(p_values, alpha=0.05)
            
            for i in range(len(list(dict_p_value.keys()))): 
                dict_p_value[list(dict_p_value.keys())[i]][feature].append(pvals_corrected[i])
            
            
            
    
        output_folder="{}/general_processed_data".format(Dict_directory["saving_directory"])
        
        output_file="{}/p-value_csmh_{}s-{}s_normType{}.json".format(output_folder,windows[window][0],windows[window][1],norm_type)
        
        if not os.path.exists(output_folder):
              os.makedirs(output_folder)
              
    
        with open(output_file,'w') as fi:
            json.dump(dict_p_value,fi)
        print("file created ")      
        
        
                        
        output_text_file="{}/p-value_csmh_{}s-{}s_normType{}.txt".format(output_folder,windows[window][0],windows[window][1],norm_type)     
        
        text=""
        for key1 in dict_p_value.keys()  :
            text += "\n { " + key1 + "\n"
            for key2 in dict_p_value[key1].keys(): 
                text+= "{} : {} \n".format(key2,str(dict_p_value[key1][key2]))
            
            text+= "} \n "
            
        with open( output_text_file, 'w') as fichier:
            fichier.write(text)
                
    
      
                    
                   
                   