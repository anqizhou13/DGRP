#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 11:51:34 2023

@author: bouchet
"""

from setup import Dict_directory as Dict_directory
from setup import Windows as windows
from setup import Dict_action as Dict_action
from setup import statistical_analysis as statistical_analysis
from setup import col_names_choreograph as col_names_choreograph
from setup import Normalization_name as Normalization_name
from setup import dict_control as dict_control


import os
import json
import numpy as np
import pandas as pd


from sklearn.preprocessing import LabelEncoder as le
import matplotlib.pyplot as plt
from tqdm import tqdm
import matplotlib.pyplot as plt
import math
import random
import string

from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
import statistics
from statistics import StatisticsError
import patchworklib as pw

from plotnine import *
import seaborn as sns
import matplotlib.pyplot as plt







def ethogram(protocol,window,time_reference,sort_larvae):


    """
     - This function takes concatenatedTrx file created by auto_concatenate methode (from Protocol class)

    The input file's structure is :


                 d= { larva 0 : {

                         "feature 1" :  [...],
                         "feature 2": [...],

                         }
                      larva 1 : {

                          "feature 1" :  [...],
                          "feature 2": [...],

                          }
                     }


    - the Protocol function's input must be a protocol object (protocol class)
    - The time window must be a key from setup.Windows dictionary
    - time_reference : the time (stimulus onset) used to sort the actions : must be an integer
    - sort larvae : must be a boolean. set as True/False

    This function sorts the larvae by the duration of the first action after defined time  :
    """

     ###############

    folder_output = '{}/Ethograms'.format(Dict_directory['saving_directory'])
    file_output="{}/Ethogram_{}_{}.pdf".format(folder_output,protocol.Genotype, protocol.Protocol)
    if os.path.exists(file_output) == True:
        print(" Ethogram already exists, skipping genotype {}, protocol {}".format(protocol.Genotype, protocol.Protocol))
        return

    input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",protocol.Genotype)
    input_file_path = "{}/concatenatedTRX.json".format(input_folder)

    Trx = json.load(open(
        input_file_path , "r"))
    t1=windows[window][0] #start time of the window
    t2=windows[window][1] #end time
    time_step = np.arange(t1,t2,0.1)



    tab = np.zeros((len(list(Trx.keys()))+1, len(time_step)))
    for l in range(tab.shape[0]):
        for c in range(tab.shape[1]):
            tab[l, c] = np.NAN
    tab[0] = time_step
    count_larva=0
    for larva in Trx.keys():

        if 't' in list(Trx[larva].keys()) : ##If a larva is not tracked during all the protocol, skip the larva and avoid Keyerror : 't'

            for step in range(len(Trx[larva]['t'][0])):

                t = Trx[larva]['t'][0][step]



                action = Trx[larva]['global_state_large_state'][0][step]

                if (t < t1 or t > t2 -1.2):
                    #print("pass")
                    continue

                tab[count_larva+1, int((t-windows[window][0])*10)-3] = action

            count_larva+=1


    ### the next lines remove all the lines from unactive larvae
    index_larva_remove=list()

    for larva in range(len(Trx)) :
         count_NaN=0
         for i in range(len(tab[larva,:])) :
             if np.isnan(tab[larva,i])==True :
                 count_NaN+=1
         percentage_activity=1-count_NaN/len(time_step)

         if percentage_activity <0.9:
             index_larva_remove.append(larva)
    ###Here, we firstly remove the last to avoid index problems
    for i in range(len(index_larva_remove)):
        tab=np.delete(tab,index_larva_remove[len(index_larva_remove)-i-1],axis=0)


    ###### cluster the lines by action during (60-70) time steps
    ##############################################################


    """clustering using the first action for a specified time, sorted by duration of first action """

    ###


    index_reference=int((time_reference-windows[window][0])*10) ####Index in Tab general array from the action of interest start



    def sort_by_duration(dictionary,index):
        for key in dictionary.keys() :
            index_line=list(range(len(dictionary[key])))
            length_action_perline=list()
            for line in range(len(dictionary[key])):
                length=1
                action=dictionary[key][line][index]
                i=1

                while dictionary[key][line][index+i] == action :
                    length+=1
                    i+=1
                length_action_perline.append(length)


            ##Sort

            for i in range(len(index_line)):
                for j in range(len(index_line)-1) :
                    if  length_action_perline[j+1] < length_action_perline[j] :
                      length_action_perline[j+1],length_action_perline[j] =length_action_perline[j],length_action_perline[j+1]
                      index_line[j+1], index_line[j]= index_line[j], index_line[j+1]
            final_list=[0]*len(dictionary[key])
            for i in range(len(index_line)):
                final_list[i]=dictionary[key][index_line[i]]


            dictionary[key]=final_list

        return(dictionary)







    dict_clusters={}
    for i in Dict_action.keys()  :

        dict_clusters[Dict_action[i]]=list()

    for line in range(1,tab.shape[0]):
        try :
            dict_clusters[int(tab[line,index_reference])].append(tab[line,:])
        except : ###Could have an NaN in tab[larva, time_reference]
            pass


    if sort_larvae==True :
        dict_clusters=sort_by_duration(dict_clusters,index_reference)

    tab2=np.zeros([tab.shape[0]-1,tab.shape[1]])
    l=0
    for cluster_key in dict_clusters.keys() :

        for line in dict_clusters[cluster_key] :
            tab2[l,:]=line
            l+=1



    tab=tab2

    reversed_dict_action={
        1: "crawl",
        2:"head_cast",
        3:"stop" ,
        4:"hunch",
       5: "back_up" ,
       6: "roll",
       7: "small_action",
       8: "bend"

        }






    dict_data = {"time: ":time_step}
   # dict_sequence= {"temps: ":list(range(sequence.shape[1]))}


    for i in range(1,tab.shape[0]):
        dict_data["larve "+str(i)+" :"] = tab[i]
     #   dict_sequence["larve "+str(i)+" :"] = sequence[i]

    for key in list(dict_data.keys()):
        if float(0)in dict_data[key] :
            del dict_data[key]

    DataFrame = pd.DataFrame(dict_data)
   # DataFrame2=pd.DataFrame(dict_sequence)


    columns = []

    DataFrame = DataFrame.melt(
        id_vars="time: ", var_name="Larva", value_name='behavior')

    # DataFrame2 = DataFrame2.melt(
    #     id_vars="temps: ", var_name="Larve", value_name='Comportement')



    DataFrame["behavior"] = DataFrame["behavior"].astype("category")


    ethograme_main= (
        ggplot(DataFrame, aes(x="time: ", y='Larva', fill="behavior"))
        + geom_tile()
        + labs(x='Time', y='Larva', title="{}-{}s_{}s".format(protocol.Genotype,windows[window][0],windows[window][1]),fill='behavior')
        + theme_minimal()

        +scale_fill_manual(values={ 0.0 : "#F3D706",
                                            1 : "#000000",
                                          2 : "#E80617",
                                          3: "#058D02" ,
                                          4: '#0C1BD6', #y
                                          5: '#06E8AE',
                                          6: "#E8E406",
                                          7:"#ADADAD"
                                         },labels=reversed_dict_action)###Spécifier les bonnes couleurs ici, faire un fictionnaire associé à chaque nom d'action, puis l'appeler avec le dictionnaire chiffre-action
        +geom_vline(xintercept=time_reference, size=1, color="black")

        +theme(

                    figure_size=(20,22),
                    axis_text_x=element_text(size=20,face="bold"),
                    axis_text_y=element_text(size=0),
                    axis_title_x=element_text(size=25,face="bold"),
                    axis_title_y=element_text(size=0,face="bold") ,
                    plot_title=element_text(size=40,face="bold",hjust=0.5),
                    legend_text=element_text(size=17),
                    legend_key_size=25,
                    legend_title=element_text(size=20)

                    )

    )



    if not os.path.exists(folder_output):
         os.makedirs(folder_output)
    #ethograme_main.save('{}/Ethogram_{}_{}.png'.format(subfolder_protocol,protocol.Genotype, protocol.Protocol))
    #
    ethograme_main.save('{}/Ethogram_{}_{}.pdf'.format(folder_output,protocol.Genotype, protocol.Protocol))#### stupide, il suffit de copier l'image et de la transformer en PDF (mais j'imagine qu'on perd de l'information)
    #etho3.save("{}/Ethogram3_{}_{}.pdf".format(folder_output,protocol.Genotype, protocol.Protocol))





def simple_boxplot_choreograph_RAL(genotypes, window,stat=statistical_analysis): ## For group : "RAL@RAL" most of the time

      """
      This function realizes boxplot for the specified time window, and all the genotypes (Protocol object) given.
      can be used without or without (setup.statistical_analysis=True/False) statistical anaylsis.
      
      Important: - If statistical analysis set as True, must have a setup.json file created using setup.Group_config function
      
      - This function (with our without statistical analysis ) requieres normalized-data files  (created from data_process, ProtocolObject.normalisation_choreograph_metrics) 
      
      - If statistical_analysis set as True, this function requieres p-values files, created running data_process.choreograph_testGROUPvsControl1  
      
      
      
      
      
      
      
      """

      if stat==True :
          setup_file="{}/setup.json".format(Dict_directory["saving_directory"])
          setup=json.load(open(setup_file,"r"))

          control1_list=list()
          for key in setup.keys() :
              if (setup[key]["control_1"] in control1_list)==False:
                  control1_list.append(setup[key]["control_1"])
          if len(control1_list)!=1 :
              print("statistical_analysis set as True, but issue with setup.json : more than 1 control-1")
              return
          control_name=control1_list[0][0]

      for feature in tqdm(col_names_choreograph.keys()):

          for norm_type in Normalization_name.keys() :
              
              if col_names_choreograph[feature]["skipped"]==False :
                  
                  Dict_s_error={}
                  Dict_data={}


                  if norm_type in col_names_choreograph[feature]['normalization'] :

                    

                      for gen in genotypes :
                          if stat==True : 
                              
                              if ((gen.Genotype in setup.keys()) or (gen.Genotype==control_name) ) :
    
                                    input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",gen.Genotype)
                                    folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                                    input_file='{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
    
                                    file=open(input_file,'r')
                                    data_file=json.load(file)
                                    data_feature=list()
                                    for larva in data_file.keys() :
                                        data_feature.append(data_file[larva][feature])
    
                                    if len(data_feature) != 0 :
                                          # print("succès")
    
                                            Dict_data[str(gen.Genotype)] = data_feature
                                            Dict_s_error[str(gen.Genotype)]=[np.std( data_feature,ddof=1)/np.sqrt(len( data_feature))]
                                    else:
                                        Dict_data[str(gen.Genotype)]=[np.NaN]
                          
                          else: 
                              
                              input_folder="{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",gen.Genotype)
                              folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                              input_file='{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)

                              file=open(input_file,'r')
                              data_file=json.load(file)
                              data_feature=list()
                              for larva in data_file.keys() :
                                  data_feature.append(data_file[larva][feature])

                              if len(data_feature) != 0 :
                                    # print("succès")

                                      Dict_data[str(gen.Genotype)] = data_feature
                                      Dict_s_error[str(gen.Genotype)]=[np.std( data_feature,ddof=1)/np.sqrt(len( data_feature))]
                              else:
                                  Dict_data[str(gen.Genotype)]=[np.NaN]
                                  

                      max_length=0
                      for i in Dict_data.keys():
                          if len(Dict_data[i])>max_length :
                             max_length  = len(Dict_data[i])

                      for i in Dict_data.keys():
                          while  len(Dict_data[i])<max_length :
                              Dict_data[i].append(np.NaN)




                      if stat==True : 
                      
                    ##### Loading p-values from MannWhitney test
                          p_values=dict()
    
                          input_folder="{}/general_processed_data".format(Dict_directory["saving_directory"])
                          input_file="{}/p-value_csmh_{}s-{}s_normType{}.json".format(input_folder,windows[window][0],windows[window][1],norm_type) 
    
                          file=open(input_file,"r")
                          test_UMW=json.load(file)
    
                          for key in Dict_data.keys() :
    
                               if key=="CSMH_RAL_cont@CSMH_RAL_cont":
                                 continue
                               p_values[key]=test_UMW[key][feature][2]
    
                        ###log transformation
     
                          for key in p_values.keys() :
                            p_values[key]=-(math.log10(p_values[key]))
    
                          dict_color=dict()
                          for key in p_values.keys():
    
                            if (p_values[key] > 5 and p_values[key] < 10) :
                                dict_color[key]="#F9BFF9"
                            elif (p_values[key] > 10 and p_values[key] < 50) :
                                dict_color[key]="#FA78FA"
                            elif p_values[key] > 50 :
                                  dict_color[key]="#F728F7"
    
                        ## Th following dictionary will just be used to create a legend
                          dict_signficance_color={"0.05" : "#F9BFF9", "0.01" :"#FA78FA","0.005" : "#F728F7" }
                          df_significance_color=pd.DataFrame(dict_signficance_color,index=[0])
                          df_significance_color = pd.melt(df_significance_color, var_name='Significance', value_name='Color')
                          df_significance_color["empty"]=[0]*3



                    # for i in Dict_data.keys() :
                    #     while   len(Dict_s_error[i]) < len(Dict_data[i]) :
                    #         Dict_s_error[i].append(Dict_s_error[i][0])


                      df_se=pd.DataFrame(Dict_s_error)
                      df_se=pd.melt(df_se,var_name="Genotype",value_name="SEM")
                      df_se= df_se.sort_values(by='Genotype', ascending=True)

                      df=pd.DataFrame(Dict_data)
                      df=pd.melt(df,var_name="Genotype",value_name="Value")
                      df= df.sort_values(by='Value', ascending=True)

                      df['Genotype'] = pd.Categorical(df['Genotype'], categories=df.groupby('Genotype')['Value'].median().sort_values().index)

                      merged_df = df.merge( df_se[['Genotype', "SEM"]], on='Genotype', how='left')
                      list_p_values=list()




                      text_label=" windows : {}s_{}s \n normalizationType : {} \n feature : {}".format(windows[window][0],windows[window][1],norm_type,feature)
                      list_colours=[]
                      for i in range(len(list(Dict_data.keys()))):
                        list_colours.append("red")
                    # max_value = max(merged_df['Value'])
                    #print(merged_df)

                      plot=( ggplot(df) 

                           +labs(x='Genotypes', y='Valeur',subtitle=text_label, title="{} -  {}_{}".format(feature,windows[window][0],windows[window][1]))

                  
                    
                           +theme(

                                figure_size=(20,25),
                                axis_text_x=element_text(size=20,face="bold"),
                                axis_text_y=element_text(size=20),
                                axis_title_x=element_text(size=25,face="bold"),
                                axis_title_y=element_text(size=25,face="bold") ,
                                plot_title=element_text(size=40,face="bold",hjust=0.5)

                                )

                           + coord_flip()

                           )
                      if stat==True : 
                          plot = (plot +  geom_boxplot(aes(x="Genotype", y="Value",label="p_values",fill='Genotype'),show_legend=False)
                                   + scale_fill_manual(values=dict_color)
                                  +  geom_label(aes(x="Genotype", y="Value",label="p_values"),nudge_x=0.1,nudge_y=0.1)   
                                  )
                      else: 
                          plot = plot +  geom_boxplot(aes(x="Genotype", y="Value"),show_legend=False)
                                  
                            
                                  
                          
                    ##############



                      folder_output="{}/Boxplot_Choreograph_RAL".format(Dict_directory["saving_directory"])
                    
                      folder_ouput2="{}/normType_{}".format( folder_output,norm_type)

                      if not os.path.exists(folder_ouput2):

                        os.makedirs(folder_ouput2)

                      subfolder_window="{}/{}_{}".format(folder_ouput2,windows[window][0],windows[window][1])

                      if not os.path.exists(subfolder_window):
                         os.makedirs(subfolder_window)


                      if feature == "length/midline" :
                          plot.save("{}/ratio(length,midline).pdf".format(subfolder_window,feature))
                      else : 
                          plot.save("{}/{}.pdf".format(subfolder_window,feature))
                      





def boxplot_each_experiment(genotypes,window): 
   
    
    """This function only works for statistical_analysis==True 
    
    """
    if statistical_analysis==True : 
        setup=json.load(open("{}/setup.json".format(Dict_directory["saving_directory"]),"r"))
        
        for feature in col_names_choreograph.keys() : 
            df_data=pd.DataFrame({'Genotype' : [] , 'experiment' : [], "value" : []})
            
            for gen in genotypes : 
                
                if (gen.Genotype in setup.keys()) == False: 
                    continue 
                
                
                for experiment in gen.list_experiment : 
                        
                        date=str()
                        i=0
                        while str(experiment)[i]!="_" : 
                             date+=str(experiment)[i]
                             i+=1
                                
                        input_folder_experiment="{}/processed_data/{}/DatConcatenate_experiment/{}s_{}s".format(Dict_directory["saving_directory"],gen.Genotype,windows[window][0],windows[window][1])
                        input_file_experiment="{}/{}_DAT_concatenate.json".format( input_folder_experiment,experiment)   
                        
                        
                        dict_experiment=json.load(open(input_file_experiment,"r"))
                        
                        for larva in dict_experiment.keys() : 
                            
                                df_transit=pd.DataFrame({'Genotype' : [gen.Genotype] , 'experiment' : [date], "value" : [dict_experiment[larva][feature]]})
                                df_data=pd.concat([df_data,df_transit],ignore_index=True)
            print("plotting..")       
            
           
    
            plot2=(
             ggplot(df_data, aes(x='Genotype', y='value', fill='experiment'))
              + geom_boxplot(width=0.3, outlier_size=1 ,  position = position_dodge(width = 0.75))
              + labs(title=feature+'   -    '+"{}_{}".format(windows[window][0],windows[window][1]), x='Genotype', y=feature)
              + coord_flip()  
             
             # + annotate("segment", y=0,yend=0,x=0,xend=len( complete_Name_sorted), color="red", size=1) 
              +theme( 
                 
                  figure_size=(30,120),
                  axis_text_x=element_text(size=25,face="bold"), 
                  axis_text_y=element_text(size=20),  
                  axis_title_x=element_text(size=25,face="bold"), 
                  axis_title_y=element_text(size=25,face="bold") , 
                  plot_title=element_text(size=40,face="bold",hjust=0.5),
                  legend_position='right',  # Vous pouvez ajuster la position comme nécessaire ('top', 'right', etc.)
                  legend_direction='vertical',
                  
                  )
    )
    
          
           
            folder_output="{}/Boxplot_Choreograph_ALL_EXPERIMENT".format(Dict_directory["saving_directory"])
            folder_each_window="{}/{}_{}".format(folder_output,windows[window][0],windows[window][1])
            if not os.path.exists( folder_each_window):
    
              os.makedirs(folder_each_window)
            
   
                      
  
            if feature == "length/midline" :
                plot2.save("{}/ratio(length,midline).pdf".format(subfolder_window,feature),limitsize=False)
            else : 
                plot2.save("{}/{}.pdf".format(folder_each_window,feature),limitsize=False)
            

           
                        
                    
                
                
def boxplot_type2_control(genotypes,window) : 
    
    """This function works only when statistical_analysis is set as true, obviously"""
  
    if statistical_analysis==True : 
       
        setup=json.load(open("{}/setup.json".format(Dict_directory["saving_directory"]),"r"))
        num_control=dict_control['control_2']
       
        for feature in col_names_choreograph.keys() : 
            
            if col_names_choreograph[feature]['skipped']==False:  
            
                for norm_type in Normalization_name.keys() : 
                    
                    if norm_type in col_names_choreograph[feature]['normalization'] : 
                        
                  
                        df_data=pd.DataFrame({'Genotype' : [] , 'type' : [], "value" : []})
                        
                        for gen in genotypes : 
                            
                            if (gen.Genotype in setup.keys()) == False: 
                                continue 
                            
                            
                          
                            control_names=setup[gen.Genotype]['control_2']
                            list_object=[0]*num_control
                            for g in genotypes : 
                                if g.Genotype in control_names : 
                                    list_object[control_names.index(g.Genotype)]=g
                                    
                             
                            
                     
                            input_folder= "{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",gen.Genotype)
                            folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                            output_file = '{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
                            
                            data_group=json.load(open(output_file,"r"))
                            
                            for larva in data_group.keys() : 
                                df_transit=pd.DataFrame({'Genotype' : [gen.Genotype] , 'type' : 'test', "value" : [data_group[larva][feature]]})
                                df_data=pd.concat([df_data,df_transit],ignore_index=True)
                                
                            
                            for control in range(num_control): 
                                 if list_object[control]!=0 : 
                                
                                     input_folder= "{}/{}/{}".format(Dict_directory["saving_directory"],"processed_data",list_object[control].Genotype)
                                     folder_each_window = '{}/{}s_{}s'.format(input_folder,windows[window][0],windows[window][1])
                                     output_file = '{}/DAT_concatenate_normalized_NormType{}.json'.format(folder_each_window,norm_type)
                                     
                                     data_group=json.load(open(output_file,"r"))
                                     
                                     for larva in data_group.keys() : 
                                         df_transit=pd.DataFrame({'Genotype' : [gen.Genotype] , 'type' : "control_{}".format(control), "value" : [data_group[larva][feature]]})
                                         df_data=pd.concat([df_data,df_transit],ignore_index=True) 
                        
                        dict_colors={'test':"#CACFD2", 
                                     'control_1' : "#F1948A",
                                     'control_2' : "#7FB3D5"  }
                        ##### Change here for the colors 
                        
                        
                        plot2=(
                         ggplot(df_data, aes(x='Genotype', y='value', fill='type'))
                          + geom_boxplot(width=0.3, outlier_size=1,position = position_dodge(width = 0.5))
                          + labs(title=feature+'   -    '+"{}_{}".format(windows[window][0],windows[window][1]), x='Genotype', y=feature)
                          + coord_flip()  
                          + scale_fill_manual(values=dict_colors)
                         # + annotate("segment", y=0,yend=0,x=0,xend=len( complete_Name_sorted), color="red", size=1) 
                          +theme( 
                             
                              figure_size=(30,70),
                              axis_text_x=element_text(size=25,face="bold"), 
                              axis_text_y=element_text(size=20),  
                              axis_title_x=element_text(size=25,face="bold"), 
                              axis_title_y=element_text(size=25,face="bold") , 
                              plot_title=element_text(size=40,face="bold",hjust=0.5),
                              legend_position='right',  # Vous pouvez ajuster la position comme nécessaire ('top', 'right', etc.)
                              legend_direction='vertical',
                              
                              )
                          )
                
                        folder_output="{}/Boxplot_Choreograph_TestVsType2_control".format(Dict_directory["saving_directory"])
                        folder_each_norm="{}/{}".format( folder_output,Normalization_name[norm_type])
                        folder_each_window="{}/{}_{}".format(folder_each_norm,windows[window][0],windows[window][1])
                    
                        if not os.path.exists( folder_each_window):
             
                             os.makedirs(folder_each_window)
                             
        
                                     
                        
                        if feature == "length/midline" :
                            plot2.save("{}/ratio(length,midline).pdf".format(folder_each_window,feature),limitsize=False)
                        else : 
                            plot2.save("{}/{}.pdf".format(folder_each_window,feature),limitsize=False)
                    

           
                        
             
                


