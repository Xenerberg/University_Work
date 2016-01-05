function [week,wsec,dayoy,jd,mjd]=gpstime(year,month,day,hour,minute,second)
% -----------------------------------------------------------------------------
% GPSTIME.M
% generates day of year, GPS-week and -week-second from date and time
% -----------------------------------------------------------------------------
%
% in:  year (4-stellig), month, day, hour, minute, second
% out: dayoy, week, wsec, jd, mjd
%
% --> proofed by Ashtech's TIMESYS.EXE (GPPS)
%
% Literature: Leick (1995)[chap. 2.2], Hofmann-Wellenhof et al. (1992)[chap. 3.3], ...
%
% JD/MJD: Sneeuw/Zebhauser			04/01/96      (from: JULIANJH.M)
% GPS-week/-weeksec: Zebhauser   1999-03-12
%
% -----------------------------------------------------------------------------
% GPSLab (c) iapg 1999 zeb

if any(month(:)>12 | month(:)<1) ...
| any(day(:)>31 | day(:)<1) ...
| any(hour(:)>24 | hour(:)<0) ...
| any(minute(:)>60 | minute(:)<0) ...
| any(second(:)>60 | second(:)<0),

         errordlg(['Break in >>time conversion<< :' ...
               ' Date or time is not plausible, ' ...
               ' so the time conversion was stopped. Please rpeat with valid values.'], ...   
   						 'GPSLab: Break');
         return;
end

% Konstanten
gps_week_origin = 44244;		% GPS-Wochenanfang MJD 44244.0 = 0 UT 6.1.1980 (So) 
count_of_days = [31,28,31,30,31,30,31,31,30,31,30,31];

% Julianisches Datum, Modifiziertes Julianisches Datum
ut=hour+minute/60+second/3600;

jd  = 367*year - floor(7*(year+floor((month+9)/12))/4);
jd  = jd + floor(275*month/9) + day + 1721014 + ut/24 - 0.5;
mjd =  jd-2400000.5;				% modifiziertes jd

% GPS-Woche und -Wochensekunden
week = fix((mjd - gps_week_origin)/7);
wsec = (rem(mjd - gps_week_origin,7))*24*60*60;

% Tag des Jahres DAYOY
dayoy = 0;
wkd_counter = 1;

while wkd_counter < month,
   dayoy = dayoy + count_of_days(wkd_counter);
   wkd_counter = wkd_counter + 1;
end

dayoy = dayoy + day;

if rem(year,4) == 0 & month >2       % Schaltjahrregelung (ohne Jahrhundertregelung)
   dayoy = dayoy + 1;
end

% GPSLab (c) iapg 1999 zeb

