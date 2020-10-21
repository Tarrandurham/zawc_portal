class ZCL_ZAWC_LOCATION_DPC_EXT definition
  public
  inheriting from ZCL_ZAWC_LOCATION_DPC
  create public .

public section.
protected section.

  methods ETCLIENTSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZAWC_LOCATION_DPC_EXT IMPLEMENTATION.


  METHOD etclientset_get_entityset.
    SELECT SINGLE client, outb_active, globdat_active
      FROM zawc_loc_client
      INTO @DATA(ls_loc_client).
    IF sy-subrc <> 0.
*     Keine Client-Einstellungen gepflegt.
    ELSE.
      APPEND ls_loc_client TO et_entityset.
    ENDIF.

**TRY.
*CALL METHOD SUPER->ETCLIENTSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  ENDMETHOD.
ENDCLASS.
