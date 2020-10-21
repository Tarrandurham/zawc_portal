class ZCL_AWC_FO_EVENT definition
  public
  final
  create public .

public section.

  methods GET_LAST_EVENT
    importing
      !IT_FO_KEY type /BOBF/T_FRW_KEY
    returning
      value(RT_LAST_EVENT) type ZAWC_T_FO_EVENT .
  methods CREATE_EVENT
    importing
      !IS_EVENT_DATA type ZAWC_S_FO_EVENT
    exporting
      !ES_EVENT_DATA type ZAWC_S_FO_EVENT
    raising
      ZCX_AWC_FO_OVERVIEW .
  methods GET_EVENT_BY_KEY
    importing
      !IV_EVENT_KEY type /BOBF/CONF_KEY
    exporting
      !ES_EVENT type ZAWC_S_FO_EVENT .
  methods REVOKE_EVENT
    importing
      !IT_EVENT_KEYS type /BOBF/T_FRW_KEY .
  methods CONSTRUCTOR .
  methods GET_EVENTS_BY_FO
    importing
      !IV_FO_KEY type /BOBF/CONF_KEY
    exporting
      !ET_EVENT type ZAWC_T_FO_EVENT .
protected section.
private section.

  class-data GO_TOR_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .

  methods GET_EVENT_DESC
    importing
      !IV_EVENT_CODE type /SCMTMS/TOR_EVENT
    exporting
      !EV_EVENT_DESC type /SCMTMS/DESCRIPTION_S
    raising
      ZCX_AWC_FO_OVERVIEW .
ENDCLASS.



CLASS ZCL_AWC_FO_EVENT IMPLEMENTATION.


  METHOD constructor.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

  ENDMETHOD.


  METHOD create_event.
    DATA: ls_event_data TYPE /scmtms/s_tor_exec_k,
          lt_mod        TYPE /bobf/t_frw_modification.

    MOVE-CORRESPONDING is_event_data TO ls_event_data.
    GET TIME STAMP FIELD DATA(timestamp).

    NEW zcl_awc_fo_location( )->get_loc_by_uuid(
      EXPORTING
        iv_loc_uuid = ls_event_data-ext_loc_uuid    " Lokations-GUID (004) mit Konvertierungs-Exit
      IMPORTING
        es_loc_data = DATA(ls_loc_data)    " Adressdaten einer Lokation
    ).

    ls_event_data-key           = go_tor_srv_mgr->get_new_key( ).
    ls_event_data-actual_date   = timestamp.
    ls_event_data-actual_tzone  = ls_loc_data-time_zone_code.
    ls_event_data-execution_id  = ''.
    ls_event_data-created_by    = sy-uname.
    ls_event_data-created_on    = timestamp.
    ls_event_data-ext_loc_id    = is_event_data-ext_loc_id.

    /scmtms/cl_mod_helper=>mod_create_single(
      EXPORTING
        is_data        = ls_event_data
        iv_key         = ls_event_data-key
        iv_parent_key  = ls_event_data-parent_key
        iv_root_key    = ls_event_data-root_key
        iv_node        = /scmtms/if_tor_c=>sc_node-executioninformation
        iv_source_node = /scmtms/if_tor_c=>sc_node-root
        iv_association = /scmtms/if_tor_c=>sc_association-root-executioninformation_tr
*      IMPORTING
*        es_mod         =
      CHANGING
        ct_mod         = lt_mod
    ).

    go_tor_srv_mgr->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_mod_message)
    ).

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
     EXPORTING
       iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
     IMPORTING
       eo_message             = DATA(lo_sav_message)
       ev_rejected            = DATA(lv_rejected)
    ).

    IF lv_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_sav_message
          is_textid  = zcx_awc_fo_overview=>event_reporting_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

    MOVE-CORRESPONDING ls_event_data TO es_event_data.

    IF is_event_data-comment IS NOT INITIAL.
      NEW zcl_awc_fo_attachment( )->add_note_to_event(
        EXPORTING
          iv_text_type = 'TOREM'    " Textart
          iv_text      = is_event_data-comment    " Textinhalt
          iv_event_key = ls_event_data-key    " NodeID
          iv_fo_key = ls_event_data-parent_key
      ).
    ENDIF.

  ENDMETHOD.


  METHOD get_events_by_fo.

    DATA: lt_fo_keys    TYPE /bobf/t_frw_key,
          lt_exec_data  TYPE /scmtms/t_tor_exec_k,
          lo_location   TYPE REF TO zcl_awc_fo_location,
          lt_loc_keys   TYPE /bobf/t_frw_key,
          lt_event_keys TYPE /bobf/t_frw_key.

    CREATE OBJECT lo_location.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-exec
*        is_parameters           =
*        it_filtered_attributes  =
*        iv_fill_data            = ABAP_FALSE
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_change               =
*        eo_message              =
*        et_data                 =
        et_key_link             = DATA(lt_key_link)
        et_target_key           = DATA(lt_target_key)
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executioninformation
        it_key                  = lt_target_key
*    iv_before_image         = ABAP_FALSE
*    iv_edit_mode            =
*    iv_fill_data            = ABAP_TRUE
*    iv_invalidate_cache     = ABAP_FALSE
*    it_requested_attributes =
      IMPORTING
*    eo_message              =
*    eo_change               =
        et_data                 = lt_exec_data
*    et_failed_key           =
    ).

    MOVE-CORRESPONDING lt_exec_data TO et_event.

    LOOP AT et_event ASSIGNING FIELD-SYMBOL(<fs_event>).
      INSERT VALUE #( key = <fs_event>-ext_loc_uuid ) INTO TABLE lt_loc_keys.
      INSERT VALUE #( key = <fs_event>-key ) INTO TABLE lt_event_keys.
    ENDLOOP.

    lo_location->get_addr_by_loc(
      EXPORTING
        it_loc_uuid = lt_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
      IMPORTING
        et_loc_data = DATA(lt_loc_data)    " Adressdaten einer Lokation
    ).

    NEW zcl_awc_fo_attachment( )->get_notes_from_event(
      EXPORTING
        it_event_key = lt_event_keys    " AWC Key
      IMPORTING
        et_fo_note   = DATA(lt_event_notes)    " Tabellentyp Note
    ).

    IF et_event IS NOT INITIAL.
      LOOP AT et_event ASSIGNING FIELD-SYMBOL(<fs_event_data>).
        IF <fs_event_data>-ext_loc_uuid IS NOT INITIAL.
          READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<fs_loc_data>) WITH KEY loc_uuid =  <fs_event_data>-ext_loc_uuid.
          <fs_event_data>-name1 = <fs_loc_data>-name1.
        ENDIF.
        get_event_desc(
          EXPORTING
            iv_event_code = <fs_event_data>-event_code    " Ereignis, das bei einer Transportaktivität stattfindet
          IMPORTING
            ev_event_desc = <fs_event_data>-description_s    " Beschreibung
        ).
        IF lt_event_notes IS NOT INITIAL.
          READ TABLE lt_event_notes ASSIGNING FIELD-SYMBOL(<fs_event_notes>) WITH KEY event_key = <fs_event_data>-key.
          IF sy-subrc = 0.
            <fs_event_data>-comment = <fs_event_notes>-text.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_event_by_key.

    DATA: lt_event_keys TYPE /bobf/t_frw_key,
          lt_event_data TYPE /scmtms/t_tor_exec_k,
          lo_location   TYPE REF TO zcl_awc_fo_location,
          lt_loc_keys   TYPE /bobf/t_frw_key.

    CREATE OBJECT lo_location.

    INSERT VALUE #( key = iv_event_key ) INTO TABLE lt_event_keys.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executioninformation
        it_key                  = lt_event_keys
*        iv_before_image         = ABAP_FALSE
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = ABAP_FALSE
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_event_data
*        et_failed_key           =
    ).

    READ TABLE lt_event_data INDEX 1 INTO DATA(ls_event_data).
    MOVE-CORRESPONDING ls_event_data TO es_event.

    INSERT VALUE #( key = es_event-ext_loc_uuid ) INTO TABLE lt_loc_keys.

    lo_location->get_addr_by_loc(
      EXPORTING
        it_loc_uuid = lt_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
      IMPORTING
        et_loc_data = DATA(lt_loc_data)    " Adressdaten einer Lokation
    ).

    IF es_event IS NOT INITIAL.
        IF es_event-ext_loc_uuid IS NOT INITIAL.
          READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<fs_loc_data>) WITH KEY loc_uuid =  es_event-ext_loc_uuid.
          es_event-name1 = <fs_loc_data>-name1.
        ENDIF.
        get_event_desc(
          EXPORTING
            iv_event_code = es_event-event_code    " Ereignis, das bei einer Transportaktivität stattfindet
          IMPORTING
            ev_event_desc = es_event-description_s    " Beschreibung
        ).
    ENDIF.


*    lo_location->get_addr_by_loc(
*      EXPORTING
*        iv_loc_uuid = es_event-ext_loc_uuid    " Lokations-GUID (004) mit Konvertierungs-Exit
*      IMPORTING
*        es_loc_data = DATA(ls_loc_data)    " Adressdaten einer Lokation
*    ).

*    es_event-name1 = ls_loc_data-name1.

    get_event_desc(
      EXPORTING
        iv_event_code = es_event-event_code    " Ereignis, das bei einer Transportaktivität stattfindet
      IMPORTING
        ev_event_desc = es_event-description_s    " Beschreibung
    ).

  ENDMETHOD.


  METHOD get_event_desc.

    SELECT SINGLE description_s FROM /scmtms/c_ev_tyt WHERE tor_event = @iv_event_code INTO @ev_event_desc.

  ENDMETHOD.


  METHOD get_last_event.

    DATA: lt_fo_keys    TYPE /bobf/t_frw_key,
          lt_exec_data  TYPE /scmtms/t_tor_exec_k,
          lo_location   TYPE REF TO zcl_awc_fo_location,
          lt_loc_keys   TYPE /bobf/t_frw_key,
          lt_event_keys TYPE /bobf/t_frw_key,
          lt_event_data TYPE STANDARD TABLE OF /scmtms/s_tor_exec_k.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-exec
*        is_parameters           =
*        it_filtered_attributes  =
*        iv_fill_data            = ABAP_FALSE
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_change               =
*        eo_message              =
*        et_data                 =
        et_key_link             = DATA(lt_key_link)
        et_target_key           = DATA(lt_target_key)
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executioninformation
        it_key                  = lt_target_key
*    iv_before_image         = ABAP_FALSE
*    iv_edit_mode            =
    iv_fill_data            = abap_true
*    iv_invalidate_cache     = ABAP_FALSE
*    it_requested_attributes =
      IMPORTING
*    eo_message              =
*    eo_change               =
        et_data                 = lt_exec_data
*    et_failed_key           =
    ).

    MOVE-CORRESPONDING lt_exec_data TO lt_event_data.

    SORT lt_event_data DESCENDING BY actual_date.

    MOVE-CORRESPONDING lt_event_data TO rt_last_event.

  ENDMETHOD.


  METHOD revoke_event.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-executioninformation-revoke_event
        it_key               = it_event_keys
*            is_parameters        =
      IMPORTING
*            eo_change            =
        eo_message           = DATA(lo_act_message)
        et_failed_key        = data(lt_failed_key)
        et_failed_action_key = data(lt_failed_action_key)
*        et_data              =
).

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
      EXPORTING
        iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
      IMPORTING
        eo_message             = DATA(lo_sav_message)
    ).
  ENDMETHOD.
ENDCLASS.
