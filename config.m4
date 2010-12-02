PHP_ARG_ENABLE(gdal,
  [whether to enable GDAL extension support],
  [  --enable-gdal           Enable GDAL extension support])

if test "$PHP_GDAL" != "no"; then
  AC_DEFINE(HAVE_GDAL, 1, [Whether you have GDAL])
  dnl  --with-ogr -> check with-path
  SEARCH_PATH="/usr/local /usr"
  SEARCH_FOR="/bin/gdal-config" # modified by okapi

  if test -r $PHP_GDAL/; then
    GDAL_DIR=$PHP_GDAL
  else # search default path list
    AC_MSG_CHECKING([for ORG files in default path])
    for i in $SEARCH_PATH ; do
      if test -r $i/$SEARCH_FOR; then
        GDAL_DIR=$i
        AC_MSG_RESULT(found in $i)
      fi
    done
  fi

  if test -z "$GDAL_DIR"; then
    AC_MSG_RESULT([not found])
    AC_MSG_ERROR([Please install the GDAL distribution])
  fi

  if ${GDAL_DIR}/bin/gdal-config --libs print > /dev/null 2>&1; then
    GDAL_CONFIG=${GDAL_DIR}/bin/gdal-config
  else
    if ${GDAL_DIR}/gdal-config --libs print > /dev/null 2>&1; then
       GDAL_CONFIG=${GDAL_DIR}/gdal-config
    fi
  fi

  ogr_version_full=`$GDAL_CONFIG --version`
  ogr_version=`echo ${ogr_version_full} | awk 'BEGIN { FS = "."; } { printf "%d", ($1 * 1000 + $2) * 1000 + $3;}'`
  if test "$ogr_version" -ge 1007003; then
    AC_MSG_RESULT($ogr_version_full)
    GDAL_LIBS=`$GDAL_CONFIG --libs`
    GDAL_CFLAGS=`$GDAL_CONFIG --cflags`
  else
    AC_MSG_ERROR(GDAL version 1.7.3 or later is required to compile php with GDAL support)
  fi

  PHP_EVAL_INCLINE($GDAL_CFLAGS)
  PHP_ADD_INCLUDE($GDAL_DIR/include)
  PHP_EVAL_LIBLINE($GDAL_LIBS, GDAL_SHARED_LIBADD)

  if test x`$GDAL_CONFIG --ogr-enabled` = "xyes" ; then
      AC_DEFINE(HAVE_GDAL,1,[ ])
  else
      AC_MSG_ERROR(GDAL support not found.  Please make sure your GDAL includes OGR support.)
  fi


  PHP_REQUIRE_CXX()
  PHP_SUBST(GDAL_SHARED_LIBADD)
  PHP_ADD_LIBRARY(stdc++, 1, GDAL_SHARED_LIBADD)
  PHP_NEW_EXTENSION(gdal, gdal.cc cpl.cc ogr.cc ogrsfdriverregistrar.cc ogrlayer.cc, $ext_shared)
fi
