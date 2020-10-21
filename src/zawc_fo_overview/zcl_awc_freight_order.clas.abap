CLASS zcl_awc_freight_order DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_assigned_fus
      IMPORTING
        !it_fo_keys       TYPE /bobf/t_frw_key
      RETURNING
        VALUE(rt_fu_keys) TYPE /bobf/t_frw_key .
    METHODS confirm_reject_anno
      IMPORTING
        !iv_amountprf    TYPE /scmtms/tend_amount_pref
        !iv_tend_req_nr  TYPE /scmtms/tend_req_nr
        !iv_conf_flag    TYPE char1
        !iv_rej_reason   TYPE /scmtms/rej_reason_code OPTIONAL
      EXPORTING
        !ev_is_confirmed TYPE char1 .
    METHODS assign_vehicle
      IMPORTING
        !iv_fo_key  TYPE /bobf/conf_key
        !iv_veh_key TYPE /bobf/conf_key
      RAISING
        zcx_awc_fo_overview .
    METHODS get_carrier_for_user
      RETURNING
        VALUE(rt_carrier_ids) TYPE /bofu/t_bupa_relship_k .
    METHODS confirm_fo
      IMPORTING
        !it_fo_keys TYPE /bobf/t_frw_key
      RAISING
        zcx_awc_fo_overview .
    METHODS get_fo
      IMPORTING
        !iv_fo_key  TYPE /bobf/conf_key
      EXPORTING
        !es_fo_data TYPE zawc_s_fo_data .
    METHODS reject_fo
      IMPORTING
        !it_fo_keys      TYPE /bobf/t_frw_key
      EXPORTING
        !ev_is_confirmed TYPE char1
      RAISING
        zcx_awc_fo_overview .
    METHODS constructor .
    METHODS get_fos
      IMPORTING
        !iv_app_indicator TYPE char1
        !iv_anno_status   TYPE string
        !iv_conf_status   TYPE string
        !iv_exec_status   TYPE string
      EXPORTING
        !et_fo_data       TYPE zawc_t_fo_data .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA go_tor_srv_mgr TYPE REF TO /bobf/if_tra_service_manager .
    CLASS-DATA go_bp_srv_mgr TYPE REF TO /bobf/if_tra_service_manager .

    METHODS get_dom_values
      EXPORTING
        !et_lifecycle      TYPE zawc_t_dom_val
        !et_execution      TYPE zawc_t_dom_val
        !et_confirmation   TYPE zawc_t_dom_val
        !et_subcontracting TYPE zawc_t_dom_val .
    METHODS calc_remaining_anno_time
      IMPORTING
        !iv_anno_enddate    TYPE zawc_tend_enddate
      RETURNING
        VALUE(rv_remaining) TYPE zawc_tend_time_remain .
    METHODS get_fos_from_tor
      IMPORTING
        !it_carriers      TYPE /bofu/t_bupa_relship_k
        !iv_app_indicator TYPE char1
        !iv_conf_status   TYPE string
        !iv_exec_status   TYPE string
      RETURNING
        VALUE(rt_fo_data) TYPE zawc_t_fo_data .
    METHODS get_tend_data
      IMPORTING
        !it_fo_keys         TYPE /bobf/t_frw_key
      RETURNING
        VALUE(rt_tend_data) TYPE zawc_t_fo_tend_data .
    METHODS get_announced_fos_for_carrier
      IMPORTING
        !it_fos                          TYPE zawc_t_fo_data
        !it_carriers                     TYPE /bofu/t_bupa_relship_k
      RETURNING
        VALUE(rt_announced_fos_for_carr) TYPE zawc_t_fo_data .
    METHODS check_amounts_changed
      IMPORTING
        !it_fo_keys               TYPE /bobf/t_frw_key
      RETURNING
        VALUE(rt_amounts_changed) TYPE zawc_t_fo_amts_change .
    METHODS get_charges
      IMPORTING
        !it_fo_keys            TYPE /bobf/t_frw_key
      RETURNING
        VALUE(rt_charges_data) TYPE /scmtms/t_tcc_root_k .
    METHODS get_partner
      IMPORTING
        !it_fo_data        TYPE zawc_t_fo_data
      RETURNING
        VALUE(rt_partners) TYPE zawc_t_fo_partner .
    METHODS get_pick_drop_date
      IMPORTING
        !it_fo_keys   TYPE /bobf/t_frw_key
      EXPORTING
        !et_summ_data TYPE /scmtms/t_tor_root_transient_k
        !et_src_loc   TYPE zawc_t_fo_loc
        !et_des_loc   TYPE zawc_t_fo_loc .
    METHODS get_status_descr
      CHANGING
        !cs_fo_data TYPE zawc_s_fo_data .
    METHODS get_veh_res
      IMPORTING
        !it_fo_keys       TYPE /bobf/t_frw_key
      RETURNING
        VALUE(rt_veh_res) TYPE /scmtms/t_tor_item_tr_k .
    METHODS get_fos_for_carr
      IMPORTING
        !it_fo   TYPE zawc_t_fo_data
        !it_carr TYPE /bofu/t_bupa_relship_k
      EXPORTING
        !et_fo   TYPE zawc_t_fo_data .
ENDCLASS.



CLASS ZCL_AWC_FREIGHT_ORDER IMPLEMENTATION.


  METHOD assign_vehicle.

    DATA: lt_fo_keys   TYPE /bobf/t_frw_key,
          ls_ass_veh   TYPE /scmtms/s_tor_root_a_chg_vres,
          lr_s_ass_veh TYPE REF TO data.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    ls_ass_veh-veh_key = iv_veh_key.
    ls_ass_veh-no_scheduling = 'X'.

    GET REFERENCE OF ls_ass_veh INTO lr_s_ass_veh.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-root-assign_vehicle_res
        it_key               = lt_fo_keys
        is_parameters        = lr_s_ass_veh
      IMPORTING
*          eo_change            =
        eo_message           = DATA(lo_ass_message)
        et_failed_key        = DATA(lt_failed_key)
*          et_failed_action_key =
*          et_data              =
    ).

    IF lt_failed_key IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_ass_message
          is_textid     = zcx_awc_fo_overview=>vehicle_assignment_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
      EXPORTING
        iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
      IMPORTING
        eo_message             = DATA(lo_ass_veh_message)
        ev_rejected            = DATA(lv_ass_veh_rejected)
      ).

    IF lv_ass_veh_rejected IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message    = lo_ass_veh_message
          is_textid     = zcx_awc_fo_overview=>vehicle_assignment_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

  ENDMETHOD.


  METHOD calc_remaining_anno_time.

    GET TIME STAMP FIELD DATA(lv_actual_time).

    DATA(lv_time_diff) = lv_actual_time - iv_anno_enddate.

    rv_remaining = lv_time_diff / 100.

  ENDMETHOD.


  METHOD check_amounts_changed.

    DATA: lt_item_data  TYPE /scmtms/t_tor_item_tr_k,
          lt_item_keys  TYPE /bobf/t_frw_key,
          lt_event_data TYPE /scmtms/t_tor_exec_k.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-item_tr
*        is_parameters           =
*        it_filtered_attributes  =
*        iv_fill_data            = abap_true
*        iv_before_image         = ABAP_FALSE
*        iv_invalidate_cache     = ABAP_FALSE
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
*        et_data                 = lt_item_data
*        et_key_link             =
        et_target_key           = lt_item_keys
*        et_failed_key           =
    ).

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
        et_data                 = lt_event_data
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    LOOP AT it_fo_keys ASSIGNING FIELD-SYMBOL(<fs_fo_keys>).
      READ TABLE lt_event_data ASSIGNING FIELD-SYMBOL(<fs_event_data>) WITH KEY parent_key = <fs_fo_keys>-key.
      IF sy-subrc = 0.
        INSERT VALUE #( key             = <fs_fo_keys>-key
                        amounts_changed = 'X'               ) INTO TABLE rt_amounts_changed.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.


  METHOD confirm_fo.

    go_tor_srv_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-root-set_conf_status_accepted
        it_key               = it_fo_keys
      IMPORTING
        eo_message           = DATA(lo_act_message)
        et_failed_key        = DATA(lt_failed_key)
    ).

    IF lt_failed_key IS NOT INITIAL.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_act_message
          is_textid  = zcx_awc_fo_overview=>fo_confirmation_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

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
          is_textid  = zcx_awc_fo_overview=>fo_confirmation_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.

  ENDMETHOD.


  METHOD confirm_reject_anno.

    DATA: ls_confirm_resp     TYPE /scmtms/s_tor_tend_resp_k,
          lt_tend_keys        TYPE /bobf/t_frw_key,
          lt_mod              TYPE /bobf/t_frw_modification,
          lt_tend_req_data    TYPE /scmtms/t_tor_tend_req_k,
          ls_tend_req_data    TYPE /scmtms/s_tor_tend_req_k,
          lt_sel_param        TYPE /bobf/t_frw_query_selparam,
          ls_sel_param        TYPE /bobf/s_frw_query_selparam,
          lt_failed_key       TYPE /bobf/t_frw_key,
          lo_change_all       TYPE REF TO /bobf/if_frw_change,
          lo_change           TYPE REF TO /bobf/if_frw_change,
          lt_req_keys         TYPE /bobf/t_frw_key,
          lv_resp_status      TYPE zwawc_resp_status, " VALUE 'O',
          lt_tend_res_data    TYPE /scmtms/t_tor_tend_resp_k,
          ls_tend_res_data    TYPE /scmtms/s_tor_tend_resp_k,
          ls_key              TYPE /bobf/s_frw_key,
          lt_resp_key         TYPE /bobf/t_frw_key,
          lt_resp_data        TYPE /scmtms/t_tor_tend_resp_k,
          lt_resp_keys        TYPE /bobf/t_frw_key,
          lr_comp_subm_par    TYPE REF TO /scmtms/s_tend_a_compl_and_sub,
          lo_message          TYPE REF TO /bobf/if_frw_message,
          lr_create_quotation TYPE REF TO /scmtms/s_tend_a_accrej_req,
          ls_param            TYPE /scmtms/s_tend_a_accrej_req_t.

    FIELD-SYMBOLS: <ls_resp_data>         TYPE /scmtms/s_tor_tend_resp_k.

    lo_change_all    = /bobf/cl_frw_factory=>get_change( ).

    GET TIME STAMP FIELD DATA(timestamp).

    CREATE DATA lr_create_quotation.
    lr_create_quotation->no_check            = abap_true.
    GET TIME STAMP FIELD lr_create_quotation->tst_now.
    lr_create_quotation->skip_cons_check     = abap_true.
    lr_create_quotation->submit_now          = abap_true.
    lr_create_quotation->quo_doc_type_code   = /scmtms/if_tend_c=>sc_quotation_type_code-online.
    CLEAR lr_create_quotation->t_param.

    ls_sel_param-attribute_name = /scmtms/if_tor_c=>sc_query_attribute-tenderingrequest-tenderingreq_elements-req_nr.
    ls_sel_param-low    = iv_tend_req_nr.
    ls_sel_param-option = 'EQ'.
    ls_sel_param-sign   = 'I'.

    APPEND ls_sel_param TO lt_sel_param.

    go_tor_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_tor_c=>sc_query-tenderingrequest-tenderingreq_elements
        it_selection_parameters = lt_sel_param
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tend_req_data
        et_key                  = lt_req_keys
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-tenderingrequest
        it_key                  = lt_req_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-tenderingrequest-tenderingresponse
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tend_res_data
    ).

    IF lt_tend_req_data IS NOT INITIAL.
      READ TABLE lt_tend_req_data INDEX 1 INTO ls_tend_req_data.
      IF sy-subrc = 0.
        ls_confirm_resp-parent_key        = ls_tend_req_data-key.
        ls_confirm_resp-root_key          = ls_tend_req_data-root_key.
        ls_confirm_resp-submit_datetime   = timestamp.
        ls_confirm_resp-created_by        = sy-uname.
        ls_confirm_resp-created_on        = timestamp.
        ls_confirm_resp-tsp_key           = ls_tend_req_data-tsp_key.
        ls_confirm_resp-lifecycle         = /scmtms/if_tor_status_c=>sc_tenderingresponse-lifecycle-v_sent.
        ls_confirm_resp-req_nr            = iv_tend_req_nr.
        ls_confirm_resp-tend_key          = ls_tend_req_data-parent_key.
*        ls_confirm_resp-resp_seq_nr       = '1'.
        ls_confirm_resp-acc_result        = 'PE'.

        ls_param-tend_req_key    = ls_tend_req_data-key.
        ls_param-tend_resp_key   = /bobf/cl_frw_factory=>get_new_key( ).
      ENDIF.
*      ls_param-rej_reason_code = ls_quotation_data-rej_reason_code.
      APPEND ls_param TO lr_create_quotation->t_param.

      READ TABLE lt_tend_res_data INTO ls_tend_res_data WITH KEY tsp_key = ls_tend_req_data-tsp_key.
      IF sy-subrc = 4.
        lv_resp_status  = 'O'.
      ELSEIF sy-subrc = 0 AND ( ls_tend_res_data-response_code = 'AX' OR ls_tend_res_data-response_code = 'AP' ).
        lv_resp_status  = 'C'.
*        ev_is_confirmed = 'X'.
      ELSEIF sy-subrc = 0 AND ls_tend_res_data-response_code = 'RE'.
        lv_resp_status  = 'R'.
      ENDIF.

      IF iv_conf_flag = 'C'.
        ls_confirm_resp-amountsub           = iv_amountprf / 10000.
        ls_confirm_resp-currcode016sub      = 'EUR'.
        ls_confirm_resp-amountprf           = iv_amountprf / 10000.
        ls_confirm_resp-currcode016prf      = 'EUR'.
        ls_confirm_resp-key                 = ls_tend_res_data-key.
        IF lv_resp_status = 'O'.
          ls_confirm_resp-response_code     = 'AP'.
          ls_confirm_resp-key               = go_tor_srv_mgr->get_new_key( ).
        ENDIF.
        IF lv_resp_status = 'R'.
          ls_confirm_resp-response_code     = 'AX'.
          ls_confirm_resp-key               = ls_tend_res_data-key.
        ENDIF.
      ENDIF.

      IF iv_conf_flag = 'R'.
        ls_confirm_resp-key               = ls_tend_res_data-key.
        ls_confirm_resp-response_code     = 'RE'.
        ls_confirm_resp-rej_reason_code   = 'NONE'.
      ENDIF.

      IF lv_resp_status = 'O'.
        IF iv_conf_flag = 'C'.

          go_tor_srv_mgr->do_action(
            EXPORTING iv_act_key    = /scmtms/if_tor_c=>sc_action-tenderingrequest-accept_request_bckgr
                      it_key        = lt_req_keys
                      is_parameters = lr_create_quotation
            IMPORTING et_failed_key = lt_failed_key
                      eo_change     = DATA(lo_change_trx)
                      eo_message    = lo_message ).

          ls_key-key = ls_param-tend_resp_key.
          INSERT ls_key INTO TABLE lt_resp_key.
          CALL METHOD go_tor_srv_mgr->retrieve
            EXPORTING
              iv_node_key   = /scmtms/if_tor_c=>sc_node-tenderingresponse
              it_key        = lt_resp_key
              iv_fill_data  = abap_true
            IMPORTING
              et_failed_key = lt_failed_key
              et_data       = lt_resp_data.

          READ TABLE lt_resp_data INDEX 1 ASSIGNING <ls_resp_data>.
          CHECK sy-subrc = 0.

          CREATE DATA lr_comp_subm_par.

          CALL METHOD cl_gdt_conversion=>amount_inbound
              EXPORTING
                im_value         = iv_amountprf
                im_currency_code = 'EUR'
              IMPORTING
                ex_value         = <ls_resp_data>-amountsub
                ex_currency_code = <ls_resp_data>-currcode016sub.

          CALL METHOD cl_gdt_conversion=>amount_inbound
              EXPORTING
                im_value         = iv_amountprf
                im_currency_code = 'EUR'
              IMPORTING
                ex_value         = <ls_resp_data>-amountprf
                ex_currency_code = <ls_resp_data>-currcode016prf.

          <ls_resp_data>-acc_result = 'PE'.

          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-amountsub       TO lr_comp_subm_par->t_changed_fields.
          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-currcode016sub  TO lr_comp_subm_par->t_changed_fields.
          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-amountprf       TO lr_comp_subm_par->t_changed_fields.
          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-acc_result      TO lr_comp_subm_par->t_changed_fields.
          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-currcode016prf  TO lr_comp_subm_par->t_changed_fields.

          GET TIME STAMP FIELD <ls_resp_data>-submit_datetime.
          APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-submit_datetime TO lr_comp_subm_par->t_changed_fields.

*          <ls_resp_data>-amountsub      = iv_amountprf / 10000.
*          <ls_resp_data>-currcode016sub = 'EUR'.
**          <ls_resp_data>-amountprf      = iv_amountprf / 10000.
**          <ls_resp_data>-currcode016prf = 'EUR'.

          lr_comp_subm_par->tend_resp_data = <ls_resp_data>.
          go_tor_srv_mgr->do_action(
            EXPORTING iv_act_key    = /scmtms/if_tor_c=>sc_action-tenderingresponse-complete_and_submit
                      it_key        = lt_resp_key
                      is_parameters = lr_comp_subm_par
            IMPORTING et_failed_key = lt_failed_key
                      eo_change     = lo_change_trx
                      eo_message    = lo_message ).

                    lo_change_trx->get_bo_changes(
            EXPORTING iv_bo_key = /scmtms/if_tor_c=>sc_bo_key
            IMPORTING eo_change = lo_change ).
          lo_change_all->merge( io_change = lo_change ).


          /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
             EXPORTING
               iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
             IMPORTING
               eo_message             = DATA(lo_sav_message)
               ev_rejected = DATA(lv_rejected)
            ).

          IF lv_rejected = abap_true.
            NEW zcl_awc_fo_overview_helper( )->raise_exception(
              EXPORTING
                io_message = lo_sav_message
                is_textid  = zcx_awc_fo_overview=>anno_response_failed                " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
            ).
          ENDIF.
        ELSEIF iv_conf_flag = 'R'.
          go_tor_srv_mgr->do_action(
            EXPORTING
              iv_act_key           = /scmtms/if_tor_c=>sc_action-tenderingrequest-reject_request
              it_key               = lt_req_keys
              is_parameters        = lr_create_quotation
            IMPORTING
              eo_message           = lo_message
              et_failed_key        = lt_failed_key
          ).
        ENDIF.

      ELSEIF lv_resp_status = 'R' OR lv_resp_status = 'C' OR lv_resp_status IS INITIAL.
        /scmtms/cl_mod_helper=>mod_update_single(
          EXPORTING
            is_data            = ls_confirm_resp
            iv_node            = /scmtms/if_tor_c=>sc_node-tenderingresponse
            iv_key             = ls_confirm_resp-key
            iv_bo_key          = /scmtms/if_tor_c=>sc_bo_key
          CHANGING
            ct_mod             = lt_mod
        ).
      ENDIF.

      IF lt_mod IS NOT INITIAL.
        go_tor_srv_mgr->modify(
          EXPORTING
            it_modification = lt_mod
          IMPORTING
            eo_message      = DATA(lo_mod_message)
          ).

*        IF timestamp < ls_tend_req_data-resp_due_dtime.
*
*        ELSE.
*          RETURN.
*        ENDIF.

      ENDIF.
*      /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
*        EXPORTING
*          iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
*        IMPORTING
*          eo_message  = lo_sav_message
*          ev_rejected = lv_rejected
*       ).
*
*      IF lv_rejected = abap_true.
*        NEW zcl_awc_fo_overview_helper( )->raise_exception(
*          EXPORTING
*            io_message = lo_sav_message
*            is_textid  = zcx_awc_fo_overview=>anno_response_failed                " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
*        ).
*      ENDIF.
    ENDIF.

*    IF lv_error_occured = abap_true.
*      NEW ycl_tms_cp_helper( )->raise_exception(
*        EXPORTING
*          io_message = lo_error_message
*          is_textid  = ycx_tms_coll_portal=>anno_response_failed                " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
*      ).
*    ENDIF.

*    CREATE DATA lr_create_quotation.
*    lr_create_quotation->no_check            = abap_true.
*    GET TIME STAMP FIELD lr_create_quotation->tst_now.
*    lr_create_quotation->skip_cons_check     = abap_true.
*    lr_create_quotation->submit_now          = abap_false.
*    lr_create_quotation->quo_doc_type_code   = /scmtms/if_tend_c=>sc_quotation_type_code-online.
*    CLEAR lr_create_quotation->t_param.
*
*    ls_sel_param-attribute_name = /scmtms/if_tor_c=>sc_query_attribute-tenderingrequest-tenderingreq_elements-req_nr.
*    ls_sel_param-low    = iv_tend_req_nr.
*    ls_sel_param-option = 'EQ'.
*    ls_sel_param-sign   = 'I'.
*
*    APPEND ls_sel_param TO lt_sel_param.
*
*    go_tor_srv_mgr->query(
*      EXPORTING
*        iv_query_key            = /scmtms/if_tor_c=>sc_query-tenderingrequest-tenderingreq_elements
**        it_filter_key           =
*        it_selection_parameters = lt_sel_param
**        is_query_options        =
*        iv_fill_data            = abap_true
**        it_requested_attributes =
*      IMPORTING
**        eo_message              =
**        es_query_info           =
*        et_data                 = lt_tend_req_data
*        et_key                  = lt_req_keys
*    ).
*
*    go_tor_srv_mgr->retrieve_by_association(
*      EXPORTING
*        iv_node_key             = /scmtms/if_tor_c=>sc_node-tenderingrequest
*        it_key                  = lt_req_keys
*        iv_association          = /scmtms/if_tor_c=>sc_association-tenderingrequest-tenderingresponse
**        is_parameters           =
**        it_filtered_attributes  =
*        iv_fill_data            = abap_true
**        iv_before_image         = abap_false
**        iv_invalidate_cache     = abap_false
**        iv_edit_mode            =
**        it_requested_attributes =
*      IMPORTING
**        eo_message              =
**        eo_change               =
*        et_data                 = lt_tend_res_data
**        et_key_link             =
**        et_target_key           =
**        et_failed_key           =
*    ).
*
*    IF lt_tend_req_data IS NOT INITIAL.
*      READ TABLE lt_tend_req_data INDEX 1 INTO ls_tend_req_data.
*
*      ls_confirm_resp-parent_key        = ls_tend_req_data-key.
*      ls_confirm_resp-root_key          = ls_tend_req_data-root_key.
*      ls_confirm_resp-submit_datetime   = timestamp.
*      ls_confirm_resp-created_by        = sy-uname.
*      ls_confirm_resp-created_on        = timestamp.
*      ls_confirm_resp-tsp_key           = ls_tend_req_data-tsp_key.
*      ls_confirm_resp-lifecycle         = /scmtms/if_tor_status_c=>sc_tenderingresponse-lifecycle-v_sent.
*      ls_confirm_resp-req_nr            = iv_tend_req_nr.
*      ls_confirm_resp-tend_key          = ls_tend_req_data-parent_key.
*      ls_confirm_resp-resp_seq_nr       = '1'.
*      ls_confirm_resp-acc_result        = 'PE'.
*
*      ls_param-tend_req_key    = ls_tend_req_data-key.
*      ls_param-tend_resp_key   = /bobf/cl_frw_factory=>get_new_key( ).
**      ls_param-rej_reason_code = ls_quotation_data-rej_reason_code.
*      APPEND ls_param TO lr_create_quotation->t_param.
*
*      READ TABLE lt_tend_res_data INTO ls_tend_res_data WITH KEY tsp_key = ls_tend_req_data-tsp_key.
*      IF sy-subrc = 4.
*        lv_resp_status  = 'O'.
*      ELSEIF sy-subrc = 0 AND ( ls_tend_res_data-response_code = 'AX' OR ls_tend_res_data-response_code = 'AP' ).
*        lv_resp_status  = 'C'.
*        ev_is_confirmed = 'X'.
*      ELSEIF sy-subrc = 0 AND ls_tend_res_data-response_code = 'RE'.
*        lv_resp_status  = 'R'.
*      ENDIF.
*
*      IF iv_conf_flag = 'C'.
*        ls_confirm_resp-amountsub           = iv_amountprf / 10000.
*        ls_confirm_resp-currcode016sub      = 'EUR'.
*        ls_confirm_resp-amountprf           = iv_amountprf / 10000.
*        ls_confirm_resp-currcode016prf      = 'EUR'.
*        ls_confirm_resp-key                 = ls_tend_res_data-key.
*        IF lv_resp_status = 'O'.
*          ls_confirm_resp-response_code     = 'AP'.
*          ls_confirm_resp-key               = go_tor_srv_mgr->get_new_key( ).
*        ENDIF.
*        IF lv_resp_status = 'R'.
*          ls_confirm_resp-response_code     = 'AX'.
*          ls_confirm_resp-key               = ls_tend_res_data-key.
*        ENDIF.
*      ENDIF.
*
*      IF iv_conf_flag = 'R'.
*        ls_confirm_resp-key               = ls_tend_res_data-key.
*        ls_confirm_resp-response_code     = 'RE'.
*        ls_confirm_resp-rej_reason_code   = 'NONE'.
*      ENDIF.
*
*      IF lv_resp_status = 'O'.
**        /scmtms/cl_mod_helper=>mod_create_single(
**          EXPORTING
**            is_data        = ls_confirm_resp
**            iv_key         = ls_confirm_resp-key
**            iv_parent_key  = ls_confirm_resp-parent_key
**            iv_root_key    = ls_confirm_resp-root_key
**            iv_node        = /scmtms/if_tor_c=>sc_node-tenderingresponse
**            iv_source_node = /scmtms/if_tor_c=>sc_node-tenderingrequest
**            iv_association = /scmtms/if_tor_c=>sc_association-tenderingrequest-tenderingresponse
***      IMPORTING
***        es_mod         =
**          CHANGING
**            ct_mod         = lt_mod
**        ).
*
*        go_tor_srv_mgr->do_action(
*          EXPORTING iv_act_key    = /scmtms/if_tor_c=>sc_action-tenderingrequest-accept_request_bckgr
*                    it_key        = lt_req_keys
*                    is_parameters = lr_create_quotation
*          IMPORTING et_failed_key = lt_failed_key
*                    eo_change     = DATA(lo_change_trx)
*                    eo_message    = DATA(lo_message) ).
*
*        ls_key-key = ls_param-tend_resp_key.
*        INSERT ls_key INTO TABLE lt_resp_key.
*        CALL METHOD go_tor_srv_mgr->retrieve
*          EXPORTING
*            iv_node_key   = /scmtms/if_tor_c=>sc_node-tenderingresponse
*            it_key        = lt_resp_key
*            iv_fill_data  = abap_true
*          IMPORTING
*            et_failed_key = lt_failed_key
*            et_data       = lt_resp_data.
*
*        CREATE DATA lr_comp_subm_par.
*
*        APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-amountsub       TO lr_comp_subm_par->t_changed_fields.
*        APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-currcode016sub  TO lr_comp_subm_par->t_changed_fields.
*
*        GET TIME STAMP FIELD <ls_resp_data>-submit_datetime.
*        APPEND /scmtms/if_tor_c=>sc_node_attribute-tenderingresponse-submit_datetime TO lr_comp_subm_par->t_changed_fields.
*
*        <ls_resp_data>-amountsub      = iv_amountprf.
*        <ls_resp_data>-currcode016sub = 'EUR'.
*
*        lr_comp_subm_par->tend_resp_data = <ls_resp_data>.
*        go_tor_srv_mgr->do_action(
*          EXPORTING iv_act_key    = /scmtms/if_tor_c=>sc_action-tenderingresponse-complete_and_submit
*                    it_key        = lt_resp_key
*                    is_parameters = lr_comp_subm_par
*          IMPORTING et_failed_key = lt_failed_key
*                    eo_change     = lo_change_trx
*                    eo_message    = lo_message ).
*
*      ELSEIF lv_resp_status = 'R' OR lv_resp_status = 'C'.
*        /scmtms/cl_mod_helper=>mod_update_single(
*          EXPORTING
*            is_data            = ls_confirm_resp
*            iv_node            = /scmtms/if_tor_c=>sc_node-tenderingresponse
*            iv_key             = ls_confirm_resp-key
**            it_changed_fields  =
**            iv_autofill_fields = 'X'
*            iv_bo_key          = /scmtms/if_tor_c=>sc_bo_key
**          IMPORTING
**            es_mod             =
*          CHANGING
*            ct_mod             = lt_mod
*        ).
*      ENDIF.
*
*      IF lt_mod IS NOT INITIAL.
*        go_tor_srv_mgr->modify(
*          EXPORTING
*            it_modification = lt_mod
*          IMPORTING
**                  eo_change       =
*            eo_message      = DATA(lo_mod_message)
*          ).
*
*
*        IF timestamp < ls_tend_req_data-resp_due_dtime.
*          /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
*           EXPORTING
*             iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
*           IMPORTING
*             eo_message             = DATA(lo_sav_message)
*             ev_rejected = DATA(lv_rejected)
*          ).
*        ELSE.
*          "Raise Exception
*        ENDIF.
*
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD constructor.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    go_bp_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_bp_c=>sc_bo_key ).

  ENDMETHOD.


  METHOD get_announced_fos_for_carrier.

    TYPES:
      BEGIN OF key_status,
        fo_key     TYPE /bobf/conf_key,
        req_status TYPE /scmtms/response_code,
      END OF key_status.
*
    DATA: lt_tendering_keys         TYPE /bobf/t_frw_key,
          lt_tendering_data         TYPE /scmtms/t_tor_tend_k,
          lt_tendering_request_data TYPE /scmtms/t_tor_tend_req_k,
          lt_tendering_keys_carr    TYPE /bobf/t_frw_key,
          lt_announced_fo_keys      TYPE /bobf/t_frw_key,
          lt_tend_resp_data         TYPE /scmtms/t_tor_tend_resp_k,
          lt_resp_status            TYPE STANDARD TABLE OF key_status.

    DATA: lt_selpar        TYPE /bobf/t_frw_query_selparam,
          lt_tend_req_data TYPE /scmtms/t_tor_tend_req_k,
          lt_fo_data       TYPE /scmtms/t_tor_root_k,
          lt_fo_keys       TYPE /bobf/t_frw_key,
          lt_fo_data_tend  TYPE zawc_t_fo_data,
          lt_fo_data_ret   TYPE zawc_t_fo_data,
          ls_fo_data_ret   TYPE zawc_s_fo_data,
          lt_tend_req_keys TYPE /bobf/t_frw_key.

    FIELD-SYMBOLS: <fs_tend_resp_data> TYPE /scmtms/s_tor_tend_resp_k,
                   <fs_fo_data_ret>    TYPE zawc_s_fo_data.

    LOOP AT it_carriers ASSIGNING FIELD-SYMBOL(<fs_bp_rel>).
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <fs_bp_rel>-relshp_partner
                      attribute_name  = 'TSP_INTERNAL_ID' ) INTO TABLE lt_selpar.
    ENDLOOP.

*    INSERT VALUE #( sign            = 'I'
*                    option          = 'EQ'
*                    low             = '02'
*                    attribute_name  = 'LIFECYCLE' ) INTO TABLE lt_selpar.

    go_tor_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_tor_c=>sc_query-tenderingrequest-tenderingreq_elements
        it_selection_parameters = lt_selpar
        iv_fill_data            = abap_true
      IMPORTING
        eo_message              = DATA(lo_query_message)
        et_data                 = lt_tend_req_data
*        et_key                  = lt_tend_req_keys
    ).

    LOOP AT lt_tend_req_data INTO DATA(ls_tend_req_data).
      INSERT VALUE #( key           = ls_tend_req_data-root_key ) INTO TABLE lt_fo_keys.
*      INSERT VALUE #( req_nr        = ls_tend_req_data-req_nr
*                      key           = ls_tend_req_data-root_key
*                      tend_req_key  = ls_tend_req_data-key ) INTO TABLE lt_fo_data_tend.
    ENDLOOP.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-active_tendering
      IMPORTING
        et_target_key           = DATA(lt_act_tend_keys)
    ).

    LOOP AT lt_tend_req_data ASSIGNING FIELD-SYMBOL(<ls_tend_req_data>).
      READ TABLE lt_act_tend_keys ASSIGNING FIELD-SYMBOL(<ls_act_tend_keys>) WITH KEY key = <ls_tend_req_data>-tend_key.
      IF sy-subrc = 0.
      INSERT VALUE #( req_nr        = <ls_tend_req_data>-req_nr
                      key           = <ls_tend_req_data>-root_key
                      tend_req_key  = <ls_tend_req_data>-key ) INTO TABLE lt_fo_data_tend.
      INSERT VALUE #( key           = <ls_tend_req_data>-key ) INTO TABLE lt_tend_req_keys.
      ENDIF.
    ENDLOOP.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fo_data
    ).

    LOOP AT lt_fo_data_tend INTO DATA(ls_fo_data_tend).
      READ TABLE lt_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>) WITH KEY key = ls_fo_data_tend-key.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <fs_fo_data> TO ls_fo_data_ret.
        ls_fo_data_ret-req_nr = ls_fo_data_tend-req_nr.
        ls_fo_data_ret-tend_req_key = ls_fo_data_tend-tend_req_key.
        APPEND ls_fo_data_ret TO lt_fo_data_ret.
      ENDIF.
    ENDLOOP.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-tenderingrequest
        it_key                  = lt_tend_req_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-tenderingrequest-tenderingresponse
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tend_resp_data
    ).

    LOOP AT lt_fo_data_ret ASSIGNING <fs_fo_data_ret>.
*      CLEAR <fs_tend_resp_data>.
      READ TABLE lt_tend_resp_data ASSIGNING <fs_tend_resp_data> WITH KEY parent_key = <fs_fo_data_ret>-tend_req_key.
      IF sy-subrc <> 0.
        <fs_fo_data_ret>-announcement = '01'.
      ELSE.
        IF <fs_tend_resp_data>-response_code = 'AP' OR <fs_tend_resp_data>-response_code = 'AX'.
          <fs_fo_data_ret>-announcement = '02'.
        ELSEIF <fs_tend_resp_data>-response_code = 'RE'.
          <fs_fo_data_ret>-announcement = '03'.
        ENDIF.
        <fs_fo_data_ret>-tend_current_bid = <fs_tend_resp_data>-amountprf * 10000.
        <fs_fo_data_ret>-tend_prf_curr    = <fs_tend_resp_data>-currcode016prf.
      ENDIF.
      READ TABLE lt_tend_req_data ASSIGNING FIELD-SYMBOL(<fs_tend_req_data>) WITH KEY key = <fs_fo_data_ret>-tend_req_key.
      IF sy-subrc = 0.
        <fs_fo_data_ret>-tend_end_date          = <fs_tend_req_data>-resp_due_dtime.
        <fs_fo_data_ret>-tend_minutes_remaining = calc_remaining_anno_time( iv_anno_enddate = <fs_fo_data_ret>-tend_end_date ).
*        <fs_fo_data_ret>-tend_max_amount        = <fs_tend_req_data>-amount.
*        <fs_fo_data_ret>-currcode016            = <fs_tend_req_data>-currcode016.
      ENDIF.
    ENDLOOP.
*    LOOP AT lt_fo_data_ret ASSIGNING <fs_fo_data_ret>.
*      READ TABLE lt_tend_resp_data ASSIGNING <fs_tend_resp_data> WITH KEY parent_key = <fs_fo_data_ret>-tend_req_key.
*      IF sy-subrc <> 0.
*        <fs_fo_data_ret>-announcement = '01'.
*      ENDIF.
*    ENDLOOP.
*
*    LOOP AT lt_fo_data_ret ASSIGNING <fs_fo_data_ret>.
*      READ TABLE lt_tend_resp_data ASSIGNING <fs_tend_resp_data> WITH KEY parent_key = <fs_fo_data_ret>-tend_req_key.
*      IF sy-subrc = 0.
*        IF <fs_tend_resp_data>-response_code = 'AP' OR <fs_tend_resp_data>-response_code = 'AX'.
*          <fs_fo_data_ret>-announcement = '02'.
*        ELSEIF <fs_tend_resp_data>-response_code = 'RE'.
*          <fs_fo_data_ret>-announcement = '03'.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.

    rt_announced_fos_for_carr = lt_fo_data_ret.

  ENDMETHOD.


  METHOD get_assigned_fus.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-assigned_fus
*        is_parameters           =
*        it_filtered_attributes  =
*        iv_fill_data            = abap_false
*        iv_before_image         = abap_false
*        iv_invalidate_cache     = abap_false
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
*        et_data                 =
*        et_key_link             =
        et_target_key           = rt_fu_keys
*        et_failed_key           =
    ).
  ENDMETHOD.


  METHOD get_carrier_for_user.

    DATA: lt_selpar       TYPE /bobf/t_frw_query_selparam,
          lt_bp           TYPE /scmtms/t_bupa_q_uname_result,
          lt_bp_rel       TYPE /bofu/t_bupa_relship_k,
          ls_query_filter TYPE /scmtms/s_tor_q_fo,
          lt_query_filter TYPE STANDARD TABLE OF /scmtms/s_tor_q_fo,
          lt_fo_data      TYPE /scmtms/t_tor_q_fo_r.

    "get the business partner from SAP user
    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = sy-uname
                    attribute_name  = 'UNAME'
                    ) INTO TABLE lt_selpar.

    go_bp_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_bp_c=>sc_query-root-query_by_uname
        it_selection_parameters = lt_selpar
     IMPORTING
       et_data                 = lt_bp
       et_key                  = DATA(lt_key)
       ).

    go_bp_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-root
        it_key                  = lt_key
        iv_association          = /bofu/if_bupa_constants=>sc_association-root-relationship
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_bp_rel
    ).

    CLEAR lt_selpar.

    LOOP AT lt_bp_rel ASSIGNING FIELD-SYMBOL(<fs_bp_rel>) WHERE relationshipcategory = 'BUR002-2'.
      APPEND <fs_bp_rel> TO rt_carrier_ids.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_charges.
    DATA: lt_fo_keys      TYPE /bobf/t_frw_key,
          lt_charges_data TYPE /scmtms/t_tcc_root_k.

*    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-transportcharges
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
        et_data                 = lt_charges_data
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    rt_charges_data = lt_charges_data.

*    READ TABLE lt_charges_data INDEX 1 INTO es_charges_data.

  ENDMETHOD.


  METHOD get_dom_values.

    DATA: lt_lifecycle      TYPE STANDARD TABLE OF dd07v,
          lt_execution      TYPE STANDARD TABLE OF dd07v,
          lt_confirmation   TYPE STANDARD TABLE OF dd07v,
          lt_subcontracting TYPE STANDARD TABLE OF dd07v,
          lt_tabb           TYPE STANDARD TABLE OF dd07v.

    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name   = zif_awc_overview_constants=>c_lifecycle_domain
        langu         = sy-langu
        withtext      = 'X'
      TABLES
        dd07v_tab_a   = lt_lifecycle
        dd07v_tab_n   = lt_tabb
      EXCEPTIONS
        illegal_value = 1
        op_failure    = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING lt_lifecycle TO et_lifecycle.
    ENDIF.

    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name   = zif_awc_overview_constants=>c_execution_domain
        langu         = sy-langu
        withtext      = 'X'
      TABLES
        dd07v_tab_a   = lt_execution
        dd07v_tab_n   = lt_tabb
      EXCEPTIONS
        illegal_value = 1
        op_failure    = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING lt_execution TO et_execution.
    ENDIF.

    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name   = zif_awc_overview_constants=>c_confirmation_domain
        langu         = sy-langu
        withtext      = 'X'
      TABLES
        dd07v_tab_a   = lt_confirmation
        dd07v_tab_n   = lt_tabb
      EXCEPTIONS
        illegal_value = 1
        op_failure    = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING lt_confirmation TO et_confirmation.
    ENDIF.

    CALL FUNCTION 'DD_DOMA_GET'
      EXPORTING
        domain_name   = zif_awc_overview_constants=>c_subcontracting_domain
        langu         = sy-langu
        withtext      = 'X'
      TABLES
        dd07v_tab_a   = lt_subcontracting
        dd07v_tab_n   = lt_tabb
      EXCEPTIONS
        illegal_value = 1
        op_failure    = 2
        OTHERS        = 3.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING lt_subcontracting TO et_subcontracting.
    ENDIF.
  ENDMETHOD.


  METHOD get_fo.

    DATA: lt_fo_keys      TYPE /bobf/t_frw_key,
          lt_fo_data_bopf TYPE /scmtms/t_tor_root_k,
          ls_fo_data_bopf TYPE /scmtms/s_tor_root_k,
          lt_fo_data      TYPE zawc_t_fo_data,
          ls_bupa         TYPE /bofu/s_bupa_root_k.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_fo_keys.

    DATA: lo_awc_helper TYPE REF TO zcl_awc_fo_overview_helper.

    CREATE OBJECT lo_awc_helper.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
*        iv_before_image         = ABAP_FALSE
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = ABAP_FALSE
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_fo_data_bopf
*        et_failed_key           =
    ).

    MOVE-CORRESPONDING lt_fo_data_bopf TO lt_fo_data.

    DATA(lt_carriers) = get_carrier_for_user( ).

    DATA(lt_fos_anno_carr) = get_announced_fos_for_carrier(
      EXPORTING
        it_fos           = lt_fo_data
        it_carriers      = lt_carriers
    ).

    get_pick_drop_date(
      EXPORTING
        it_fo_keys   = lt_fo_keys
      IMPORTING
        et_summ_data = DATA(lt_summ_data)
        et_src_loc = DATA(lt_src_loc)
        et_des_loc = DATA(lt_des_loc)
    ).

    SELECT * FROM /scmtms/c_ev_tyt INTO TABLE @DATA(lt_event_desc).

    DATA(lt_partner_data) = get_partner( it_fo_data = lt_fo_data ).

    DATA(lt_charges_data) = get_charges( it_fo_keys = lt_fo_keys ).

    DATA(lt_veh_res) = get_veh_res( it_fo_keys = lt_fo_keys ).

    DATA(lt_tend_data) = get_tend_data( it_fo_keys = lt_fo_keys ).

    DATA(lt_event_data) = NEW zcl_awc_fo_event( )->get_last_event( it_fo_key = lt_fo_keys ).

    get_dom_values(
      IMPORTING
        et_lifecycle      = DATA(lt_lifecycle)                 " Generierte Tabelle zu einem View
        et_execution      = DATA(lt_execution)                 " Generierte Tabelle zu einem View
        et_confirmation   = DATA(lt_confirmation)                 " Generierte Tabelle zu einem View
        et_subcontracting = DATA(lt_subcontracting)                 " Generierte Tabelle zu einem View
      ).

    LOOP AT lt_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).
      READ TABLE lt_summ_data ASSIGNING FIELD-SYMBOL(<fs_summ_data>) WITH KEY parent_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-first_stop_aggr_assgn_start_l  = <fs_summ_data>-first_stop_aggr_assgn_start_l.
        <fs_fo_data>-last_stop_aggr_assgn_end_l     = <fs_summ_data>-last_stop_aggr_assgn_end_l.
        <fs_fo_data>-pick_count_load                = <fs_summ_data>-pick_count_load.
        <fs_fo_data>-drop_count_unload              = <fs_summ_data>-drop_count.
        <fs_fo_data>-src_loc_uuid                   = <fs_summ_data>-first_stop_log_loc_uuid.
        <fs_fo_data>-des_loc_uuid                   = <fs_summ_data>-last_stop_log_loc_uuid.
        <fs_fo_data>-max_util                       = <fs_summ_data>-max_util.
        <fs_fo_data>-total_distance_km              = <fs_summ_data>-tot_distance_km.
        <fs_fo_data>-total_duration_net             = <fs_summ_data>-tot_duration.
      ENDIF.

      READ TABLE lt_src_loc INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_src_loc>). "WITH KEY key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-src_loc_name1                  = <fs_src_loc>-name1.
        <fs_fo_data>-src_loc_country_code           = <fs_src_loc>-country_code.
        <fs_fo_data>-src_loc_region                 = <fs_src_loc>-region.
        <fs_fo_data>-src_loc_city_name              = <fs_src_loc>-city_name.
        <fs_fo_data>-src_loc_street_postal_code     = <fs_src_loc>-street_postal_code.
        <fs_fo_data>-src_loc_street_name            = <fs_src_loc>-street_name.
        <fs_fo_data>-src_loc_house_id               = <fs_src_loc>-house_id.
        <fs_fo_data>-src_timezone_code              = <fs_src_loc>-time_zone_code.

        <fs_fo_data>-first_stop_aggr_assgn_start_l = lo_awc_helper->convert_into_tz(
          EXPORTING
            iv_from_tz = 'UTC'                 " Zeitzone
            iv_to_tz   = <fs_fo_data>-src_timezone_code                 " Zeitzone
            iv_from_ts = CONV #( <fs_fo_data>-first_stop_aggr_assgn_start_l )                 " Textfeld Länge 14
        ).
      ENDIF.

      READ TABLE lt_des_loc INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_des_loc>). " WITH KEY key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-des_loc_name1                  = <fs_des_loc>-name1.
        <fs_fo_data>-des_loc_country_code           = <fs_des_loc>-country_code.
        <fs_fo_data>-des_loc_region                 = <fs_des_loc>-region.
        <fs_fo_data>-des_loc_city_name              = <fs_des_loc>-city_name.
        <fs_fo_data>-des_loc_street_postal_code     = <fs_des_loc>-street_postal_code.
        <fs_fo_data>-des_loc_street_name            = <fs_des_loc>-street_name.
        <fs_fo_data>-des_loc_house_id               = <fs_des_loc>-house_id.
        <fs_fo_data>-des_timezone_code              = <fs_des_loc>-time_zone_code.

        <fs_fo_data>-last_stop_aggr_assgn_end_l =  lo_awc_helper->convert_into_tz(
          EXPORTING
            iv_from_tz = 'UTC'                 " Zeitzone
            iv_to_tz   = <fs_fo_data>-des_timezone_code                 " Zeitzone
            iv_from_ts = CONV #( <fs_fo_data>-last_stop_aggr_assgn_end_l )                " Textfeld Länge 14
        ).
      ENDIF.

      READ TABLE lt_charges_data INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_charges_data>).
      IF sy-subrc = 0.
        <fs_fo_data>-net_amount                     = <fs_charges_data>-net_amount * 10000.
        <fs_fo_data>-doc_currency                   = <fs_charges_data>-doc_currency.
      ENDIF.

      READ TABLE lt_partner_data INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_partner_data>).
      IF sy-subrc = 0.
        <fs_fo_data>-commpty_desc                   = <fs_partner_data>-commpty_desc.
        <fs_fo_data>-cons_bupa_description          = <fs_partner_data>-cons_bupa_desc.
        <fs_fo_data>-shp_bupa_description           = <fs_partner_data>-shp_bupa_desc.
        <fs_fo_data>-tsp_desc                       = <fs_partner_data>-tsp_desc.
        <fs_fo_data>-tspexec_desc                   = <fs_partner_data>-tspexec_desc.
        <fs_fo_data>-comm_party_email               = <fs_partner_data>-email.
        <fs_fo_data>-comm_party_telephone           = <fs_partner_data>-telephone.
      ENDIF.

      READ TABLE lt_veh_res INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_veh_res>).
      IF sy-subrc = 0.
        <fs_fo_data>-vehicleres_id                  = <fs_veh_res>-res_id.
        <fs_fo_data>-platenumber                    = <fs_veh_res>-platenumber.
        <fs_fo_data>-country                        = <fs_veh_res>-country.
      ENDIF.

      READ TABLE lt_tend_data ASSIGNING FIELD-SYMBOL(<fs_tend_data>) WITH KEY fo_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-tend_end_date                  = <fs_tend_data>-tend_end_date.
        <fs_fo_data>-tend_minutes_remaining         = <fs_tend_data>-tend_minutes_remaining.
        <fs_fo_data>-req_nr                         = <fs_tend_data>-tend_req_nr.
*        <fs_fo_data>-tend_current_bid               = <fs_tend_data>-tend_current_bid * 10000.
*        <fs_fo_data>-tend_prf_curr                  = <fs_tend_data>-tend_prf_curr.
      ENDIF.

      READ TABLE lt_fos_anno_carr INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_fos_anno_carr>).
      IF sy-subrc = 0.
        <fs_fo_data>-announcement = <fs_fos_anno_carr>-announcement.
      ENDIF.

      READ TABLE lt_lifecycle INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_lifecycle>).
      IF sy-subrc = 0.
        <fs_fo_data>-lifecycle_status_desc = <fs_lifecycle>-ddtext.
      ENDIF.

      READ TABLE lt_execution INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_execution>).
      IF sy-subrc = 0.
        <fs_fo_data>-execution_status_desc = <fs_execution>-ddtext.
      ENDIF.

      READ TABLE lt_confirmation INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_confirmation>).
      IF sy-subrc = 0.
        <fs_fo_data>-conf_status_desc = <fs_confirmation>-ddtext.
      ENDIF.

      READ TABLE lt_subcontracting INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_subcontracting>).
      IF sy-subrc = 0.
        <fs_fo_data>-subcont_status_desc = <fs_subcontracting>-ddtext.
      ENDIF.

      READ TABLE lt_event_data ASSIGNING FIELD-SYMBOL(<fs_event_data>) WITH KEY root_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        READ TABLE lt_event_desc ASSIGNING FIELD-SYMBOL(<fs_event_desc>) WITH KEY tor_event = <fs_event_data>-event_code.
        IF sy-subrc = 0.
          <fs_fo_data>-last_event = <fs_event_desc>-description_s.
        ENDIF.
      ENDIF.

    ENDLOOP.

    READ TABLE lt_fo_data INDEX 1 INTO es_fo_data.

  ENDMETHOD.


  METHOD get_fos.

    DATA: ls_fo_data       TYPE zawc_s_fo_data,
          ls_ret_data      TYPE zawc_s_fo_data,
          lt_ret_data      TYPE zawc_t_fo_data,
          ls_last_event    TYPE zawc_s_fo_event,
          lt_fo_keys       TYPE /bobf/t_frw_key,
          lo_event         TYPE REF TO zcl_awc_fo_event,
          lt_fo_anno_keys  TYPE /bobf/t_frw_key,
          lt_announced_fos TYPE zawc_t_fo_data,
          lo_awc_helper    TYPE REF TO zcl_awc_fo_overview_helper.

    CREATE OBJECT lo_awc_helper.

    CREATE OBJECT lo_event.

    DATA(lt_carriers) = get_carrier_for_user( ).

    IF lt_carriers IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_app_indicator <> 'A'.
      DATA(lt_fo_data) = get_fos_from_tor( it_carriers      = lt_carriers
                               iv_app_indicator = iv_app_indicator
                               iv_conf_status   = iv_conf_status
                               iv_exec_status   = iv_exec_status ).

      MOVE-CORRESPONDING lt_fo_data TO et_fo_data.
    ELSE.

      DATA(lt_fos_anno_carr) = get_announced_fos_for_carrier(
        EXPORTING
          it_fos           = lt_fo_data
          it_carriers      = lt_carriers
      ).

      MOVE-CORRESPONDING lt_fos_anno_carr TO lt_ret_data.

      IF iv_anno_status IS NOT INITIAL.
        LOOP AT lt_ret_data INTO ls_ret_data WHERE announcement = iv_anno_status.
          APPEND ls_ret_data TO et_fo_data.
        ENDLOOP.
      ELSE.
        et_fo_data = lt_ret_data.
      ENDIF.
    ENDIF.

    LOOP AT et_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data_keys>).
      INSERT VALUE #( key = <fs_fo_data_keys>-key ) INTO TABLE lt_fo_keys.
    ENDLOOP.

    DATA(lt_partner_data) = get_partner( it_fo_data = et_fo_data ).

    get_pick_drop_date(
      EXPORTING
        it_fo_keys   = lt_fo_keys
      IMPORTING
        et_summ_data = DATA(lt_summ_data)
        et_src_loc = DATA(lt_src_loc)
        et_des_loc = DATA(lt_des_loc)
    ).

    SELECT * FROM /scmtms/c_ev_tyt INTO TABLE @DATA(lt_event_desc).

    DATA(lt_charges_data) = get_charges( it_fo_keys = lt_fo_keys ).

    DATA(lt_veh_res) = get_veh_res( it_fo_keys = lt_fo_keys ).

    DATA(lt_amts_change) = check_amounts_changed( it_fo_keys = lt_fo_keys ).

    DATA(lt_tend_data) = get_tend_data( it_fo_keys = lt_fo_keys ).

    DATA(lt_event_data) = NEW zcl_awc_fo_event( )->get_last_event( it_fo_key = lt_fo_keys ).

    get_dom_values(
    IMPORTING
      et_lifecycle      = DATA(lt_lifecycle)                 " Generierte Tabelle zu einem View
      et_execution      = DATA(lt_execution)                 " Generierte Tabelle zu einem View
      et_confirmation   = DATA(lt_confirmation)                 " Generierte Tabelle zu einem View
      et_subcontracting = DATA(lt_subcontracting)                 " Generierte Tabelle zu einem View
  ).

    LOOP AT et_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).
      READ TABLE lt_summ_data ASSIGNING FIELD-SYMBOL(<fs_summ_data>) WITH KEY parent_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-first_stop_aggr_assgn_start_l  = <fs_summ_data>-first_stop_aggr_assgn_start_l.
        <fs_fo_data>-last_stop_aggr_assgn_end_l     = <fs_summ_data>-last_stop_aggr_assgn_end_l.
        <fs_fo_data>-pick_count_load                = <fs_summ_data>-pick_count_load.
        <fs_fo_data>-drop_count_unload              = <fs_summ_data>-drop_count.
        <fs_fo_data>-src_loc_uuid                   = <fs_summ_data>-first_stop_log_loc_uuid.
        <fs_fo_data>-des_loc_uuid                   = <fs_summ_data>-last_stop_log_loc_uuid.
        <fs_fo_data>-max_util                       = <fs_summ_data>-max_util.
        <fs_fo_data>-total_distance_km              = <fs_summ_data>-tot_distance_km.
        <fs_fo_data>-total_duration_net             = <fs_summ_data>-tot_duration.
      ENDIF.

      READ TABLE lt_amts_change ASSIGNING FIELD-SYMBOL(<fs_amts_change>) WITH KEY key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-amounts_changed                = <fs_amts_change>-amounts_changed.
      ENDIF.

      READ TABLE lt_src_loc ASSIGNING FIELD-SYMBOL(<fs_src_loc>) WITH KEY loc_uuid = <fs_fo_data>-src_loc_uuid.
      IF sy-subrc = 0.
*      READ TABLE lt_src_loc ASSIGNING FIELD-SYMBOL(<fs_src_loc>) WITH KEY key = <fs_fo_data>-key.
        <fs_fo_data>-src_loc_name1                  = <fs_src_loc>-name1.
        <fs_fo_data>-src_loc_country_code           = <fs_src_loc>-country_code.
        <fs_fo_data>-src_loc_region                 = <fs_src_loc>-region.
        <fs_fo_data>-src_loc_city_name              = <fs_src_loc>-city_name.
        <fs_fo_data>-src_loc_street_postal_code     = <fs_src_loc>-street_postal_code.
        <fs_fo_data>-src_loc_street_name            = <fs_src_loc>-street_name.
        <fs_fo_data>-src_loc_house_id               = <fs_src_loc>-house_id.
        <fs_fo_data>-src_timezone_code              = <fs_src_loc>-time_zone_code.

        <fs_fo_data>-first_stop_aggr_assgn_start_l = lo_awc_helper->convert_into_tz(
          EXPORTING
            iv_from_tz = 'UTC'                 " Zeitzone
            iv_to_tz   = <fs_fo_data>-src_timezone_code                 " Zeitzone
            iv_from_ts = CONV #( <fs_fo_data>-first_stop_aggr_assgn_start_l )                 " Textfeld Länge 14
        ).
      ENDIF.

      READ TABLE lt_des_loc ASSIGNING FIELD-SYMBOL(<fs_des_loc>) WITH KEY loc_uuid = <fs_fo_data>-des_loc_uuid.
      IF sy-subrc = 0.
*      READ TABLE lt_des_loc ASSIGNING FIELD-SYMBOL(<fs_des_loc>) WITH KEY key = <fs_fo_data>-key.
        <fs_fo_data>-des_loc_name1                  = <fs_des_loc>-name1.
        <fs_fo_data>-des_loc_country_code           = <fs_des_loc>-country_code.
        <fs_fo_data>-des_loc_region                 = <fs_des_loc>-region.
        <fs_fo_data>-des_loc_city_name              = <fs_des_loc>-city_name.
        <fs_fo_data>-des_loc_street_postal_code     = <fs_des_loc>-street_postal_code.
        <fs_fo_data>-des_loc_street_name            = <fs_des_loc>-street_name.
        <fs_fo_data>-des_loc_house_id               = <fs_des_loc>-house_id.
        <fs_fo_data>-des_timezone_code              = <fs_des_loc>-time_zone_code.

        <fs_fo_data>-last_stop_aggr_assgn_end_l =  lo_awc_helper->convert_into_tz(
          EXPORTING
            iv_from_tz = 'UTC'                 " Zeitzone
            iv_to_tz   = <fs_fo_data>-des_timezone_code                 " Zeitzone
            iv_from_ts = CONV #( <fs_fo_data>-last_stop_aggr_assgn_end_l )                " Textfeld Länge 14
        ).
      ENDIF.

      READ TABLE lt_charges_data ASSIGNING FIELD-SYMBOL(<fs_charges_data>) WITH KEY parent_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-net_amount                     = <fs_charges_data>-net_amount * 10000.
        <fs_fo_data>-doc_currency                   = <fs_charges_data>-doc_currency.
      ENDIF.

      READ TABLE lt_partner_data ASSIGNING FIELD-SYMBOL(<fs_partner_data>) WITH KEY fo_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-commpty_desc                   = <fs_partner_data>-commpty_desc.
        <fs_fo_data>-cons_bupa_description          = <fs_partner_data>-cons_bupa_desc.
        <fs_fo_data>-shp_bupa_description           = <fs_partner_data>-shp_bupa_desc.
        <fs_fo_data>-tsp_desc                       = <fs_partner_data>-tsp_desc.
        <fs_fo_data>-tspexec_desc                   = <fs_partner_data>-tspexec_desc.
        <fs_fo_data>-comm_party_email               = <fs_partner_data>-email.
        <fs_fo_data>-comm_party_telephone           = <fs_partner_data>-telephone.
      ENDIF.

      READ TABLE lt_veh_res ASSIGNING FIELD-SYMBOL(<fs_veh_res>) WITH KEY parent_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-vehicleres_id                  = <fs_veh_res>-res_id.
        <fs_fo_data>-platenumber                    = <fs_veh_res>-platenumber.
        <fs_fo_data>-country                        = <fs_veh_res>-country.
      ENDIF.

      READ TABLE lt_tend_data ASSIGNING FIELD-SYMBOL(<fs_tend_data>) WITH KEY fo_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        <fs_fo_data>-tend_end_date                  = <fs_tend_data>-tend_end_date.
        <fs_fo_data>-tend_minutes_remaining         = <fs_tend_data>-tend_minutes_remaining.
        <fs_fo_data>-req_nr                         = <fs_tend_data>-tend_req_nr.
*        <fs_fo_data>-tend_current_bid               = <fs_tend_data>-tend_current_bid * 10000.
*        <fs_fo_data>-tend_prf_curr                  = <fs_tend_data>-tend_prf_curr.
      ENDIF.

      READ TABLE lt_lifecycle ASSIGNING FIELD-SYMBOL(<fs_lifecycle>) WITH KEY domvalue_l = <fs_fo_data>-lifecycle.
      IF sy-subrc = 0.
        <fs_fo_data>-lifecycle_status_desc = <fs_lifecycle>-ddtext.
      ENDIF.

      READ TABLE lt_execution ASSIGNING FIELD-SYMBOL(<fs_execution>) WITH KEY domvalue_l = <fs_fo_data>-execution.
      IF sy-subrc = 0.
        <fs_fo_data>-execution_status_desc = <fs_execution>-ddtext.
      ENDIF.

      READ TABLE lt_confirmation ASSIGNING FIELD-SYMBOL(<fs_confirmation>) WITH KEY domvalue_l = <fs_fo_data>-confirmation.
      IF sy-subrc = 0.
        <fs_fo_data>-conf_status_desc = <fs_confirmation>-ddtext.
      ENDIF.

      READ TABLE lt_subcontracting ASSIGNING FIELD-SYMBOL(<fs_subcontracting>) WITH KEY domvalue_l = <fs_fo_data>-subcontracting.
      IF sy-subrc = 0.
        <fs_fo_data>-subcont_status_desc = <fs_subcontracting>-ddtext.
      ENDIF.

      READ TABLE lt_event_data ASSIGNING FIELD-SYMBOL(<fs_event_data>) WITH KEY root_key = <fs_fo_data>-key.
      IF sy-subrc = 0.
        READ TABLE lt_event_desc ASSIGNING FIELD-SYMBOL(<fs_event_desc>) WITH KEY tor_event = <fs_event_data>-event_code.
        IF sy-subrc = 0.
          <fs_fo_data>-last_event = <fs_event_desc>-description_s.
        ENDIF.
      ENDIF.

    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM et_fo_data.

  ENDMETHOD.


  METHOD get_fos_for_carr.

    DATA: lt_selpar       TYPE /bobf/t_frw_query_selparam,
          lt_bp           TYPE /scmtms/t_bupa_q_uname_result,
          lt_bp_rel       TYPE /bofu/t_bupa_relship_k,
          ls_query_filter TYPE /scmtms/s_tor_q_fo,
          lt_query_filter TYPE STANDARD TABLE OF /scmtms/s_tor_q_fo,
          lt_fo_data      TYPE /scmtms/t_tor_q_fo_r.

    LOOP AT it_carr ASSIGNING FIELD-SYMBOL(<fs_bp_rel>).
      IF <fs_bp_rel>-relationshipcategory = 'BUR001-2'.
        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = <fs_bp_rel>-partner
                        attribute_name  = 'TSP_ID'
            ) INTO TABLE lt_selpar.
      ENDIF.
    ENDLOOP.

    go_tor_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_tor_c=>sc_query-root-fo_data_by_attr
*        it_filter_key           =
        it_selection_parameters = lt_selpar
*        is_query_options        =
        iv_fill_data            = abap_true
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        es_query_info           =
        et_data                 = lt_fo_data
*        et_key                  =
    ).

    LOOP AT lt_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).
      READ TABLE it_fo WITH KEY key = <fs_fo_data>-db_key INTO DATA(ls_fo_data).
      APPEND ls_fo_data TO et_fo.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_fos_from_tor.

    DATA: lt_selpar  TYPE /bobf/t_frw_query_selparam,
          lt_fo_data TYPE /scmtms/t_tor_root_k.

    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = 'TO'
                    attribute_name  = 'TOR_CAT' ) INTO TABLE lt_selpar.

    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = 'BO'
                    attribute_name  = 'TOR_CAT' ) INTO TABLE lt_selpar.

    IF iv_app_indicator <> 'A'.
      LOOP AT it_carriers ASSIGNING FIELD-SYMBOL(<fs_bp_rel>).
        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = <fs_bp_rel>-relshp_partner
                        attribute_name  = 'TSPID' ) INTO TABLE lt_selpar.
      ENDLOOP.

      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = '03'
                      attribute_name  = 'SUBCONTRACTING' ) INTO TABLE lt_selpar.

      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = '04'
                      attribute_name  = 'SUBCONTRACTING' ) INTO TABLE lt_selpar.
*
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = '02'
                      attribute_name  = 'LIFECYCLE' ) INTO TABLE lt_selpar.

      IF iv_app_indicator = 'C'.

        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = '02'
                        attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = '08'
                        attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

        IF iv_conf_status IS NOT INITIAL.
          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = iv_conf_status
                          attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

        ELSE.
          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '01'
                          attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '03'
                          attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '04'
                          attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

        ENDIF.

      ELSEIF iv_app_indicator = 'E'.
        IF iv_exec_status IS NOT INITIAL.

          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = iv_exec_status
                          attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

        ELSE.
          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '03'
                          attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '04'
                          attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

          INSERT VALUE #( sign            = 'I'
                          option          = 'EQ'
                          low             = '07'
                          attribute_name  = 'EXECUTION' ) INTO TABLE lt_selpar.

        ENDIF.

        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = '01'
                        attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = '04'
                        attribute_name  = 'CONFIRMATION' ) INTO TABLE lt_selpar.

      ENDIF.
    ELSE.
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = '02'
                      attribute_name  = 'SUBCONTRACTING' ) INTO TABLE lt_selpar.
    ENDIF.

    go_tor_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_tor_c=>sc_query-root-root_elements
        it_selection_parameters = lt_selpar
        iv_fill_data            = abap_true
     IMPORTING
       et_data                 = lt_fo_data
*       et_key                  = DATA(lt_key)
       ).

    MOVE-CORRESPONDING lt_fo_data TO rt_fo_data.
  ENDMETHOD.


  METHOD get_partner.
    DATA: lt_fo_keys      TYPE /bobf/t_frw_key,
          lt_party_keys   TYPE /bobf/t_frw_key,
          lt_party_data   TYPE /scmtms/t_tor_party_k,
          ls_party_data   TYPE /scmtms/s_tor_party_k,
          ls_bupa_data    TYPE /bofu/s_bupa_root_k,
          lo_bupa         TYPE REF TO zcl_awc_fo_bupa,
          lt_partner_data TYPE zawc_t_fo_partner,
          lt_bupa_keys    TYPE /bobf/t_frw_key.

    LOOP AT it_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).
      INSERT VALUE #( key = <fs_fo_data>-key ) INTO TABLE lt_fo_keys.
      INSERT VALUE #( fo_key = <fs_fo_data>-key
                      tsp_key = <fs_fo_data>-tsp
                      commpty_key = <fs_fo_data>-commpty_key
                      tspexec_key = <fs_fo_data>-tspexec_key ) INTO TABLE lt_partner_data.
    ENDLOOP.

    CREATE OBJECT lo_bupa.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-party
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
        et_data                 = lt_party_data
*          et_key_link             =
        et_target_key           = lt_party_keys
*          et_failed_key           =
    ).

    LOOP AT lt_party_data ASSIGNING FIELD-SYMBOL(<fs_shp_data>) WHERE party_rco = 'TM026'.


      INSERT VALUE #( fo_key = <fs_shp_data>-parent_key
                      shp_bupa_key = <fs_shp_data>-party_uuid ) INTO TABLE lt_partner_data.
    ENDLOOP.

    LOOP AT lt_party_data ASSIGNING FIELD-SYMBOL(<fs_cons_data>) WHERE party_rco = 'TM027'.



      INSERT VALUE #( fo_key = <fs_cons_data>-parent_key
                      shp_bupa_key = <fs_cons_data>-party_uuid ) INTO TABLE lt_partner_data.

    ENDLOOP.

    LOOP AT lt_partner_data ASSIGNING FIELD-SYMBOL(<fs_partner>).
      INSERT VALUE #( key = <fs_partner>-commpty_key ) INTO TABLE lt_bupa_keys.
      INSERT VALUE #( key = <fs_partner>-tspexec_key ) INTO TABLE lt_bupa_keys.
      INSERT VALUE #( key = <fs_partner>-tsp_key ) INTO TABLE lt_bupa_keys.
      INSERT VALUE #( key = <fs_partner>-cons_bupa_key ) INTO TABLE lt_bupa_keys.
      INSERT VALUE #( key = <fs_partner>-shp_bupa_key ) INTO TABLE lt_bupa_keys.
    ENDLOOP.

    lo_bupa->get_bupa(
      EXPORTING
        it_bupa_key  = lt_bupa_keys    " NodeID
      IMPORTING
        et_bupa_data = DATA(lt_bupa_data)
    ).

    DATA(lt_bupa_contact) = lo_bupa->get_contact_info( it_bupa_keys = lt_bupa_keys ).

    LOOP AT lt_bupa_data ASSIGNING FIELD-SYMBOL(<fs_bupa>).
      LOOP AT lt_partner_data ASSIGNING FIELD-SYMBOL(<fs_partner_data>).
        IF <fs_partner_data>-cons_bupa_key = <fs_bupa>-key.
          <fs_partner_data>-cons_bupa_desc = <fs_bupa>-description.
        ENDIF.
        IF <fs_partner_data>-tsp_key = <fs_bupa>-key.
          <fs_partner_data>-tsp_desc = <fs_bupa>-description.
        ENDIF.
        IF <fs_partner_data>-shp_bupa_key = <fs_bupa>-key.
          <fs_partner_data>-shp_bupa_desc = <fs_bupa>-description.
        ENDIF.
        IF <fs_partner_data>-commpty_key = <fs_bupa>-key.
          READ TABLE lt_bupa_contact INTO DATA(ls_bupa_contact) WITH KEY key = <fs_bupa>-key.
          <fs_partner_data>-telephone     = ls_bupa_contact-telephone.
          <fs_partner_data>-email         = ls_bupa_contact-email.
          <fs_partner_data>-commpty_desc  = <fs_bupa>-description.
        ENDIF.
        IF <fs_partner_data>-tspexec_key = <fs_bupa>-key.
          <fs_partner_data>-tspexec_desc = <fs_bupa>-description.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rt_partners = lt_partner_data.


  ENDMETHOD.


  METHOD get_pick_drop_date.

    DATA: lt_fo_keys      TYPE /bobf/t_frw_key,
          lt_summ_data    TYPE /scmtms/t_tor_root_transient_k,
          lo_location     TYPE REF TO zcl_awc_fo_location,
          lt_src_loc_keys TYPE /bobf/t_frw_key,
          lt_des_loc_keys TYPE /bobf/t_frw_key,
          ls_src_loc      TYPE zawc_s_fo_loc,
          ls_des_loc      TYPE zawc_s_fo_loc.

    CREATE OBJECT lo_location.

*    LOOP AT ct_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).

*      INSERT VALUE #( key = cs_fo_data-key ) INTO TABLE lt_fo_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-summary
*          iv_before_image         = ABAP_FALSE
*          iv_edit_mode            =
        iv_fill_data            = abap_true
*          iv_invalidate_cache     = ABAP_FALSE
*          it_requested_attributes =
      IMPORTING
*          eo_message              =
*          eo_change               =
        et_data                 = lt_summ_data
*          et_failed_key           =
    ).

    LOOP AT lt_summ_data ASSIGNING FIELD-SYMBOL(<fs_summ_data>).
      INSERT VALUE #( key = <fs_summ_data>-first_stop_log_loc_uuid ) INTO TABLE lt_src_loc_keys.

      INSERT VALUE #( key = <fs_summ_data>-last_stop_log_loc_uuid ) INTO TABLE lt_des_loc_keys.
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

    LOOP AT lt_summ_data ASSIGNING FIELD-SYMBOL(<fs_summ>).
      READ TABLE lt_src_loc ASSIGNING FIELD-SYMBOL(<fs_src>) WITH KEY loc_uuid = <fs_summ>-first_stop_log_loc_uuid.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <fs_src> TO ls_src_loc.
        <fs_src>-key = <fs_summ>-parent_key.
        APPEND ls_src_loc TO et_src_loc.
      ENDIF.

      READ TABLE lt_des_loc ASSIGNING FIELD-SYMBOL(<fs_des>) WITH KEY loc_uuid = <fs_summ>-last_stop_log_loc_uuid.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING <fs_des> TO ls_des_loc.
        <fs_des>-key = <fs_summ>-parent_key.
        APPEND ls_des_loc TO et_des_loc.
      ENDIF.
    ENDLOOP.

    et_summ_data = lt_summ_data.


*      READ TABLE lt_summ_data INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_summ_data>).
*      cs_fo_data-first_stop_aggr_assgn_start_l = <fs_summ_data>-first_stop_aggr_assgn_start_l.
*      cs_fo_data-last_stop_aggr_assgn_end_l = <fs_summ_data>-last_stop_aggr_assgn_end_l.
*      cs_fo_data-pick_count_load = <fs_summ_data>-pick_count_load.
*      cs_fo_data-drop_count_unload = <fs_summ_data>-drop_count.

*      get_charges(
*        EXPORTING
*          iv_fo_key       = conv #( cs_fo_data-key )    " NodeID
*        IMPORTING
*          es_charges_data = data(ls_charges_data)
*      ).
*
*      cs_fo_data-net_amount = ls_charges_data-net_amount.

*    ENDLOOP.
  ENDMETHOD.


  METHOD get_status_descr.

    DATA : l_value TYPE dd07v-domvalue_l.

    DATA : dd07v_wa TYPE dd07v.

*    LOOP AT ct_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>).
    l_value = cs_fo_data-lifecycle.

    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = zif_awc_overview_constants=>c_lifecycle_domain
        value         = l_value
        langu         = sy-langu
        texts_only    = 'X'
      IMPORTING
        dd07v_wa      = dd07v_wa
      EXCEPTIONS
        not_found     = 1
        illegal_input = 2
        OTHERS        = 3.

    cs_fo_data-lifecycle_status_desc = dd07v_wa-ddtext.

    l_value = cs_fo_data-execution.

    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = zif_awc_overview_constants=>c_execution_domain
        value         = l_value
        langu         = sy-langu
        texts_only    = 'X'
      IMPORTING
        dd07v_wa      = dd07v_wa
      EXCEPTIONS
        not_found     = 1
        illegal_input = 2
        OTHERS        = 3.

    cs_fo_data-execution_status_desc = dd07v_wa-ddtext.

    l_value = cs_fo_data-confirmation.

    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = zif_awc_overview_constants=>c_confirmation_domain
        value         = l_value
        langu         = sy-langu
        texts_only    = 'X'
      IMPORTING
        dd07v_wa      = dd07v_wa
      EXCEPTIONS
        not_found     = 1
        illegal_input = 2
        OTHERS        = 3.

    cs_fo_data-conf_status_desc = dd07v_wa-ddtext.

    l_value = cs_fo_data-subcontracting.

    CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
      EXPORTING
        name          = zif_awc_overview_constants=>c_subcontracting_domain
        value         = l_value
        langu         = sy-langu
        texts_only    = 'X'
      IMPORTING
        dd07v_wa      = dd07v_wa
      EXCEPTIONS
        not_found     = 1
        illegal_input = 2
        OTHERS        = 3.

    cs_fo_data-subcont_status_desc = dd07v_wa-ddtext.
*    ENDLOOP.
  ENDMETHOD.


  METHOD get_tend_data.

    DATA: lt_tend_data      TYPE /scmtms/t_tor_tend_k,
          ls_tend_data      TYPE /scmtms/s_tor_tend_k,
          lt_tend_keys      TYPE /bobf/t_frw_key,
          lt_tend_req_data  TYPE /scmtms/t_tor_tend_req_k,
          ls_tend_req_data  TYPE /scmtms/s_tor_tend_req_k,
          lt_tend_req_keys  TYPE /bobf/t_frw_key,
          lt_request        TYPE zawc_t_fo_request,
          lv_time_remaining TYPE zawc_tend_time_remain,
          lt_tend_step_keys TYPE /bobf/t_frw_key,
          lt_tend_resp_data TYPE /scmtms/t_tor_tend_resp_k,
          ls_tend_resp_data TYPE /scmtms/s_tor_tend_resp_k.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-active_tendering
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = abap_false
*        iv_invalidate_cache     = abap_false
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_tend_data
*        et_key_link             =
        et_target_key           = lt_tend_keys
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-tendering
        it_key                  = lt_tend_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-tendering-active_tenderingstep
*        is_parameters           =
*        it_filtered_attributes  =
*        iv_fill_data            = abap_false
*        iv_before_image         = abap_false
*        iv_invalidate_cache     = abap_false
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
*        et_data                 =
*        et_key_link             =
        et_target_key           = lt_tend_step_keys
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-tenderingstep
        it_key                  = lt_tend_step_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-tenderingstep-tenderingrequest
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = abap_false
*        iv_invalidate_cache     = abap_false
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_tend_req_data
*        et_key_link             =
        et_target_key           = lt_tend_req_keys
*        et_failed_key           =
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-tenderingrequest
        it_key                  = lt_tend_req_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-tenderingrequest-tenderingresponse
*        is_parameters           =
*        it_filtered_attributes  =
        iv_fill_data            = abap_true
*        iv_before_image         = abap_false
*        iv_invalidate_cache     = abap_false
*        iv_edit_mode            =
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_tend_resp_data
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

    IF lt_tend_data IS NOT INITIAL.
      LOOP AT lt_tend_data ASSIGNING FIELD-SYMBOL(<fs_tend_data>).
        "Get requests for tenderings and sort requests by date to get earliest request
        LOOP AT lt_tend_req_data INTO ls_tend_req_data WHERE tend_key = <fs_tend_data>-key.
          APPEND ls_tend_req_data TO lt_request.
        ENDLOOP.
        SORT lt_request DESCENDING BY start_datetime.
        READ TABLE lt_request INDEX 1 INTO ls_tend_req_data.
        lv_time_remaining = calc_remaining_anno_time( iv_anno_enddate =  ls_tend_req_data-resp_due_dtime ).
        READ TABLE lt_tend_resp_data INTO ls_tend_resp_data WITH KEY tend_key = <fs_tend_data>-key.
        INSERT VALUE #( tend_end_date = <fs_tend_data>-est_end_datetime
                        fo_key = <fs_tend_data>-root_key
                        tend_minutes_remaining = lv_time_remaining
                        tend_req_nr = ls_tend_req_data-req_nr
                        tend_current_bid = ls_tend_resp_data-amountprf
                        tend_prf_curr = ls_tend_resp_data-currcode016prf ) INTO TABLE rt_tend_data.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD get_veh_res.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-item_tr_main
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
        et_data                 = rt_veh_res
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).

  ENDMETHOD.


  METHOD reject_fo.

    DATA: lt_fo_data     TYPE /scmtms/t_tor_root_k,
          lv_conf_status TYPE /scmtms/tor_confirm_status.

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
*        iv_before_image         = abap_false
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = abap_false
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_fo_data
*        et_failed_key           =
    ).

    READ TABLE lt_fo_data INDEX 1 INTO DATA(ls_fo_data).
    IF sy-subrc = 0.
      lv_conf_status = ls_fo_data-confirmation.
    ENDIF.

*    IF lv_conf_status <> '04'.
      go_tor_srv_mgr->do_action(
        EXPORTING
          iv_act_key           = /scmtms/if_tor_c=>sc_action-root-set_conf_status_rejected
          it_key               = it_fo_keys
*            is_parameters        =
        IMPORTING
*            eo_change            =
          eo_message           = DATA(lo_act_message)
          et_failed_key        = DATA(lt_failed_key)
*            et_failed_action_key =
*            et_data              =
      ).

      IF lt_failed_key IS NOT INITIAL.
        NEW zcl_awc_fo_overview_helper( )->raise_exception(
          EXPORTING
            io_message = lo_act_message
            is_textid  = zcx_awc_fo_overview=>fo_rejection_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
        ).
      ENDIF.

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
            is_textid  = zcx_awc_fo_overview=>fo_rejection_failed                 " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
        ).
      ENDIF.

*    ELSE.

*    ENDIF.

  ENDMETHOD.
ENDCLASS.
