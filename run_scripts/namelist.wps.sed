&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '_START_','_START_',
 end_date   = '_END_','_END_',
 interval_seconds = 10800,
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   1,   1,  2,
 parent_grid_ratio =   1,   3,  3,
 i_parent_start    =   1,  201, 100,
 j_parent_start    =   1,  150, 120
 e_we              =   660, 202,
 e_sn              =   560, 202,
 geog_data_res     = '30s','30s', '30s',
 dx = 4000,
 dy = 4000,
 map_proj = 'lambert',
 ref_lat   =  41.4,
 ref_lon   =  -111.2,
 truelat1  =   60.0,
 truelat2  =   30.0,
 stand_lon =  -111.2,
 geog_data_path = '/nobackup/ctrujil1/DATA/geogV3'
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2,
 constants_name = 'QNWFA_QNIFA_Monthly_GFS'
/

&mod_levs
 press_pa = 201300 , 200100 , 100000 ,
             97500 ,  95000 ,  92500 , 90000 ,
             85000 ,  80000 ,
             75000 ,  70000 ,
             65000 ,  60000 ,
             55000 ,  50000 ,
             45000 ,  40000 ,
             35000 ,  30000 ,
             25000 ,  20000 ,
             15000 ,  10000 ,
              7000 ,   5000 ,   3000 , 2000 , 1000
/


