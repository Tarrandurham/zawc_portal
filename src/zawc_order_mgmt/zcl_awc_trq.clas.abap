class ZCL_AWC_TRQ definition
  public
  final
  create public .

public section.

  methods CREATE_TEMP_TRQ
    importing
      !IS_CREATE type ZSAWC_CREATE_TRQ
    exporting
      !EV_FU_ID type /SCMTMS/TOR_ID
      !EV_FU_KEY type ZAWC_KEY
      !EV_TRQ_KEY type ZAWC_KEY
      !EV_TRQ_ID type /SCMTMS/TRQ_ID
      !EV_CHG_KEY type ZAWC_KEY
      !ET_CHARGES type ZT_AWC_TRQ_CHARGES
    raising
      ZCX_AWC_BOPF .
  methods CREATE_TRQ
    importing
      !IS_CREATE type ZSAWC_CREATE_TRQ
    exporting
      !EV_TRQ_KEY type ZAWC_KEY
      !EV_TRQ_ID type /SCMTMS/TRQ_ID
      !EV_FU_KEY type ZAWC_KEY
      !EV_FU_ID type /SCMTMS/TOR_ID
    raising
      ZCX_AWC_BOPF .
  methods GET_TRQ_DATA
    importing
      !IT_TRQ_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_TRQ_DATA type /SCMTMS/T_TRQ_Q_RESULT .
  methods GET_TRQ_KEYS_FROM_FU
    importing
      !IT_FU_DOCREF type /SCMTMS/T_TOR_DOCREF_K
    exporting
      !ET_FWO_KEYS type /BOBF/T_FRW_KEY .
  methods UPDATE_TRQ
    importing
      !IS_UPDATE type ZSAWC_CREATE_TRQ
    exporting
      !ES_UPDATE type ZSAWC_CREATE_TRQ
    raising
      ZCX_AWC_BOPF .
  methods CANCEL_TRQ
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
    raising
      ZCX_AWC_BOPF .
  methods CONSTRUCTOR .
  methods CONVERT_INTO_TZ
    importing
      !IV_FROM_TZ type TZONREF-TZONE
      !IV_TO_TZ type TZONREF-TZONE
      !IV_FROM_TS type CHAR14
    returning
      value(EV_TO_TS) type CHAR14 .
  PROTECTED SECTION.
private section.

  data MS_TRQ_REL_DATA type ZDAWC_TRQ_REL_DA .

  methods SAVE_TRQ
    raising
      ZCX_AWC_BOPF .
ENDCLASS.



CLASS ZCL_AWC_TRQ IMPLEMENTATION.


  method CANCEL_TRQ.
    DATA: lt_fu_keys TYPE /bobf/t_frw_key.

    DATA(lo_trq_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_trq_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_fu_keys.

    NEW zcl_awc_fu( )->get_docref(
      EXPORTING
        it_fu_key    = lt_fu_keys
      IMPORTING
        et_fu_docref = DATA(lt_fu_docref)
    ).

    get_trq_keys_from_fu(
      EXPORTING
        it_fu_docref = lt_fu_docref
      IMPORTING
        et_fwo_keys  = DATA(lt_fwo_keys)
    ).

    lo_trq_service_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_trq_c=>sc_action-root-cancel
        it_key               = lt_fwo_keys
       IMPORTING
         eo_message           = DATA(lo_message)
    ).

    save_trq( ).
  endmethod.


  METHOD constructor.

    SELECT  * FROM zdawc_trq_rel_da
      INTO TABLE @DATA(lt_trq_rel_data).

    READ TABLE lt_trq_rel_data INTO ms_trq_rel_data INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_trq_rel_data.
    ENDIF.

  ENDMETHOD.


  METHOD convert_into_tz.
    DATA: tstp TYPE timestamp.

    DATA(lv_date) = iv_from_ts+0(8).
    DATA(lv_time) = iv_from_ts+8.

    CONVERT DATE lv_date TIME lv_time INTO TIME STAMP tstp TIME ZONE iv_from_tz.

    CONVERT TIME STAMP tstp TIME ZONE iv_to_tz INTO DATE lv_date TIME lv_time.

    CONCATENATE lv_date lv_time into ev_to_ts.
  ENDMETHOD.


  METHOD create_temp_trq.

    DATA: ls_trq_root     TYPE /scmtms/s_trq_root_k,
          ls_trq_item     TYPE /scmtms/s_trq_item_k,
          lt_trq_root     TYPE /scmtms/t_trq_root_k,
          lt_trq_item     TYPE /scmtms/t_trq_item_k,

          lt_trq_key      TYPE /bobf/t_frw_key,
          lt_trq_data     TYPE /scmtms/t_trq_root_k,
          lt_trq_chg_data TYPE ZT_AWC_TRQ_CHARGES,
          lt_fu_data      TYPE /scmtms/t_tor_root_k,

          lt_mod          TYPE /bobf/t_frw_modification,
          lo_message      TYPE REF TO /bobf/if_frw_message,
          lo_change       TYPE REF TO /bobf/if_tra_change,
          lo_rejected     TYPE boole_d.

    DATA(lo_srv_trq) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_transaction_mgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

    ls_trq_root-key = lo_srv_trq->get_new_key( ).
    ls_trq_root-root_key = ls_trq_root-key.

    ls_trq_root-src_loc_key = is_create-src_loc_key.
    ls_trq_root-pic_ear_req = convert_into_tz(
                                iv_from_tz = is_create-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = CONV #( is_create-pic_ear_req )
                              ).
    ls_trq_root-pic_lat_req = convert_into_tz(
                                iv_from_tz = is_create-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = CONV #( is_create-pic_lat_req )
                              ).

    ls_trq_root-des_loc_key = is_create-des_loc_key.
    ls_trq_root-del_ear_req = convert_into_tz(
                                iv_from_tz = is_create-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = CONV #( is_create-del_ear_req )
                              ).
    ls_trq_root-del_lat_req = convert_into_tz(
                                iv_from_tz = is_create-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = CONV #( is_create-del_lat_req )
                              ).

*    ls_trq_root-transsrvlvl_code = '02'.


    "set other parameters for forwarding order
    ls_trq_root-movem_type = ms_trq_rel_data-movem_type.
    ls_trq_root-trq_cat = ms_trq_rel_data-trq_cat.
    ls_trq_root-trq_type = 'Z101'.
    ls_trq_root-order_date = sy-datum.
    ls_trq_root-traffic_direct = is_create-TRAFFIC_DIRECT.
    ls_trq_root-mot = is_create-mot.

    LOOP AT is_create-trq_item ASSIGNING FIELD-SYMBOL(<ls_trq_item>).
*      "set item parameters for forwarding order
*      ls_trq_item-key = lo_srv_trq->get_new_key( ).
*      ls_trq_item-root_key = ls_trq_root-key.
*      ls_trq_item-parent_key = ls_trq_root-key.
*
*      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
*      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.
*



      IF <ls_trq_item>-Item_Cat EQ 'PKG'.
        "set item parameters for forwarding order
        ls_trq_item-key = lo_srv_trq->get_new_key( ).
        ls_trq_item-root_key = ls_trq_root-key.
        ls_trq_item-parent_key = ls_trq_root-key.

        ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
        ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.
        ls_trq_item-item_parent_key = ls_trq_root-parent_key.
        ls_trq_item-measuom = <ls_trq_item>-measuom.
        ls_trq_item-length = <ls_trq_item>-length.
        ls_trq_item-height = <ls_trq_item>-height.
        ls_trq_item-width = <ls_trq_item>-width.
        ls_trq_item-product_id = ''.
        ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
        ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

        ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
        ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
        ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.

        DATA(lv_prd_id) = <ls_trq_item>-prd_id.
        SHIFT lv_prd_id LEFT DELETING LEADING '0'.

        ls_trq_item-main_cargo_item = abap_true.
        ls_trq_item-item_descr      = lv_prd_id.
        ls_trq_item-item_cat        = ms_trq_rel_data-item_cat.
        ls_trq_item-item_type       = ms_trq_rel_data-item_cat.
        ls_trq_item-package_id      = lv_prd_id.
*      ls_trq_item-package_tco     = 'PAL'.
      ELSE.
        "set item parameters for forwarding order



        ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
        ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.

        ls_trq_item-measuom = <ls_trq_item>-measuom.
        ls_trq_item-length = <ls_trq_item>-length.
        ls_trq_item-height = <ls_trq_item>-height.
        ls_trq_item-width = <ls_trq_item>-width.
        ls_trq_item-product_id = <ls_trq_item>-prd_id.
        ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
        ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

        ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
        ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
        ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.
        lv_prd_id = <ls_trq_item>-prd_id.
        SHIFT lv_prd_id LEFT DELETING LEADING '0'.
        ls_trq_item-item_descr      = <ls_trq_item>-prd_id.


        IF ls_trq_root-root_key EQ <ls_trq_item>-item_parent_key.
          ls_trq_item-main_cargo_item = abap_true.
          ls_trq_item-item_parent_key = ls_trq_root-parent_key.
*is_update-trq_key.

          ls_trq_item-key = lo_srv_trq->get_new_key( ).
          ls_trq_item-root_key = ls_trq_root-key.
          ls_trq_item-parent_key = ls_trq_root-key.

          ls_trq_item-item_cat        = 'PRD'.
          ls_trq_item-item_type       = 'PRD'.
          ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

        ELSE.
          ls_trq_item-main_cargo_item = abap_false.
          IF ls_trq_item-item_cat = 'PKG'.
            ls_trq_item-item_parent_key = ls_trq_item-key.
          ELSE.
            ls_trq_item-item_parent_key = ls_trq_item-item_parent_key.
          ENDIF.
          ls_trq_item-key = lo_srv_trq->get_new_key( ).
          ls_trq_item-root_key = ls_trq_root-key.
          ls_trq_item-parent_key = ls_trq_root-key.

          ls_trq_item-item_cat        = 'PRD'.
          ls_trq_item-item_type       = 'PRD'.
          ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

        ENDIF.
      ENDIF.


      APPEND ls_trq_item TO lt_trq_item.
    ENDLOOP.

    APPEND ls_trq_root TO lt_trq_root.

    /scmtms/cl_mod_helper=>mod_create_multi(
     EXPORTING
       iv_node        = /scmtms/if_trq_c=>sc_node-root
       it_data        = lt_trq_root
     CHANGING
       ct_mod         = lt_mod
   ).





    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_message_root)
    ).
*    CATCH /bobf/cx_frw_contrct_violation.( lt_mod ).

    CLEAR lt_mod.

    /scmtms/cl_mod_helper=>mod_create_multi(
     EXPORTING
       iv_node        = /scmtms/if_trq_c=>sc_node-item
       it_data        = lt_trq_item
       iv_association = /scmtms/if_trq_c=>sc_association-root-item
       iv_source_node = /scmtms/if_trq_c=>sc_node-root
     CHANGING
       ct_mod         = lt_mod
   ).

    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod

      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_message_item)
    ).

    save_trq( ).

*DATA: lr_param_build_fus TYPE REF TO /scmtms/s_trq_a_build_fus.
*CREATE DATA lr_param_build_fus.
* lr_param_build_fus->process = /scmtms/if_fub_const=>sc_fub_process-initial_fu.
* lo_srv_trq->do_action(
*          EXPORTING
*            iv_act_key           = /scmtms/if_trq_c=>sc_action-root-build_fus
*            it_key               = lt_trq_key
*             is_parameters = lr_param_build_fus
*
*           IMPORTING
*             eo_message           = DATA(lo_message6)
*
*             et_failed_key            = DATA(test1)
**             eo_change               =                  " Interface of Change Object
**    eo_message              =                  " Interface of Message Object
**    et_failed_key           =                  " Key Table
**    et_failed_action_key    =                  " Key Table
**    ev_static_action_failed =
**    et_data                 =
**    et_data_link            =
*        ).

*/scmtms/cl_fu_builder_helper=>create_initial_fu_4_trq(
* EXPORTING
* iv_trq_key = <ls_key>-key
* it_trq_stages = lt_trq_stage
* iv_recreate = abap_true
* iv_no_propagation = abap_true
* IMPORTING
* ev_failed = DATA(lf_inital_fu_failed)
* ).


    INSERT VALUE #( key = ls_trq_root-key ) INTO TABLE lt_trq_key.
    lo_srv_trq->do_action(
          EXPORTING
            iv_act_key           = /scmtms/if_trq_c=>sc_action-root-calc_transportation_charges
            it_key               = lt_trq_key

           IMPORTING
             eo_message           = DATA(lo_message3)
             et_data              = lt_trq_chg_data
             et_failed_key            = DATA(test)
*             eo_change               =                  " Interface of Change Object
*    eo_message              =                  " Interface of Message Object
*    et_failed_key           =                  " Key Table
*    et_failed_action_key    =                  " Key Table
*    ev_static_action_failed =
*    et_data                 =
*    et_data_link            =
        ).


    lo_srv_trq->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
*        iv_fill_data            = abap_true
        it_key                  = lt_trq_key
*        iv_before_image         = abap_true
*        iv_invalidate_cache     = abap_true
      IMPORTING
        et_data                 = lt_trq_data
        eo_message              = DATA(lo_message4)
    ).


* lo_srv_trq->retrieve_by_association(
*      EXPORTING
*        iv_node_key             =       /scmtms/if_trq_c=>sc_node-root
*        it_key                  =        lt_trq_key
*        iv_association          =       /scmtms/if_trq_c=>sc_association-root-trq_dtr_root  " Association
*        iv_fill_data            = abap_true                         " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
*      IMPORTING
**    eo_message              =                                    " Interface of Message Object
**    eo_change               =                                    " Interface of Change Object
*         et_data             =  lt_trq_data
**    et_key_link             =                                    " Key Link
**    et_target_key           =                                    " Key Table
**    et_failed_key           =                                    " Key Table
*    ).
**CATCH /bobf/cx_frw_contrct_violation. " Caller violates a BOPF contract



    lo_srv_trq->retrieve_by_association(
      EXPORTING
        iv_node_key             =       /scmtms/if_trq_c=>sc_node-root
        it_key                  =        lt_trq_key
        iv_association          =       /scmtms/if_trq_c=>sc_association-root-transportcharges   " Association
        iv_fill_data            = abap_true                         " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
      IMPORTING
*    eo_message              =                                    " Interface of Message Object
*    eo_change               =                                    " Interface of Change Object
         et_data             =  lt_trq_chg_data
*    et_key_link             =                                    " Key Link
*    et_target_key           =                                    " Key Table
*    et_failed_key           =                                    " Key Table
    ).
*CATCH /bobf/cx_frw_contrct_violation. " Caller violates a BOPF contract






    DATA(lo_fu) = NEW zcl_awc_fu( ).
    lo_fu->get_fu_keys_from_trq(
      EXPORTING
        iv_trq_key = ls_trq_root-key    " NodeID
      IMPORTING
        et_fu_key  = DATA(lt_fu_keys)
    ).

    READ TABLE lt_fu_keys INTO DATA(ls_fu_keys) INDEX 1.




    lo_tor_service_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
      IMPORTING
        eo_message              = DATA(lo_message1)
        et_data                 = lt_fu_data
    ).

    /scmtms/cl_mod_helper=>mod_delete_multi(
      EXPORTING
        iv_node       =   /scmtms/if_trq_c=>sc_node-root  " Node
        it_keys       =    lt_trq_key   " NodeID
*    iv_do_sorting =                  " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
    CHANGING
      ct_mod = lt_mod
        ).
    lo_srv_trq->modify(
          EXPORTING
            it_modification = lt_mod
          IMPORTING
*        eo_change       =
            eo_message      = DATA(lo_message_root2)
        ).
*    CATCH /bobf/cx_frw_contrct_violation.( lt_mod ).

    CLEAR lt_mod.

    save_trq( ).

    READ TABLE lt_fu_data  INTO DATA(ls_fu_data) INDEX 1.
    READ TABLE lt_trq_data INTO DATA(ls_trq_data) WITH KEY root_key = ls_trq_root-key.
    READ TABLE lt_trq_chg_data INTO DATA(ls_trq_temp_data) INDEX 1.

*    INSERT lt_trq_chg_data INTO is_create-trq_charges.

    ev_fu_key   = ls_fu_data-key.
    ev_fu_id    = ls_fu_data-tor_id.
    ev_trq_key  = ls_trq_root-key.
    ev_trq_id   = ls_trq_data-trq_id.
    ev_chg_key  = ls_trq_temp_data-key.
    et_charges  = lt_trq_chg_data.


  ENDMETHOD.


  METHOD create_trq.
    DATA: ls_trq_root TYPE /scmtms/s_trq_root_k,
          ls_trq_item TYPE /scmtms/s_trq_item_k,
          lt_trq_root TYPE /scmtms/t_trq_root_k,
          lt_trq_item TYPE /scmtms/t_trq_item_k,

          lt_trq_key  TYPE /bobf/t_frw_key,
          lt_trq_data TYPE /scmtms/t_trq_root_k,
          lt_fu_data  TYPE /scmtms/t_tor_root_k,

          lt_mod      TYPE /bobf/t_frw_modification,
          lo_message  TYPE REF TO /bobf/if_frw_message,
          lo_change   TYPE REF TO /bobf/if_tra_change,
          lo_rejected TYPE boole_d.

    DATA(lo_srv_trq) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_transaction_mgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

    ls_trq_root-key = lo_srv_trq->get_new_key( ).
    ls_trq_root-root_key = ls_trq_root-key.

    ls_trq_root-src_loc_key = is_create-src_loc_key.
    ls_trq_root-pic_ear_req = convert_into_tz(
                                iv_from_tz = is_create-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_create-pic_ear_req )
                              ).
    ls_trq_root-pic_lat_req = convert_into_tz(
                                iv_from_tz = is_create-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_create-pic_lat_req )
                              ).

    ls_trq_root-des_loc_key = is_create-des_loc_key.
    ls_trq_root-del_ear_req = convert_into_tz(
                                iv_from_tz = is_create-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_create-del_ear_req )
                              ).
    ls_trq_root-del_lat_req = convert_into_tz(
                                iv_from_tz = is_create-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_create-del_lat_req )
                              ).

*    ls_trq_root-transsrvlvl_code = '02'.


    "set other parameters for forwarding order
    ls_trq_root-movem_type = ms_trq_rel_data-movem_type.
    ls_trq_root-trq_cat = ms_trq_rel_data-trq_cat.
    ls_trq_root-trq_type = ms_trq_rel_data-trq_type.
    ls_trq_root-order_date = sy-datum.

    LOOP AT is_create-trq_item ASSIGNING FIELD-SYMBOL(<ls_trq_item>).
*      "set item parameters for forwarding order
*      ls_trq_item-key = lo_srv_trq->get_new_key( ).
*      ls_trq_item-root_key = ls_trq_root-key.
*      ls_trq_item-parent_key = ls_trq_root-key.
*
*      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
*      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.
*
*      ls_trq_item-measuom = <ls_trq_item>-measuom.
*      ls_trq_item-length = <ls_trq_item>-length.
*      ls_trq_item-height = <ls_trq_item>-height.
*      ls_trq_item-width = <ls_trq_item>-width.
*
*      ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
*      ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.
*
*      ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
*      ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
*      ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.
*
*      DATA(lv_prd_id) = <ls_trq_item>-prd_id.
*      SHIFT lv_prd_id LEFT DELETING LEADING '0'.
*
*      ls_trq_item-main_cargo_item = abap_true.
*      ls_trq_item-item_descr      = lv_prd_id.
*      ls_trq_item-item_cat        = ms_trq_rel_data-item_cat.
*      ls_trq_item-item_type       = ms_trq_rel_data-item_cat.
*      ls_trq_item-package_id      = lv_prd_id.
**      ls_trq_item-package_tco     = 'PAL'.


IF <ls_trq_item>-Item_Cat EQ 'PKG'.
      "set item parameters for forwarding order
      ls_trq_item-key = lo_srv_trq->get_new_key( ).
      ls_trq_item-root_key = ls_trq_root-key.
      ls_trq_item-parent_key = ls_trq_root-key.

      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.
      ls_trq_item-item_parent_key = ls_trq_root-parent_key.
      ls_trq_item-measuom = <ls_trq_item>-measuom.
      ls_trq_item-length = <ls_trq_item>-length.
      ls_trq_item-height = <ls_trq_item>-height.
      ls_trq_item-width = <ls_trq_item>-width.
      ls_trq_item-product_id = ''.
      ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
      ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

      ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
      ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
      ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.

      DATA(lv_prd_id) = <ls_trq_item>-prd_id.
      SHIFT lv_prd_id LEFT DELETING LEADING '0'.

      ls_trq_item-main_cargo_item = abap_true.
      ls_trq_item-item_descr      = lv_prd_id.
      ls_trq_item-item_cat        = ms_trq_rel_data-item_cat.
      ls_trq_item-item_type       = ms_trq_rel_data-item_cat.
      ls_trq_item-package_id      = lv_prd_id.
*      ls_trq_item-package_tco     = 'PAL'.
      ELSE.
      "set item parameters for forwarding order



      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.

      ls_trq_item-measuom = <ls_trq_item>-measuom.
      ls_trq_item-length = <ls_trq_item>-length.
      ls_trq_item-height = <ls_trq_item>-height.
      ls_trq_item-width = <ls_trq_item>-width.
      ls_trq_item-product_id = <ls_trq_item>-prd_id.
      ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
      ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

      ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
      ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
      ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.
      lv_prd_id = <ls_trq_item>-prd_id.
      SHIFT lv_prd_id LEFT DELETING LEADING '0'.
      ls_trq_item-item_descr      = <ls_trq_item>-prd_id.


            IF ls_trq_root-root_key EQ <ls_trq_item>-item_parent_key.
            ls_trq_item-main_cargo_item = abap_true.
            ls_trq_item-item_parent_key = ls_trq_root-parent_key.
*is_update-trq_key.

            ls_trq_item-key = lo_srv_trq->get_new_key( ).
            ls_trq_item-root_key = ls_trq_root-key.
            ls_trq_item-parent_key = ls_trq_root-key.

           ls_trq_item-item_cat        = 'PRD'.
            ls_trq_item-item_type       = 'PRD'.
            ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

            ELSE.
             ls_trq_item-main_cargo_item = abap_false.
                  IF ls_trq_item-item_cat = 'PKG'.
                    ls_trq_item-item_parent_key = ls_trq_item-key.
                  ELSE.
                    ls_trq_item-item_parent_key = ls_trq_item-item_parent_key.
                  ENDIF.
            ls_trq_item-key = lo_srv_trq->get_new_key( ).
            ls_trq_item-root_key = ls_trq_root-key.
            ls_trq_item-parent_key = ls_trq_root-key.

            ls_trq_item-item_cat        = 'PRD'.
            ls_trq_item-item_type       = 'PRD'.
            ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

    ENDIF.
ENDIF.


      APPEND ls_trq_item TO lt_trq_item.
    ENDLOOP.

    APPEND ls_trq_root TO lt_trq_root.

    /scmtms/cl_mod_helper=>mod_create_multi(
     EXPORTING
       iv_node        = /scmtms/if_trq_c=>sc_node-root
       it_data        = lt_trq_root
     CHANGING
       ct_mod         = lt_mod
   ).

    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_message_root)
    ).
*    CATCH /bobf/cx_frw_contrct_violation.( lt_mod ).

    CLEAR lt_mod.

    /scmtms/cl_mod_helper=>mod_create_multi(
     EXPORTING
       iv_node        =  /scmtms/if_trq_c=>sc_node-item
       it_data        = lt_trq_item
       iv_association = /scmtms/if_trq_c=>sc_association-root-item
       iv_source_node = /scmtms/if_trq_c=>sc_node-root
     CHANGING
       ct_mod         = lt_mod
   ).

    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
*        eo_change       =
        eo_message      = DATA(lo_message_item)
    ).

    save_trq( ).

    INSERT VALUE #( key = ls_trq_root-key ) INTO TABLE lt_trq_key.

    lo_srv_trq->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
        it_key                  = lt_trq_key
      IMPORTING
        et_data                 = lt_trq_data
    ).

    DATA(lo_fu) = NEW zcl_awc_fu( ).
    lo_fu->get_fu_keys_from_trq(
      EXPORTING
        iv_trq_key = ls_trq_root-key    " NodeID
      IMPORTING
        et_fu_key  = DATA(lt_fu_keys)
    ).

    READ TABLE lt_fu_keys INTO DATA(ls_fu_keys) INDEX 1.

    "CREATE ATTACHMENT FOLDER
    NEW zcl_awc_attachment( )->add_attachment_to_fu(
      EXPORTING
        iv_root_key = ls_fu_keys-key
    ).

    DATA(lo_attachment) = NEW zcl_awc_attachment( ).

    lo_attachment->add_notes(
      EXPORTING
        iv_reference_nr      = is_create-reference_nr
        iv_shipping_noti_nr  = is_create-shipping_noti_nr
        iv_shipping_noti_doc = is_create-shipping_noti_doc
        iv_add_note          = is_create-add_note
        iv_fu_root_key       = ls_fu_keys-key
    ).

    lo_tor_service_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
      IMPORTING
        eo_message              = DATA(lo_message1)
        et_data                 = lt_fu_data
    ).

    READ TABLE lt_fu_data  INTO DATA(ls_fu_data) INDEX 1.
    READ TABLE lt_trq_data INTO DATA(ls_trq_data) WITH KEY root_key = ls_trq_root-key.

    ev_fu_key   = ls_fu_data-key.
    ev_fu_id    = ls_fu_data-tor_id.
    ev_trq_key  = ls_trq_root-key.
    ev_trq_id   = ls_trq_data-trq_id.
  ENDMETHOD.


  METHOD get_trq_data.
    DATA(lo_trq_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_trq_c=>sc_bo_key ).

    lo_trq_service_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_trq_c=>sc_query-root-qdb_query_by_attributes
        it_filter_key           = it_trq_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = et_trq_data
        et_key                  = DATA(lt_key)
    ).
  ENDMETHOD.


  METHOD get_trq_keys_from_fu.

    LOOP AT it_fu_docref ASSIGNING FIELD-SYMBOL(<ls_fu_docref>).
      IF NOT line_exists( et_fwo_keys[ key = <ls_fu_docref>-orig_ref_root ] ).
        INSERT VALUE #( key = <ls_fu_docref>-orig_ref_root ) INTO TABLE et_fwo_keys.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  method SAVE_TRQ.
    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
          EXPORTING
            iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
          IMPORTING
            ev_rejected            = DATA(lo_rejected)
            eo_change              = DATA(lo_change)
            eo_message             = DATA(lo_message)
        ).

    new zcl_AWC_general( )->check_bopf_messages( lo_message ).
  endmethod.


  METHOD update_trq.
    DATA: lt_fwo_keys      TYPE /bobf/t_frw_key,
          lt_fwo_item_keys TYPE /bobf/t_frw_key,
          lt_fwo_data      TYPE /scmtms/t_trq_root_k,
          lt_fwo_items     TYPE /scmtms/t_trq_item_k,
          ls_trq_item      TYPE /scmtms/s_trq_item_k,
          lt_trq_item      TYPE /scmtms/t_trq_item_k,
          lt_mod           TYPE /bobf/t_frw_modification.

    DATA(lo_srv_trq) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).

    INSERT VALUE #( key = is_update-trq_key ) INTO TABLE lt_fwo_keys.

    lo_srv_trq->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
        it_key                  = lt_fwo_keys
      IMPORTING
        et_data                 = lt_fwo_data
    ).

    READ TABLE lt_fwo_data INTO DATA(ls_fwo_data) WITH KEY root_key = is_update-trq_key.
    ls_fwo_data-pic_ear_req = convert_into_tz(
                                iv_from_tz = is_update-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_update-pic_ear_req )
                              ).
    ls_fwo_data-pic_lat_req = convert_into_tz(
                                iv_from_tz = is_update-src_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_update-pic_lat_req )
                              ).

    ls_fwo_data-del_ear_req = convert_into_tz(
                                iv_from_tz = is_update-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_update-del_ear_req )
                              ).
    ls_fwo_data-del_lat_req = convert_into_tz(
                                iv_from_tz = is_update-des_time_zone_code
                                iv_to_tz   = 'UTC'
                                iv_from_ts = conv #( is_update-del_lat_req )
                              ).

*    ls_fwo_data-src_loc_key = is_update-src_loc_key.
*    ls_fwo_data-des_loc_key = is_update-des_loc_key.

    /scmtms/cl_mod_helper=>mod_update_single(
      EXPORTING
        iv_node            = /scmtms/if_trq_c=>sc_node-root
        is_data            = ls_fwo_data
        iv_autofill_fields = abap_false
      CHANGING
        ct_mod             = lt_mod
    ).

    lo_srv_trq->modify( lt_mod ).
    CLEAR lt_mod.

    lo_srv_trq->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
        it_key                  = lt_fwo_keys
        iv_association          = /scmtms/if_trq_c=>sc_association-root-item
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fwo_items
        eo_message              = DATA(lo_mssg)
    ).

    LOOP AT is_update-trq_item ASSIGNING FIELD-SYMBOL(<ls_trq_item>).
      IF <ls_trq_item>-Item_Cat EQ 'PKG'.
      "set item parameters for forwarding order
      ls_trq_item-key = lo_srv_trq->get_new_key( ).
      ls_trq_item-root_key = ls_fwo_data-key.
      ls_trq_item-parent_key = ls_fwo_data-key.

      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.
      ls_trq_item-item_parent_key = ls_fwo_data-parent_key.
      ls_trq_item-measuom = <ls_trq_item>-measuom.
      ls_trq_item-length = <ls_trq_item>-length.
      ls_trq_item-height = <ls_trq_item>-height.
      ls_trq_item-width = <ls_trq_item>-width.
      ls_trq_item-product_id = ''.
      ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
      ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

      ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
      ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
      ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.

      DATA(lv_prd_id) = <ls_trq_item>-prd_id.
      SHIFT lv_prd_id LEFT DELETING LEADING '0'.

      ls_trq_item-main_cargo_item = abap_true.
      ls_trq_item-item_descr      = lv_prd_id.
      ls_trq_item-item_cat        = ms_trq_rel_data-item_cat.
      ls_trq_item-item_type       = ms_trq_rel_data-item_cat.
      ls_trq_item-package_id      = lv_prd_id.
*      ls_trq_item-package_tco     = 'PAL'.
      ELSE.
      "set item parameters for forwarding order



      ls_trq_item-qua_pcs_val = <ls_trq_item>-qua_pcs_val.
      ls_trq_item-qua_pcs_uni = <ls_trq_item>-qua_pcs_uni.

      ls_trq_item-measuom = <ls_trq_item>-measuom.
      ls_trq_item-length = <ls_trq_item>-length.
      ls_trq_item-height = <ls_trq_item>-height.
      ls_trq_item-width = <ls_trq_item>-width.
      ls_trq_item-product_id = <ls_trq_item>-prd_id.
      ls_trq_item-gro_wei_val = <ls_trq_item>-gro_wei_val * <ls_trq_item>-qua_pcs_val.
      ls_trq_item-gro_wei_uni = <ls_trq_item>-gro_wei_uni.

      ls_trq_item-gro_vol_val = <ls_trq_item>-gro_vol_val.
      ls_trq_item-gro_vol_uni = <ls_trq_item>-gro_vol_uni.
      ls_trq_item-zz_stackability = <ls_trq_item>-maxstack.
      lv_prd_id = <ls_trq_item>-prd_id.
      SHIFT lv_prd_id LEFT DELETING LEADING '0'.
      ls_trq_item-item_descr      = <ls_trq_item>-prd_id.


            IF is_update-trq_key EQ <ls_trq_item>-item_parent_key.
            ls_trq_item-main_cargo_item = abap_true.
            ls_trq_item-item_parent_key = ls_fwo_data-parent_key.
*is_update-trq_key.

            ls_trq_item-key = lo_srv_trq->get_new_key( ).
            ls_trq_item-root_key = ls_fwo_data-key.
            ls_trq_item-parent_key = ls_fwo_data-key.

           ls_trq_item-item_cat        = 'PRD'.
            ls_trq_item-item_type       = 'PRD'.
            ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

            ELSE.
             ls_trq_item-main_cargo_item = abap_false.
                  IF ls_trq_item-item_cat = 'PKG'.
                    ls_trq_item-item_parent_key = ls_trq_item-key.
                  ELSE.
                    ls_trq_item-item_parent_key = ls_trq_item-item_parent_key.
                  ENDIF.
            ls_trq_item-key = lo_srv_trq->get_new_key( ).
            ls_trq_item-root_key = ls_fwo_data-key.
            ls_trq_item-parent_key = ls_fwo_data-key.

            ls_trq_item-item_cat        = 'PRD'.
            ls_trq_item-item_type       = 'PRD'.
            ls_trq_item-package_id      = ''.
*            ls_trq_item-package_tco     = 'PAL'.

            ENDIF.
      ENDIF.



      APPEND ls_trq_item TO lt_trq_item.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_create_multi(
     EXPORTING
       iv_node        =  /scmtms/if_trq_c=>sc_node-item
       it_data        = lt_trq_item
       iv_association = /scmtms/if_trq_c=>sc_association-root-item
       iv_source_node = /scmtms/if_trq_c=>sc_node-root
     CHANGING
       ct_mod         = lt_mod
    ).

    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_message      = DATA(lo_msage)
    ).
    CLEAR lt_mod.

    LOOP AT lt_fwo_items ASSIGNING FIELD-SYMBOL(<ls_fwo_items>).
      INSERT VALUE #( key = <ls_fwo_items>-key ) INTO TABLE lt_fwo_item_keys.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_delete_multi(
      EXPORTING
        iv_node       = /scmtms/if_trq_c=>sc_node-item
        it_keys       = lt_fwo_item_keys
      CHANGING
        ct_mod        = lt_mod
    ).

    lo_srv_trq->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_message      = DATA(lo_msg)
    ).

    NEW zcl_awc_fu( )->set_add_address( is_update = is_update ).

    save_trq( ).

    NEW zcl_awc_fu( )->update_text_from_fu(
      EXPORTING
        iv_fu_key            = CONV #( is_update-fu_key )   " NodeID
        iv_reference_nr      = is_update-reference_nr    " Textinhalt
        iv_shipping_noti_nr  = is_update-shipping_noti_nr    " Textinhalt
        iv_shipping_noti_doc = is_update-shipping_noti_doc    " Textinhalt
        iv_add_note          = is_update-add_note
    ).
  ENDMETHOD.
ENDCLASS.
