*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZAWC_LOC_CLIENT
*   generation date: 26.05.2020 at 12:08:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZAWC_LOC_CLIENT    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
