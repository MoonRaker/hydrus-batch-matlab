% PROFILEDAT.m
% Created by Derek Groenendyk
% 1/27/2015
% This a class that accesses the ATMOSPH.IN file

classdef PROFILEDAT < handle
    properties
        expFileLocation
        fid
        C
    end
      
    methods        
        function profile = PROFILEDAT(directory)
            profile.expFileLocation = directory;
            profile.fid = fopen([profile.expFileLocation,'\PROFILE.DAT'],'r+');
            profile.C = textscan(profile.fid, '%s', 'delimiter', '','whitespace', '');
            profile.C = profile.C{1};
            fclose(profile.fid);
        end
       
        function setData(profile,param,paramValue)
            if strcmp(param,'numLayers')
                row = 5;
                column = 1;                
                sLine = textscan(profile.C{row}, '%s','whitespace','');
                wline = writeLine(sLine{1},column,num2str(paramValue));
                profile.C{row} = wline;
            elseif strcmp(param,'columnLength')
                row = 4;
                column = 2;
                sData = sprintf('%e', paramValue);
                [A,B,C] = strread(sData,'%8.7f %2s  %03d');
                paramValue = sprintf('-%fe+%03d',A,C);
                sLine = textscan(profile.C{row}, '%s','whitespace','');
                wline = writeLine(sLine{1},column,num2str(paramValue));
                profile.C{row} = wline;
            elseif strcmp(param,'numObs')
                sLine = textscan(profile.C{5}, '%s');                        
                numLayers = sLine{1}{1};
                sLine = textscan(profile.C{end}, '%s');
                if strcmp(sLine{1}{1},numLayers)
                    profile.C = [profile.C(1:end) ; '0';sprintf('% 5d',0)];
                end
                sLine = textscan(profile.C{end-1}, '%s','whitespace','');
                wline = writeLine(sLine{1},1,num2str(paramValue));
                profile.C{end-1} = wline;
            elseif strcmp(param,'obsLoc')               
                wline = '';
                for ii=1:length(paramValue)
                    wline = strcat(wline,sprintf('% 5d',paramValue(ii)));
                end
                profile.C{end} = wline;
            elseif ischar(param)
                sLine = textscan(profile.C{5}, '%s');
                ind = find(strcmp(sLine{1},param)==1)-3;             
                numLayers = sLine{1}{1};
                sLine = textscan(profile.C{end-1}, '%s','whitespace','');
                if length(sLine{1}) < 7
                    numLayers = numLayers + 2;
                end
                if numLayers > length(paramValue)
                    profile.C = [profile.C(1:5+length(paramValue)); profile.C(end)];
                elseif numLayers < length(paramValue)
                    sLine = textscan(profile.C{6}, '%s','whitespace','');
                    newCells = repmat(sLine{1},[length(paramValue) 1]);
                    profile.C = [profile.C(1:5); newCells ;profile.C(6+length(paramValue):end)];
                end
                for jj=6:5+length(paramValue)
                    sLine = textscan(profile.C{jj}, '%s','whitespace','');
                    wline = writeLine(sLine{1},1,sprintf('%d',jj-5),[]);
                    profile.C{jj} = wline;                
                end
                
                [paramValue,exps] = profile.readExp(paramValue);
                if ~isempty(ind)
                    kk = 0;
                    for jj=6:5+length(paramValue)
                        kk = kk + 1;
                        sLine = textscan(profile.C{jj}, '%s','whitespace','');
                        if ind < 3
                            val = sprintf('-%fe+%03d',paramValue(jj-5),exps(jj-5));
                        else
                            val = sprintf('%fe%04d',paramValue(jj-5),exps(jj-5));
                        end                            
                        wline = writeLine(sLine{1},ind,val);
                        profile.C{jj} = wline;
                    end
                end
            end
        end
        
        function [A,B] = readExp(profile,data)
            sData = sprintf('%e,',data);
            str1 = sprintf('%%%d.%df',8,6);
            results = textscan(sData,strcat(str1,' %2s  %03d'),'delimiter',',');
            A = results{1};
            B = results{3};
        end
            
        function update(profile)
            profile.fid = fopen([profile.expFileLocation,'\PROFILE.DAT'],'w');
            frewind(profile.fid)
            for i=1:length(profile.C)
                wline = profile.C{i};
                fprintf(profile.fid,'%s\n',wline);
            end
            fclose(profile.fid);
            
            profile.fid = fopen([profile.expFileLocation,'\PROFILE.DAT'],'r');
            profile.C = textscan(profile.fid, '%s', 'delimiter', '','whitespace', '');
            profile.C = profile.C{1};
            fclose(profile.fid);
            
        end % writeData   
    end % methods
end % classdef


        
        
        