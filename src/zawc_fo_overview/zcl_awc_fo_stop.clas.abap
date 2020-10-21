CLASS zcl_awc_fo_stop DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_stops_by_fo
      IMPORTING
        !iv_fo_key   TYPE /bobf/conf_key
      EXPORTING
        !et_fo_stops TYPE zawc_t_fo_stop .
    METHODS move_stop
      IMPORTING
        !iv_fo_key          TYPE /bobf/conf_key
        !iv_successor_key   TYPE /bobf/conf_key
        !iv_predecessor_key TYPE /bobf/conf_key
        !iv_stop_key        TYPE /bobf/conf_key
      RAISING
        zcx_awc_fo_overview .
    METHODS constructor .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA go_tor_srv_mgr TYPE REF TO /bobf/if_tra_service_manager .

    METHODS get_actual_times
      IMPORTING
        !iv_stop_succ_key TYPE /bobf/conf_key
      EXPORTING
        !ev_act_dep_time  TYPE tzntstmps
        !ev_act_arr_time  TYPE tzntstmps .
    METHODS get_both_stop_data
      IMPORTING
        !it_succ_keys     TYPE /bobf/t_frw_key
      EXPORTING
        !es_inbound_data  TYPE /scmtms/s_tor_stop_k
        !es_outbound_data TYPE /scmtms/s_tor_stop_k .
    METHODS get_stop_loc
      CHANGING
        !ct_fo_stops TYPE zawc_t_fo_stop .
    METHODS get_stop_succ_data
      CHANGING
        !ct_stop_data TYPE zawc_t_fo_stop .
ENDCLASS.



CLASS ZCL_AWC_FO_STOP IMPLEMENTATION.


  METHOD constructor.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

  ENDMETHOD.


  METHOD get_actual_times.

    DATA: lt_stop_succ_keys TYPE /bobf/t_frw_key,
          lt_exec_dep       TYPE /scmtms/t_tor_exec_k,
          lt_exec_arr       TYPE /scmtms/t_tor_exec_k.

    INSERT VALUE #( key = iv_stop_succ_key ) INTO TABLE lt_stop_succ_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-stop_successor
        it_key                  = lt_stop_succ_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-stop_successor-execution_departure
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_exec_dep
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-stop_successor
        it_key                  = lt_stop_succ_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-stop_successor-execution_arrival
*            is_parameters           =
*            it_filtered_attributes  =
        iv_fill_data            = abap_true
*            iv_before_image         = ABAP_FALSE
*            iv_invalidate_cache     = ABAP_FALSE
*            iv_edit_mode            =
*            it_requested_attributes =
      IMPORTING
*            eo_message              =
*            eo_change               =
        et_data                 = lt_exec_arr
*            et_key_link             =
*            et_target_key           =
*            et_failed_key           =
    ).

    READ TABLE lt_exec_dep INDEX 1 INTO DATA(ls_exec_dep).
    ev_act_dep_time = ls_exec_dep-actual_date.

    READ TABLE lt_exec_arr INDEX 1 INTO DATA(ls_exec_arr).
    ev_act_arr_time = ls_exec_arr-actual_date.
  ENDMETHOD.


  METHOD get_both_stop_data.

    DATA: lt_both_stop_data TYPE /scmtms/t_tor_stop_k.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-stop_successor
        it_key                  = it_succ_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-stop_successor-both_stops
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_both_stop_data
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    LOOP AT lt_both_stop_data ASSIGNING FIELD-SYMBOL(<fs_both_stop>).
      IF <fs_both_stop>-stop_cat = 'O'.
        es_outbound_data = <fs_both_stop>.
      ENDIF.
      IF <fs_both_stop>-stop_cat = 'I'.
        es_inbound_data = <fs_both_stop>.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_stops_by_fo.

    DATA: lt_fo_keys   TYPE /bobf/t_frw_key,
          lt_succ_keys TYPE /bobf/t_frw_key,
          lt_stop_succ TYPE /scmtms/t_tor_stop_succ_k.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.


    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-stop_succ
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_stop_succ
*        et_key_link             =
*        et_target_key           = lt_succ_keys
*        et_failed_key           =
    ).

    MOVE-CORRESPONDING lt_stop_succ TO et_fo_stops.

    LOOP AT et_fo_stops ASSIGNING FIELD-SYMBOL(<fs_fo_stops>).

      INSERT VALUE #( key = <fs_fo_stops>-key ) INTO TABLE lt_succ_keys.

      get_both_stop_data(
        EXPORTING
          it_succ_keys     = lt_succ_keys
        IMPORTING
          es_inbound_data  = DATA(ls_inbound_data)
          es_outbound_data = DATA(ls_outbound_data)
      ).

      <fs_fo_stops>-src_log_loc_uuid    = ls_outbound_data-log_loc_uuid.
      <fs_fo_stops>-des_log_loc_uuid    = ls_inbound_data-log_loc_uuid.
      <fs_fo_stops>-src_log_locid       = ls_outbound_data-log_locid.
      <fs_fo_stops>-des_log_locid       = ls_inbound_data-log_locid.
      <fs_fo_stops>-src_plan_trans_time = ls_outbound_data-plan_trans_time.
      <fs_fo_stops>-des_plan_trans_time = ls_inbound_data-plan_trans_time.
      <fs_fo_stops>-load_begin          = ls_outbound_data-aggr_assgn_start_l.
      <fs_fo_stops>-load_end            = ls_outbound_data-aggr_assgn_end_l.
      <fs_fo_stops>-unload_begin        = ls_inbound_data-aggr_assgn_start_l.
      <fs_fo_stops>-unload_end          = ls_inbound_data-aggr_assgn_end_l.
    ENDLOOP.

    get_stop_loc(
      CHANGING
        ct_fo_stops = et_fo_stops    " Tabellentyp Abschnitte
    ).

  ENDMETHOD.


  METHOD get_stop_loc.

    DATA: lo_location     TYPE REF TO zcl_awc_fo_location,
          lt_src_loc_keys TYPE /bobf/t_frw_key,
          lt_des_loc_keys TYPE /bobf/t_frw_key,
          ls_src_loc_data TYPE zawc_s_fo_loc,
          ls_des_loc_data TYPE zawc_s_fo_loc.

    CREATE OBJECT lo_location.

    LOOP AT ct_fo_stops ASSIGNING FIELD-SYMBOL(<fs_fo_stops>).

      CLEAR lt_src_loc_keys.
      INSERT VALUE #( key = <fs_fo_stops>-src_log_loc_uuid ) INTO TABLE lt_src_loc_keys.

      CLEAR lt_des_loc_keys.
      INSERT VALUE #( key = <fs_fo_stops>-des_log_loc_uuid ) INTO TABLE lt_des_loc_keys.

      lo_location->get_addr_by_loc(
        EXPORTING
          it_loc_uuid = lt_src_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
        IMPORTING
          et_loc_data = DATA(lt_src_loc_data)    " Adressdaten einer Lokation
      ).

      READ TABLE lt_src_loc_data INDEX 1 INTO ls_src_loc_data.

      <fs_fo_stops>-src_loc_name1               = ls_src_loc_data-name1.
      <fs_fo_stops>-src_loc_country_code        = ls_src_loc_data-country_code.
      <fs_fo_stops>-src_loc_region              = ls_src_loc_data-region.
      <fs_fo_stops>-src_loc_city_name           = ls_src_loc_data-city_name.
      <fs_fo_stops>-src_loc_street_postal_code  = ls_src_loc_data-street_postal_code.
      <fs_fo_stops>-src_loc_street_name         = ls_src_loc_data-street_name.
      <fs_fo_stops>-src_loc_house_id            = ls_src_loc_data-house_id.
      <fs_fo_stops>-src_time_zone_code          = ls_src_loc_data-time_zone_code.

      lo_location->get_addr_by_loc(
        EXPORTING
          it_loc_uuid = lt_des_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
        IMPORTING
          et_loc_data = DATA(lt_des_loc_data)    " Adressdaten einer Lokation
      ).

      READ TABLE lt_des_loc_data INDEX 1 INTO ls_des_loc_data.

      <fs_fo_stops>-des_loc_name1               = ls_des_loc_data-name1.
      <fs_fo_stops>-des_loc_country_code        = ls_des_loc_data-country_code.
      <fs_fo_stops>-des_loc_region              = ls_des_loc_data-region.
      <fs_fo_stops>-des_loc_city_name           = ls_des_loc_data-city_name.
      <fs_fo_stops>-des_loc_street_postal_code  = ls_des_loc_data-street_postal_code.
      <fs_fo_stops>-des_loc_street_name         = ls_des_loc_data-street_name.
      <fs_fo_stops>-des_loc_house_id            = ls_des_loc_data-house_id.
      <fs_fo_stops>-des_time_zone_code          = ls_des_loc_data-time_zone_code.

*      IF <fs_fo_stops>-stop_cat = 'O'.
*        <fs_fo_stops>-time_zone_code = ls_src_loc_data-time_zone_code.
*      ENDIF.
*      IF <fs_fo_stops>-stop_cat = 'I'.
*        <fs_fo_stops>-time_zone_code = ls_des_loc_data-time_zone_code.
*      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_stop_succ_data.

    DATA: lt_stop_keys    TYPE /bobf/t_frw_key,
          lt_succ_keys    TYPE /bobf/t_frw_key,
          lt_stop_succ    TYPE /scmtms/t_tor_stop_succ_k,
          lv_act_dep_time TYPE tzntstmps,
          lv_act_arr_time TYPE tzntstmps.

    LOOP AT ct_stop_data ASSIGNING FIELD-SYMBOL(<fs_stop_data>).

      INSERT VALUE #( key = <fs_stop_data>-key ) INTO TABLE lt_stop_keys.

      go_tor_srv_mgr->retrieve_by_association(
        EXPORTING
          iv_node_key             = /scmtms/if_tor_c=>sc_node-stop
          it_key                  = lt_stop_keys
          iv_association          = /scmtms/if_tor_c=>sc_association-stop-stop_successor
*          is_parameters           =
*          it_filtered_attributes  =
          iv_fill_data            = abap_true
*          iv_before_image         = ABAP_FALSE
*          iv_invalidate_cache     = ABAP_FALSE
*          iv_edit_mode            =
*          it_requested_attributes =
        IMPORTING
*          eo_message              =
*          eo_change               =
          et_data                 = lt_stop_succ
*          et_key_link             =
          et_target_key           = lt_succ_keys
*          et_failed_key           =
      ).

      LOOP AT lt_stop_succ ASSIGNING FIELD-SYMBOL(<fs_stop_succ>).
        <fs_stop_data>-successor_id = <fs_stop_succ>-successor_id.
        <fs_stop_data>-distance_km = <fs_stop_succ>-distance_km.
        <fs_stop_data>-duration_net = <fs_stop_succ>-duration_net.
        <fs_stop_data>-max_util = <fs_stop_succ>-max_util.

        get_actual_times(
          EXPORTING
            iv_stop_succ_key = CONV #( <fs_stop_succ>-key )    " NodeID
          IMPORTING
            ev_act_dep_time  = lv_act_dep_time    " UTC-Zeitstempel in Kurzform (JJJJMMTThhmmss)
            ev_act_arr_time  = lv_act_arr_time    " UTC-Zeitstempel in Kurzform (JJJJMMTThhmmss)
        ).

        <fs_stop_data>-act_dep_time = lv_act_dep_time.
        <fs_stop_data>-act_arr_time = lv_act_arr_time.
      ENDLOOP.

      get_both_stop_data(
        EXPORTING
          it_succ_keys     = lt_succ_keys
        IMPORTING
          es_inbound_data  = DATA(ls_inbound_data)
          es_outbound_data = DATA(ls_outbound_data)
      ).

      <fs_stop_data>-src_log_loc_uuid     = ls_outbound_data-log_loc_uuid.
      <fs_stop_data>-des_log_loc_uuid     = ls_inbound_data-log_loc_uuid.
      <fs_stop_data>-src_log_locid        = ls_outbound_data-log_locid.
      <fs_stop_data>-des_log_locid        = ls_inbound_data-log_locid.
      <fs_stop_data>-src_plan_trans_time  = ls_outbound_data-plan_trans_time.
      <fs_stop_data>-des_plan_trans_time  = ls_inbound_data-plan_trans_time.
    ENDLOOP.

  ENDMETHOD.


  METHOD move_stop.

    DATA: ls_move_stop   TYPE /scmtms/s_tor_a_move_stop,
          lr_s_move_stop TYPE REF TO data.

    ls_move_stop-lv_root_key = iv_fo_key.
    ls_move_stop-predecessor_key = iv_predecessor_key.
    ls_move_stop-successor_key = iv_successor_key.
    INSERT VALUE #( key = iv_stop_key ) INTO TABLE ls_move_stop-lt_stop_key.

    GET REFERENCE OF ls_move_stop INTO lr_s_move_stop.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-stop-move_stop
        it_key               = ls_move_stop-lt_stop_key
        is_parameters        = lr_s_move_stop
      IMPORTING
*        eo_change            =
        eo_message           = DATA(lo_act_message)
        et_failed_key        = DATA(lt_failed_key)
*        et_failed_action_key =
*        et_data              =
    ).

    IF lt_failed_key IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_act_message
          is_textid     = zcx_awc_fo_overview=>stop_movement_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
      EXPORTING
      iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
      IMPORTING
      eo_message             = DATA(lo_sav_message)
      ev_rejected            = DATA(lv_sav_rejected)
    ).

    IF lv_sav_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_sav_message
          is_textid     = zcx_awc_fo_overview=>stop_movement_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
