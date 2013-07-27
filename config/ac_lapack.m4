AC_DEFUN([AC_LAPACK],
  [
  AC_SUBST(LAPACK_LDFLAGS)
  AC_SUBST(LAPACK_LIBS)
  AC_SUBST(EXAMPLE_LAPACK)
  AC_SUBST(OBJ_LAPACK)
    
  AC_ARG_WITH(atlas,
    AC_HELP_STRING([--with-atlas=LIBS],[ATLAS library]),
    [
    if test "x$withval" = "xno"; then
      atlas=no
    else
      atlas=yes
      blas=no
      if test "x$withval" != "xyes"; then
        atlas_flags=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`
      fi
    fi
    ]
  )
  
  AC_ARG_WITH(blas,
    AC_HELP_STRING([--with-blas=LIBS],[BLAS library]),
    [
    if test "x$withval" = "xno" ; then
      blas=no
    else
      blas=yes
      atlas=no
      if test "x$withval" != "xyes" ; then
        blas_flags=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`
      fi
    fi
    ]
  )

  if test "x$blas" = x; then
    blas=yes
  fi
  if test "x$atlas" = x; then
    atlas=yes
  fi
  
  lapack=yes
  
  AC_ARG_WITH(lapack,
    AC_HELP_STRING([--with-lapack=LIBS],[LAPACK library]),
    [
    if test "x$blas" = "xno" ; then
      if test "x$atlas" = "xno" ; then
        AC_MSG_ERROR([LAPACK needs either BLAS or ATLAS])
      fi
    fi
    if test "x$withval" = "xno"; then
      lapack=no
    else
      lapack=yes
      if test "x$withval" != "xyes"; then
        lapack_flags=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`
      fi
    fi
    ]
  )

  AC_ARG_WITH(atlas-dir,
    AC_HELP_STRING([--with-atlas-dir=DIR],[ATLAS lib directory]),
    [atlas_dir=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`]
  )
  AC_ARG_WITH(blas-dir,
    AC_HELP_STRING([--with-blas-dir=DIR],[BLAS lib directory]),
    [blas_dir=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`]
  )
  AC_ARG_WITH(lapack-dir,
    AC_HELP_STRING([--with-lapack-dir=DIR],[LAPACK lib directory]),
    [lapack_dir=`echo "$withval" | sed 's,//*,/,g' | sed 's,/$,,'`]
  )

  if test -n "$blas_dir"; then
    AC_MSG_CHECKING([for BLAS library directory])
    AC_MSG_RESULT([$blas_dir])
    if test -d "$blas_dir"; then 
      LAPACK_LDFLAGS="-L$blas_dir"
    fi
  fi

  if test -n "$atlas_dir"; then
    AC_MSG_CHECKING([for ATLAS library directory])
    AC_MSG_RESULT([$atlas_dir])
    if test -d "$atlas_dir"; then 
      LAPACK_LDFLAGS="-L$atlas_dir $LAPACK_LDFLAGS"
    fi
  fi

  if test -n "$lapack_dir"; then
    AC_MSG_CHECKING([for LAPACK library directory])
    AC_MSG_RESULT([$lapack_dir])
    if test -d "$lapack_dir"; then
      LAPACK_LDFLAGS="-L$lapack_dir $LAPACK_LDFLAGS"
    fi
  fi
  
  AC_LANG_SAVE
  AC_LANG_C
  ac_save_LDFLAGS=$LDFLAGS
  ac_save_LIBS=$LIBS
  LDFLAGS="$LAPACK_LDFLAGS $LDFLAGS"


  if test "atlas" != no ; then
    found=no
    if test "x$atlas_flags" != "x" ; then
      if test "x$atlas_flags" != "xyes" ; then
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$atlas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dgemm() in $LAPACK_LDFLAGS $atlas_flags])
        AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
      fi
    fi
    if test "$found" = no ; then
      atlas_flags=
      LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
      LIBS="$atlas_flags $ac_save_LIBS"
      AC_MSG_CHECKING([for dgemm() in $LAPACK_LDFLAGS $atlas_flags])
      AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
    fi
    if test "$found" = no ;  then
      for atlas_flags in '-lf77blas -latlas' '-lf77blas -latlas -lI77 -lF77' '-lf77blas -latlas -lf2c' ; do
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$atlas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dgemm() in $LAPACK_LDFLAGS $atlas_flags])
        AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
        if test "$found" = no ; then
          if test "x$atlas_dir" = x ; then
            for atlas_dir in $HOME $HOME/src $prefix $prefix/src /usr /usr/local /usr/local/src; do
              LDFLAGS="-L$atlas_dir/lib $LAPACK_LDFLAGS $ac_save_LDFLAGS"
              AC_MSG_CHECKING([for dgemm() in -L$atlas_dir/lib $LAPACK_LDFLAGS $atlas_flags])
              AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
              LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
              if test "$found" = yes ; then
                LAPACK_LDFLAGS="-L$atlas_dir/lib $LAPACK_LDFLAGS"
                break
              fi
            done
            atlas_dir=
          fi
        fi
        if test "$found" = yes ; then
          break
        fi
      done
    fi
  
    if test "$found" = no ; then
      if test "$blas" != no; then
        blas=yes
      fi
      atlas=no
      atlas_flags=
    else
      blas=no
    fi
  fi 
  
  if test "$blas" != no ; then
    found=no
    if test "x$blas_flags" != "x" ; then
      if test "x$blas_flags" != "xyes" ; then
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$blas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dgemm() in $LAPACK_LDFLAGS $blas_flags])
        AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
      fi
    fi
    if test "$found" = no ; then
      blas_flags=
      LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
      LIBS="$blas_flags $ac_save_LIBS"
      AC_MSG_CHECKING([for dgemm() in $LAPACK_LDFLAGS $blas_flags])
      AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
    fi
    if test "$found" = no ;  then
      for blas_flags in -lblas '-lblas -lg2c' '-lblas -lf2c' '-lblas -lpgftnrtl -lpgc'; do
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$blas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dgemm() in $blas_flags])
        AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
        if test "$found" = no ; then
          if test "x$blas_dir" = x ; then
            for blas_dir in $HOME $HOME/src $prefix $prefix/src /usr /usr/local /usr/local/src; do
              LDFLAGS="-L$blas_dir/lib $LAPACK_LDFLAGS $ac_save_LDFLAGS"
              AC_MSG_CHECKING([for dgemm() in -L$blas_dir/lib $LAPACK_LDFLAGS $blas_flags])
              AC_TRY_LINK([],[dgemm_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
              LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
              if test "$found" = yes ; then
                LAPACK_LDFLAGS="-L$blas_dir/lib $LAPACK_LDFLAGS"
                break
              fi
            done
            blas_dir=
          fi
        fi
        if test "$found" = yes ; then
          break
        fi
      done
    fi
  
    if test "$found" = no ; then
      blas=no
      blas_flags=
    else
      blas=yes
    fi
  fi

  if test "$lapack" != no ; then
    found=no
    if test "x$lapack_flags" != "x" ; then
      if test "x$lapack_flags" != "xyes" ; then
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$lapack_flags $atlas_flags $blas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dsyev() in $LAPACK_LDFLAGS $lapack_flags $atlas_flags $blas_flags])
        AC_TRY_LINK([],[dsyev_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
      fi
    fi
    if test "$found" = no ; then
      lapack_flags=
      LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
      LIBS="$lapack_flags $atlas_flags $blas_flags $ac_save_LIBS"
      AC_MSG_CHECKING([for dsyev() in $LAPACK_LDFLAGS $lapack_flags $atlas_flags $blas_flags])
      AC_TRY_LINK([],[dsyev_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
    fi
    if test "$found" = no ;  then
      for lapack_flags in -llapack '-llapack -lf2c'; do
        LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
        LIBS="$lapack_flags $atlas_flags $blas_flags $ac_save_LIBS"
        AC_MSG_CHECKING([for dsyev() in $LAPACK_LDFLAGS $lapack_flags $atlas_flags $blas_flags])
        AC_TRY_LINK([],[dsyev_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
        if test "$found" = no ; then
          if test "x$lapack_dir" = x ; then
            for lapack_dir in $HOME $HOME/src $prefix $prefix/src /usr /usr/local /usr/local/src; do
              LDFLAGS="-L$lapack_dir/lib $LAPACK_LDFLAGS $ac_save_LDFLAGS"
              AC_MSG_CHECKING([for dsyev() in -L$lapack_dir/lib $LAPACK_LDFLAGS $lapack_flags $atlas_flags $blas_flags])
              AC_TRY_LINK([],[dsyev_();],
                    [AC_MSG_RESULT(yes); found=yes],
                    AC_MSG_RESULT(no))
              LDFLAGS="$LAPACK_LDFLAGS $ac_save_LDFLAGS"
              if test "$found" = yes ; then
                LAPACK_LDFLAGS="-L$lapack_dir/lib $LAPACK_LDFLAGS"
                break
              fi
            done
            lapack_dir=
          fi
        fi
        if test "$found" = yes ; then
          break
        fi
      done
    fi
  
    if test "$found" = no ; then
      lapack=no
    else
      lapack=yes
    fi
  fi

  LDFLAGS=$ac_save_LDFLAGS
  LIBS=$ac_save_LIBS
  AC_LANG_RESTORE

  LAPACK_LIBS="$lapack_flags $atlas_flags $blas_flags"
  
  if test "$atlas" != no; then
    ac_cv_have_atlas=yes
    AC_DEFINE(IETL_HAVE_BLAS)
    AC_DEFINE(IETL_HAVE_ATLAS)
    AC_MSG_NOTICE([enabling ATLAS support])
  else
    ac_cv_have_atlas=no
    AC_MSG_NOTICE([disabling ATLAS support])
  fi

  if test "$blas" != no; then
    ac_cv_have_blas=yes
    AC_DEFINE(ALPS_HAVE_BLAS)
    AC_MSG_NOTICE([enabling BLAS support])
  else
    ac_cv_have_blas=no
    AC_MSG_NOTICE([disabling BLAS support])
  fi

  if test "$lapack" != no; then
    ac_cv_have_lapack=yes
    AC_DEFINE(IETL_HAVE_LAPACK)
    EXAMPLE_LAPACK='$(EXAMPLE_LAPACK)'
    OBJ_LAPACK='$(OBJ_LAPACK)'
    AC_MSG_NOTICE([enabling LAPACK support])
  else
    ac_cv_have_lapack=no
    AC_MSG_NOTICE([disabling LAPACK support])
  fi

  ]
)
