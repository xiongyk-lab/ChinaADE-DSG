import pandas as pd
import numpy as np
import joblib

'''********************************************************************************************************************************************''' 
# Predicting model
def Predicting(data,Mdinf):
    Y_Pre = data[Tylabel]
    X_Pre = data[Tfeatures]
    # Random Forest 
    ResultRFp = best_model_rfTotal.predict(X_Pre)
    ResultRFp = pd.DataFrame(ResultRFp, columns=['Predicted total electricity generation'])
    ResultRF = pd.concat([data[Mdinf].reset_index(drop=True),Y_Pre.reset_index(drop=True),ResultRFp.reset_index(drop=True)],axis=1, ignore_index=True)
    # Gradient Boosting
    ResultGBp = best_model_gbboostTotal.predict(X_Pre)
    ResultGBp = pd.DataFrame(ResultGBp, columns=['Predicted total electricity generation'])
    ResultGB = pd.concat([data[Mdinf].reset_index(drop=True),Y_Pre.reset_index(drop=True),ResultGBp.reset_index(drop=True)],axis=1, ignore_index=True)
    # XGBoost
    ResultXGp = best_model_xgboostTotal.predict(X_Pre)
    ResultXGp = pd.DataFrame(ResultXGp, columns=['Predicted total electricity generation'])
    ResultXG = pd.concat([data[Mdinf].reset_index(drop=True),Y_Pre.reset_index(drop=True),ResultXGp.reset_index(drop=True)],axis=1, ignore_index=True)
    # CatBoost
    ResultCATp = best_model_catboostTotal.predict(X_Pre)
    ResultCATp = pd.DataFrame(ResultCATp, columns=['Predicted total electricity generation'])
    ResultCAT = pd.concat([data[Mdinf].reset_index(drop=True),Y_Pre.reset_index(drop=True),ResultCATp.reset_index(drop=True)],axis=1, ignore_index=True)
    # Integrated result
    Integrated = np.zeros((70,6))
    Integrated[:,0:5] = ResultRF.to_numpy()[:,0:5]
    data = {
    'ResultRF': ResultRF.to_numpy()[:,5],
    'ResultGB': ResultGB.to_numpy()[:,5],
    'ResultXG': ResultXG.to_numpy()[:,5],
    'ResultCAT': ResultCAT.to_numpy()[:,5]
    }
    df = pd.DataFrame(data)
    Integrated[:,5] = df.mean(axis=1)
    Integrated = pd.DataFrame(Integrated, columns= Mdinf + ['Total electricity generation','Predicted']) 
    return Integrated

'''********************************************************************************************************************************************''' 
################# Loading model and data
best_model_rfTotal = joblib.load('input/best_model_rfTotal.pkl')
best_model_gbboostTotal = joblib.load('input/best_model_gbboostTotal.pkl')
best_model_xgboostTotal = joblib.load('input/best_model_xgboostTotal.pkl')
best_model_catboostTotal = joblib.load('input/best_model_catboostTotal.pkl')
Eledata2050 = pd.read_csv('input/Eledata2050.csv'); 
Mdinf = ['ModelID','ScenarioID','Temperature','Year']
Tylabel = ['Total electricity generation']
Tfeatures = ['Coal capacity','Gas capacity','Oil capacity','Solar capacity','Wind capacity','Nuclear capacity','Hydro capacity','Biomass capacity',
    'Electricity trade','Storage capacity', #'Carbon emissions',
    'Carbon sequestration','Afforestation',
    'GDP','Population','Water consumption',
    'Investments in EST','Investments in ETD']

'''********************************************************************************************************************************************''' 
###### Predicting
## Residual from filled data
IntResidual = Predicting(Eledata2050,Mdinf)
IntResidual['Residual'] =  IntResidual['Total electricity generation'] -  IntResidual['Predicted'];

######### The demand of electricity supply in 2050 due to AI development (Pwh)
TrsF = 0.27777777777778
meanEd = 21.2261/TrsF
# Utilization rate in 2025 and 2050
IAMWindtk = pd.read_csv('input/IAMWindtk.csv')
IAMWindtk_sorted = IAMWindtk.sort_values(by=['ModelID','ScenarioID'])
IAMSolartk = pd.read_csv('input/IAMSolartk.csv')
IAMSolartk_sorted = IAMSolartk.sort_values(by=['ModelID','ScenarioID'])
IAMBiomasstk = pd.read_csv('input/IAMBiomasstk.csv')
IAMBiomasstk_sorted = IAMBiomasstk.sort_values(by=['ModelID','ScenarioID'])
NBioEneCap = pd.read_csv('input/NBioEneCap.csv')
NBioEneCap_sorted = NBioEneCap.sort_values(by=['ModelID','ScenarioID'])
NStorageCap = pd.read_csv('input/NStorageCap.csv')
NStorageCap_sorted = NStorageCap.sort_values(by=['ModelID','ScenarioID'])
######### Reference data
Hydrofspace = pd.read_csv('input/Hydrofspace.csv')
######### Capacity (GW)
# 79464; 45604; 113210
PVpt = 45604
Windpt = 10948
######### Strategies
for sTra in range(2,3):            
    # Mixed strategies
    data = {
    'ModellD': Eledata2050.copy().reset_index(drop=True).to_numpy()[:,0],
    'ScenariolD': Eledata2050.copy().reset_index(drop=True).to_numpy()[:,1],
    'Temperature': Eledata2050.copy().reset_index(drop=True).to_numpy()[:,2],
    'Year': Eledata2050.copy().reset_index(drop=True).to_numpy()[:,3],
    'Total electricity generation': Eledata2050.copy().reset_index(drop=True).to_numpy()[:,4],       
    } 
    # Probability 50%
    Mixedcap50 = np.zeros((1,7))
    Strategy50 = pd.DataFrame(data.copy())
    Casedata50 = pd.DataFrame(data.copy())
    count50 = 0
    # Probability 67%
    Mixedcap67 = np.zeros((1,7))               
    Strategy67 = pd.DataFrame(data.copy())
    Casedata67 = pd.DataFrame(data.copy())
    count67 = 0
    # 5, 8, 10, 10
    for wt in np.arange(1.0, 5.1, 0.1):
        for st in np.arange(1.0, 5.1, 0.1):
            for bt in np.arange(1.0, 5.1, 0.1):
                for es in np.arange(1.0, 5.1, 0.1):                        
                    subEledata = Eledata2050.copy().reset_index(drop=True)
                    # Wind
                    wsubEledata = subEledata['Wind capacity'].copy()
                    rtwind = wsubEledata*wt
                    lmwind = IAMWindtk_sorted['maxUR']*Windpt
                    dfwind = pd.DataFrame({'col1': rtwind, 'col2': lmwind})
                    subEledata['Wind capacity'] = dfwind[['col1', 'col2']].min(axis=1)                    
                    # Solar
                    ssubEledata = subEledata['Solar capacity'].copy()
                    rtsolar = ssubEledata*st
                    lmsolar = IAMSolartk_sorted['maxUR']*PVpt                   
                    dfsolar = pd.DataFrame({'col1': rtsolar, 'col2': lmsolar})
                    subEledata['Solar capacity'] = dfsolar[['col1', 'col2']].min(axis=1)                    
                    # Biomass
                    bsubEledata = subEledata['Biomass capacity'].copy()
                    rtbiomass = bsubEledata*bt
                    lmbiomass = NBioEneCap_sorted['Y50']                    
                    dfbiomass = pd.DataFrame({'col1': rtbiomass, 'col2': lmbiomass})
                    subEledata['Biomass capacity'] = dfbiomass[['col1', 'col2']].min(axis=1) 
                    # Eletricity Storage
                    esubEledata = subEledata['Storage capacity'].copy()
                    rtstorage = esubEledata*es
                    lmstorage = NStorageCap_sorted['Y50']                    
                    dfstorage = pd.DataFrame({'col1': rtstorage, 'col2': lmstorage})
                    subEledata['Storage capacity'] = dfstorage[['col1', 'col2']].min(axis=1)                         
                    # Predicting
                    subCase = Predicting(subEledata,Mdinf)    
                    subCase['Predicted'] = subCase['Predicted'] + IntResidual['Residual']                        
                    # Pathways rules (67% probability & median value > AI electricity mean demand)
                    mdcase = np.median(subCase['Predicted'])
                    prob = np.sum(subCase['Predicted']>meanEd)/len(Eledata2050)
                    print("Inforamtion: ",wt,st,bt,es)                        
                    # Probability (50%)
                    if prob >= 0.50 and prob < 0.67 and  mdcase > meanEd:
                        # Predicted value
                        Casedata50['Predicted'+str(count50)] = subCase['Predicted']                       
                        # Capacity
                        Strategy50['Wind'+str(count50)] = dfwind[['col1', 'col2']].min(axis=1)
                        Strategy50['Solar'+str(count50)] = dfsolar[['col1', 'col2']].min(axis=1)
                        Strategy50['Biomass'+str(count50)] = dfbiomass[['col1', 'col2']].min(axis=1)  
                        Strategy50['Storage'+str(count50)] = dfstorage[['col1', 'col2']].min(axis=1)                                             
                        # Parameters                       
                        Mixedcap50[count50,0] = count50
                        Mixedcap50[count50,1] = wt
                        Mixedcap50[count50,2] = st
                        Mixedcap50[count50,3] = bt
                        Mixedcap50[count50,4] = es
                        Mixedcap50[count50,5] = prob
                        Mixedcap50[count50,6] = mdcase
                        count50 = count50 + 1
                        Mixedcap50 = np.vstack((Mixedcap50, np.zeros((1, 7))))
                        print("Case50",count50)  
                        break                        
                    # Probability (67%)
                    if prob >= 0.67 and  mdcase > meanEd:
                        # Predicted value
                        Casedata67['Predicted'+str(count67)] = subCase['Predicted']                       
                        # Capacity
                        Strategy67['Wind'+str(count67)] = dfwind[['col1', 'col2']].min(axis=1)
                        Strategy67['Solar'+str(count67)] = dfsolar[['col1', 'col2']].min(axis=1)
                        Strategy67['Biomass'+str(count67)] = dfbiomass[['col1', 'col2']].min(axis=1)  
                        Strategy67['Storage'+str(count67)] = dfstorage[['col1', 'col2']].min(axis=1)                                             
                        # Parameters                       
                        Mixedcap67[count67,0] = count67
                        Mixedcap67[count67,1] = wt
                        Mixedcap67[count67,2] = st
                        Mixedcap67[count67,3] = bt
                        Mixedcap67[count67,4] = es
                        Mixedcap67[count67,5] = prob
                        Mixedcap67[count67,6] = mdcase
                        count67 = count67 + 1
                        Mixedcap67 = np.vstack((Mixedcap67, np.zeros((1, 7))))
                        print("Case67",count67)  
                        break

        
