function [gpsobs,gpsepo] = readRnx(filename)
% ------------------------------------------------------------------------
% [gpsobs,gpsepo,satlist,gpsweek,marker,antenna,receiver,xyz,dneu] = readrnx (filename);
%
% Purpose: Read GNSS RINEX 2.10 Observation File
%
% Input:   filname        - GNSS RINEX observation file name
% Output:  gpsobs(i,j,k)  - observations (see remark)
%          gpsepo(i)      - observation epochs (seconds of GPS week)
%          satlist(j)     - list of satellites
%          gpsweek        - GPS week for first observation
%          marker         - marker name
%          antenna        - antenna type
%          receiver       - receiver type
%          xyz            - approximative position (m)
%          dneu           - antenna eccentricity
%
% Remarks: Indices:
%          i=1,...,maxepo   epoch index
%                           default: maxepo=2880, sampling = 30 sec
%                           The observations read by the function thus
%                           cover an entire day in 30 sec intervals.
%
%          j=1,...,maxsat   satellite index
%                           maxsat=31 (only GPS), =47 (including GLONASS)
%                           The index points to the 'satlist' array that
%                           contains the satellite PRN numbers.
%                           The PRN numbers have fixed indices. The output
%                           array 'gpsobs' thus always contains the same
%                           PRN number at the same index j.
%                           If a satellite is not observed, the column
%                           is filled with zeroes.
%
%          k=1,...,maxtyp   observation type
%                           The fixed order of observation types:
%                           C1, P1, P2, L1, L2, D1, D2, S1, S2
%                           If a particular observation type is not
%                           contained in the file the corresponding
%                           array elements in 'gpsobs' are set to zero.
%
%          The 'gpsobs' array element is filled with zero if for a 
%          particular combination of indices i,j,k no observation exists.
%
%          Simple usage:    cccc = readrnx('ccccddd0.yyO')
%
% Author:  Urs Hugentobler, FESG
% Date  :  26-10-2006
% -------------------------------------------------------------------------
format compact;

fid=fopen(filename,'r');

% Maximum number of 
%  - observation types
%  - observation epochs
%  - maximum number of satellites
% sampling
% use glonass

glonass=   0;
maxepo =86400; % 24 h of 1 Hz data
maxsat =  47;
if (glonass == 0) maxsat=31; end;
maxtyp =   9;
sampl  =  1;


gps=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31];
glo=[101,102,103,104,105,106,107,108,117,118,119,120,121,122,123,124];
satlist=gps;
if (glonass ~= 0) satlist=[gps,glo]; end;

% initialize matrix for values to be read in
iepo=-1;
gpsobs =zeros(maxepo,maxsat,maxtyp)*NaN;
gpsepo =zeros(1,maxepo)*NaN;

% definition of observation types and their order in the output array
types = ['C1','P1','P2','L1','L2','D1','D2','S1','S2'];

% Epochs
for i=1:maxepo;
   gpsepo(i)=(i-1)*sampl;
end;

% Read header
% -----------
while 1
    tline=fgetl(fid);
    if (~isempty(strfind(tline,'MARKER NAME')))
        marker = tline(1:4);
    end
    if (~isempty(strfind(tline,'ANT # / TYPE')))
        antenna = tline(21:40);
    end
    if (~isempty(strfind(tline,'REC # / TYPE / VERS')))
        receiver = tline(21:40);
    end
    if (~isempty(strfind(tline,'APPROX POSITION XYZ')))
        tline = strrep (tline,'APPROX POSITION XYZ','');
        xyz = str2num(tline);
    end
    if (~isempty(strfind(tline,'ANTENNA: DELTA H/E/N')))
        tline = strrep (tline,'ANTENNA: DELTA H/E/N','');
        dneu = str2num(tline);
        u    = dneu(1);
        n    = dneu(2);
        e    = dneu(3);
        dneu = [n,e,u];
    end
    if (~isempty(strfind(tline,'# / TYPES OF OBSERV')))
        tline = strrep (tline,'# / TYPES OF OBSERV','');
        [token,tline]  = strtok(tline);
% Get list of types
        ntyp  = str2num(token);
        if (ntyp > 9)
            print='*** Too many obseration types in file, first nine used'
            ntyp = 9;
        end;
        typlst=zeros(1,9);
        for i=1:9;
            [token,tline]=strtok(tline);
            k=strfind(types,token);
            if (~isempty(k)) typlst(i)=(k+1)/2; end;
        end;
    end
    if (~isempty(strfind(tline,'END OF HEADER')))
        break;
    end
end

while 1
    tline=fgetl(fid);
    if tline==-1
        break;
    end
    
% epoch flag
    flg=str2num(tline(29:29));
    if (flg > 2)
% skip comment lines
        n=str2num(tline(30:32));
        for i=1:n;
            tline=fgetl(fid);
        end;
    else
    
% read epoch line
        [token,tline] = strtok(tline); yy=str2num(token);
        if (yy < 80)
            yy = yy+2000;
        else
            yy = yy+1900;
        end 
        [token,tline] = strtok(tline); mm =str2num(token);
        [token,tline] = strtok(tline); dd =str2num(token); 
        [token,tline] = strtok(tline); h  =str2num(token);
        [token,tline] = strtok(tline); min=str2num(token);
        [token,tline] = strtok(tline); sec=str2num(token);
        [week,sec]=gpstime(yy,mm,dd,h,min,sec);
        sec=round(sec);

        if (iepo == -1) 
           [gpsweek,sec0]=gpstime(yy,mm,dd,0,0,0);
           gpsepo=gpsepo+sec0;
        end;
        iepo=find(gpsepo == sec);
        if (isempty(iepo)) iepo=0; end;

% satellite numbers
        [token,tline] = strtok(tline);
        nsat=str2num(tline(1:3));
        if (nsat > 12)
            tline1=fgetl(fid);
            tline=[tline(4:12*3+3),tline1(33:(nsat-12)*3+32)];
        else
            tline=tline(4:nsat*3+3);
        end;
        
        isat(1:nsat)=0;
        for i=1:nsat;
            sat=tline(i*3-2:i*3);
            prn=str2num(sat(2:3));
            if (strncmpi(sat,'R',1)) prn = prn+100; end;
            if (strncmpi(sat,'E',1)) prn = prn+200; end;

% find satellite in list or add if missing
            if (~(glonass==0 & prn > 100))
                found=0;
                for k=1:maxsat;
                    if (prn == satlist(k)) found=k; break; end;
                end;
                if (found > 0)
                    isat(i)=found;
                else
                    print='*** satellite not found'
                    prn
                end;
            end;
        end;

% read observations
        for i=1:nsat;
           tline=fgetl(fid);
           if (ntyp > 5)
               tline =[tline,'                                                                                '];
               tline1=fgetl(fid);
               tline =[tline(1:80),tline1];
           end;
           tline =[tline,'                                                                                '];
           if (iepo>0 & isat(i)>0) 
               for k=1:ntyp;
                   token=tline((k-1)*16+1:k*16-2);
                   obs=str2num(token);
                   if (~isempty(obs))
                       ityp=typlst(k);
                       gpsobs(iepo,isat(i),ityp)=obs;
                   end;
               end;
           end;
       end;
   end;

end;

%close file
fclose(fid);
