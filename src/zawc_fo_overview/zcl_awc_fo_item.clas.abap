class ZCL_AWC_FO_ITEM definition
  public
  final
  create public .

public section.

  methods REASSIGN_FU
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
      !IV_FO_KEY type /BOBF/CONF_KEY .
  methods GET_ITEM_BY_KEY
    importing
      !IV_ITEM_KEY type /BOBF/CONF_KEY
    exporting
      !ES_ITEM_DATA type ZAWC_S_FO_ITEM .
  methods UPDATE_ACT_VAL
    importing
      !IS_UPDATE_FO_ITEM type ZAWC_S_FO_ITEM
    raising
      ZCX_AWC_FO_OVERVIEW .
  methods CONSTRUCTOR .
  methods GET_ITEMS_BY_FO
    importing
      !IV_FO_KEY type /BOBF/CONF_KEY
    exporting
      !ET_FO_ITEMS type ZAWC_T_FO_ITEM .
    methods DELETE_FU_ASSIGNMENTS
    importing
      !IT_FU_KEYS type /BOBF/T_FRW_KEY .
protected section.
private section.

  class-data GO_TOR_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .

  methods GET_ACT_VALUES
    importing
      !IV_ITEM_KEY type /BOBF/CONF_KEY
    exporting
      !ES_ACT_VAL type /SCMTMS/S_TOR_EXEC_K
    raising
      ZCX_AWC_FO_OVERVIEW .

ENDCLASS.



CLASS ZCL_AWC_FO_ITEM IMPLEMENTATION.


  METHOD constructor.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

  ENDMETHOD.


  METHOD delete_fu_assignments.

    DATA: ls_rem_ass      TYPE /scmtms/s_tor_a_root_remassgn,
          lr_s_rem_ass    TYPE REF TO data.

    ls_rem_ass-remove_links_from_tor = 'X'.

    GET REFERENCE OF ls_rem_ass INTO lr_s_rem_ass.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-root-remove_tor_assignments
        it_key               = it_fu_keys
        is_parameters        = lr_s_rem_ass
      IMPORTING
*    eo_change            =
        eo_message           = DATA(lo_rem_message)
        et_failed_key        = DATA(lt_failed_key)
*    et_failed_action_key =
*    et_data              =
    ).

    IF lt_failed_key IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_rem_message
          is_textid     = zcx_awc_fo_overview=>fu_unassign_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
      EXPORTING
        iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
      IMPORTING
        eo_message             = DATA(lo_rm_sav_message)
        ev_rejected            = DATA(lv_sav_rejected)
    ).

    IF lv_sav_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_rm_sav_message
          is_textid     = zcx_awc_fo_overview=>fu_unassign_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

  ENDMETHOD.


  METHOD get_act_values.

    DATA: lt_item_keys  TYPE /bobf/t_frw_key,
          lt_qty_report TYPE /scmtms/t_tor_exec_k,
          lt_exec       TYPE zawc_t_fo_exec.

    INSERT VALUE #( key = iv_item_key ) INTO TABLE lt_item_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-item_tr
        it_key                  = lt_item_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-item_tr-qty_report_all
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
        et_data                 = lt_qty_report
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    lt_exec = lt_qty_report.

    SORT lt_exec DESCENDING BY actual_date.

    READ TABLE lt_exec INDEX 1 INTO es_act_val.

  ENDMETHOD.


  METHOD get_items_by_fo.

    DATA: lt_fo_keys      TYPE /bobf/t_frw_key,
          lt_fo_items     TYPE /scmtms/t_tor_item_tr_k,
          lo_location     TYPE REF TO zcl_awc_fo_location,
          lo_bupa         TYPE REF TO zcl_awc_fo_bupa,
          lt_src_loc_keys TYPE /bobf/t_frw_key,
          lt_des_loc_keys TYPE /bobf/t_frw_key,
          lt_shp_keys     TYPE /bobf/t_frw_key,
          lt_cons_keys    TYPE /bobf/t_frw_key,
          lt_fu_data      TYPE /scmtms/t_tor_root_k,
          lt_fu_keys      TYPE /bobf/t_frw_key,
          lt_item_keys    TYPE /bobf/t_frw_key,
          ls_awc_item     TYPE zawc_s_fo_item,
          lv_veh_key      TYPE /bobf/conf_key,
          lt_fur_keys     TYPE /bobf/t_frw_key.

    CREATE OBJECT lo_location.
    CREATE OBJECT lo_bupa.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    "Retrieve all Items for requested FO
    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-item_tr
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
        et_data                 = lt_fo_items
*        et_key_link             =
*        et_target_key           = lt_item_keys
*        et_failed_key           =
    ).

    LOOP AT lt_fo_items ASSIGNING FIELD-SYMBOL(<fs_item_data>).
      INSERT VALUE #( key = <fs_item_data>-fu_root_key ) INTO TABLE lt_item_keys.
    ENDLOOP.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_item_keys
*        iv_before_image         = ABAP_FALSE
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = ABAP_FALSE
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_fu_data
*        et_failed_key           =
    ).

    DELETE ADJACENT DUPLICATES FROM lt_fu_data COMPARING key.

    LOOP AT lt_fo_items INTO DATA(ls_fo_items) WHERE item_cat = 'AVR'.
      lv_veh_key = ls_fo_items-key.
    ENDLOOP.

    LOOP AT lt_fo_items INTO DATA(ls_fur) WHERE item_cat = 'FUR'.
      INSERT VALUE #( key = ls_fur-key ) INTO TABLE lt_fur_keys.
      DELETE TABLE lt_fo_items FROM ls_fur.
    ENDLOOP.

    MOVE-CORRESPONDING lt_fo_items TO et_fo_items.

    LOOP AT lt_fu_data ASSIGNING FIELD-SYMBOL(<fs_fu_data>).
      ls_awc_item-key             = <fs_fu_data>-key. "go_tor_srv_mgr->get_new_key( ).
      ls_awc_item-parent_key      = iv_fo_key.
      ls_awc_item-root_key        = iv_fo_key.
      ls_awc_item-item_parent_key = lv_veh_key.
      ls_awc_item-item_cat        = 'FUR'.

      INSERT ls_awc_item INTO TABLE et_fo_items.

      LOOP AT et_fo_items ASSIGNING FIELD-SYMBOL(<fs_fo_item>) WHERE fu_root_key = <fs_fu_data>-key.
        IF <fs_fo_item>-main_cargo_item = 'X'.
          <fs_fo_item>-item_parent_key = ls_awc_item-key.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT et_fo_items ASSIGNING FIELD-SYMBOL(<fs_items>).
      INSERT VALUE #( key = <fs_items>-src_loc_keytrq ) INTO TABLE lt_src_loc_keys.
      INSERT VALUE #( key = <fs_items>-des_loc_keytrq ) INTO TABLE lt_des_loc_keys.
      INSERT VALUE #( key = <fs_items>-shipper_key ) INTO TABLE lt_shp_keys.
      INSERT VALUE #( key = <fs_items>-consignee_key ) INTO TABLE lt_cons_keys.
    ENDLOOP.

    lo_location->get_addr_by_loc(
      EXPORTING
        it_loc_uuid = lt_src_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
      IMPORTING
        et_loc_data = DATA(lt_src_loc)    " Adressdaten einer Lokation
    ).

    lo_location->get_addr_by_loc(
      EXPORTING
        it_loc_uuid = lt_des_loc_keys    " Lokations-GUID (004) mit Konvertierungs-Exit
      IMPORTING
        et_loc_data = DATA(lt_des_loc)    " Adressdaten einer Lokation
    ).

    lo_bupa->get_bupa(
      EXPORTING
        it_bupa_key  = lt_shp_keys    " NodeID
      IMPORTING
        et_bupa_data = DATA(lt_shp_data)
    ).

    lo_bupa->get_bupa(
      EXPORTING
        it_bupa_key  = lt_cons_keys    " NodeID
      IMPORTING
        et_bupa_data = DATA(lt_cons_data)
    ).

    LOOP AT et_fo_items ASSIGNING FIELD-SYMBOL(<fs_fo_items>).
      READ TABLE lt_src_loc ASSIGNING FIELD-SYMBOL(<fs_src>) WITH KEY loc_uuid = <fs_fo_items>-src_loc_keytrq.
      IF sy-subrc = 0.
        <fs_fo_items>-src_loc_name1 = <fs_src>-name1.
      ENDIF.

      READ TABLE lt_des_loc ASSIGNING FIELD-SYMBOL(<fs_des>) WITH KEY loc_uuid = <fs_fo_items>-des_loc_keytrq.
      IF sy-subrc = 0.
        <fs_fo_items>-des_loc_name1 = <fs_des>-name1.
      ENDIF.

      READ TABLE lt_shp_data ASSIGNING FIELD-SYMBOL(<fs_shp>) WITH KEY key = <fs_fo_items>-shipper_key.
      IF sy-subrc = 0.
        <fs_fo_items>-shp_description = <fs_shp>-description.
      ENDIF.

      READ TABLE lt_cons_data ASSIGNING FIELD-SYMBOL(<fs_cons>) WITH KEY key = <fs_fo_items>-consignee_key.
      IF sy-subrc = 0.
        <fs_fo_items>-cons_description = <fs_cons>-description.
      ENDIF.

      get_act_values(
        EXPORTING
          iv_item_key = CONV #( <fs_fo_items>-key )   " NodeID
        IMPORTING
          es_act_val  = DATA(ls_act_val)    " Item von Frachtauftrag
      ).

      <fs_fo_items>-act_gro_wei_val   = ls_act_val-gro_wei_val.
      <fs_fo_items>-act_gro_wei_uni   = ls_act_val-gro_wei_uni.
      <fs_fo_items>-act_gro_vol_val   = ls_act_val-gro_vol_val.
      <fs_fo_items>-act_gro_vol_uni   = ls_act_val-gro_vol_uni.
      <fs_fo_items>-act_qua_pcs_val   = ls_act_val-qua_pcs_val.
      <fs_fo_items>-act_qua_pcs_uni   = ls_act_val-qua_pcs_uni.
      <fs_fo_items>-act_qua_pcs2_val  = ls_act_val-qua_pcs2_val.
      <fs_fo_items>-act_qua_pcs2_uni  = ls_act_val-qua_pcs2_uni.
      <fs_fo_items>-act_net_wei_val   = ls_act_val-net_wei_val.
      <fs_fo_items>-act_net_wei_uni   = ls_act_val-net_wei_uni.

    ENDLOOP.


  ENDMETHOD.


  METHOD get_item_by_key.

    DATA: lt_item_keys TYPE /bobf/t_frw_key,
          lt_item_data TYPE /scmtms/t_tor_item_tr_k.

    INSERT VALUE #( key = iv_item_key ) INTO TABLE lt_item_keys.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-item_tr
        it_key                  = lt_item_keys
*        iv_before_image         = ABAP_FALSE
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = ABAP_FALSE
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_item_data
*        et_failed_key           =
    ).

    get_act_values(
      EXPORTING
        iv_item_key = CONV #( iv_item_key )   " NodeID
      IMPORTING
        es_act_val  = DATA(ls_act_val)    " Item von Frachtauftrag
    ).

    READ TABLE lt_item_data INDEX 1 INTO DATA(ls_item_data).
    MOVE-CORRESPONDING ls_item_data TO es_item_data.

    es_item_data-act_gro_wei_val = ls_act_val-gro_wei_val.
    es_item_data-act_gro_wei_uni = ls_act_val-gro_wei_uni.
    es_item_data-act_gro_vol_val = ls_act_val-gro_vol_val.
    es_item_data-act_gro_vol_uni = ls_act_val-gro_vol_uni.
    es_item_data-act_qua_pcs_val = ls_act_val-qua_pcs_val.
    es_item_data-act_qua_pcs_uni = ls_act_val-qua_pcs_uni.
    es_item_data-act_qua_pcs2_uni = ls_act_val-qua_pcs2_uni.
    es_item_data-act_qua_pcs2_uni = ls_act_val-qua_pcs2_uni.

  ENDMETHOD.


 METHOD reassign_fu.
    DATA: lt_fo_keys           TYPE /bobf/t_frw_key,
          lt_fu_keys           TYPE /bobf/t_frw_key,
          ls_add_stages        TYPE /scmtms/s_tor_a_add_fu_pln,
          lr_s_add_stages      TYPE REF TO data,
          lt_fu_stop_succ_data TYPE /scmtms/t_tor_stop_succ_k.

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_fu_keys.
    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    delete_fu_assignments( it_fu_keys = lt_fu_keys ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-stop
*          is_parameters           =
*          it_filtered_attributes  =
        iv_fill_data            = abap_true
*          iv_before_image         = abap_false
*          iv_invalidate_cache     = abap_false
*          iv_edit_mode            =
*          it_requested_attributes =
      IMPORTING
*          eo_message              =
*          eo_change               =
*        et_data                 = lt_fu_stop_data
*          et_key_link             =
        et_target_key           = DATA(lt_fu_stop_keys)
*          et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-stop
        it_key                  = lt_fu_stop_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-stop-stop_successor
*      is_parameters           =
*      it_filtered_attributes  =
        iv_fill_data            = abap_true
*      iv_before_image         = abap_false
*      iv_invalidate_cache     = abap_false
*      iv_edit_mode            =
*      it_requested_attributes =
      IMPORTING
*      eo_message              =
*      eo_change               =
        et_data                 = lt_fu_stop_succ_data
*      et_key_link             =
*      et_target_key           =
*      et_failed_key           =
    ).

    LOOP AT lt_fu_stop_succ_data INTO DATA(ls_fu_stop_succ_data).
      INSERT VALUE #( key = ls_fu_stop_succ_data-key ) INTO TABLE ls_add_stages-stop_succ_keys.
    ENDLOOP.

    GET REFERENCE OF ls_add_stages INTO lr_s_add_stages.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-root-add_fustage_with_planning
        it_key               = lt_fo_keys
        is_parameters        = lr_s_add_stages
      IMPORTING
*      eo_change            =
        eo_message           = DATA(lo_add_stop_message)
        et_failed_key        = DATA(lt_add_stop_failed)
*      et_failed_action_key =
*      et_data              =
    ).

    IF lt_add_stop_failed IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_add_stop_message
          is_textid  = zcx_awc_fo_overview=>fu_assigning_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
      EXPORTING
        iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
      IMPORTING
        ev_rejected            = DATA(lv_rejected)
        eo_message             = DATA(lo_succ_sav_message)
    ).

    IF lv_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_succ_sav_message
          is_textid  = zcx_awc_fo_overview=>fu_assigning_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.
  ENDMETHOD.


  METHOD update_act_val.

    DATA: lt_item_keys TYPE /bobf/t_frw_key,
          lt_exec_inf  TYPE /scmtms/t_tor_exec_k,
          ls_exec_inf  TYPE /scmtms/s_tor_exec_k,
          lt_mod       TYPE /bobf/t_frw_modification.

    GET TIME STAMP FIELD DATA(timestamp).

    INSERT VALUE #( key = is_update_fo_item-key ) INTO TABLE lt_item_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-item_tr
        it_key                  = lt_item_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-item_tr-qty_report_all
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
        et_data                 = lt_exec_inf
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    IF lt_exec_inf IS NOT INITIAL.
      READ TABLE lt_exec_inf INDEX 1 INTO ls_exec_inf.
    ENDIF.

    ls_exec_inf-gro_wei_val   = is_update_fo_item-act_gro_wei_val.
    ls_exec_inf-gro_wei_uni   = is_update_fo_item-act_gro_wei_uni.
    ls_exec_inf-gro_vol_val   = is_update_fo_item-act_gro_vol_val.
    ls_exec_inf-gro_vol_uni   = is_update_fo_item-act_gro_vol_uni.
    ls_exec_inf-qua_pcs_val   = is_update_fo_item-act_qua_pcs_val.
    ls_exec_inf-qua_pcs_uni   = is_update_fo_item-act_qua_pcs_uni.
    ls_exec_inf-qua_pcs2_uni  = is_update_fo_item-act_qua_pcs2_uni.
    ls_exec_inf-qua_pcs2_uni  = is_update_fo_item-act_qua_pcs2_uni.
    ls_exec_inf-net_wei_val   = is_update_fo_item-act_net_wei_val.
    ls_exec_inf-net_wei_uni   = is_update_fo_item-act_net_wei_uni.
    ls_exec_inf-actual_date   = timestamp.
    ls_exec_inf-toritmuuid    = is_update_fo_item-key.

*    IF lt_exec_inf IS INITIAL.
    ls_exec_inf-key = go_tor_srv_mgr->get_new_key( ).
*      ls_exec_inf-toritmuuid = is_update_fo_item-key.
    ls_exec_inf-event_code = 'REPORT_QUANTITY'.
    ls_exec_inf-parent_key = is_update_fo_item-key. "parent_key.  "parent key wäre hier fo key, oder?
    ls_exec_inf-root_key = is_update_fo_item-root_key.
*      ls_exec_inf-torstopuuid = is_update_fo_item-des_stop_key.
    ls_exec_inf-event_status = 'N'.
    ls_exec_inf-execinfo_source = 'C'.
*      ls_exec_inf-execution_id = '0000000010'.

    /scmtms/cl_mod_helper=>mod_create_single(
      EXPORTING
        is_data        = ls_exec_inf
        iv_key         = ls_exec_inf-key
        iv_parent_key  = ls_exec_inf-parent_key
        iv_root_key    = ls_exec_inf-root_key
        iv_node        = /scmtms/if_tor_c=>sc_node-executioninformation
        iv_source_node = /scmtms/if_tor_c=>sc_node-item_tr
        iv_association = /scmtms/if_tor_c=>sc_association-item_tr-qty_report_all
*        IMPORTING
*          es_mod         =
      CHANGING
        ct_mod         = lt_mod
    ).

    go_tor_srv_mgr->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_change       = DATA(lo_change)
        eo_message      = DATA(lo_mod_message)
    ).

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
     EXPORTING
       iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
     IMPORTING
       eo_message             = DATA(lo_sav_message)
       ev_rejected = DATA(lv_rejected)
   ).

    IF lv_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_sav_message
          is_textid  = zcx_awc_fo_overview=>amount_reporting_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
