def find_nearest(array, value):
    import numpy as np
    array = np.asarray(array)
    idx = (np.abs(array - value)).argmin()
    return idx

def concatenate(input,output,protocol,paths,features):
    import time
    import glob
    import h5py
    import pickle
    import os
    import numpy as np
    import sys

    # for each genotype of RAL lines
    for path in paths:
        # time each iteration
        startTime = time.time()
        # find all trx files for each genotype
        trx_files = glob.glob("{}/{}/{}/**/trx.mat".format(input,path,protocol), recursive = True)

        if len(trx_files) == 0:
            print(" No trx files found for genotype {}".format(path))
            sys.exit()
        else:
            print(" {} trx files found for genotype {}".format(len(trx_files), path))

        # instantiate empty list as new concatenated trx
        trx = []
        print(" Concatenating trx files ... ")
        
        # open trx files for each genotype
        for trx_file in trx_files:

            # if files are already concatenated, skip
            output_file_path = "{}/{}.pkl".format(output,path)
            if os.path.exists(output_file_path) == True:
                print(" Concatenated trx file already exists, skipping genotype {}".format(path))
                continue
            # if files are not concatenated, open trx
            f = h5py.File(trx_file,'r')
            each_trx = f.get('trx')

            for i in range(len(each_trx[features[0]][0])): # for each larva of each trx file
                value = [] # instantiate empty vector
                for feature in features: # then for each feature
                    value.append(np.array(f[each_trx[feature][0][i]]))
                # features appended to each row, transpose to get dim 1 larva x n_features
                value = np.array(value)
                value = np.transpose(value,(1,0,2))
                # append features from each larva into row
                trx.append(value)

        # dump appended trx to a pickle file
        with open(output_file_path,'wb') as fi:
            pickle.dump(trx,fi)
        endTime = time.time()
        runTime = endTime - startTime
        print(" Concatenated trx saved, runtime {} seconds ".format(runTime))


def probability(input,output,paths,features):
    import pickle
    import itertools
    import time
    from time import sleep
    import pandas as pd
    import numpy as np
    from tqdm import tqdm

    for path in paths:
        # open concatenated trx
        # time each iteration
        startTime = time.time()
        print(' Processing genotype {}'.format(path))
        with open('{}/{}.pkl'.format(input,path),'rb') as pickle_trx:
            trx = pickle.load(pickle_trx)

            # get all the timestamps from the trx
            t = [trx[i][0][0] for i in range(len(trx))]
            # remove any duplicate value and sort in ascending order
            t = list(itertools.chain(*t))
            t = sorted(set(t))
            # keep number of larvae tracked 
            n_larvae = [0]*len(t)
            # start a dataframe to store result
            proba = np.zeros((len(t),(len(features))))

            # FOR LOOP STARTS HERE
            for i in tqdm(range(len(trx))):
                # progress bar
                sleep(3)
                # retrieve data for each larva
                data = trx[i][0]
                data = np.array(data).T

                # for each time point of tracked larva
                for s in range(len(data)):

                    # find the corresponding index in the proba dataframe
                    temp = t == data[s][0]
                    timestamp = int(np.where(temp)[0])

                    # the larva is tracked at this time, increment by 1
                    n_larvae[timestamp] = n_larvae[timestamp]+1
                    # add the values
                    proba[timestamp][1:] += data[s][1:].clip(min=0)

        raw = pd.DataFrame(proba,index=t,columns =features)
        output_file = "{}/{}_freq.csv".format(output,path)
        raw.to_csv(output_file)

        n_all = pd.Series(n_larvae,index=t)
        output_file = "{}/{}_n.csv".format(output,path)
        n_all.to_csv(output_file)

        proba = np.array(proba)
        for j in range(len(features)):
            if j == 0: # skip the t vector
                continue
            proba[:][j] = proba[:][j]/n_larvae
            # normalize by the number of larvae tracked at that time

        prob = pd.DataFrame(proba,index=t,columns =features)
        output_file = "{}/{}_prob.csv".format(output,path)
        prob.to_csv(output_file)

        # clear variables before moving on to the next path
        del trx, t, n_larvae, proba, data, raw, prob, n_all

        # save proba file as pd.dataframe
        endTime = time.time()
        runTime = endTime - startTime
        print(" Probability file saved, runtime {} seconds ".format(runTime))

def visualize(input,protocol,root,genotypes,output,neuron,colors,line_smooth):
    import glob
    import scipy.io
    import numpy as np
    import os
    from itertools import combinations
    import scipy.stats as stats
    import matplotlib.pyplot as plt
    from matplotlib.patches import Rectangle

    plt.rcParams['font.sans-serif'] = "Arial"
    # Then, "ALWAYS use sans-serif fonts"
    plt.rcParams['font.family'] = "sans-serif"

    actions = [
        'run',
        'cast',
        'stop',
        'hunch',
        'backup',
        'bend_static'
    ]

    windows = [
        #'window15s_55s',
        'window60s_61s',
        'window60s_62s',
        'window60s_70s',
        'window60s_80s',
        'window60s_90s',
    ]

    output_line_plots = '{}/line_plots/{}'.format(output,neuron)
    output_bar_plots = '{}/bar_plots/{}'.format(output,neuron)

    lst = [output,output_line_plots,output_bar_plots]
    for item in lst:
        if not os.path.exists(item):
            os.makedirs(item)

    genotypes_to_plot = []
    t = []
    n_larvae = []

    for genotype in genotypes:

        file = "{}/{}/{}/{}/probabilitiesovertime.mat".format(input,genotype,protocol,root)
        prob = scipy.io.loadmat(file,squeeze_me = True)
        prob = prob['probabilities']
        actions_to_plot = []

        for a,action in enumerate(actions):
            data = prob[action].item()
            data = np.transpose(data)
            t = data[0]
            n = max(data[2])
            probability = data[1]
            actions_to_plot.append(probability)
        
        actions_to_plot = np.array(actions_to_plot)
        genotypes_to_plot.append(actions_to_plot)
        n_larvae.append(n)

    genotypes_to_plot = np.array(genotypes_to_plot)

    fig,axs = plt.subplots(3,2, figsize=(11,8), dpi=300)
    axs = axs.flatten()
    for i,action in enumerate(actions):
        for j,__ in enumerate(genotypes):
            y = genotypes_to_plot[j][i].tolist()
            if line_smooth == True:
                kernel_size = 10
                kernel = np.ones(kernel_size) / kernel_size
                y = np.convolve(y, kernel, mode='same')
            axs[i].plot(t,y, colors[j],linewidth = 3)
            axs[i].set_title(action)
            axs[i].set_xlabel('Seconds (s)')
            axs[i].set_ylabel('Probability')
            axs[i].set_xlim([40,120])
            axs[3].set_xlim([59,62])

            x_left, x_right = axs[i].get_xlim()
            y_low, y_high = axs[i].get_ylim()       
            axs[i].set_aspect(abs((x_right-x_left)/(y_low-y_high))*0.5)
            axs[i].spines.right.set_visible(False)
            axs[i].spines.top.set_visible(False)

            axs[i].add_patch(Rectangle((60, 0), 30, y_high,facecolor = '#eeeeee',fill=True))
    plt.tight_layout()
    txt = "Number of animals in experiments:\n{}\n{}".format(genotypes,n_larvae)
    plt.figtext(0.5, -0.07, txt, wrap=True, horizontalalignment='center', fontsize=12)
    if line_smooth == True:
        plt.savefig('{}/{}_lineplot_smoothed.svg'.format(output_line_plots,genotypes), format='svg',bbox_inches="tight")
        plt.savefig('{}/{}_lineplot_smoothed.pdf'.format(output_line_plots,genotypes), format='pdf',bbox_inches='tight')
    plt.savefig('{}/{}_lineplot.svg'.format(output_line_plots,genotypes), format='svg',bbox_inches="tight")
    plt.savefig('{}/{}_lineplot.pdf'.format(output_line_plots,genotypes), format='pdf',bbox_inches='tight')


    # bar plot visualization & statistical test
    for window in windows:

        path = output_bar_plots+'/{}'.format(window)
        if not os.path.exists(path):
            os.makedirs(path)
        
        # for each window, loop through genotypes
        genotypes_to_plot = []
        n_larvae = []
        for genotype in genotypes:
            file = "{}/{}/{}/{}/cumulativeProbabilities.mat".format(input,genotype,protocol,root)
            cumProb = scipy.io.loadmat(file,squeeze_me = True)
            cumProb = cumProb['cumulativeProbabilities']
            actions_to_plot = []

            for a,action in enumerate(actions):
                
                if action == 'cast':
                    data = (cumProb[window].item()[action].item()['proba'].item() - cumProb[window].item()[action].item()['probacontrol'].item()
                    + cumProb[window].item()['bend_static'].item()['proba'].item())
                elif action == 'bend_static':
                    data = 0
                else:
                    data = cumProb[window].item()[action].item()['proba'].item() 
                actions_to_plot.append(data)
                n = cumProb[window].item()[action].item()['numberoflarvae'].item()
            
            actions_to_plot = np.array(actions_to_plot)
            genotypes_to_plot.append(actions_to_plot)
            n_larvae.append(n)

        genotypes_to_plot = np.transpose(np.array(genotypes_to_plot))

        combos = list(combinations(range(len(genotypes)), 2))
        result = []

        for a, action in enumerate(actions):
            result=[]
            for i,__ in enumerate(combos):
                group1 = genotypes[combos[i][0]]
                group2 = genotypes[combos[i][1]]

                observation = np.array([
                    [genotypes_to_plot[a][combos[i][0]]*n_larvae[combos[i][0]],genotypes_to_plot[a][combos[i][1]]*n_larvae[combos[i][1]]],
                    [n_larvae[combos[i][0]],n_larvae[combos[i][1]]]
                ])
                try:
                    test = stats.chi2_contingency(observation)
                    statistic = test[0]
                    pvalue = test[1]
                    padj = pvalue*len(combos)
                    result.append([group1,group2,statistic,pvalue,padj])
                except:
                    result.append(['NA','NA','NA','NA','NA'])
            # Not sure if you want to increase counti here
            # if so add the line here
                    continue 

            with open('{}/chisquare_{}.txt'.format(path,action), 'w') as fp:
                for item in result:
                    # write each item on a new line
                    fp.write('%s\n' % ['group1','group2','statistic','pvalue','padjusted'])
                    fp.write('%s\n' % item)
        
        action_names_plot = ['Crawl','Bend','Stop','Hunch','Backup','N/A']
        fig,axs = plt.subplots(1,len(actions), figsize=(10,2), dpi=300)
        axs = axs.flatten()
        for i,action in enumerate(actions):
            y = genotypes_to_plot[i]
            
            axs[i].bar(np.arange(len(genotypes)),genotypes_to_plot[i],color=colors)
            axs[i].set_title(action_names_plot[i])
            axs[i].set_ylabel('Cumulative Probability')
            axs[i].set_ylim([0,1])

            x_left, x_right = axs[i].get_xlim()
            y_low, y_high = axs[i].get_ylim()       
            axs[i].set_aspect(abs((x_right-x_left)/(y_low-y_high))*2)
            axs[i].spines.right.set_visible(False)
            axs[i].spines.top.set_visible(False)
            axs[i].xaxis.set_tick_params(labelbottom=False, bottom=False)

        plt.tight_layout()
        fig.suptitle(window)
        plt.savefig('{}/{}.svg'.format(path,genotypes), format='svg',bbox_inches="tight")
        plt.savefig('{}/{}.eps'.format(path,genotypes), format='eps',bbox_inches='tight')

def ethogram(input,root,genotypes,protocol,output):
    import glob
    import scipy.io
    import numpy as np
    import os
    import matplotlib.pyplot as plt
    from matplotlib.colors import ListedColormap
    import seaborn as sns
    import pandas as pd

    for genotype in genotypes:
        file = "{}/{}/{}/{}/trx_concatenated.mat".format(input,genotype,protocol,root)
        data = scipy.io.loadmat(file,squeeze_me = True)
        # extract data
        ts = data['TRX']['t'] # time
        actions = data['TRX']['global_state_large_state'] # numbered state

        # small function to find index of nearest given value of an array
        def find_nearest(array, value):     
            array = np.asarray(array)    
            idx = (np.abs(array - value)).argmin()     
            return idx

        # instantiate time vector
        t = np.linspace(50,110,num = 600)
        y = []
        for i in range(len(ts)): # for each larva tracked
            dy = []
            # if the larva is tracked for more than 110s starting from 30s to 120s, 
            # and if sampling rate of data is more than 2Hz, keep the data for this larva
            if (min(ts[i])<40) & (max(ts[i])>110) & (ts[i][1]-ts[i][0]<0.5):
                for dt in t:
                    # find the time point closest to linspace
                    index = find_nearest(ts[i],dt)
                    # append action at that time 
                    dy.append(actions[i][index])
                # append action vector of that larva
                y.append(dy)
        # convert to n x t array, n = number of larvae, t = time vector
        y = np.array(y)
        df = pd.DataFrame(y,columns = t)

        # sort columns by action performed at the 61st second for best visualization of hunch
        df = df.sort_values(by = df.columns[find_nearest(df.columns,60.5)])

        # visualize
        plt.rcParams['font.sans-serif'] = "Arial"
        # Then, "ALWAYS use sans-serif fonts"
        plt.rcParams['font.family'] = "sans-serif"

        fig,ax = plt.subplots(1,1,figsize = (8,6))
        colors = ListedColormap(['black','orangered','yellowgreen','blue','gray','gray','deepskyblue'])
        ax = sns.heatmap(df,cmap = colors)
        ax.set(xticklabels=[])
        ax.set(yticklabels=[])
        ax.tick_params(bottom=False,left=False)
        ax.set(title='{}, n={}, 50-110s'.format(genotype,len(df)))
        plt.savefig('{}/ethograms/{}.png'.format(output,genotype), format='png',bbox_inches='tight')