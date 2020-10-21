*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 26.05.2020 at 12:08:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZAWC_LOC_CLIENT.................................*
DATA:  BEGIN OF STATUS_ZAWC_LOC_CLIENT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAWC_LOC_CLIENT               .
CONTROLS: TCTRL_ZAWC_LOC_CLIENT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZAWC_LOC_CLIENT               .
TABLES: ZAWC_LOC_CLIENT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
