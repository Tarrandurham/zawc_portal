class ZCL_AWC_DOCK_APP definition
  public
  final
  create public .

public section.

  methods CREATE_DOCK_APP
    importing
      !IS_CREATE type /SCWM/S_DSAPP_ROOT_K
    exporting
      !ET_DOCK_APP type /SCWM/S_DSAPP_ROOT_K .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AWC_DOCK_APP IMPLEMENTATION.


  method CREATE_DOCK_APP.

*DATA: ls_event_data TYPE /scmtms/s_tor_exec_k,
*          lt_mod        TYPE /bobf/t_frw_modification.
*
*    MOVE-CORRESPONDING is_event_data TO ls_event_data.
*    GET TIME STAMP FIELD DATA(timestamp).
*
*    NEW zcl_awc_fo_location( )->get_loc_by_uuid(
*      EXPORTING
*        iv_loc_uuid = ls_event_data-ext_loc_uuid    " Lokations-GUID (004) mit Konvertierungs-Exit
*      IMPORTING
*        es_loc_data = DATA(ls_loc_data)    " Adressdaten einer Lokation
*    ).
*
*    ls_event_data-key           = go_tor_srv_mgr->get_new_key( ).
*    ls_event_data-actual_date   = timestamp.
*    ls_event_data-actual_tzone  = ls_loc_data-time_zone_code.
*    ls_event_data-execution_id  = ''.
*    ls_event_data-created_by    = sy-uname.
*    ls_event_data-created_on    = timestamp.
*    ls_event_data-ext_loc_id    = is_event_data-ext_loc_id.
*
*    /scmtms/cl_mod_helper=>mod_create_single(
*      EXPORTING
*        is_data        = ls_event_data
*        iv_key         = ls_event_data-key
*        iv_parent_key  = ls_event_data-parent_key
*        iv_root_key    = ls_event_data-root_key
*        iv_node        = /scmtms/if_tor_c=>sc_node-executioninformation
*        iv_source_node = /scmtms/if_tor_c=>sc_node-root
*        iv_association = /scmtms/if_tor_c=>sc_association-root-executioninformation_tr
**      IMPORTING
**        es_mod         =
*      CHANGING
*        ct_mod         = lt_mod
*    ).
*
*    go_tor_srv_mgr->modify(
*      EXPORTING
*        it_modification = lt_mod
*      IMPORTING
**        eo_change       =
*        eo_message      = DATA(lo_mod_message)
*    ).
*
*    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
*     EXPORTING
*       iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
*     IMPORTING
*       eo_message             = DATA(lo_sav_message)
*       ev_rejected            = DATA(lv_rejected)
*    ).
*
*    IF lv_rejected IS NOT INITIAL.
*      NEW zcl_awc_fo_overview_helper( )->raise_exception(
*        EXPORTING
*          io_message = lo_sav_message
*          is_textid  = zcx_awc_fo_overview=>event_reporting_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
*      ).
*    ENDIF.
*
*    MOVE-CORRESPONDING ls_event_data TO es_event_data.
*
*    IF is_event_data-comment IS NOT INITIAL.
*      NEW zcl_awc_fo_attachment( )->add_note_to_event(
*        EXPORTING
*          iv_text_type = 'TOREM'    " Textart
*          iv_text      = is_event_data-comment    " Textinhalt
*          iv_event_key = ls_event_data-key    " NodeID
*          iv_fo_key = ls_event_data-parent_key
*      ).
*    ENDIF.

DATA: ls_dock_app TYPE /scwm/s_dsapp_root_k,
      lt_mod        TYPE /bobf/t_frw_modification.

  DATA(lo_srv_dsapp) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /SCWM/IF_DSAPP_C=>sc_bo_key ).
  DATA(lo_dsapp_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /SCWM/IF_DSAPP_C=>sc_bo_key ).
  DATA(lo_transaction_mgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).



    MOVE-CORRESPONDING is_create TO ls_dock_app.
    GET TIME STAMP FIELD DATA(timestamp).

  ls_dock_app-key = lo_srv_dsapp->get_new_key( ).
  ls_dock_app-root_key = ls_dock_app-key.


  ls_dock_app-created_by = sy-uname.
  ls_dock_app-created_on = timestamp.




*    /scmtms/cl_mod_helper=>mod_create_single(
*      EXPORTING
*        is_data        = ls_dock_app
*        iv_key         = ls_dock_app-key
*        iv_parent_key  = ls_dock_app-parent_key
*        iv_root_key    = ls_dock_app-root_key
*        iv_node        = /SCWM/IF_DSAPP_C=>sc_node-root
*      CHANGING
*        ct_mod         = lt_mod
*    ).

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_dock_app
*          iv_key         =                  " NodeID
*          iv_parent_key  =                  " NodeID
*          iv_root_key    =                  " NodeID
          iv_node        =  /SCWM/IF_DSAPP_C=>sc_node-root
*          iv_source_node =                  " Node
*          iv_association =                  " Association
*        IMPORTING
*          es_mod         =                  " Change
        CHANGING
          ct_mod         = lt_mod
).

*    ls_event_data-key           = go_tor_srv_mgr->get_new_key( ).
*    ls_event_data-actual_date   = timestamp.
*    ls_event_data-actual_tzone  = ls_loc_data-time_zone_code.
*    ls_event_data-execution_id  = ''.
*    ls_event_data-created_by    = sy-uname.
*    ls_event_data-created_on    = timestamp.
*    ls_event_data-ext_loc_id    = is_event_data-ext_loc_id.
*
*    /scmtms/cl_mod_helper=>mod_create_single(
*      EXPORTING
*        is_data        = ls_event_data
*        iv_key         = ls_event_data-key
*        iv_parent_key  = ls_event_data-parent_key
*        iv_root_key    = ls_event_data-root_key
*        iv_node        = /scmtms/if_tor_c=>sc_node-executioninformation
*        iv_source_node = /scmtms/if_tor_c=>sc_node-root
*        iv_association = /scmtms/if_tor_c=>sc_association-root-executioninformation_tr
**      IMPORTING
**        es_mod         =
*      CHANGING
*        ct_mod         = lt_mod
*    ).
*
    lo_srv_dsapp->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_mod_message)
    ).
*

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
     EXPORTING
       iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
     IMPORTING
       eo_message             = DATA(lo_sav_message)
       ev_rejected            = DATA(lv_rejected)
    ).
*
*    IF lv_rejected IS NOT INITIAL.
*      NEW zcl_awc_fo_overview_helper( )->raise_exception(
*        EXPORTING
*          io_message = lo_sav_message
*          is_textid  = zcx_awc_fo_overview=>event_reporting_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
*      ).
*    ENDIF.
*
*    MOVE-CORRESPONDING ls_event_data TO es_event_data.


  endmethod.
ENDCLASS.
