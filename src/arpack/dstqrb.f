c-----------------------------------------------------------------------
c\BeginDoc
c
c\Name: IGRAPHARPACKDSTQRB
c
c\Description:
c  Computes all eigenvalues and the last component of the eigenvectors
c  of a symmetric tridiagonal matrix using the implicit QL or QR method.
c
c  This is mostly a modification of the LAPACK routine IGRAPHARPACKDSTEQR.
c  See Remarks.
c
c\Usage:
c  call IGRAPHARPACKDSTQRB
c     ( N, D, E, Z, WORK, INFO )
c
c\Arguments
c  N       Integer.  (INPUT)
c          The number of rows and columns in the matrix.  N >= 0.
c
c  D       Double precision array, dimension (N).  (INPUT/OUTPUT)
c          On entry, D contains the diagonal elements of the
c          tridiagonal matrix.
c          On exit, D contains the eigenvalues, in ascending order.
c          If an error exit is made, the eigenvalues are correct
c          for indices 1,2,...,INFO-1, but they are unordered and
c          may not be the smallest eigenvalues of the matrix.
c
c  E       Double precision array, dimension (N-1).  (INPUT/OUTPUT)
c          On entry, E contains the subdiagonal elements of the
c          tridiagonal matrix in positions 1 through N-1.
c          On exit, E has been destroyed.
c
c  Z       Double precision array, dimension (N).  (OUTPUT)
c          On exit, Z contains the last row of the orthonormal 
c          eigenvector matrix of the symmetric tridiagonal matrix.  
c          If an error exit is made, Z contains the last row of the
c          eigenvector matrix associated with the stored eigenvalues.
c
c  WORK    Double precision array, dimension (max(1,2*N-2)).  (WORKSPACE)
c          Workspace used in accumulating the transformation for 
c          computing the last components of the eigenvectors.
c
c  INFO    Integer.  (OUTPUT)
c          = 0:  normal return.
c          < 0:  if INFO = -i, the i-th argument had an illegal value.
c          > 0:  if INFO = +i, the i-th eigenvalue has not converged
c                              after a total of  30*N  iterations.
c
c\Remarks
c  1. None.
c
c-----------------------------------------------------------------------
c
c\BeginLib
c
c\Local variables:
c     xxxxxx  real
c
c\Routines called:
c     IGRAPHARPACKDAXPY   Level 1 BLAS that computes a vector triad.
c     IGRAPHARPACKDCOPY   Level 1 BLAS that copies one vector to another.
c     IGRAPHARPACKDSWAP   Level 1 BLAS that swaps the contents of two vectors.
c     IGRAPHARPACKLSAME   LAPACK character comparison routine.
c     IGRAPHARPACKDLAE2   LAPACK routine that computes the eigenvalues of a 2-by-2 
c             symmetric matrix.
c     IGRAPHARPACKDLAEV2  LAPACK routine that eigendecomposition of a 2-by-2 symmetric 
c             matrix.
c     IGRAPHARPACKDLAMCH  LAPACK routine that determines machine constants.
c     IGRAPHARPACKDLANST  LAPACK routine that computes the norm of a matrix.
c     IGRAPHARPACKDLAPY2  LAPACK routine to compute sqrt(x**2+y**2) carefully.
c     IGRAPHARPACKDLARTG  LAPACK Givens rotation construction routine.
c     IGRAPHARPACKDLASCL  LAPACK routine for careful scaling of a matrix.
c     IGRAPHARPACKDLASET  LAPACK matrix initialization routine.
c     IGRAPHARPACKDLASR   LAPACK routine that applies an orthogonal transformation to 
c             a matrix.
c     IGRAPHARPACKDLASRT  LAPACK sorting routine.
c     IGRAPHARPACKDSTEQR  LAPACK routine that computes eigenvalues and eigenvectors
c             of a symmetric tridiagonal matrix.
c     IGRAPHARPACKXERBLA  LAPACK error handler routine.
c
c\Authors
c     Danny Sorensen               Phuong Vu
c     Richard Lehoucq              CRPC / Rice University
c     Dept. of Computational &     Houston, Texas
c     Applied Mathematics
c     Rice University           
c     Houston, Texas            
c
c\SCCS Information: @(#) 
c FILE: stqrb.F   SID: 2.5   DATE OF SID: 8/27/96   RELEASE: 2
c
c\Remarks
c     1. Starting with version 2.5, this routine is a modified version
c        of LAPACK version 2.0 subroutine SSTEQR. No lines are deleted,
c        only commeted out and new lines inserted.
c        All lines commented out have "c$$$" at the beginning.
c        Note that the LAPACK version 1.0 subroutine SSTEQR contained
c        bugs. 
c
c\EndLib
c
c-----------------------------------------------------------------------
c
      subroutine IGRAPHARPACKDSTQRB ( n, d, e, z, work, info )
c
c     %------------------%
c     | Scalar Arguments |
c     %------------------%
c
      integer    info, n
c
c     %-----------------%
c     | Array Arguments |
c     %-----------------%
c
      Double precision
     &           d( n ), e( n-1 ), z( n ), work( 2*n-2 )
c
c     .. parameters ..
      Double precision               
     &                   zero, one, two, three
      parameter          ( zero = 0.0D+0, one = 1.0D+0, 
     &                     two = 2.0D+0, three = 3.0D+0 )
      integer            maxit
      parameter          ( maxit = 30 )
c     ..
c     .. local scalars ..
      integer            i, icompz, ii, iscale, j, jtot, k, l, l1, lend,
     &                   lendm1, lendp1, lendsv, lm1, lsv, m, mm, mm1,
     &                   nm1, nmaxit
      Double precision               
     &                   anorm, b, c, eps, eps2, f, g, p, r, rt1, rt2,
     &                   s, safmax, safmin, ssfmax, ssfmin, tst
c     ..
c     .. external functions ..
      logical            IGRAPHARPACKLSAME
      Double precision
     &                   IGRAPHARPACKDLAMCH, IGRAPHARPACKDLANST, IGRAPHARPACKDLAPY2
      external           IGRAPHARPACKLSAME, IGRAPHARPACKDLAMCH, IGRAPHARPACKDLANST, IGRAPHARPACKDLAPY2
c     ..
c     .. external subroutines ..
      external           IGRAPHARPACKDLAE2, IGRAPHARPACKDLAEV2, IGRAPHARPACKDLARTG, IGRAPHARPACKDLASCL, IGRAPHARPACKDLASET, IGRAPHARPACKDLASR,
     &                   IGRAPHARPACKDLASRT, IGRAPHARPACKDSWAP, IGRAPHARPACKXERBLA
c     ..
c     .. intrinsic functions ..
      intrinsic          abs, max, sign, sqrt
c     ..
c     .. executable statements ..
c
c     test the input parameters.
c
      info = 0
c
c$$$      IF( IGRAPHARPACKLSAME( COMPZ, 'N' ) ) THEN
c$$$         ICOMPZ = 0
c$$$      ELSE IF( IGRAPHARPACKLSAME( COMPZ, 'V' ) ) THEN
c$$$         ICOMPZ = 1
c$$$      ELSE IF( IGRAPHARPACKLSAME( COMPZ, 'I' ) ) THEN
c$$$         ICOMPZ = 2
c$$$      ELSE
c$$$         ICOMPZ = -1
c$$$      END IF
c$$$      IF( ICOMPZ.LT.0 ) THEN
c$$$         INFO = -1
c$$$      ELSE IF( N.LT.0 ) THEN
c$$$         INFO = -2
c$$$      ELSE IF( ( LDZ.LT.1 ) .OR. ( ICOMPZ.GT.0 .AND. LDZ.LT.MAX( 1,
c$$$     $         N ) ) ) THEN
c$$$         INFO = -6
c$$$      END IF
c$$$      IF( INFO.NE.0 ) THEN
c$$$         CALL IGRAPHARPACKXERBLA( 'SSTEQR', -INFO )
c$$$         RETURN
c$$$      END IF
c
c    *** New starting with version 2.5 ***
c
      icompz = 2
c    *************************************
c
c     quick return if possible
c
      if( n.eq.0 )
     $   return
c
      if( n.eq.1 ) then
         if( icompz.eq.2 )  z( 1 ) = one
         return
      end if
c
c     determine the unit roundoff and over/underflow thresholds.
c
      eps = IGRAPHARPACKDLAMCH( 'e' )
      eps2 = eps**2
      safmin = IGRAPHARPACKDLAMCH( 's' )
      safmax = one / safmin
      ssfmax = sqrt( safmax ) / three
      ssfmin = sqrt( safmin ) / eps2
c
c     compute the eigenvalues and eigenvectors of the tridiagonal
c     matrix.
c
c$$      if( icompz.eq.2 )
c$$$     $   call IGRAPHARPACKDLASET( 'full', n, n, zero, one, z, ldz )
c
c     *** New starting with version 2.5 ***
c
      if ( icompz .eq. 2 ) then
         do 5 j = 1, n-1
            z(j) = zero
  5      continue
         z( n ) = one
      end if
c     *************************************
c
      nmaxit = n*maxit
      jtot = 0
c
c     determine where the matrix splits and choose ql or qr iteration
c     for each block, according to whether top or bottom diagonal
c     element is smaller.
c
      l1 = 1
      nm1 = n - 1
c
   10 continue
      if( l1.gt.n )
     $   go to 160
      if( l1.gt.1 )
     $   e( l1-1 ) = zero
      if( l1.le.nm1 ) then
         do 20 m = l1, nm1
            tst = abs( e( m ) )
            if( tst.eq.zero )
     $         go to 30
            if( tst.le.( sqrt( abs( d( m ) ) )*sqrt( abs( d( m+
     $          1 ) ) ) )*eps ) then
               e( m ) = zero
               go to 30
            end if
   20    continue
      end if
      m = n
c
   30 continue
      l = l1
      lsv = l
      lend = m
      lendsv = lend
      l1 = m + 1
      if( lend.eq.l )
     $   go to 10
c
c     scale submatrix in rows and columns l to lend
c
      anorm = IGRAPHARPACKDLANST( 'i', lend-l+1, d( l ), e( l ) )
      iscale = 0
      if( anorm.eq.zero )
     $   go to 10
      if( anorm.gt.ssfmax ) then
         iscale = 1
         call IGRAPHARPACKDLASCL( 'g', 0, 0, anorm, ssfmax, lend-l+1, 1, d( l ), n,
     $                info )
         call IGRAPHARPACKDLASCL( 'g', 0, 0, anorm, ssfmax, lend-l, 1, e( l ), n,
     $                info )
      else if( anorm.lt.ssfmin ) then
         iscale = 2
         call IGRAPHARPACKDLASCL( 'g', 0, 0, anorm, ssfmin, lend-l+1, 1, d( l ), n,
     $                info )
         call IGRAPHARPACKDLASCL( 'g', 0, 0, anorm, ssfmin, lend-l, 1, e( l ), n,
     $                info )
      end if
c
c     choose between ql and qr iteration
c
      if( abs( d( lend ) ).lt.abs( d( l ) ) ) then
         lend = lsv
         l = lendsv
      end if
c
      if( lend.gt.l ) then
c
c        ql iteration
c
c        look for small subdiagonal element.
c
   40    continue
         if( l.ne.lend ) then
            lendm1 = lend - 1
            do 50 m = l, lendm1
               tst = abs( e( m ) )**2
               if( tst.le.( eps2*abs( d( m ) ) )*abs( d( m+1 ) )+
     $             safmin )go to 60
   50       continue
         end if
c
         m = lend
c
   60    continue
         if( m.lt.lend )
     $      e( m ) = zero
         p = d( l )
         if( m.eq.l )
     $      go to 80
c
c        if remaining matrix is 2-by-2, use IGRAPHARPACKDLAE2 or IGRAPHARPACKDLAEV2
c        to compute its eigensystem.
c
         if( m.eq.l+1 ) then
            if( icompz.gt.0 ) then
               call IGRAPHARPACKDLAEV2( d( l ), e( l ), d( l+1 ), rt1, rt2, c, s )
               work( l ) = c
               work( n-1+l ) = s
c$$$               call IGRAPHARPACKDLASR( 'r', 'v', 'b', n, 2, work( l ),
c$$$     $                     work( n-1+l ), z( 1, l ), ldz )
c
c              *** New starting with version 2.5 ***
c
               tst      = z(l+1)
               z(l+1) = c*tst - s*z(l)
               z(l)   = s*tst + c*z(l)
c              *************************************
            else
               call IGRAPHARPACKDLAE2( d( l ), e( l ), d( l+1 ), rt1, rt2 )
            end if
            d( l ) = rt1
            d( l+1 ) = rt2
            e( l ) = zero
            l = l + 2
            if( l.le.lend )
     $         go to 40
            go to 140
         end if
c
         if( jtot.eq.nmaxit )
     $      go to 140
         jtot = jtot + 1
c
c        form shift.
c
         g = ( d( l+1 )-p ) / ( two*e( l ) )
         r = IGRAPHARPACKDLAPY2( g, one )
         g = d( m ) - p + ( e( l ) / ( g+sign( r, g ) ) )
c
         s = one
         c = one
         p = zero
c
c        inner loop
c
         mm1 = m - 1
         do 70 i = mm1, l, -1
            f = s*e( i )
            b = c*e( i )
            call IGRAPHARPACKDLARTG( g, f, c, s, r )
            if( i.ne.m-1 )
     $         e( i+1 ) = r
            g = d( i+1 ) - p
            r = ( d( i )-g )*s + two*c*b
            p = s*r
            d( i+1 ) = g + p
            g = c*r - b
c
c           if eigenvectors are desired, then save rotations.
c
            if( icompz.gt.0 ) then
               work( i ) = c
               work( n-1+i ) = -s
            end if
c
   70    continue
c
c        if eigenvectors are desired, then apply saved rotations.
c
         if( icompz.gt.0 ) then
            mm = m - l + 1
c$$$            call IGRAPHARPACKDLASR( 'r', 'v', 'b', n, mm, work( l ), work( n-1+l ),
c$$$     $                  z( 1, l ), ldz )
c
c             *** New starting with version 2.5 ***
c
              call IGRAPHARPACKDLASR( 'r', 'v', 'b', 1, mm, work( l ), 
     &                    work( n-1+l ), z( l ), 1 )
c             *************************************                             
         end if
c
         d( l ) = d( l ) - p
         e( l ) = g
         go to 40
c
c        eigenvalue found.
c
   80    continue
         d( l ) = p
c
         l = l + 1
         if( l.le.lend )
     $      go to 40
         go to 140
c
      else
c
c        qr iteration
c
c        look for small superdiagonal element.
c
   90    continue
         if( l.ne.lend ) then
            lendp1 = lend + 1
            do 100 m = l, lendp1, -1
               tst = abs( e( m-1 ) )**2
               if( tst.le.( eps2*abs( d( m ) ) )*abs( d( m-1 ) )+
     $             safmin )go to 110
  100       continue
         end if
c
         m = lend
c
  110    continue
         if( m.gt.lend )
     $      e( m-1 ) = zero
         p = d( l )
         if( m.eq.l )
     $      go to 130
c
c        if remaining matrix is 2-by-2, use IGRAPHARPACKDLAE2 or IGRAPHARPACKDLAEV2
c        to compute its eigensystem.
c
         if( m.eq.l-1 ) then
            if( icompz.gt.0 ) then
               call IGRAPHARPACKDLAEV2( d( l-1 ), e( l-1 ), d( l ), rt1, rt2, c, s )
c$$$               work( m ) = c
c$$$               work( n-1+m ) = s
c$$$               call IGRAPHARPACKDLASR( 'r', 'v', 'f', n, 2, work( m ),
c$$$     $                     work( n-1+m ), z( 1, l-1 ), ldz )
c
c               *** New starting with version 2.5 ***
c
                tst      = z(l)
                z(l)   = c*tst - s*z(l-1)
                z(l-1) = s*tst + c*z(l-1)
c               ************************************* 
            else
               call IGRAPHARPACKDLAE2( d( l-1 ), e( l-1 ), d( l ), rt1, rt2 )
            end if
            d( l-1 ) = rt1
            d( l ) = rt2
            e( l-1 ) = zero
            l = l - 2
            if( l.ge.lend )
     $         go to 90
            go to 140
         end if
c
         if( jtot.eq.nmaxit )
     $      go to 140
         jtot = jtot + 1
c
c        form shift.
c
         g = ( d( l-1 )-p ) / ( two*e( l-1 ) )
         r = IGRAPHARPACKDLAPY2( g, one )
         g = d( m ) - p + ( e( l-1 ) / ( g+sign( r, g ) ) )
c
         s = one
         c = one
         p = zero
c
c        inner loop
c
         lm1 = l - 1
         do 120 i = m, lm1
            f = s*e( i )
            b = c*e( i )
            call IGRAPHARPACKDLARTG( g, f, c, s, r )
            if( i.ne.m )
     $         e( i-1 ) = r
            g = d( i ) - p
            r = ( d( i+1 )-g )*s + two*c*b
            p = s*r
            d( i ) = g + p
            g = c*r - b
c
c           if eigenvectors are desired, then save rotations.
c
            if( icompz.gt.0 ) then
               work( i ) = c
               work( n-1+i ) = s
            end if
c
  120    continue
c
c        if eigenvectors are desired, then apply saved rotations.
c
         if( icompz.gt.0 ) then
            mm = l - m + 1
c$$$            call IGRAPHARPACKDLASR( 'r', 'v', 'f', n, mm, work( m ), work( n-1+m ),
c$$$     $                  z( 1, m ), ldz )
c
c           *** New starting with version 2.5 ***
c
            call IGRAPHARPACKDLASR( 'r', 'v', 'f', 1, mm, work( m ), work( n-1+m ),
     &                  z( m ), 1 )
c           *************************************                             
         end if
c
         d( l ) = d( l ) - p
         e( lm1 ) = g
         go to 90
c
c        eigenvalue found.
c
  130    continue
         d( l ) = p
c
         l = l - 1
         if( l.ge.lend )
     $      go to 90
         go to 140
c
      end if
c
c     undo scaling if necessary
c
  140 continue
      if( iscale.eq.1 ) then
         call IGRAPHARPACKDLASCL( 'g', 0, 0, ssfmax, anorm, lendsv-lsv+1, 1,
     $                d( lsv ), n, info )
         call IGRAPHARPACKDLASCL( 'g', 0, 0, ssfmax, anorm, lendsv-lsv, 1, e( lsv ),
     $                n, info )
      else if( iscale.eq.2 ) then
         call IGRAPHARPACKDLASCL( 'g', 0, 0, ssfmin, anorm, lendsv-lsv+1, 1,
     $                d( lsv ), n, info )
         call IGRAPHARPACKDLASCL( 'g', 0, 0, ssfmin, anorm, lendsv-lsv, 1, e( lsv ),
     $                n, info )
      end if
c
c     check for no convergence to an eigenvalue after a total
c     of n*maxit iterations.
c
      if( jtot.lt.nmaxit )
     $   go to 10
      do 150 i = 1, n - 1
         if( e( i ).ne.zero )
     $      info = info + 1
  150 continue
      go to 190
c
c     order eigenvalues and eigenvectors.
c
  160 continue
      if( icompz.eq.0 ) then
c
c        use quick sort
c
         call IGRAPHARPACKDLASRT( 'i', n, d, info )
c
      else
c
c        use selection sort to minimize swaps of eigenvectors
c
         do 180 ii = 2, n
            i = ii - 1
            k = i
            p = d( i )
            do 170 j = ii, n
               if( d( j ).lt.p ) then
                  k = j
                  p = d( j )
               end if
  170       continue
            if( k.ne.i ) then
               d( k ) = d( i )
               d( i ) = p
c$$$               call IGRAPHARPACKDSWAP( n, z( 1, i ), 1, z( 1, k ), 1 )
c           *** New starting with version 2.5 ***
c
               p    = z(k)
               z(k) = z(i)
               z(i) = p
c           *************************************
            end if
  180    continue
      end if
c
  190 continue
      return
c
c     %---------------%
c     | End of IGRAPHARPACKDSTQRB |
c     %---------------%
c
      end