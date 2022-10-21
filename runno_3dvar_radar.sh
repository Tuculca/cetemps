#!/bin/bash
export OMP_STACKSIZE=1024M
export OMP_NUM_THREADS=4
ulimit -s unlimited
source /etc/bashrc
source /home/model/.config.intel
#
HOME=/home/model/OPER2WAY_GFS
cd $HOME
rm -rf DA_RADAR_TMP
#rm -fr RADAR_DATA
mkdir $HOME/DA_RADAR_TMP
echo 'Inizio 3dvar Radar'
YEAR_S=$1
YEAR_E=$2
echo $YEAR_S $YEAR_E 'Anno (inizio e fine)'
MONTH_S=$3
MONTH_E=$4
echo $MONTH_S $MONTH_E 'Mese'
DAY_S=$5
DAY_E=$6
echo $DAY_S $DAY_E 'Giorno'
TIME_S=$7
TIME_E=$8
echo $TIME_S $TIME_E 'ora'
echo " :::: ho letto bene"
DAY_MM=$9
echo $DAY_MM 'vedo se scrivo bene il giorno'
MONTH_MM=${10}
YEAR_MM=${11}
##############per evitare problemi con gli ottali!!!!!!
DAY_MM=10#${DAY_MM}
MONTH_MM=10#${MONTH_MM}
#################################################################
echo $YEAR_MM $MONTH_MM $DAY_MM $TIME_S" :::: ho letto bene anche il giorno prima"
# definisco il time window per la 3dvar#######################
if [ $TIME_S -eq 12 ]; then
DAY_M=$DAY_S
let MONTH_M=10#$MONTH_S
let YEAR_M=$YEAR_S
echo ${DAY_M}' sono dopo + e -'
let TIME_MINUS=$TIME_S-1
TIME_PLUS=12
fi
if [ $TIME_S -eq 00 ]; then
let DAY_M=$DAY_S-1
let MONTH_M=$MONTH_MM
let YEAR_M=$YEAR_MM
echo "${DAY_MM} ${MONTH_MM} ${YEAR_MM} scrivo come leggo"
echo 'sono dopo if'
echo "${DAY_M} ${MONTH_M} ${YEAR_M} sono dopo if 0"
TIME_MINUS=23
TIME_PLUS=00
fi
MINUT_M=30
echo "${MINUT_M} fatti if"
MINUT_P=30
MINUT=00
if [ $MONTH_M -lt 10 ]; then
MONTH_M=0$MONTH_M
fi
if [ $DAY_M -lt 10 ]; then
DAY_M=0$DAY_M
fi
echo 'fatti tutti i controlli' $DAY_M, $MINUT_M, $TIME_MINUS
#
# Si prevede script a parte solo per generazione della BE *VEDERE SCRIPT runno_be.csh
# Va lanciato lo script 'gen_be_wrapper.ksh' che sta in /home/model/codes/intel/wrfda-3.2.1/var/scripts/gen_be/gen_be_wrapper.ksh
# Attenzione all'editing di tale script.... per un esempio vedere in /OPER/namelist_oper_3dvar
# Attenzione all'archiviazione dei wrfout* in un'apposita directory 'fc' da noi creata
# insieme alle successive sottodirectories nominate per tempo di forecast iniziale 

# Usa il programmino 'per_wrf_new' in /home/model/codes/intel/OPER/preproc_radar/WRF_NEW
#prendo i dati radar################################################
cd $HOME
# per observation=01 viene skippata la parte sulle osservazioni convenzionali ##############
 observation=00
echo "scrivo osservazioni ${observation}"
#
echo 'scrivo time window, min, ana, max'
echo ${YEAR_M}${MONTH_M}${DAY_M}${TIME_MINUS}${MINUT_M}
echo ${YEAR_S}${MONTH_S}${DAY_S}${TIME_S}${MINUT}
echo ${YEAR_S}${MONTH_S}${DAY_S}${TIME_PLUS}${MINUT_P}
##################################################
############################################################################################
cd $HOME/DA_RADAR_TMP
#rm -f ob.radar wrf.dat be.dat
# Linkiamo gli eseguibili
ln -s /home/model/WRFDA3.8.1/var/build/da_wrfvar.exe da_wrfvar.exe
ln -s /home/model/WRFDA3.8.1/var/build/da_update_bc.exe da_update_bc.exe
# Linkiamo tutti i files di input
cp -s $HOME/RADAR_DATA/wrf.dat ob.radar 
ln -s /home/model/WRFDA3.8.1/var/run/be.dat.cv3 be.dat
###################################################################################
##### linko BE fornita da WRFDA per una prova, ricorda di settare cv_options=3 in &wrfvar7 ###
#ln -s /home/model/Programs/WRFDA/var/run/be.dat.cv3 be.dat
####################################################################################
#ln -s /home/model/codes/intel/OPER/run/wrfinput_d01 fg
#ln -s /data02/OPER_OUT/TMP/wrfout_d01_${YEAR_S}-${MONTH_S}-${DAY_S}_${TIME_S}:${MINUT}:00 fg
cp $HOME/wrf/run/wrfbdy_d01 $HOME/DA_RADAR_TMP/wrfbdy_d01
##### conservo copia delle vecchie bdy ###################################################
cp $HOME/DA_RADAR_TMP/wrfbdy_d01 wrfbdy_d01_old
#########################################################################################
cp $HOME/wrf/run/wrfinput_d01 $HOME/DA_RADAR_TMP/wrfinput_d01
ln -s $HOME/DA_RADAR_TMP/wrfinput_d01 fg
ln -s /home/model/WRFDA3.8.1/run/LANDUSE.TBL LANDUSE.TBL
##########################################################################################
echo 'ho linkato tutti i files'
# Entra la 'namelist.input' di cui si puo' vedere un esempio in /home/model/codes/intel/OPER/namelist_oper_3dvar
cat << End_Of_Namelist9 | sed -e 's/#.*//; s/  *$//' > ./namelist.input
&wrfvar1
write_increments=true,
print_detail_radar=true,
print_detail_grad=false,
print_detail_be=false,
print_detail_outerloop=false,
/
&wrfvar2
calc_w_increment=true,
/
&wrfvar3
/
&wrfvar4                    
use_synopobs=false,
use_shipsobs=false,
use_metarobs=false,
use_soundobs=false,
use_mtgirsobs=false,
use_pilotobs=false,
use_airepobs=false,
use_geoamvobs=false,
use_polaramvobs=false,
use_bogusobs=false,
use_buoyobs=false,
use_profilerobs=false,
use_satemobs=false,
use_gpspwobs=false,
use_gpsrefobs=false,
use_qscatobs=false,
use_radarobs=true,
use_radar_rv=true,
use_radar_rf=true,
use_airsretobs=false,
/
&wrfvar5
/
&wrfvar6
max_ext_its=1,
ntmax=75,
eps=0.001,
/
&wrfvar7
cv_options=3,
/
&wrfvar8
/
&wrfvar9
/
&wrfvar10
/
&wrfvar11
/
&wrfvar12
/
&wrfvar13
/
&wrfvar14
/
&wrfvar15
/
&wrfvar16
/
&wrfvar17
/
&wrfvar18
analysis_date=${YEAR_S}-${MONTH_S}-${DAY_S}_${TIME_S}:${MINUT}:00.0000,
/
&wrfvar19
/
&wrfvar20
/
&wrfvar21
time_window_min=${YEAR_M}-${MONTH_M}-${DAY_M}_${TIME_MINUS}:${MINUT_M}:00.0000,
/
&wrfvar22
time_window_max=${YEAR_S}-${MONTH_S}-${DAY_S}_${TIME_PLUS}:${MINUT_P}:00.0000,
/
&wrfvar23
/
&time_control
start_year=$YEAR_S,
start_month=$MONTH_S,
start_day=$DAY_S,
start_hour=$TIME_S,
end_year=$YEAR_E,
end_month=$MONTH_E,
end_day=$DAY_E,
end_hour=$TIME_E,
/
&fdda
grid_fdda=1,
gfdda_inname="wrffdda_d<domain>",
gfdda_interval_m=360,
gfdda_end_h=6,
io_form_gfdda=2,
fgdt=0,
if_no_pbl_nudging_uv=0,
if_no_pbl_nudging_t=0,
if_no_pbl_nudging_q=0,
if_zfac_uv=0,
k_zfac_uv=10,
if_zfac_t=0,
k_zfac_t=10,
if_zfac_q=0,
k_zfac_q=10,
guv=0.0003,
gt=0.0003,
gq=0.0003,
if_ramping=0,
dtramp_min=60.0,
/
&domains
e_we=379,
e_sn=431,
e_vert=40,
dx=3000,
dy=3000,
/
&dfi_control
/
&tc
/
&physics
mp_physics=6,
ra_lw_physics=1,
ra_sw_physics=1,
radt=1,
sf_sfclay_physics=2,
sf_surface_physics=2,
bl_pbl_physics=2,
cu_physics=0,
cudt=0,
num_soil_layers=4,
mp_zero_out=2,
num_land_cat=21,
/
&scm
/
&dynamics
/
&bdy_control
/
&grib2
/
&fire
/
&namelist_quilt
/
&perturbation
/
End_Of_Namelist9

#echo "${analysis_date}, ${time_window_min}, ${time_window_max} "
#######################################################################
mpirun -np 10 ./da_wrfvar.exe > wrfda_out
cp wrfvar_output wrfvar_output_old
echo 'ho fatto 3dvar' 
# Abbiamo fatto la wrfda ma manca l'aggiornamento delle bc
# NB: con la partenza a caldo cycling=.true.
cat << End_Of_Namelist10 | sed -e 's/#.*//; s/  *$//' > ./parame.in
&control_param
da_file            = './wrfvar_output'
wrf_bdy_file       = './wrfbdy_d01'
domain_id          = 1 
wrf_input          = './wrfinput_d01'
cycling = .false.
update_lateral_bdy = .true.
debug   = .true.
low_bdy_only = .false.
update_lsm = .false.
var4d_lbc = .false.
/
End_Of_Namelist10

./da_update_bc.exe > out_bdy
echo 'ho aggiornato bdy'
# I files 'wrfvar_output' e 'wrfbdy_d01' cosi aggiornati, saranno gli input per la nuova corsa di wrf
cp wrfvar_output $HOME/wrf/run/wrfinput_d01
cp wrfbdy_d01 $HOME/wrf/run/wrfbdy_d01
exit
# Runna wrf  (ricorda che il real.exe non va piu' runnato!)
