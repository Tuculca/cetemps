!        program sweepping
	subroutine wrf_1180_new_MM (nfile,nfile2,minu,ora,gio,mes,ann)
	parameter(ni=4,na=225,ndata=1003,nbin=1003,nincl=4)
	real mat(ni,na,ndata),vmi(na,ndata),rain(na,ndata)
        real hmax (nbin,nincl),mat2(ni,na,ndata)
	character*7 nfile
        character*7 nfile2
	character*20 newfile
        character*23 newfile2
	character*10 afile
	character*13 afile2
        character*10 data
        integer ann,mes,gio,ora,minu
        integer qc,error,qc2,error2
!	character*14 afile2
	character*1 char
	logical formfile /.true./

!	write(char,'(i1)') nelev
!!        nfile="0011071000.BZ"
	afile=nfile
	newfile=afile//'_'//'VMI'//'.BZ'
	newfile2=afile//'_'//'VMI'//'_PIO'//'.BZ'
	afile2=nfile
!	newfile=afile2//'_'//char//'.map'
        print*,nfile
	
	a=150.
	b=1.6
        pi = 3.1415/180.
        zlat_radar=42.057
        zlon_radar=13.177
        h_radar=1710.0      !metri
        Re=6370.            !km
        gate=0.125          !km
!        numObs=ni*na*ndata
        numObs=na*(ndata-3)

         open(11,file=nfile,status='old')
         do i=1,nincl
           do k=1,na
             read(11,222) (mat(i,k,j),j=1,nbin)
c            read(10,222) (mat(i,k,j),j=1,478)

c             read(10,'(<nbin>f10.2)') (mat(i,k,j),j=1,nbin)
           enddo
         enddo
         
        close(11)
c      if (formfile) then
         open(12,file=nfile2,status='old')
         do i=1,nincl
           do k=1,na
             read(12,222) (mat2(i,k,j),j=1,nbin)
c            read(10,222) (mat(i,k,j),j=1,478)
 
c             read(10,'(<nbin>f10.2)') (mat(i,k,j),j=1,nbin)
           enddo
         enddo

	close(12)

	open(20,file='/mnt/disk2/afalcione/ass_radar/RADAR_DATA_MM/
     *wrf.dat_MM', status='unknown', ACCESS='append')
 
c        open(10,file='temp.log',form='formatted',status='old')

c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c          read (10,'(1x)')
c         read (10,'(1x)')

c          read (10,'(22x,i4,1x,i2,1x,i2,1x,i2,1x,i2)')
c     +    ann,mes,gio,ora,minu

c          close (10)

          write(20,fmt='(a17)') 'TOTAL RADAR     1'

          write(20,fmt='(a)') ' '
          write(20,fmt='(a)') ' '

          write(20,220) zlon_radar,zlat_radar,h_radar,ann,mes,gio,
     *    ora,minu,numObs,nincl
 220   format('RADAR  DWSR-93C',2x,f8.3,2x,f8.3,2x,f8.1,
     * 4x,i4,'-',i2.2,'-',i2.2,'_',i2.2,':',i2.2,':','00',
     * i6,i6)


          write(20,fmt='(a)') ' '
          write(20,fmt='(a)') ' '



		

	  do k=1,na
!   al raggio zero mette tutti BAD_VALUE
	    do j=4,nbin
                  jj=j-3 
!          modificato 

                mazimuth=k/2.
                zrange=gate*jj
		zdelta_lat=zrange*cos(pi*mazimuth);
		zdelta_lon=zrange*sin(pi*mazimuth);
                zlat=zlat_radar+(zdelta_lat/111.25);
                zgrado_uno_lon=111.30666667*cos(pi*zlat);
		
	        zlon=zlon_radar+(zdelta_lon/zgrado_uno_lon);		



c      visualiza k e j
c               write(20,223) anno,mese,giorno,ora,minuto,
c     *         k,j,zlat,zlon,nincl
               write(20,223) ann,mes,gio,ora,minu,
     *         zlat,zlon,h_radar,nincl
	        do i=1,nincl
!		 do i=1,nincl

                 hmax (j,i)= h_radar + jj*0.5*1000*sin(i*pi)
                  if (mat(i,k,j) == -32) then
                      mat(i,k,j) = -888888.000
                  endif
                  if (mat2(i,k,j) == -32) then
                      mat2(i,k,j) = -888888.000
                  endif
                  if (mat(i,k,j) /= -888888.000) then
                      qc = 0.0
                      error = 1.0
                  else
                      qc = -88
                      error = -88
                  endif
                 if ( mat2(i,k,j)/= -888888.000) then
                      qc2 = 0.0
                      error2 = 1.0
                 else
                      qc2 = -88
                      error2 = -88
                 endif
           write(20,224)  hmax(j,i),mat2(i,k,j),qc2,error2,mat(i,k,j),
     *           qc,error
		 end do
          
           
	    enddo
	  enddo

!           altezza[i]=
!           sqrt(range*range+rag*rag+2*range*rag*sin(elev*pi/180.))-rag+quorad1/100
!0.;
!               altezza[i]= altezza[i] - range*tan(pi/180.*delta);




 222    format (1003(f9.2))
c   visualizza j_azime k_bin
c 223    format ('FM-128 RADAR',1x,i4,'-',i2.2,'-',i2.2,
c     *  '-',i2.2,':',i2.2,':','00',1x,i3,1x,i3,1x,f8.4,1x,f8.4,
c     *   1x,'1710.0',1x,i2.2)

 223    format ('FM-128 RADAR',3x,i4,'-',i2.2,'-',i2.2,
     *  '_',i2.2,':',i2.2,':','00',2x,f12.3,2x,f12.3,
     *   2x,f8.1,2x,i6)


c 224    format (f14.6,1x,f14.6,1x,'0.0',1x,'1.0',1x,f14.6,1x,'0.0',
c     *    1x,'1.0')
 224    format (3x,f12.1,2x,f12.3,2x,i4,2x,i4,2x,f12.3,2x,i4,
     *    2x,i4)






	close(30)
	close(20)
	return
	end
