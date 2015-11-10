% HYDRUS_Class.m
% Derek Groenendyk
% Created 5/4/2012
% Updated 11/3/2015
% Class that calls and runs HYRDUS in Matlab

classdef HYDRUS_Class
    properties
        expFileLocation;
        fileExtList = {'.OUT' '.IN' '.TXT' '.DAT'};
    end
      
    methods
        function hydrus = HYDRUS_Class(directory)
            hydrus.expFileLocation = directory;
        end
        function run_hydrus(hydrus,noCMDWindow)
            selectIN = SELECTORIN(hydrus.expFileLocation);
            if noCMDWindow == 1
                selectIN.setData('lEnter','f');
                selectIN.update()
                command = ['h1d_calc.exe ' hydrus.expFileLocation '> NUL 2>&1'];
                system(command);                
            else
                selectIN.setData('lEnter','t');
                selectIN.update()
                command = ['h1d_calc.exe ' hydrus.expFileLocation ];
                [status,result] = system(command,'-echo');
            end
        end
        
        function outputResults(hydrus,folder,trial)
            if nargin < 2
                trial =  '1';
            end
            root = pwd;
            cd(hydrus.expFileLocation)
            listing = dir(pwd);
            cd(root)
                
            for ii=1:length(listing)-2
                [pathstr, name, ext] = fileparts(listing(ii+2).name);
                temp = cell2mat(strfind(hydrus.fileExtList,upper(ext)));
                
                if length(temp==1) > 0
                    INFILES{ii} = listing(ii+2).name;
                end
            end
            ind = strfind(hydrus.expFileLocation,'\');
            resultsDir = [hydrus.expFileLocation(1:ind(end-1)) 'Results\' folder '\Trial= ' trial];
            
            if exist(resultsDir,'dir') == 0
                mkdir(resultsDir)
            end
               
%         Will automatically overwrite files
            for i=1:length(INFILES)
                srcDir = [hydrus.expFileLocation '\' char(INFILES(i))];
%                 untested: code to prevent overwrite
%                if exist(srcDir,'file') > 0 
%                    ['File ' char(INFILES(i)) ' Overwritten']
%                end
                desDir = [resultsDir];
                copyfile(srcDir,desDir);
            end
        end %outputResults
        
    end %methods
end %HYDRUS_Class
