% HYDRUS_main.m
% Created by Derek Groenendyk
% 5/4/2012
% Class that calls and runs HYRDUS in Matlab

clear all;
clc;

noCMDWindow = 1; % set to 1 to NOT have to press enter after each simulation
        
exp = 'Test'; % directory main name
% exp = 'Cyclic'; % directory main name
mainDirectory = 'C:\Temp\HYDRUS_Data\';
expDirectory = [mainDirectory 'Projects\' exp];

Hydrus = HYDRUS_Class(expDirectory);

% order of the soils included in usdaSoils
% sand, loamy sand, sandy loam,	loam, silt,	silt loam, sandy clay loam, clay loam,
% silty clay loam, sandy clay loam,	silty clay,	clay
usdaSoils = csvread('USDARosettaSoils.csv'); % all of the van Genuchten soils for the 12 main soil types

paramValues=usdaSoils;
paramList = {'thr','ths','Alfa','n','Ks'};


% list of variable properties with min and max values
topflux=[0 5];
topperiod=[1 30];
soiltype=[1 12];
numprinttimes=14;
endtime=140;
infiltcycles=3;
topBCtimes=(1:2*infiltcycles)*endtime/infiltcycles/2
rsoilhold=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
Prechold=[1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];
% number of realizations to run
numrealizs=1;

    
for ii=1:numrealizs
    % later apply Latin hypercube sampling here
    topfluxval=rand(1)*(max(topflux)-min(topflux))+min(topflux);
    topperiodval=rand(1)*(max(topperiod)-min(topperiod))+min(topperiod);
    soiltypeval=floor(0.5+rand(1)*(max(soiltype)-min(soiltype))+min(soiltype));

    topfluxval=1;
    topperiodval=1;
    soiltypeval=4;

%   create ATMOSPH.IN object
    atmosphIN = ATMOSPHIN(expDirectory);    
    atmosphIN.setData('Prec',[topfluxval]);
%   commits/writes changes to the file (overwrites previous file)
    atmosphIN.setData('tAtm',topBCtimes)
    atmosphIN.setData('Prec',-Prechold(1:infiltcycles*2))
    atmosphIN.setData('rSoil',rsoilhold(1:infiltcycles*2))
    atmosphIN.setData('hCritA',rsoilhold(1:infiltcycles*2)*100000)
    atmosphIN.setData('MaxAL',infiltcycles*2)
    atmosphIN.update()        


%   set soil parameters
    selectIN = SELECTORIN(expDirectory);
    for j=1:length(paramList)
        if j == 5
            paramValue = roundn(paramValues(soiltypeval,j),-2); 
        elseif j == 3
            paramValue = roundn(paramValues(soiltypeval,j),-4);
        else
            paramValue = roundn(paramValues(soiltypeval,j),-4);
        end
        selectIN.setData(paramList(j),paramValue,1) % last arg selects material
    end
%   set other selector.in parameters
    selectIN.setData('TPrint(1),TPrint(2),...,TPrint(MPL)',[endtime/numprinttimes:endtime/numprinttimes:endtime])
    selectIN.setData('MPL',numprinttimes)
%   commits/writes changes to the file (overwrites previous file)
    selectIN.update();        

    Hydrus.run_hydrus(noCMDWindow)
    Hydrus.outputResults(exp,num2str(ii))

    % compile results - for now, just water content
    nodinf = NODINF(expDirectory);
    data = nodinf.getAllData();
    qvals(ii,:,:)=data(:,:,5);

    holdtopfluxval(ii)=topfluxval;
    holdtopperiodval(ii)=topperiodval;
    holdsoiltypeval(ii)=soiltypeval;

end;

for ii=1:numrealizs
    toplotz=-1:-1:-size(qvals,3);    
    toplotq=squeeze(qvals(ii,:,:));
    plot(toplotq,toplotz);
    hold on;
end;

% extra lines after here


% atmosphIN.setData('SinusVar','t')
% 
% % create PROFILE.DAT object
% profileDAT = PROFILEDAT(expDirectory);
% 
% % values used for setting parameters
% columnLength = 100; % row 4, 2
% numLayers = 101; % row 5, 1
% layerThickness = 1;
% matArray = []; % column 4
% layerArray = []; % column 5
% beta = 0.000000; % column 6
% xz = 1.00000; % column 7, 8, 9
% 
% % set PROFILE.DAT parameters
% profileDAT.setData('columnLength',columnLength)
% profileDAT.setData('numLayers',numLayers) 
% profileDAT.setData('x',0:1:101)
% profileDAT.setData('h',ones([101,1])*-10.0)
% profileDAT.setData('numObs',7)
% profileDAT.setData('obsLoc',[10,35,77])
% 
% % commits/writes changes to the file (overwrites previous file)        
% profileDAT.update()





