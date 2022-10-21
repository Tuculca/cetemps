#!/bin/bash
#
# Questo script scarica i dati grezzi e li formatta producendo il file wrf.dat in RADAR_DATA, pronto per essere assimilato
# Va utilizzato con la seguente sintassi: 
# ./nomeScript.sh annoInizio annoFine meseInizio meseFine giornoInizio giornoFine oraInizio oraFine annoGiornoprecedente meseGiornoprecedente numeroGiornopr
#
###############################################################################################################
ulimit -s unlimited
#
HOME=/mnt/disk2/afalcione/ass_radar
#

cd ${HOME}	 
rm -fr RADAR_DATA_MM
rm -fr RADAR_DATA_CEPA
rm -fr RADAR_DATA_TORT
#rm -fr RADAR_DATA_AQ
rm -fr RADAR_DATA
YEAR_S=$1
YEAR_E=$2
echo $YEAR_S $YEAR_E 'Anno (Inizio e fine)'
MONTH_S=$3
MONTH_E=$4
echo $MONTH_S $MONTH_E 'Mese'
DAY_S=$5
DAY_E=$6
echo $DAY_S $DAY_E 'Giorno'
TIME_S=$7
TIME_E=$8
echo $TIME_S $TIME_E 'Ora'
echo " :::: ho letto bene"
DAY_MM=$9
MONTH_MM=${10}
YEAR_MM=${11}
echo $YEAR_MM $MONTH_MM $DAY_MM $TIME_S " :::: ho letto bene anche il giorno prima"
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
 let DAY_M=$DAY_MM
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
##############per evitare problemi con gli ottali!!!!!!
DAY_MM=10#${DAY_MM}
MONTH_MM=10#${MONTH_MM}
#################################################################
echo 'fatti tutti i controlli' $DAY_M, $MINUT_M, $TIME_MINUS
########################################################################
### Commentato da Ale ###
ora=00
#########################
#### Scarico dati Radar ###
cd ${HOME} 
mkdir RADAR_DATA_MM
cd ${HOME}/RADAR_DATA_MM
wget -r  http://radar.aquila.infn.it/Volumi_Polari_Radar/MMidia/${YEAR_S}/${MONTH_S}/${DAY_S}/ -A '*1200UTC*' -nc -np -nd -e robots=off
##
echo 'ho preso i dati radar di Monte Midia delle 12'
########################################################################################################################
cd ${HOME}
mkdir RADAR_DATA_CEPA
cd RADAR_DATA_CEPA
wget -r  http://radar.aquila.infn.it/Volumi_Polari_Radar/Cepagatti/${YEAR_S}/${MONTH_S}/${DAY_S}/ -A '*1200UTC*' -nc -np -nd -e robots=off
echo 'ho preso i dati radar di Cepagatti delle 12'
########################################################################################################################
cd ${HOME}
mkdir RADAR_DATA_TORT
cd RADAR_DATA_TORT
wget -r  http://radar.aquila.infn.it/Volumi_Polari_Radar/Tortoreto/${YEAR_S}/${MONTH_S}/${DAY_S}/ -A '*1200UTC*' -nc -np -nd -e robots=off
###rm -f ftp.tmp
##echo " fine ftp files "
echo 'ho preso i dati radar di Tortoreto delle 12'
#########################################################################################################################
# processo i dati del radar di Monte Midia
cd ${HOME}/RADAR_DATA_MM
ln -s ${HOME}/per_wrf_new_MM per_wrf_new_MM
ln -s ${HOME}/Zsweep_wrf_1180_linux_new_MM Zsweep_wrf_1180_linux_new_MM
ln -s ${HOME}/wrf_1180_new_MM.f wrf_1180_new_MM.f
echo 'ho linkato correttamente'
./per_wrf_new_MM > out_radarobs_MM
echo 'ho prodotto il file wrf.dat_MM per la 3dvar'
###########################################################################################
# processo i dati del radar di Cepagatti
#cd /home/model/OPER2WAY_NEW/RADAR_DATA_CEPA
#ln -s /home/model/OPER2WAY_NEW/preproc_radar/per_wrf_new_CEPA per_wrf_new_CEPA
#ln -s /home/model/OPER2WAY_NEW/preproc_radar/Zsweep_wrf_1180_linux_new_CEPA Zsweep_wrf_1180_linux_new_CEPA
#ln -s /home/model/OPER2WAY_NEW/preproc_radar/wrf_1180_new_CEPA.f wrf_1180_new_CEPA.f
#echo 'ho linkato correttamente'
#./per_wrf_new_CEPA >! out_radarobs_CEPA
#echo 'ho prodotto il file wrf.dat_CEPA per la 3dvar'
############################################################################################
# processo i dati del radar di Tortoreto 
#cd /home/model/OPER2WAY_GFS/RADAR_DATA_TORT
#ln -s /home/model/OPER2WAY_GFS/preproc_radar/per_wrf_new_TORT per_wrf_new_TORT
#ln -s /home/model/OPER2WAY_GFS/preproc_radar/Zsweep_wrf_1180_linux_new_TORT Zsweep_wrf_1180_linux_new_TORT
#ln -s /home/model/OPER2WAY_GFS/preproc_radar/wrf_1180_new_TORT.f wrf_1180_new_TORT.f
#echo 'ho linkato correttamente'
#./per_wrf_new_TORT > out_radarobs_TORT
#echo 'ho prodotto il file wrf.dat_TORT per la 3dvar'
############################################################################################
#############################################################################################
# Copio tutti i file di dati radar in una unica directory e 
# incollo uno dopo l'altro i files dei 4 radar inframmezzati ciascuno da una linea vuota
cd ${HOME}
mkdir RADAR_DATA
cd  ${HOME}/RADAR_DATA
cp  ${HOME}/RADAR_DATA_MM/wrf.dat_MM  wrf.dat
#cp /home/model/OPER2WAY_NEW/RADAR_DATA_MM/wrf.dat_CEPA  wrf.dat_CEPA
#cp /home/model/OPER2WAY_GFS/RADAR_DATA_TORT/wrf.dat_TORT  wrf.dat_TORT
#cp /home/model/OPER2WAY_GFS/preproc_radar/blankline blankline 
#cat wrf.dat_CEPA | sed '1,3d' > wrf.dat_CEPA_bis  #tolgo le prime 3 righe dal file di Tortoreto
#cat wrf.dat_TORT | sed '1,3d' > wrf.dat_TORT_bis  #tolgo le prime 3 righe dal file di Cepagatti
#cat wrf.dat_MM blankline wrf.dat_TORT_bis blankline wrf.dat_CEPA_bis > wrf.dat_all3 #concateno i 4 radars separandoli con una riga
#cat wrf.dat_MM blankline wrf.dat_TORT_bis > wrf.dat_all2 #concateno solo i 2 radars che ho, separandoli con una riga vuota
#sed -i "1 s/1/2/g" wrf.dat_all2 #sostituisco l'1 di TOTAL RADAR con il 2 
#
exit
