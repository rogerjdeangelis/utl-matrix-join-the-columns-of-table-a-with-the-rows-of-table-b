Matrix join the columns of table a with the rows of table b                                                        
                                                                                                                   
  These type of problems may be better done in a matrix language                                                   
  Because we are crossing rows and columns.                                                                        
                                                                                                                   
    Two solutions                                                                                                  
                                                                                                                   
         1   SAS (utl_gather macro) Alea Iacta https://github.com/clindocu                                         
         2.  R one-liner 'stack(setNames(hav1st, hav2nd$IND))'.                                                    
                                                                                                                   
  May be able to use 'proc score'                                                                                  
                                                                                                                   
StackOverflow                                                                                                      
https://tinyurl.com/y2g6qy2c                                                                                       
https://stackoverflow.com/questions/54658721/merge-each-row-with-corresponding-column-to-form-a-vertical-table     
                                                                                                                   
Akun                                                                                                               
https://stackoverflow.com/users/3732271/akrun                                                                      
                                                                                                                   
INPUT                                                                                                              
=====                                                                                                              
                                                                                                                   
options validvarname=upcase;                                                                                       
libname sd1 "d:/sd1";                                                                                              
data sd1.hav1st;                                                                                                   
input col1 col2 col3;                                                                                              
cards4;                                                                                                            
1 5 9                                                                                                              
2 6 10                                                                                                             
3 7 11                                                                                                             
4 8 12                                                                                                             
;;;;                                                                                                               
run;quit;                                                                                                          
                                                                                                                   
data sd1.hav2nd;                                                                                                   
input cols $ ind $;                                                                                                
cards4;                                                                                                            
 COL1 a                                                                                                            
 COL2 b                                                                                                            
 COL3 c                                                                                                            
;;;;                                                                                                               
run;quit;                                                                                                          
                                                                                                                   
                                                                                                                   
SD1.HAV1ST total obs=4                                                                                             
                                                                                                                   
  COL1    COL2    COL3                                                                                             
                                                                                                                   
    1       5       9                                                                                              
    2       6      10                                                                                              
    3       7      11                                                                                              
    4       8      12                                                                                              
                                                                                                                   
SD1.HAV2ND total obs=3                                                                                             
                                                                                                                   
  COLS    IND                                                                                                      
                                                                                                                   
  COL1     a                                                                                                       
  COL2     b                                                                                                       
  COL3     c                                                                                                       
                                                                                                                   
                                                                                                                   
EXAMPLE OUTPUT                                                                                                     
--------------                                                                                                     
                                                                                                                   
WORK.WANT total obs=12                                                                                             
                                                                                                                   
   KEY     IND    VAL   RULES                                                                                      
                                                                                                                   
   COL1     a       1   Column1 (COL1) in Hav1st                                                                   
   COL1     a       2                                                                                              
   COL1     a       3                                                                                              
   COL1     a       4                                                                                              
                                                                                                                   
   COL2     b       5    Column2 (COL2) in Hav1st                                                                  
   COL2     b       6                                                                                              
   COL2     b       7                                                                                              
   COL2     b       8                                                                                              
                                                                                                                   
   COL3     c       9   Column3 (COL3) in Hav1st                                                                   
   COL3     c      10                                                                                              
   COL3     c      11                                                                                              
   COL3     c      12                                                                                              
                                                                                                                   
                                                                                                                   
SOLUTIONS                                                                                                          
=========                                                                                                          
                                                                                                                   
---------------------------------------                                                                            
1.   SAS (utl_gather macro) Alea Iacta                                                                             
---------------------------------------                                                                            
                                                                                                                   
Proc datasets lib=work;                                                                                            
  delete havXpo want;                                                                                              
run;quit;                                                                                                          
                                                                                                                   
data _null_;                                                                                                       
                                                                                                                   
   * Transpose and add key;                                                                                        
  if _n_=0 then do; %let rc=%sysfunc(dosubl('                                                                      
     %utl_gather(sd1.hav1st,var,val,,havXpo,valformat=8.);                                                         
    '));                                                                                                           
  end;                                                                                                             
                                                                                                                   
  rc=dosubl('                                                                                                      
    proc sql;                                                                                                      
      create                                                                                                       
        table want as                                                                                              
      select                                                                                                       
        l.cols                                                                                                     
       ,l.ind                                                                                                      
       ,r.val                                                                                                      
      from                                                                                                         
        sd1.hav2nd as l, havXpo as r                                                                               
      where                                                                                                        
        l.cols = r.var                                                                                             
      order                                                                                                        
        by l.cols, r.val                                                                                           
   ;quit;                                                                                                          
  ');                                                                                                              
                                                                                                                   
run;quit;                                                                                                          
                                                                                                                   
                                                                                                                   
------------------------------------------------------                                                             
2.  R one-liner 'stack(setNames(hav1st, hav2nd$IND))'.                                                             
------------------------------------------------------                                                             
                                                                                                                   
%utl_submit_r64('                                                                                                  
library(haven);                                                                                                    
library(SASxport);                                                                                                 
library(data.table);                                                                                               
hav1st<-as.data.frame(read_sas("d:/sd1/hav1st.sas7bdat"));                                                         
hav2nd<-as.data.frame(read_sas("d:/sd1/hav2nd.sas7bdat"));                                                         
want<-stack(setNames(hav1st, hav2nd$IND));                                                                         
want<-as.data.table(lapply(want,function(x) if(is.factor(x)) as.character(x) else x));                             
want;                                                                                                              
write.xport(want,file="d:/xpt/want.xpt");                                                                          
');                                                                                                                
                                                                                                                   
libname xpt xport "d:/xpt/want.xpt";                                                                               
data want;                                                                                                         
  set xpt.want;                                                                                                    
run;quit;                                                                                                          
libname xpt clear;                                                                                                 
                                                                                                                   
LOOG                                                                                                               
                                                                                                                   
>                                                                                                                  
    values ind                                                                                                     
 1:      1   a                                                                                                     
 2:      2   a                                                                                                     
 3:      3   a                                                                                                     
 4:      4   a                                                                                                     
 5:      5   b                                                                                                     
 6:      6   b                                                                                                     
 7:      7   b                                                                                                     
 8:      8   b                                                                                                     
 9:      9   c                                                                                                     
10:     10   c                                                                                                     
11:     11   c                                                                                                     
12:     12   c                                                                                                     
>                                                                                                                  
                                                                                                                   
4114   data want;                                                                                                  
4115     set xpt.want;                                                                                             
4116   run;                                                                                                        
                                                                                                                   
5011   data want;                                                                                                  
5012     set xpt.want;                                                                                             
5013   run;                                                                                                        
                                                                                                                   
NOTE: There were 12 observations read from the data set XPT.WANT.                                                  
NOTE: The data set WORK.WANT has 12 observations and 2 variables.                                                  
                                                                                                                   
/*                                                                                                                 
WORK.WANT total obs=12                                                                                             
                                                                                                                   
  VALUES    IND                                                                                                    
                                                                                                                   
     1       a                                                                                                     
     2       a                                                                                                     
     3       a                                                                                                     
     4       a                                                                                                     
     5       b                                                                                                     
     6       b                                                                                                     
     7       b                                                                                                     
     8       b                                                                                                     
     9       c                                                                                                     
    10       c                                                                                                     
    11       c                                                                                                     
    12       c                                                                                                     
*/                                                                                                                 
                                                                                                                   
