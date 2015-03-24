function [ paramStart,params,spaces ] = readLine( string )

    spaceLen = 0;
    paramLen = 0;
    paramStart = [];
    spaces = [];
    params = [];
    
    string = string{1};
    
    for i=1:length(string)
       if i == length(string)
           if strcmp(string(i),' ')
               if ~strcmp(string(i-1),' ')
                    params(end+1) = paramLen;
                    spaces(end+1) = spaceLen;
               end
               spaces(end+1) = (length(string)-(paramStart(end)+params(end) - 1));
           else
               if paramLen > 0
                   paramLen = paramLen + 1;
                   params(end+1) = paramLen;
                   spaces(end+1) = spaceLen;  %might not need, DGG 1/29/2015
               else
                   spaces(end+1) = spaceLen;
                   paramStart(end+1) = i;
                   params(end+1) = 1;
               end
           end
       else
           if strcmp(string(i),' ')
               spaceLen = spaceLen + 1;
           else
               paramLen = paramLen + 1;
               if i == 1
                   paramStart(end+1) = i;
               elseif ~strcmp(string(i-1),' ')
                   paramStart(end+1) = i;
               elseif strcmp(string(i-1),' ')
                   paramStart(end+1) = i;
               end
               if i+1 < length(string) - 1
                   if strcmp(string(i+1),' ')
                       spaces(end+1) = spaceLen;
                       spaceLen = 0;
                       params(end+1) = paramLen;
                       paramLen = 0;
                   end
               end
           end
       end
    end
end
