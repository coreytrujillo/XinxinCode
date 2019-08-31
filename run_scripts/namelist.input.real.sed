&time_control
 run_days =  0,
 run_hours                           = _steps_,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = _SAAAA1_, _SAAAA1_,
 start_month                         = _SMM1_, _SMM1_,
 start_day                           = _SDD1_, _SDD1_,
 start_hour                          = _SHH1_, _SHH1_,
 start_minute                        = 00,   00,
 start_second                        = 00,   00,
 end_year                            = _EAAAA1_, _EAAAA1_,
 end_month                           = _EMM1_, _EMM1_,
 end_day                             = _EDD1_, _EDD1_,
 end_hour                            = _EHH1_, _EHH1_,
 end_minute                          = 00,   00,   00,
 end_second                          = 00,   00,   00,
interval_seconds                    = 10800,
input_from_file                     = .true.,.true.,.true.,
fine_input_stream                   = 0, 2, 2, 2, 2
history_interval                    = 60,  60,   60,
frames_per_outfile                  = 1,    1,    1,
restart                             = .false.,
restart_interval                    = 1440,
io_form_history                     = 102,
io_form_restart                     = 2,
io_form_input                       = 2,
io_form_boundary                    = 2,
io_form_auxinput2                   = 2,
io_form_auxinput4                   = 0,
io_form_auxinput5                   = 0,
io_form_auxinput6                   = 0,
io_form_auxinput7                   = 0,
auxinput4_interval_m                = 360, 360, 360, 360,
auxinput5_interval_m                = 60, 60,  60, 60,
auxinput7_interval_m                = 60, 60,  60, 60,
auxinput4_inname                    = "wrflowinp_d<domain>",
auxinput5_inname                    = "wrfchemi_<hour>_d<domain>",
auxinput6_inname                    = "wrfbiochemi_d<domain>",
auxinput7_inname                    = "wrffirechemi_d<domain>_<date>",
frames_per_auxinput5                = 12, 1, 1, 1,
frames_per_auxinput7                = 1, 1, 1, 1,
debug_level                         = 0,
/
&domains
time_step                           = 20,
time_step_fract_num                 = 0,
time_step_fract_den                 = 1,
max_dom                             = 1,
e_we                                = 660,  262,  301, 1406,
e_sn                                = 560,  274,  274, 1271,
e_vert                              = 53,   53,    53,   53,
p_top_requested                     = 5000,
num_metgrid_levels                  = 40,
num_metgrid_soil_levels             = 4,
dx                                  = 4000,  1333.333, 266.666,
dy                                  = 4000,  1333.333, 266.666,
grid_id                             = 1,     2,     3,     4,
parent_id                           = 0,     1,     2,     3,
i_parent_start                      = 1,     120,   120,  10,
j_parent_start                      = 1,     166,   110,  10,
parent_grid_ratio                   = 1,     3,     3,     5,
parent_time_step_ratio              = 1,     3,     3,     3,
feedback                            = 0,
smooth_option                       = 0,
eta_levels                          = 1.0000, 0.9940, 0.9880, 0.9820, 0.9750,0.9680, 0.9560, 0.9440, 0.9320, 0.9200,0.9020, 0.8790, 0.8560, 0.8330, 0.8100, 0.7870, 0.7600, 0.7330, 0.7060, 0.6730,0.6400, 0.6070, 0.5740, 0.5410, 0.5080,0.4750, 0.4420, 0.4090, 0.3820, 0.3550, 0.3330, 0.3110, 0.2890, 0.2670, 0.2450, 0.2240, 0.2030, 0.1820, 0.1614, 0.1412, 0.1220, 0.1050, 0.0890, 0.0750, 0.0625, 0.0520, 0.0425, 0.0335, 0.0250, 0.0175, 0.0110, 0.0050, 0.0000
/
&physics
mp_physics                          = 28,    28,    28,    28,
ra_lw_physics                       = 4,     4,     4,     4,
ra_sw_physics                       = 4,     4,     4,     4,
radt                                = 5,     5,     5,     5,
sf_sfclay_physics                   = 2,     2,     2,     2,
sf_surface_physics                  = 2,     2,     2,     2,
bl_pbl_physics                      = 2,     2,     2,     0,
bldt                                = 0,     0,     0,     0,
mp_zero_out                         = 0,
cu_physics                          = 3,     0,     0,     0,
cudt                                = 0,     0,     0,     0,
cu_diag                             = 1,
cugd_avedx                          = 0,
maxiens                             = 1,
maxens                              = 3,
maxens2                             = 3,
maxens3                             = 16,
ensdim                              = 144,
cu_rad_feedback                     = .true.,  .false.,  .false.,
isfflx                              = 1,
ifsnow                              = 0,
icloud                              = 1,
surface_input_source                = 1,
num_soil_layers                     = 4,
use_aero_icbc                       = .TRUE.
scalar_pblmix                       = 1,     1,     1,     1,
aer_opt                             = 3,
/
&fdda
 grid_fdda                           = 1,            0,            0,     0,
 gfdda_inname                        = "wrffdda_d<domain>",
 gfdda_end_h                         = 84,        10000,        10000, 10000,
 gfdda_interval_m                    = 360,          360,          360, 360,
 fgdt                                = 0,            0,            0,  0,
 if_no_pbl_nudging_uv                = 1,            0,            0,  0,
 if_no_pbl_nudging_t                 = 1,            0,            0,  0,
 if_no_pbl_nudging_q                 = 1,            0,            0,  0,
 if_zfac_uv                          = 1,            0,            0,  0,
 k_zfac_uv                           = 15,
 if_zfac_t                           = 1,            0,            0,  0,
 k_zfac_t                            = 15,
 if_zfac_q                           = 1,            0,            0,  0,
 k_zfac_q                            = 15,
 guv                                 = 0.0003,       0.0003,       0.0003, 0.0003,
 gt                                  = 0.0003,       0.0003,       0.0003, 0.0003,
 gq                                  = 0.0003,       0.0003,       0.0003, 0.0003,
 if_ramping                          = 0,
 dtramp_min                          = 60.0,
 io_form_gfdda                       = 2,
/
&dynamics
w_damping                           = 0,
diff_opt                            = 1,      1,      1,      2,
km_opt                              = 4,      4,      4,      2,
diff_6th_opt                        = 0,      0,      0,      0,
diff_6th_factor                     = 0.08,   0.12,   0.12,   0.12,
base_temp                           = 290.
damp_opt                            = 3,
zdamp                               = 5000.,  5000.,  5000.,  5000.,
dampcoef                            = 0.05,   0.05,   0.05,   0.05,
khdif                               = 0,      0,      0,      0,
kvdif                               = 0,      0,      0,      0,
non_hydrostatic                     = .true., .true., .true., .true.,
tke_adv_opt                         = 1,      1,      1,      1,
moist_adv_opt                       = 2,      2,      2,      2,
scalar_adv_opt                      = 2,      2,      2,      2,
chem_adv_opt                        = 0,      0,      0,      0,
tracer_adv_opt                      = 2,      2,      2,
tracer_opt                          = 7,
/


&bdy_control
spec_bdy_width                      = 5,
spec_zone                           = 1,
relax_zone                          = 4,
specified                           = .true., .false.,.false.,.false.,
nested                              = .false., .true., .true., .true.,
/
&grib2
/
&chem
kemit                               = 20,
chem_opt                            = 14,        14,       14,       14,
io_style_emissions                  = 1,
emiss_inpt_opt                      = 1,         1,         1,         1,
emiss_opt                           = 3,         3,         3,         3,
emi_inname                          = "wrfchemi_<hour>_d<domain>",
dust_opt                            = 3,
seas_opt                            = 2,
biomass_burn_opt                    = 0,         1,         1,         0,
scale_fire_emiss                    = .true.,
fireemi_inname                      = "wrffirechemi_d<domain>_<date>",
plumerisefire_frq                   = 30,        30,        30,        30,
gas_drydep_opt                      = 0,         0,         0,         0,
aer_drydep_opt                      = 0,         0,         0,         0,
gas_bc_opt                          = 1,         1,         1,         1,
gas_ic_opt                          = 1,         1,         1,         1,
aer_bc_opt                          = 1,         1,         1,         1,
aer_ic_opt                          = 1,         1,         1,         1,
gaschem_onoff                       = 0,         0,         0,         0,
aerchem_onoff                       = 0,         0,         0,         0,
wetscav_onoff                       = 0,         0,         0,         0,
cldchem_onoff                       = 0,         0,         0,         0,
vertmix_onoff                       = 0,         0,         0,         0,
chem_conv_tr                        = 1,         0,         0,         0,
chem_in_opt                         = 1,
input_chem_inname                   = "wrfinput_d<domain>",
/
&namelist_quilt
nio_tasks_per_group = 0,
nio_groups = 1,
/
