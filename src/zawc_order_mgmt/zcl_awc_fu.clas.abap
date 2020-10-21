class ZCL_AWC_FU definition
  public
  final
  create public .

public section.

  methods CREATE_DLVP
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    raising
      ZCX_AWC_BOPF .
  methods QUERY_FUS
    importing
      !IT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM
    exporting
      !ET_FU_KEYS type /BOBF/T_FRW_KEY
      !ET_FU_DATA type /SCMTMS/T_TOR_Q_FU_R .
  methods CANCEL_FU
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
    raising
      ZCX_AWC_BOPF .
  methods GET_ITEMS_BY_FU
    importing
      !IT_FU_KEYS type /BOBF/T_FRW_KEY
    exporting
      !ET_ITEMS type ZT_AWC_TRQ_ITEM .
  methods GET_SUMMARY
    importing
      !IT_FU_KEYS type /BOBF/T_FRW_KEY
    exporting
      !ET_FU_SUMMARY type /SCMTMS/T_TOR_ROOT_TRANSIENT_K .
  methods UPDATE_FU
    importing
      !IS_UPDATE type ZSAWC_CREATE_TRQ
    raising
      ZCX_AWC_BOPF .
  methods GET_FU_KEYS_FROM_TRQ
    importing
      !IV_TRQ_KEY type /BOBF/CONF_KEY
    exporting
      !ET_FU_KEY type /BOBF/T_FRW_KEY .
  methods GET_FUS
    importing
      !IT_ORDERBY type /IWBEP/T_MGW_TECH_ORDER optional
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION optional
      !IV_SKIP type INT4 optional
      !IV_TOP type INT4 optional
    exporting
      !ET_FU type ZT_AWC_FU .
  methods GET_FU_DATA
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_FU_DATA type /SCMTMS/T_TOR_Q_FU_R .
  methods GET_DOCREF
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_FU_DOCREF type /SCMTMS/T_TOR_DOCREF_K .
  methods GET_TEXT_FROM_FU
    importing
      !IT_TOR_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_TEXT_CONTENT type ZT_AWC_NOTE_CONTENT .
  methods RELEASE_FUS
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    raising
      ZCX_AWC_BOPF .
  methods GET_FU
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
    exporting
      !ES_TRQ_HEAD type ZSAWC_TRQ_HEAD .
  methods UPDATE_TEXT_FROM_FU
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
      !IV_REFERENCE_NR type /BOBF/TEXT_CONTENT
      !IV_SHIPPING_NOTI_NR type /BOBF/TEXT_CONTENT
      !IV_SHIPPING_NOTI_DOC type /BOBF/TEXT_CONTENT
      !IV_ADD_NOTE type /BOBF/TEXT_CONTENT .
  methods SET_ADD_ADDRESS
    importing
      !IS_UPDATE type ZSAWC_CREATE_TRQ .
  methods CONSTRUCTOR .
  methods GET_SELPAR_FROM_FILTER
    importing
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
    returning
      value(RT_SELPAR) type /BOBF/T_FRW_QUERY_SELPARAM .
  PROTECTED SECTION.
private section.

  data MS_ADD_INFO type ZDAWC_ADD_INFO .
  data MS_TRQ_REL_DATA type ZDAWC_TRQ_REL_DA .
  data MS_OTH_REL_DATA type ZDAWC_OTH_REL_DA .

  methods GET_FUS_HELP
    importing
      !IT_FU_DATA_CDS type /SCMTMS/T_TOR_Q_FU_R
      !IT_FU_KEYS type /BOBF/T_FRW_KEY
    exporting
      !ET_FU type ZT_AWC_FU .
  methods GET_OPEN_FUS
    importing
      !IT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM
      !IT_BP_REL type /BOFU/T_BUPA_RELSHIP_K
    returning
      value(RT_FU_DATA) type /SCMTMS/T_TOR_Q_FU_R .
  methods GET_CLOSED_FUS
    importing
      !IT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM
      !IT_BP_REL type /BOFU/T_BUPA_RELSHIP_K
    returning
      value(RT_FU_DATA) type /SCMTMS/T_TOR_Q_FU_R .
  methods GET_FORCAST_FUS
    importing
      !IT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM
      !IT_BP_REL type /BOFU/T_BUPA_RELSHIP_K
    returning
      value(RT_FU_DATA) type /SCMTMS/T_TOR_Q_FU_R .
  methods GET_ALL_FUS
    importing
      !IT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM
      !IT_BP_REL type /BOFU/T_BUPA_RELSHIP_K
    returning
      value(RT_FU_DATA) type /SCMTMS/T_TOR_Q_FU_R .
  methods ORDER_FUS
    importing
      !IT_ORDERBY type /IWBEP/T_MGW_TECH_ORDER
    changing
      !CT_FU_DATA type /SCMTMS/T_TOR_Q_FU_R .
  methods GET_BP_REL
    returning
      value(RT_BP_REL) type /BOFU/T_BUPA_RELSHIP_K .
  methods PREPARE_SELPAR_FOR_300
    changing
      !CT_SELPAR type /BOBF/T_FRW_QUERY_SELPARAM .
ENDCLASS.



CLASS ZCL_AWC_FU IMPLEMENTATION.


  METHOD cancel_fu.
    DATA: lt_fu_keys TYPE /bobf/t_frw_key.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_fu_keys.

    lo_tor_service_mgr->do_action(
      EXPORTING
        iv_act_key           = /scmtms/if_tor_c=>sc_action-root-cancel
        it_key               = lt_fu_keys
       IMPORTING
         eo_message           = DATA(lo_message)
    ).

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
         EXPORTING
           iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
         IMPORTING
           eo_message             = lo_message
       ).

    NEW zcl_awc_general( )->check_bopf_messages( lo_message ).
  ENDMETHOD.


  METHOD constructor.

    SELECT  * FROM zdawc_add_info
      INTO TABLE @DATA(lt_add_info).

    READ TABLE lt_add_info INTO ms_add_info INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_add_info.
    ENDIF.

    SELECT  * FROM zdawc_trq_rel_da
      INTO TABLE @DATA(lt_trq_rel_data).

    READ TABLE lt_trq_rel_data INTO ms_trq_rel_data INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_trq_rel_data.
    ENDIF.

    SELECT  * FROM zdawc_oth_rel_da
      INTO TABLE @DATA(lt_oth_rel_data).

    READ TABLE lt_oth_rel_data INTO ms_oth_rel_data INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_oth_rel_data.
    ENDIF.

  ENDMETHOD.


  METHOD create_dlvp.
      DATA: lt_block_keys TYPE /bobf/t_frw_key.



      DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-block
      IMPORTING
        et_key_link             = DATA(lt_fu_block_keys)
    ).

    LOOP AT lt_fu_block_keys ASSIGNING FIELD-SYMBOL(<ls_fu_block_keys>).
      CLEAR lt_block_keys.
      INSERT VALUE #( key = <ls_fu_block_keys>-target_key ) into table lt_block_keys.


       lo_tor_service_mgr->do_action(
        EXPORTING
          iv_act_key           = /scmtms/if_tor_c=>sc_action-root-create_and_send_dlvp
          it_key               = lt_block_keys
        IMPORTING
          eo_message           = DATA(lo_message)
      ).



      /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
            EXPORTING
              iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
            IMPORTING
              eo_message             = lo_message
          ).

      NEW zcl_awc_general( )->check_bopf_messages( lo_message ).

  ENDLOOP.


  ENDMETHOD.


  method GET_ALL_FUS.

    APPEND LINES OF get_open_fus(
                      it_selpar = it_selpar
                      it_bp_rel = it_bp_rel
                    ) TO rt_fu_data.

    APPEND LINES OF get_closed_fus(
                      it_selpar = it_selpar
                      it_bp_rel = it_bp_rel
                    ) TO rt_fu_data.

    APPEND LINES OF get_forcast_fus(
                      it_selpar = it_selpar
                      it_bp_rel = it_bp_rel
                    ) TO rt_fu_data.
  endmethod.


  METHOD get_bp_rel.

    DATA: lt_selpar  TYPE /bobf/t_frw_query_selparam,
          lt_bp      TYPE /scmtms/t_bupa_q_uname_result,
          lt_bp_data TYPE /bofu/t_bupa_root_k,
          lt_bp_rel  TYPE /bofu/t_bupa_relship_k.

    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).
    DATA(lo_srv_bp)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_bp_c=>sc_bo_key ).

    "get the business partner from SAP user
    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = sy-uname
                    attribute_name  = 'UNAME'
                    ) INTO TABLE lt_selpar.

    lo_srv_bp->query(
      EXPORTING
        iv_query_key            = /scmtms/if_bp_c=>sc_query-root-query_by_uname
        it_selection_parameters = lt_selpar
      IMPORTING
        et_data                 = lt_bp
        et_key                  = DATA(lt_key)
    ).

    lo_srv_bp->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-root
        it_key                  = lt_key
        iv_association          = /bofu/if_bupa_constants=>sc_association-root-relationship
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_bp_rel
    ).

    CLEAR lt_selpar.

    LOOP AT lt_bp_rel ASSIGNING FIELD-SYMBOL(<ls_bp_rel>).
      IF <ls_bp_rel>-relationshipcategory EQ ms_oth_rel_data-bp_realship.
                INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = <ls_bp_rel>-relshp_partner
                        attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_business_partne-business_partner_id
                    ) INTO TABLE lt_selpar.
        INSERT <ls_bp_rel> INTO TABLE rt_bp_rel.
      ENDIF.
    ENDLOOP.

    lo_srv_loc->query(
        EXPORTING
          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_business_partne
          it_selection_parameters = lt_selpar
        IMPORTING
          et_key                  = DATA(lt_loc_key)
      ).

    IF lt_loc_key IS INITIAL.
      CLEAR rt_bp_rel.
    ENDIF.

  ENDMETHOD.


  METHOD get_closed_fus.

    DATA: lt_selpar             TYPE /bobf/t_frw_query_selparam,
          lv_date_before_pickup TYPE sy-datum,
          lv_date_after_pickup  TYPE sy-datum.

    DATA: lv_time TYPE t VALUE '120000'.

    IF it_bp_rel IS INITIAL.

      RETURN.

    ENDIF.

    lt_selpar = it_selpar.

    LOOP AT it_bp_rel ASSIGNING FIELD-SYMBOL(<ls_bp_rel>).
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <ls_bp_rel>-relshp_partner
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid
                    ) INTO TABLE lt_selpar.
    ENDLOOP.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = 'ZFU4'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type
                    ) INTO TABLE lt_selpar.

    lv_date_before_pickup  = sy-datum + ms_oth_rel_data-period_before_pickup.
    lv_date_after_pickup   = sy-datum - ms_oth_rel_data-period_after_pickup.

    READ TABLE it_selpar INTO DATA(ls_selpar) WITH KEY attribute_name = 'ZZ_PICK_UP_DATE'.

    IF sy-subrc = 0.

      IF ls_selpar-option = 'EQ'.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-low LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'EQ'
                            low             = ls_selpar-low
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ELSE.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-high LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'BT'
                            low             = ls_selpar-low
                            high            = ls_selpar-high
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ENDIF.


    ELSE.

      INSERT VALUE #(   sign            = 'I'
                        option          = 'BT'
                        low             = lv_date_after_pickup
                        high            = lv_date_before_pickup
                        attribute_name  = 'ZZ_PICK_UP_DATE'
                      ) INTO TABLE lt_selpar.

    ENDIF.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '01'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '02'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_false
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-blk_plan
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_false
                      attribute_name  = 'ZZ_BLK_EXEC'
                    ) INTO TABLE lt_selpar.

    IF sy-mandt EQ 300.
      prepare_selpar_for_300(
        CHANGING
          ct_selpar = lt_selpar
      ).
    ENDIF.

    query_fus(
      EXPORTING
        it_selpar  = lt_selpar
      IMPORTING
        et_fu_keys = DATA(lt_zfu4_fus_key)
        et_fu_data = DATA(lt_zfu4_fus_data)
    ).

    DELETE lt_selpar WHERE attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid.
    DELETE lt_selpar WHERE attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type.

    LOOP AT it_bp_rel ASSIGNING <ls_bp_rel>.
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <ls_bp_rel>-relshp_partner
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-consigneeid
                    ) INTO TABLE lt_selpar.
    ENDLOOP.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = 'ZFU5'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type
                    ) INTO TABLE lt_selpar.

    query_fus(
      EXPORTING
        it_selpar  = lt_selpar
      IMPORTING
        et_fu_keys = DATA(lt_zfu5_fus_key)
        et_fu_data = DATA(lt_zfu5_fus_data)
    ).

    APPEND LINES OF lt_zfu4_fus_data TO rt_fu_data.
    APPEND LINES OF lt_zfu5_fus_data TO rt_fu_data.

  ENDMETHOD.


  METHOD get_docref.
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-docreference
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = et_fu_docref
        et_key_link             = DATA(lt_docref_key_link)
        et_target_key           = DATA(lt_target_key)
    ).
  ENDMETHOD.


  METHOD get_forcast_fus.

    DATA: lt_selpar             TYPE /bobf/t_frw_query_selparam,
          lv_date_before_pickup TYPE sy-datum,
          lv_date_after_pickup  TYPE sy-datum.

    DATA: lv_time TYPE t VALUE '120000'.

    IF it_bp_rel IS INITIAL.

      RETURN.

    ENDIF.

    lt_selpar = it_selpar.

    READ TABLE it_selpar INTO DATA(ls_selpar) WITH KEY attribute_name = 'ZZ_TRQ_CAT'.
    IF sy-subrc = 0.
      IF ls_selpar-low = '03'.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT it_bp_rel ASSIGNING FIELD-SYMBOL(<ls_bp_rel>).
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <ls_bp_rel>-relshp_partner
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid
                    ) INTO TABLE lt_selpar.
    ENDLOOP.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = 'ZFU4'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type
                    ) INTO TABLE lt_selpar.

    lv_date_before_pickup  = sy-datum + ms_oth_rel_data-period_before_pickup.
    lv_date_after_pickup   = sy-datum - ms_oth_rel_data-period_after_pickup.

    READ TABLE it_selpar INTO ls_selpar WITH KEY attribute_name = 'ZZ_PICK_UP_DATE'.

    IF sy-subrc = 0.

      IF ls_selpar-option = 'EQ'.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-low LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'EQ'
                            low             = ls_selpar-low
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ELSE.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-high LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'BT'
                            low             = ls_selpar-low
                            high            = ls_selpar-high
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ENDIF.


    ELSE.

      INSERT VALUE #(   sign            = 'I'
                        option          = 'BT'
                        low             = lv_date_after_pickup
                        high            = lv_date_before_pickup
                        attribute_name  = 'ZZ_PICK_UP_DATE'
                      ) INTO TABLE lt_selpar.

    ENDIF.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '01'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '02'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_true
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-blk_plan
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '01'
                      attribute_name  = 'ZZ_TRQ_CAT'
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'GT'
                      low             = sy-datum
                      attribute_name  = 'ZZ_EARLIERST_DUE_DATE'
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_false
                      attribute_name  = 'ZZ_BLK_EXEC'
                    ) INTO TABLE lt_selpar.

    IF sy-mandt EQ 300.
      prepare_selpar_for_300(
        CHANGING
          ct_selpar = lt_selpar
      ).
    ENDIF.

    query_fus(
      EXPORTING
        it_selpar  = lt_selpar
      IMPORTING
        et_fu_keys = DATA(lt_auto_fus_key)
        et_fu_data = rt_fu_data
    ).

  ENDMETHOD.


  METHOD get_fu.
    DATA: lt_fu_keys     TYPE /bobf/t_frw_key,
          lt_loc_key     TYPE /bobf/t_frw_key,
          lt_fu_stops    TYPE /scmtms/t_tor_stop_k,
          ls_trq_head    TYPE zsawc_trq_head,
          lv_counter     TYPE i VALUE 0.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_trq) = NEW zcl_awc_trq( ).

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_fu_keys.

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-stop
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fu_stops
        eo_message              = DATA(lo_mssg)
    ).

    get_fu_data(
      EXPORTING
        it_fu_key  = lt_fu_keys
      IMPORTING
        et_fu_data = DATA(lt_fu_data)
    ).

    get_docref(
      EXPORTING
        it_fu_key    = lt_fu_keys
      IMPORTING
        et_fu_docref = DATA(lt_fu_docref)
    ).

    get_text_from_fu(
      EXPORTING
        it_tor_key = lt_fu_keys
      IMPORTING
        et_text_content = DATA(lt_text_content)
    ).

    READ TABLE lt_fu_data INTO DATA(ls_fu_data) WITH KEY db_key = iv_fu_key.
    READ TABLE lt_text_content INTO DATA(ls_ref_nr) WITH KEY txt_type = ms_add_info-reference_nr.
    READ TABLE lt_text_content INTO DATA(ls_ship_nr) WITH KEY txt_type = ms_add_info-shipping_noti_nr.
    READ TABLE lt_text_content INTO DATA(ls_ship_doc) WITH KEY txt_type = ms_add_info-shipping_noti_doc.
    READ TABLE lt_text_content INTO DATA(ls_add_note) WITH KEY txt_type = ms_add_info-add_note.

    ls_trq_head-fu_key            = ls_fu_data-db_key.
    ls_trq_head-fu_id             = ls_fu_data-tor_id.
*    ls_trq_head-pic_ear_req       = ls_fu_data-first_stop_req_start.
*    ls_trq_head-pic_lat_req       = ls_fu_data-first_stop_req_end.
*    ls_trq_head-del_ear_req       = ls_fu_data-last_stop_req_start.
*    ls_trq_head-del_lat_req       = ls_fu_data-last_stop_req_end.
    ls_trq_head-reference_nr      = ls_ref_nr-text.
    ls_trq_head-shipping_noti_nr  = ls_ship_nr-text.
    ls_trq_head-shipping_noti_doc = ls_ship_doc-text.
    ls_trq_head-add_note          = ls_add_note-text.

    LOOP AT lt_fu_docref TRANSPORTING NO FIELDS WHERE root_key = iv_fu_key.
      ADD 1 TO lv_counter.
    ENDLOOP.

    READ TABLE lt_fu_docref INTO DATA(ls_fu_docref_for_one_fu) WITH KEY root_key = iv_fu_key btd_tco = ms_trq_rel_data-btd_tco_fwo.
    IF sy-subrc = 0.
      ls_trq_head-trq_key       = ls_fu_docref_for_one_fu-orig_ref_root.

      IF lv_counter EQ 1.
        ls_trq_head-btd_tco       = ls_fu_docref_for_one_fu-btd_tco.
      ENDIF.
    ENDIF.

    ls_trq_head-earliest_due_date = ls_fu_data-zz_earlierst_due_date.
    IF ls_trq_head-btd_tco <> ms_trq_rel_data-btd_tco_fwo.

      IF ls_fu_data-blk_plan EQ abap_true AND ( ls_fu_data-lifecycle = '01' OR ls_fu_data-lifecycle = '02' ) AND ls_fu_data-zz_earlierst_due_date <= sy-datum.
        ls_trq_head-status = 'O'.
      ELSEIF ls_fu_data-blk_plan EQ abap_false AND ( ls_fu_data-lifecycle = '01' OR ls_fu_data-lifecycle = '02' ).
        ls_trq_head-status = 'C'.
      ELSEIF ls_fu_data-blk_plan EQ abap_true AND ( ls_fu_data-lifecycle = '01' OR ls_fu_data-lifecycle = '02' ) AND ls_fu_data-zz_earlierst_due_date >= sy-datum.
        ls_trq_head-status = 'F'.
      ENDIF.

    ELSE.

      IF ls_fu_data-blk_plan EQ abap_false AND ( ls_fu_data-lifecycle = '01' OR ls_fu_data-lifecycle = '02' ).
        ls_trq_head-status = 'C'.
      ELSEIF ls_fu_data-blk_plan EQ abap_true AND ( ls_fu_data-lifecycle = '01' OR ls_fu_data-lifecycle = '02' ).
        ls_trq_head-status = 'O'.
      ENDIF.

    ENDIF.

    DATA(lo_loc) = NEW zcl_awc_location( ).

    READ TABLE lt_fu_stops INTO DATA(ls_fu_stop) WITH KEY stop_id = '0000000010'.

    lt_loc_key = VALUE #( ( key = ls_fu_data-first_stop_log_loc_uuid )
                          ( key = ls_fu_data-last_stop_log_loc_uuid )
                        ).

    READ TABLE lt_fu_stops ASSIGNING FIELD-SYMBOL(<ls_fu_stop>) WITH KEY root_key = ls_fu_data-db_key stop_id = '0000000010'.
    IF sy-subrc = 0.
      IF <ls_fu_stop>-adr_loc_uuid NE '00000000000000000000000000000000'.
        INSERT VALUE #( key = ls_fu_stop-adr_loc_uuid ) INTO TABLE lt_loc_key.
        DATA(lv_src_loc_uuid) = <ls_fu_stop>-adr_loc_uuid.
      ELSE.
        lv_src_loc_uuid = ls_fu_data-first_stop_log_loc_uuid.
      ENDIF.
    ENDIF.

    READ TABLE lt_fu_stops ASSIGNING <ls_fu_stop> WITH KEY root_key = ls_fu_data-db_key stop_id = '0000000020'.
    IF sy-subrc = 0.
      IF <ls_fu_stop>-adr_loc_uuid NE '00000000000000000000000000000000'.
        INSERT VALUE #( key = ls_fu_stop-adr_loc_uuid ) INTO TABLE lt_loc_key.
        DATA(lv_des_loc_uuid) = <ls_fu_stop>-adr_loc_uuid.
      ELSE.
        lv_des_loc_uuid = ls_fu_data-last_stop_log_loc_uuid.
      ENDIF.
    ENDIF.

    lo_loc->get_loc_data(
      EXPORTING
        it_loc_key  = lt_loc_key
      IMPORTING
        et_loc_data = DATA(lt_loc_data)
    ).

    lo_loc->get_adress_info(
      EXPORTING
        it_loc_key             = lt_loc_key
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
     ).

    "Data for source location
    READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_src_loc_data>) WITH KEY key = lv_src_loc_uuid.
    IF sy-subrc = 0.
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_src_key_link>) WITH KEY source_key = <ls_src_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_src_loc_adress>) WITH KEY key = <ls_src_key_link>-target_key.
          IF sy-subrc = 0.
            ls_trq_head-src_loc_key                  = <ls_src_loc_data>-key.
            ls_trq_head-src_location_id              = <ls_src_loc_data>-location_id.
            ls_trq_head-src_name1                    = <ls_src_loc_adress>-name1.
            ls_trq_head-src_country_code             = <ls_src_loc_adress>-country_code.
            ls_trq_head-src_region                   = <ls_src_loc_adress>-region.
            ls_trq_head-src_city_name                = <ls_src_loc_adress>-city_name.
            ls_trq_head-src_street_postal_code       = <ls_src_loc_adress>-street_postal_code.
            ls_trq_head-src_street_name              = <ls_src_loc_adress>-street_name.
            ls_trq_head-src_house_id                 = <ls_src_loc_adress>-house_id.
            ls_trq_head-src_time_zone_code           = <ls_src_loc_data>-time_zone_code.

            ls_trq_head-pic_ear_req                  = zcl_awc_general=>convert_into_tz(
                                                          iv_from_tz = 'UTC'
                                                          iv_to_tz   = <ls_src_loc_data>-time_zone_code
                                                          iv_from_ts = CONV #( ls_fu_data-first_stop_req_start )
                                                        ).
            ls_trq_head-pic_lat_req                  = zcl_awc_general=>convert_into_tz(
                                                          iv_from_tz = 'UTC'
                                                          iv_to_tz   = <ls_src_loc_data>-time_zone_code
                                                          iv_from_ts = CONV #( ls_fu_data-first_stop_req_end )
                                                        ).

          ENDIF.
      ENDIF.
    ENDIF.

    "Data for destination location
    READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_des_loc_data>) WITH KEY key = lv_des_loc_uuid.
    IF sy-subrc = 0.
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_des_key_link>) WITH KEY source_key = <ls_des_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_des_loc_adress>) WITH KEY key = <ls_des_key_link>-target_key.
          IF sy-subrc = 0.
            ls_trq_head-des_loc_key                  = <ls_des_loc_data>-key.
            ls_trq_head-des_location_id              = <ls_des_loc_data>-location_id.
            ls_trq_head-des_name1                    = <ls_des_loc_adress>-name1.
            ls_trq_head-des_country_code             = <ls_des_loc_adress>-country_code.
            ls_trq_head-des_region                   = <ls_des_loc_adress>-region.
            ls_trq_head-des_city_name                = <ls_des_loc_adress>-city_name.
            ls_trq_head-des_street_postal_code       = <ls_des_loc_adress>-street_postal_code.
            ls_trq_head-des_street_name              = <ls_des_loc_adress>-street_name.
            ls_trq_head-des_house_id                 = <ls_des_loc_adress>-house_id.
            ls_trq_head-des_time_zone_code           = <ls_des_loc_data>-time_zone_code.


            ls_trq_head-del_ear_req                  = zcl_awc_general=>convert_into_tz(
                                                         iv_from_tz = 'UTC'
                                                         iv_to_tz   = <ls_des_loc_data>-time_zone_code
                                                         iv_from_ts = CONV #( ls_fu_data-last_stop_req_start )
                                                       ).
            ls_trq_head-del_lat_req                  = zcl_awc_general=>convert_into_tz(
                                                          iv_from_tz = 'UTC'
                                                          iv_to_tz   = <ls_des_loc_data>-time_zone_code
                                                          iv_from_ts = CONV #( ls_fu_data-last_stop_req_end )
                                                        ).

          ENDIF.
      ENDIF.
    ENDIF.

    es_trq_head = ls_trq_head.
  ENDMETHOD.


  METHOD get_fus.
    DATA: lt_selpar   TYPE /bobf/t_frw_query_selparam,
          lt_fu_keys  TYPE /bobf/t_frw_key,
          lt_fu_data1 TYPE /scmtms/t_tor_q_fu_r,
          lt_fu_data  TYPE /scmtms/t_tor_q_fu_r.

    DATA(lt_bp_rel) = get_bp_rel( ).

    lt_selpar = get_selpar_from_filter( it_filter_select_options ).

    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'STATUS'.
    IF sy-subrc = 0.

      DATA(lv_status) = <ls_filter_select_options>-select_options[ 1 ]-low.

    ENDIF.

    CASE lv_status.

      WHEN 'O'.

        lt_fu_data = get_open_fus(
                       it_selpar  = lt_selpar
                       it_bp_rel  = lt_bp_rel ).

      WHEN 'C'.

        lt_fu_data = get_closed_fus(
                       it_selpar = lt_selpar
                       it_bp_rel = lt_bp_rel ).

      WHEN 'F'.

        lt_fu_data = get_forcast_fus(
                       it_selpar = lt_selpar
                       it_bp_rel = lt_bp_rel ).

    ENDCASE.

    IF lv_status IS INITIAL.

      lt_fu_data = get_all_fus(
                           it_selpar = lt_selpar
                           it_bp_rel = lt_bp_rel ).

    ENDIF.

    IF lt_fu_data IS INITIAL.

      RETURN.

    ENDIF.

    IF it_orderby IS INITIAL.

      SORT lt_fu_data ASCENDING BY tor_id.

    ELSE.

      order_fus(
        EXPORTING
          it_orderby = it_orderby
        CHANGING
          ct_fu_data = lt_fu_data
      ).

    ENDIF.

    DATA(lv_skip) = iv_skip.
    DATA(lv_top) = iv_skip + iv_top.

    IF iv_skip NE 0.

      lv_skip = lv_skip + 1.

    ENDIF.

    LOOP AT lt_fu_data ASSIGNING FIELD-SYMBOL(<ls_test>)
      FROM lv_skip TO lv_top.

      INSERT VALUE #( key = <ls_test>-db_key ) INTO TABLE lt_fu_keys.
      INSERT <ls_test> INTO TABLE lt_fu_data1.

    ENDLOOP.

*    get_fus_help(
*      EXPORTING
*        it_fu_data_cds = lt_fu_data1
*        it_fu_keys     = lt_fu_keys
*      IMPORTING
*        et_fu    = DATA(lt_fu)    " AWC
*    ).

    get_fus_help(
      EXPORTING
        it_fu_data_cds = lt_fu_data1
        it_fu_keys     = lt_fu_keys
      IMPORTING
        et_fu    = DATA(lt_fu)    " AWC
    ).

    et_fu = lt_fu.

*  METHOD get_fus.
*    DATA: lt_selpar             TYPE /bobf/t_frw_query_selparam,
*          lt_bp                 TYPE /scmtms/t_bupa_q_uname_result,
*          lt_bp_data            TYPE /bofu/t_bupa_root_k,
*          lt_bp_rel             TYPE /bofu/t_bupa_relship_k,
*          lt_fu_data            TYPE /scmtms/t_tor_q_fu_r,
*          lv_date_before_pickup TYPE sy-datum,
*          lv_date_after_pickup  TYPE sy-datum.
*
*    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
*    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).
*    DATA(lo_srv_bp)  = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_bp_c=>sc_bo_key ).
*
*    "get the business partner from SAP user
*    INSERT VALUE #( sign            = 'I'
*                    option          = 'EQ'
*                    low             = sy-uname
*                    attribute_name  = 'UNAME'
*                    ) INTO TABLE lt_selpar.
*
*    lo_srv_bp->query(
*      EXPORTING
*        iv_query_key            = /scmtms/if_bp_c=>sc_query-root-query_by_uname
*        it_selection_parameters = lt_selpar
*      IMPORTING
*        et_data                 = lt_bp
*        et_key                  = DATA(lt_key)
*    ).
*
*    IF lt_bp IS INITIAL.
*      EXIT.
*    ENDIF.
*
*    lo_srv_bp->retrieve_by_association(
*      EXPORTING
*        iv_node_key             = /bofu/if_bupa_constants=>sc_node-root
*        it_key                  = lt_key
*        iv_association          = /bofu/if_bupa_constants=>sc_association-root-relationship
*        iv_fill_data            = abap_true
*      IMPORTING
*        et_data                 = lt_bp_rel
*    ).
*
*    IF lt_bp_rel IS INITIAL.
*      EXIT.
*    ENDIF.
*
*    CLEAR lt_selpar.
*
*    LOOP AT lt_bp_rel ASSIGNING FIELD-SYMBOL(<ls_bp_rel>).
*      IF <ls_bp_rel>-relationshipcategory EQ ms_oth_rel_data-bp_realship.
*        INSERT VALUE #( sign            = 'I'
*                        option          = 'EQ'
*                        low             = <ls_bp_rel>-relshp_partner
*                        attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_business_partne-business_partner_id
*                    ) INTO TABLE lt_selpar.
*      ENDIF.
*    ENDLOOP.
*
*    lo_srv_loc->query(
*        EXPORTING
*          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_business_partne
*          it_selection_parameters = lt_selpar
*        IMPORTING
*          et_key                  = DATA(lt_loc_key)
*      ).
*
*    IF lt_loc_key IS INITIAL.
*      EXIT.
*    ENDIF.
*
*    CLEAR lt_selpar.
*
*    LOOP AT lt_bp_rel ASSIGNING <ls_bp_rel>.
*      INSERT VALUE #( sign          = 'I'
*                      option          = 'EQ'
*                      low             = <ls_bp_rel>-relshp_partner
*                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid
*                    ) INTO TABLE lt_selpar.
*    ENDLOOP.
*
*    lv_date_before_pickup  = sy-datum + ms_oth_rel_data-period_before_pickup.
*    lv_date_after_pickup   = sy-datum - ms_oth_rel_data-period_after_pickup.
*
*    INSERT VALUE #(   sign            = 'I'
*                      option          = 'BT'
*                      low             = lv_date_after_pickup
*                      high            = lv_date_before_pickup
*                      attribute_name  = 'ZZ_PICK_UP_DATE'
*                    ) INTO TABLE lt_selpar.
*
*    INSERT VALUE #(   sign            = 'I'
*                      option          = 'EQ'
*                      low             = '01'
*                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
*                    ) INTO TABLE lt_selpar.
*
*    INSERT VALUE #(   sign            = 'I'
*                      option          = 'EQ'
*                      low             = '02'
*                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
*                    ) INTO TABLE lt_selpar.
*
*    lo_tor_service_mgr->query(
*      EXPORTING
*        iv_query_key            = /scmtms/if_tor_c=>sc_query-root-fu_data_by_attr
*        it_selection_parameters = lt_selpar
*        iv_fill_data            = abap_true
*        it_requested_attributes = VALUE #(
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-db_key )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_id )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_log_loc_uuid )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_log_loc_uuid )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_start )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_start )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_end )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_type )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-lifecycle )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-blk_plan )
*                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-blk_exec )
*                                           ( zif_enh_tor_c=>sc_node_attribute-root-zz_earlierst_due_date )
*                                           ( zif_enh_tor_c=>sc_node_attribute-root-zz_latest_due_date )
*                                         )
*      IMPORTING
*        et_key                  = DATA(lt_fu_keys)
*        et_data                 = lt_fu_data
*    ).
*
*    LOOP AT lt_fu_data ASSIGNING FIELD-SYMBOL(<ls_fu_data>) WHERE blk_exec = abap_true.
*
*      DELETE lt_fu_keys WHERE key = <ls_fu_data>-db_key.
*      DELETE lt_fu_data WHERE db_key = <ls_fu_data>-db_key.
*
*    ENDLOOP.
*
*    get_fus_help(
*      EXPORTING
*        it_fu_data_cds = lt_fu_data  " AWC
*        it_fu_keys     = lt_fu_keys
*      IMPORTING
*        et_fu    = DATA(lt_fu)    " AWC
*    ).
*
*    et_fu = lt_fu.
*  ENDMETHOD.
  ENDMETHOD.


  METHOD get_fus_help.
    DATA: lt_loc_keys TYPE /bobf/t_frw_key,
          ls_fu       TYPE zsawc_fu,
          lt_fu       TYPE zt_awc_fu,
          lt_fu_stops TYPE /scmtms/t_tor_stop_k,
          lv_counter  TYPE i.

    DATA(lo_srv_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    get_docref(
      EXPORTING
        it_fu_key    = it_fu_keys
      IMPORTING
        et_fu_docref = DATA(lt_fu_docref)
    ).

    get_items_by_fu(
      EXPORTING
        it_fu_keys = it_fu_keys    " NodeID
      IMPORTING
        et_items   = DATA(lt_fu_items)    " AWC Trqitem
    ).

    get_summary(
      EXPORTING
        it_fu_keys    = it_fu_keys    " NodeID
      IMPORTING
        et_fu_summary = DATA(lt_fu_summary)
    ).

    lo_srv_tor->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-stop
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fu_stops
        eo_message              = DATA(lo_mssg)
    ).

    LOOP AT it_fu_data_cds ASSIGNING FIELD-SYMBOL(<ls_fu_data>).
      IF NOT line_exists( lt_loc_keys[ key = <ls_fu_data>-first_stop_log_loc_uuid ] ).
        INSERT VALUE #( key = <ls_fu_data>-first_stop_log_loc_uuid ) INTO TABLE lt_loc_keys.
      ENDIF.
      IF NOT line_exists( lt_loc_keys[ key = <ls_fu_data>-last_stop_log_loc_uuid ] ).
        INSERT VALUE #( key = <ls_fu_data>-last_stop_log_loc_uuid ) INTO TABLE lt_loc_keys.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_fu_stops ASSIGNING FIELD-SYMBOL(<ls_fu_stop>).
      IF NOT line_exists( lt_loc_keys[ key = <ls_fu_stop>-adr_loc_uuid ] ) AND <ls_fu_stop>-adr_loc_uuid NE '00000000000000000000000000000000'.
        INSERT VALUE #( key = <ls_fu_stop>-adr_loc_uuid ) INTO TABLE lt_loc_keys.
      ENDIF.
    ENDLOOP.

    DATA(lo_loc) = NEW zcl_awc_location( ).
    lo_loc->get_loc_data(
      EXPORTING
        it_loc_key  = lt_loc_keys
      IMPORTING
        et_loc_data = DATA(lt_loc_data)
    ).

    lo_loc->get_adress_info(
      EXPORTING
        it_loc_key             = lt_loc_keys
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
    ).

    DATA(lo_trq) = NEW zcl_awc_trq( ).

    lo_trq->get_trq_keys_from_fu(
      EXPORTING
        it_fu_docref = lt_fu_docref
      IMPORTING
        et_fwo_keys  = DATA(lt_fwo_keys)
    ).

    lo_trq->get_trq_data(
      EXPORTING
        it_trq_key  = lt_fwo_keys
      IMPORTING
        et_trq_data = DATA(lt_fwo_data)
    ).

    LOOP AT it_fu_data_cds ASSIGNING <ls_fu_data>.
*      lv_counter = 0.

*      IF <ls_fu_data>-tor_id CO '3100002333'.
*        DATA(test) = 5.
*      ENDIF.

      SELECT SINGLE descr FROM /scmtms/c_tort_t INTO @DATA(lv_tor_type_desc) WHERE type = @<ls_fu_data>-tor_type AND langu = @sy-langu.

      ls_fu-fu_key          = <ls_fu_data>-db_key.
      ls_fu-fu_id           = <ls_fu_data>-tor_id.
      ls_fu-tor_type        = <ls_fu_data>-tor_type.
      ls_fu-tor_type_desc   = lv_tor_type_desc.
      ls_fu-lifecycle       = <ls_fu_data>-lifecycle.
      ls_fu-blk_plan        = <ls_fu_data>-blk_plan.

      LOOP AT lt_fu_items ASSIGNING FIELD-SYMBOL(<ls_fu_items>) WHERE fu_key EQ <ls_fu_data>-db_key.
        IF <ls_fu_items>-item_cat = ms_trq_rel_data-item_cat.
          ls_fu-pkg_available = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_fu_docref ASSIGNING FIELD-SYMBOL(<ls_fu_docref>) WHERE root_key = <ls_fu_data>-db_key and btd_tco NE ms_trq_rel_data-btd_tco_fwo.
        DATA(lv_btd_tco) = <ls_fu_docref>-btd_tco.
      ENDLOOP.

      if lv_btd_tco is INITIAL.
        READ TABLE lt_fu_docref INTO DATA(ls_fu_docref_for_one_fu) WITH KEY root_key = <ls_fu_data>-db_key btd_tco = ms_trq_rel_data-btd_tco_fwo.

        IF sy-subrc = 0.
          ls_fu-trq_key       = ls_fu_docref_for_one_fu-orig_ref_root.
          ls_fu-btd_id        = ls_fu_docref_for_one_fu-btd_id.

          SELECT SINGLE description FROM /scmtms/c_btdtyt INTO @DATA(lv_btd_tco_desc) WHERE btd_tco129 = @ls_fu_docref_for_one_fu-btd_tco AND spras = @sy-langu.
          ls_fu-btd_tco_desc  = lv_btd_tco_desc.
          ls_fu-btd_tco       = ls_fu_docref_for_one_fu-btd_tco.

        ENDIF.
      ELSE.
        READ TABLE lt_fu_docref INTO ls_fu_docref_for_one_fu WITH KEY root_key = <ls_fu_data>-db_key btd_tco = lv_btd_tco.

          IF sy-subrc = 0.
            ls_fu-btd_id        = ls_fu_docref_for_one_fu-btd_id.
            ls_fu-trq_key       = ls_fu_docref_for_one_fu-orig_ref_root.

            ls_fu-btd_tco_desc  = TEXT-001.
          ENDIF.

      ENDIF.

      READ TABLE it_fu_data_cds ASSIGNING FIELD-SYMBOL(<ls_fu_data_cds>) WITH KEY db_key = <ls_fu_data>-db_key.
      IF sy-subrc = 0.
        ls_fu-earliest_due_date = <ls_fu_data_cds>-zz_earlierst_due_date.
        ls_fu-last_due_date     = <ls_fu_data_cds>-zz_latest_due_date.
        IF ls_fu-btd_tco <> ms_trq_rel_data-btd_tco_fwo.
          IF <ls_fu_data>-blk_plan EQ abap_true AND ( <ls_fu_data>-lifecycle = '01' OR <ls_fu_data>-lifecycle = '02' ) AND <ls_fu_data_cds>-zz_earlierst_due_date <= sy-datum.
            ls_fu-status = 'O'.
          ELSEIF <ls_fu_data>-blk_plan EQ abap_false AND ( <ls_fu_data>-lifecycle = '01' OR <ls_fu_data>-lifecycle = '02' ).
            ls_fu-status = 'C'.
          ELSEIF <ls_fu_data>-blk_plan EQ abap_true AND ( <ls_fu_data>-lifecycle = '01' OR <ls_fu_data>-lifecycle = '02' ) AND <ls_fu_data_cds>-zz_earlierst_due_date >= sy-datum.
            ls_fu-status = 'F'.
          ENDIF.
        ELSE.
          IF <ls_fu_data>-blk_plan EQ abap_false AND ( <ls_fu_data>-lifecycle = '01' OR <ls_fu_data>-lifecycle = '02' ).
            ls_fu-status = 'C'.
          ELSEIF <ls_fu_data>-blk_plan EQ abap_true AND ( <ls_fu_data>-lifecycle = '01' OR <ls_fu_data>-lifecycle = '02' ).
            ls_fu-status = 'O'.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE lt_fu_stops ASSIGNING <ls_fu_stop> WITH KEY root_key = <ls_fu_data>-db_key stop_id = '0000000010'.
      IF sy-subrc = 0.
        IF <ls_fu_stop>-adr_loc_uuid NE '00000000000000000000000000000000'.
          DATA(lv_src_loc_uuid) = <ls_fu_stop>-adr_loc_uuid.
        ELSE.
          lv_src_loc_uuid = <ls_fu_data>-first_stop_log_loc_uuid.
        ENDIF.
      ENDIF.

      READ TABLE lt_fu_stops ASSIGNING <ls_fu_stop> WITH KEY root_key = <ls_fu_data>-db_key stop_id = '0000000020'.
      IF sy-subrc = 0.
        IF <ls_fu_stop>-adr_loc_uuid NE '00000000000000000000000000000000'.
          DATA(lv_des_loc_uuid) = <ls_fu_stop>-adr_loc_uuid.
        ELSE.
          lv_des_loc_uuid = <ls_fu_data>-last_stop_log_loc_uuid.
        ENDIF.
      ENDIF.


      "Data for source location
      READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_src_loc_data>) WITH KEY key = lv_src_loc_uuid.
      IF sy-subrc = 0.
        READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_src_key_link>) WITH KEY source_key = <ls_src_loc_data>-root_key.
        IF sy-subrc = 0.
            READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_src_loc_adress>) WITH KEY key = <ls_src_key_link>-target_key.
            IF sy-subrc = 0.
              ls_fu-src_loc_key                  = <ls_src_loc_data>-key.
              ls_fu-src_location_id              = <ls_src_loc_data>-location_id.
              ls_fu-src_name1                    = <ls_src_loc_adress>-name1.
              ls_fu-src_country_code             = <ls_src_loc_adress>-country_code.
              ls_fu-src_region                   = <ls_src_loc_adress>-region.
              ls_fu-src_city_name                = <ls_src_loc_adress>-city_name.
              ls_fu-src_street_postal_code       = <ls_src_loc_adress>-street_postal_code.
              ls_fu-src_street_name              = <ls_src_loc_adress>-street_name.
              ls_fu-src_house_id                 = <ls_src_loc_adress>-house_id.
              ls_fu-src_time_zone_code           = <ls_src_loc_data>-time_zone_code.

              READ TABLE lt_fu_summary ASSIGNING FIELD-SYMBOL(<ls_fu_summary>) WITH KEY root_key = <ls_fu_data>-db_key.
              IF sy-subrc = 0.
                ls_fu-pic_ear_req         = zcl_awc_general=>convert_into_tz(
                                              iv_from_tz = 'UTC'
                                              iv_to_tz   = <ls_src_loc_data>-time_zone_code
                                              iv_from_ts = CONV #( <ls_fu_summary>-first_stop_req_start )
                                            ).
                ls_fu-pic_lat_req         = zcl_awc_general=>convert_into_tz(
                                              iv_from_tz = 'UTC'
                                              iv_to_tz   = <ls_src_loc_data>-time_zone_code
                                              iv_from_ts = CONV #( <ls_fu_summary>-first_stop_req_end )
                                            ).
              ENDIF.
            ENDIF.
          ENDIF.
      ENDIF.

      "Data for destination location
      READ TABLE lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_des_loc_data>) WITH KEY key = lv_des_loc_uuid.
      IF sy-subrc = 0.
        READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_des_key_link>) WITH KEY source_key = <ls_des_loc_data>-root_key.
        IF sy-subrc = 0.
            READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_des_loc_adress>) WITH KEY key = <ls_des_key_link>-target_key.
            IF sy-subrc = 0.
              ls_fu-des_loc_key                  = <ls_des_loc_data>-key.
              ls_fu-des_location_id              = <ls_des_loc_data>-location_id.
              ls_fu-des_name1                    = <ls_des_loc_adress>-name1.
              ls_fu-des_country_code             = <ls_des_loc_adress>-country_code.
              ls_fu-des_region                   = <ls_des_loc_adress>-region.
              ls_fu-des_city_name                = <ls_des_loc_adress>-city_name.
              ls_fu-des_street_postal_code       = <ls_des_loc_adress>-street_postal_code.
              ls_fu-des_street_name              = <ls_des_loc_adress>-street_name.
              ls_fu-des_house_id                 = <ls_des_loc_adress>-house_id.
              ls_fu-des_time_zone_code           = <ls_des_loc_data>-time_zone_code.

              READ TABLE lt_fu_summary ASSIGNING <ls_fu_summary> WITH KEY root_key = <ls_fu_data>-db_key.
              IF sy-subrc = 0.
                ls_fu-del_ear_req         = zcl_awc_general=>convert_into_tz(
                                              iv_from_tz = 'UTC'
                                              iv_to_tz   = <ls_des_loc_data>-time_zone_code
                                              iv_from_ts = CONV #( <ls_fu_summary>-last_stop_req_start )
                                            ).
                ls_fu-del_lat_req         = zcl_awc_general=>convert_into_tz(
                                              iv_from_tz = 'UTC'
                                              iv_to_tz   = <ls_des_loc_data>-time_zone_code
                                              iv_from_ts = CONV #( <ls_fu_summary>-last_stop_req_end )
                                            ).
              ENDIF.
            ENDIF.
        ENDIF.
      ENDIF.

      DATA: lv_time TYPE t VALUE '120000'.

*      IF ls_fu-status = 'O' AND ( ls_fu-last_due_date < sy-datum OR ( sy-datum = ls_fu-last_due_date AND sy-uzeit > lv_time ) ).
*        " DO nothing, becuase FU was not released in time
*      ELSE.
*        INSERT ls_fu INTO TABLE lt_fu.
*      ENDIF.
INSERT ls_fu INTO TABLE lt_fu.
      CLEAR: ls_fu, lv_btd_tco.
    ENDLOOP.

    et_fu = lt_fu.
  ENDMETHOD.


  METHOD get_fu_data.
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_service_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_tor_c=>sc_query-root-fu_data_by_attr
        it_filter_key           = it_fu_key
        iv_fill_data            = abap_true
        it_requested_attributes = VALUE #(
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-db_key )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_id )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_log_loc_uuid )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_log_loc_uuid )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_start )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_start )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_end )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_type )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-lifecycle )
                                           ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-blk_plan )
                                           ( zif_enh_tor_c=>sc_node_attribute-root-zz_earlierst_due_date )
                                           ( zif_enh_tor_c=>sc_node_attribute-root-zz_latest_due_date )
                                         )
      IMPORTING
        et_key                  = DATA(lt_key)
        et_data                 = et_fu_data
    ).
  ENDMETHOD.


  METHOD get_fu_keys_from_trq.
    DATA(lo_trq_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).

    DATA lt_trq_key TYPE /bobf/t_frw_key.

    INSERT VALUE #( key = iv_trq_key ) INTO TABLE lt_trq_key.

    lo_trq_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
        it_key                  = lt_trq_key
        iv_association          = /scmtms/if_trq_c=>sc_association-root-tor_root_fu
      IMPORTING
        et_target_key           = DATA(lt_fu_key)
    ).

    et_fu_key = lt_fu_key.
  ENDMETHOD.


  METHOD get_items_by_fu.
    DATA: lt_fu_items TYPE /scmtms/t_tor_item_tr_k,
          lt_items    TYPE zt_awc_trq_item,
          lt_mat_des  TYPE /scmtms/t_mat_description_k,
          lt_mat_key  TYPE /bobf/t_frw_key,
          lv_maxstack TYPE i,
          lv_prd_id   TYPE /SCMTMS/PRODUCT_ID.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-item_tr
        iv_fill_data            = abap_true
      IMPORTING
        eo_message              = DATA(lo_message)
        et_data                 = lt_fu_items
    ).

    DATA(lo_mat) = NEW zcl_awc_material( ).

    LOOP AT lt_fu_items ASSIGNING FIELD-SYMBOL(<ls_fu_items>) WHERE item_cat NE 'FUR'.
      IF NOT line_exists( lt_mat_key[ key = <ls_fu_items>-prd_key ] ).
        INSERT VALUE #( key = <ls_fu_items>-prd_key ) INTO TABLE lt_mat_key.
      ENDIF.

      IF <ls_fu_items>-package_id IS NOT INITIAL.
        IF NOT line_exists( lt_mat_key[ key = lo_mat->get_mat_key_by_mat_id( CONV #( <ls_fu_items>-item_descr ) ) ] ).
          INSERT VALUE #( key = lo_mat->get_mat_key_by_mat_id( CONV #( <ls_fu_items>-item_descr ) ) ) INTO TABLE lt_mat_key.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lo_srv_mat->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_association          = /scmtms/if_mat_c=>sc_association-root-description
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_des
    ).

    LOOP AT lt_fu_items ASSIGNING <ls_fu_items> WHERE item_cat NE 'FUR'.
      LOOP AT lt_mat_des ASSIGNING FIELD-SYMBOL(<ls_mat_des>)
        WHERE ( root_key = <ls_fu_items>-prd_key
        OR root_key = lo_mat->get_mat_key_by_mat_id( CONV #( <ls_fu_items>-item_descr ) ) )
        AND langu = sy-langu.

        IF <ls_fu_items>-zz_stackability > 0.
          lv_maxstack = <ls_fu_items>-zz_stackability - 1.
        ELSE.
          lv_maxstack = <ls_fu_items>-zz_stackability.
        ENDIF.

        If <ls_fu_items>-qua_pcs_val > 0.
          DATA(lv_gro_wei_val) = <ls_fu_items>-gro_wei_val / <ls_fu_items>-qua_pcs_val.
        else.
          lv_gro_wei_val = 0.
        endif.

        if <ls_fu_items>-product_id is INITIAL.
          lv_prd_id = conv #( <ls_fu_items>-item_descr ).
        Else.
          lv_prd_id = <ls_fu_items>-product_id.
        endif.

        INSERT VALUE #( item_key        = <ls_fu_items>-key
                        fu_key          = <ls_fu_items>-parent_key
                        prd_key         = NEW zcl_awc_material( )->get_mat_key_by_mat_id( CONV #( <ls_fu_items>-item_descr ) )
                        prd_id          = lv_prd_id
                        qua_pcs_val     = <ls_fu_items>-qua_pcs_val
                        qua_pcs_uni     = <ls_fu_items>-qua_pcs_uni
                        length          = <ls_fu_items>-length
                        width           = <ls_fu_items>-width
                        height          = <ls_fu_items>-height
                        measuom         = <ls_fu_items>-measuom
                        gro_wei_val     = lv_gro_wei_val
                        gro_wei_uni     = <ls_fu_items>-gro_wei_uni
                        gro_vol_val     = <ls_fu_items>-gro_vol_val
                        gro_vol_uni     = <ls_fu_items>-gro_vol_uni
                        maxstack        = lv_maxstack
                        item_cat        = <ls_fu_items>-item_cat
                        item_parent_key = <ls_fu_items>-item_parent_key
                        description     = <ls_mat_des>-maktx
                      ) INTO TABLE lt_items.
      ENDLOOP.
    ENDLOOP.

    et_items = lt_items.
  ENDMETHOD.


  METHOD get_open_fus.

    DATA: lt_selpar             TYPE /bobf/t_frw_query_selparam,
          lv_date_before_pickup TYPE sy-datum,
          lv_date_after_pickup  TYPE sy-datum,
          lv_check_selpar       TYPE abap_bool VALUE abap_false.

    DATA: lv_time TYPE t VALUE '120000'.

    IF it_bp_rel IS INITIAL.

      RETURN.

    ENDIF.

    lt_selpar = it_selpar.

    LOOP AT it_bp_rel ASSIGNING FIELD-SYMBOL(<ls_bp_rel>).
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <ls_bp_rel>-relshp_partner
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid
                    ) INTO TABLE lt_selpar.
    ENDLOOP.


    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = 'ZFU4'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type
                    ) INTO TABLE lt_selpar.

    lv_date_before_pickup  = sy-datum + ms_oth_rel_data-period_before_pickup.
    lv_date_after_pickup   = sy-datum - ms_oth_rel_data-period_after_pickup.

    READ TABLE it_selpar INTO DATA(ls_selpar) WITH KEY attribute_name = 'ZZ_PICK_UP_DATE'.

    IF sy-subrc = 0.

      IF ls_selpar-option = 'EQ'.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-low LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'EQ'
                            low             = ls_selpar-low
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ELSE.

        IF ls_selpar-low GE lv_date_after_pickup AND ls_selpar-high LE lv_date_before_pickup.

          INSERT VALUE #(   sign            = 'I'
                            option          = 'BT'
                            low             = ls_selpar-low
                            high            = ls_selpar-high
                            attribute_name  = 'ZZ_PICK_UP_DATE'
                          ) INTO TABLE lt_selpar.

        ELSE.

          RETURN.

        ENDIF.

      ENDIF.


    ELSE.

      INSERT VALUE #(   sign            = 'I'
                        option          = 'BT'
                        low             = lv_date_after_pickup
                        high            = lv_date_before_pickup
                        attribute_name  = 'ZZ_PICK_UP_DATE'
                      ) INTO TABLE lt_selpar.

    ENDIF.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '01'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '02'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-lifecycle
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_true
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-blk_plan
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '01'
                      attribute_name  = 'ZZ_TRQ_CAT'
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'LE'
                      low             = sy-datum
                      attribute_name  = 'ZZ_EARLIERST_DUE_DATE'
                    ) INTO TABLE lt_selpar.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = abap_false
                      attribute_name  = 'ZZ_BLK_EXEC'
                    ) INTO TABLE lt_selpar.

    READ TABLE it_selpar INTO ls_selpar WITH KEY attribute_name = 'ZZ_LATEST_DUE_DATE'.
    IF sy-subrc NE 0.

      IF sy-uzeit > lv_time.

        INSERT VALUE #(   sign            = 'I'
                          option          = 'GT'
                          low             = sy-datum
                          attribute_name  = 'ZZ_LATEST_DUE_DATE'
                        ) INTO TABLE lt_selpar.

      ELSE.

        INSERT VALUE #(   sign            = 'I'
                          option          = 'GE'
                          low             = sy-datum
                          attribute_name  = 'ZZ_LATEST_DUE_DATE'
                        ) INTO TABLE lt_selpar.

      ENDIF.

    ENDIF.

    IF sy-mandt EQ 300.
      prepare_selpar_for_300(
        CHANGING
          ct_selpar = lt_selpar
      ).
    ENDIF.

    READ TABLE it_selpar INTO DATA(ls_trqcat_selpar) WITH KEY attribute_name = 'ZZ_TRQ_CAT'.
    IF sy-subrc = 0.
      IF ls_trqcat_selpar-low = '01'.

        query_fus(
          EXPORTING
            it_selpar  = lt_selpar
          IMPORTING
            et_fu_keys = DATA(lt_auto_fus_key)
            et_fu_data = DATA(lt_auto_fus_data)
        ).

        RETURN.

      ENDIF.
    ELSE.
      query_fus(
         EXPORTING
           it_selpar  = lt_selpar
         IMPORTING
           et_fu_keys = lt_auto_fus_key
           et_fu_data = lt_auto_fus_data
       ).
    ENDIF.

    DELETE lt_selpar WHERE attribute_name = 'ZZ_TRQ_CAT'.
    DELETE lt_selpar WHERE attribute_name = 'ZZ_PICK_UP_DATE' AND option = 'BT' AND low = lv_date_after_pickup AND high = lv_date_before_pickup.
    DELETE lt_selpar WHERE attribute_name = 'ZZ_EARLIERST_DUE_DATE'.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = '03'
                      attribute_name  = 'ZZ_TRQ_CAT'
                    ) INTO TABLE lt_selpar.



    query_fus(
      EXPORTING
        it_selpar  = lt_selpar
      IMPORTING
        et_fu_keys = DATA(lt_man_fus_key)
        et_fu_data = DATA(lt_man_fus_data)
    ).

    DELETE lt_selpar WHERE attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-shipperid.
    DELETE lt_selpar WHERE attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type.

    LOOP AT it_bp_rel ASSIGNING <ls_bp_rel>.
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                      low             = <ls_bp_rel>-relshp_partner
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-consigneeid
                    ) INTO TABLE lt_selpar.
    ENDLOOP.

    INSERT VALUE #(   sign            = 'I'
                      option          = 'EQ'
                      low             = 'ZFU5'
                      attribute_name  = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_type
                    ) INTO TABLE lt_selpar.



    query_fus(
      EXPORTING
        it_selpar  = lt_selpar
      IMPORTING
        et_fu_keys = DATA(lt_emp_fus_key)
        et_fu_data = DATA(lt_emp_fus_data)
    ).

    APPEND LINES OF lt_auto_fus_data TO rt_fu_data.
    APPEND LINES OF lt_man_fus_data  TO rt_fu_data.
    APPEND LINES OF lt_emp_fus_data  TO rt_fu_data.

  ENDMETHOD.


  METHOD get_selpar_from_filter.

    DATA: ls_selpar TYPE /bobf/s_frw_query_selparam,
          lv_date   TYPE d,
          lv_time   TYPE t VALUE '235959',
          lv_ts     TYPE ts.

    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'FU_ID'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-fu_data_by_attr-tor_id.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'BTD_ID'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-attribute_name = 'ZZ_BTD_ID'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'BTD_TCO_DESC'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      DATA(lv_btd_tco_desc) = <ls_filter_select_options>-select_options[ 1 ]-low.

      IF lv_btd_tco_desc CP '*man*'.

        ls_selpar-low             = '03'.

      ELSEIF lv_btd_tco_desc CP '*auto*'.

        ls_selpar-low             = '01'.

      endif.

      ls_selpar-sign            = 'I'.
      ls_selpar-option          = 'EQ'.
      ls_selpar-attribute_name  = 'ZZ_TRQ_CAT'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'SRC_LOCATION_ID'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-attribute_name = 'ZZ_FIRST_STOP_LOC_ID'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'DES_LOCATION_ID'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-attribute_name = 'ZZ_LAST_STOP_LOC_ID'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'PIC_EAR_REQ'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-low  = ls_selpar-low(8).

      IF ls_selpar-option = 'BT'.
        ls_selpar-high = ls_selpar-high(8).
      ENDIF.
      ls_selpar-attribute_name = 'ZZ_PICK_UP_DATE'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'DEL_EAR_REQ'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-low  = ls_selpar-low(8).

      IF ls_selpar-option = 'BT'.
        ls_selpar-high = ls_selpar-high(8).
      ENDIF.
      ls_selpar-attribute_name = 'ZZ_DELIVERY_DATE'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'LAST_DUE_DATE'.
    IF sy-subrc = 0.
      CLEAR ls_selpar.

      ls_selpar = CORRESPONDING #( <ls_filter_select_options>-select_options[ 1 ] ).
      ls_selpar-low  = ls_selpar-low(8).

      IF ls_selpar-option = 'BT'.
        ls_selpar-high = ls_selpar-high(8).
      ENDIF.
      ls_selpar-attribute_name = 'ZZ_LATEST_DUE_DATE'.

      APPEND ls_selpar TO rt_selpar.
    ENDIF.

  ENDMETHOD.


  METHOD get_summary.
    DATA: lt_fu_summary TYPE /scmtms/t_tor_root_transient_k.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-summary
        iv_fill_data            = abap_true
      IMPORTING
        eo_message              = DATA(lo_message)
        et_data                 = lt_fu_summary
    ).

    et_fu_summary = lt_fu_summary.
  ENDMETHOD.


  METHOD GET_TEXT_FROM_FU.

    DATA : lo_tor_service_mgr  TYPE REF TO /bobf/if_tra_service_manager,
           lo_tor_bo_conf      TYPE REF TO /bobf/if_frw_configuration,
           lt_tor_text_data    TYPE /bobf/t_txc_txt_k,
           lt_tor_text_key     TYPE /bobf/t_frw_key,
           lt_tor_note_content TYPE /bobf/t_txc_con_k.

*-- Service Manager Reference
*--Export the Business Object Key of the Node
    lo_tor_service_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

*-- Configuration Reference
*--Export the Business Object Key of the Node
    lo_tor_bo_conf  = /bobf/cl_frw_factory=>get_configuration( iv_bo_key  = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_tor_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-textcollection
      IMPORTING
        et_target_key           = DATA(lt_tor_textcollection_key)
    ).

*-- Association Key of ROOT->TEXT
    DATA(lv_tor_to_txtcol_assoc) = lo_tor_bo_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
                   iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-textcollection
        it_key                  = lt_tor_textcollection_key
        iv_association          = lv_tor_to_txtcol_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_text_data
        et_target_key           = lt_tor_text_key
     ).

*-- Association Key of TEXT->TEXT_CONTENT
    DATA(lv_txtcol_to_txtcontent_assoc) = lo_tor_bo_conf->get_content_key_mapping(
                    iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                    iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
                    iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).


    DATA(lv_txtcol_to_key_assoc) = lo_tor_bo_conf->get_content_key_mapping(
             iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
             iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
             iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = lv_txtcol_to_key_assoc
        it_key                  = lt_tor_text_key
        iv_association          = lv_txtcol_to_txtcontent_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_note_content
    ).

    LOOP AT lt_tor_text_data ASSIGNING FIELD-SYMBOL(<ls_tor_text_data>).
      READ TABLE lt_tor_note_content ASSIGNING FIELD-SYMBOL(<ls_tor_note_content>) WITH KEY parent_key = <ls_tor_text_data>-key.

      INSERT VALUE #( tor_key   = <ls_tor_text_data>-root_key
                      txt_type  = <ls_tor_text_data>-text_type
                      text      = <ls_tor_note_content>-text
                    ) INTO TABLE et_text_content.
    ENDLOOP.

  ENDMETHOD.


  METHOD order_fus.

    DATA: ls_orderby LIKE LINE OF it_orderby.

    READ TABLE it_orderby INTO ls_orderby INDEX 1.
    IF sy-subrc = 0.
      IF ls_orderby-order = 'desc'.
        CASE ls_orderby-property.
          WHEN 'FU_ID'.
            SORT ct_fu_data DESCENDING BY tor_id.
          WHEN 'BTD_ID'.
            SORT ct_fu_data DESCENDING BY base_btd_id.
          WHEN 'SRC_LOCATION_ID'.
            SORT ct_fu_data DESCENDING BY first_stop_log_loc_id.
          WHEN 'DES_LOCATION_ID'.
            SORT ct_fu_data DESCENDING BY last_stop_log_loc_id.
          WHEN 'PIC_EAR_REQ'.
            SORT ct_fu_data DESCENDING BY first_stop_req_start.
          WHEN 'DEL_EAR_REQ'.
            SORT ct_fu_data DESCENDING BY last_stop_req_start.
          WHEN 'LAST_DUE_DATE'.
            SORT ct_fu_data DESCENDING BY zz_latest_due_date.
        ENDCASE.
      ELSEIF ls_orderby-order = 'asc'.
        CASE ls_orderby-property.
          WHEN 'FU_ID'.
            SORT ct_fu_data ASCENDING BY tor_id.
          WHEN 'BTD_ID'.
            SORT ct_fu_data ASCENDING BY base_btd_id.
          WHEN 'SRC_LOCATION_ID'.
            SORT ct_fu_data ASCENDING BY first_stop_log_loc_id.
          WHEN 'DES_LOCATION_ID'.
            SORT ct_fu_data ASCENDING BY last_stop_log_loc_id.
          WHEN 'PIC_EAR_REQ'.
            SORT ct_fu_data ASCENDING BY first_stop_req_start.
          WHEN 'DEL_EAR_REQ'.
            SORT ct_fu_data ASCENDING BY last_stop_req_start.
          WHEN 'LAST_DUE_DATE'.
            SORT ct_fu_data ASCENDING BY zz_latest_due_date.
        ENDCASE.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD prepare_selpar_for_300.







    DELETE ct_selpar WHERE attribute_name NE 'TOR_ID' AND attribute_name NE 'ZZ_BLK_EXEC'
    AND attribute_name NE 'BLK_PLAN'
    AND attribute_name NE 'SHIPPERID'
    AND attribute_name NE 'BLK_PLAN'
    AND attribute_name NE 'CONSIGNEEID'.
*   DELETE ct_selpar WHERE attribute_name = 'BLK_PLAN'.
*   DELETE ct_selpar WHERE attribute_name = 'ZZ_EARLIEST_DUE_DATE'.
*   DELETE ct_selpar WHERE attribute_name = 'ZZ_TRQ_CAT'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_PICK_UP_DATE'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_TRQ_CAT'.
*    DELETE ct_selpar WHERE attribute_name NE 'ZZ_BLK_EXEC'.
*    DELETE ct_selpar WHERE attribute_name = 'SHIPPERID'.
*    DELETE ct_selpar WHERE attribute_name = 'TOR_TYPE'.
*    DELETE ct_selpar WHERE attribute_name = 'LIFECYCLE'.
*    DELETE ct_selpar WHERE attribute_name = 'CONSIGNEEID'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_EARLIERST_DUE_DATE'.
*
*
*   DELETE ct_selpar WHERE attribute_name = 'ZZ_LATEST_DUE_DATE'.
*   DELETE ct_selpar WHERE attribute_name = 'BLK_PLAN'.
*   DELETE ct_selpar WHERE attribute_name = 'ZZ_EARLIEST_DUE_DATE'.
*   DELETE ct_selpar WHERE attribute_name = 'ZZ_TRQ_CAT'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_PICK_UP_DATE'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_TRQ_CAT'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_BLK_EXEC'.
*    DELETE ct_selpar WHERE attribute_name = 'SHIPPERID'.
*    DELETE ct_selpar WHERE attribute_name = 'TOR_TYPE'.
*    DELETE ct_selpar WHERE attribute_name = 'LIFECYCLE'.
*    DELETE ct_selpar WHERE attribute_name = 'CONSIGNEEID'.
*    DELETE ct_selpar WHERE attribute_name = 'ZZ_EARLIERST_DUE_DATE'.


  ENDMETHOD.


  METHOD query_fus.

    DATA: ls_query_options TYPE /bobf/s_frw_query_options.
*
*    ls_query_options-maximum_rows = 400.
*    ls_query_options-paging_options-paging_active = 'X'.
*    ls_query_options-paging_options-start_row     = 1.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    DATA(lt_selpar) = it_selpar.

    IF sy-mandt EQ 300.
      prepare_selpar_for_300(
        CHANGING
          ct_selpar = lt_selpar
      ).
    ENDIF.

    lo_tor_service_mgr->query(
        EXPORTING
          iv_query_key            = /scmtms/if_tor_c=>sc_query-root-fu_data_by_attr
          it_selection_parameters = lt_selpar
*          is_query_options        = ls_query_options
          iv_fill_data            = abap_true
          it_requested_attributes = VALUE #(
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-db_key )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_id )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_log_loc_uuid )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_log_loc_uuid )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_start )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-first_stop_req_end )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_start )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-last_stop_req_end )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-tor_type )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-lifecycle )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-blk_plan )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-blk_exec )
                                             ( /scmtms/if_tor_c=>sc_query_result_type_attribute-root-fu_data_by_attr-base_btd_tco )
                                             ( zif_enh_tor_c=>sc_node_attribute-root-zz_earlierst_due_date )
                                             ( zif_enh_tor_c=>sc_node_attribute-root-zz_latest_due_date )
                                           )
        IMPORTING
          et_key                  = et_fu_keys
          et_data                 = et_fu_data
      ).

    LOOP AT et_fu_data ASSIGNING FIELD-SYMBOL(<ls_fu_data>) WHERE blk_exec = abap_true.

      DELETE et_fu_keys WHERE key = <ls_fu_data>-db_key.
      DELETE et_fu_data WHERE db_key = <ls_fu_data>-db_key.

    ENDLOOP.

  ENDMETHOD.


  METHOD release_fus.
    DATA: lt_block_keys TYPE /bobf/t_frw_key.

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-block
      IMPORTING
        et_key_link             = DATA(lt_fu_block_keys)
    ).

    LOOP AT lt_fu_block_keys ASSIGNING FIELD-SYMBOL(<ls_fu_block_keys>).
      CLEAR lt_block_keys.
      INSERT VALUE #( key = <ls_fu_block_keys>-target_key ) into table lt_block_keys.

       lo_tor_service_mgr->do_action(
        EXPORTING
          iv_act_key           = /scmtms/if_tor_c=>sc_action-block-overrule_block
          it_key               = lt_block_keys
        IMPORTING
          eo_message           = DATA(lo_message)
      ).


      /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
            EXPORTING
              iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
            IMPORTING
              eo_message             = lo_message
          ).

      new zcl_awc_general( )->check_bopf_messages( lo_message ).
    ENDLOOP.

  ENDMETHOD.


  METHOD set_add_address.

    DATA: lt_fu_keys   TYPE /bobf/t_frw_key,
          lt_fu_stops  TYPE /scmtms/t_tor_stop_k,
          lt_mod       TYPE /bobf/t_frw_modification,
          lo_trans_mgr TYPE REF TO /bobf/if_tra_transaction_mgr.

    DATA(lo_srv_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    lo_trans_mgr = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

    SELECT * FROM zdawc_trq_rel_da INTO TABLE @DATA(lt_trq_rel_data).

    READ TABLE lt_trq_rel_data INTO DATA(ls_trq_rel_data) INDEX 1.

    INSERT VALUE #( key = is_update-fu_key ) INTO TABLE lt_fu_keys.

    lo_srv_tor->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-stop
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fu_stops
        eo_message      = DATA(lo_mssg)
    ).

    LOOP AT lt_fu_stops ASSIGNING FIELD-SYMBOL(<fs_fu_stops>).
      IF <fs_fu_stops>-stop_id = '0000000010'.
        DATA(lv_src_loc_key) = NEW zcl_awc_location( )->get_loc_key_by_loc_id( iv_loc_id = is_update-src_location_id ).
        <fs_fu_stops>-adr_loc_uuid = lv_src_loc_key .
      ELSEIF <fs_fu_stops>-stop_id = '0000000020' AND is_update-btd_tco = ls_trq_rel_data-btd_tco_fwo.
        DATA(lv_des_loc_key) = NEW zcl_awc_location( )->get_loc_key_by_loc_id( iv_loc_id = is_update-des_location_id ).
        <fs_fu_stops>-adr_loc_uuid = lv_des_loc_key.
      ENDIF.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_update_multi(
      EXPORTING
        iv_node            = /scmtms/if_tor_c=>sc_node-stop
        it_data            = lt_fu_stops
        iv_autofill_fields = abap_false
      CHANGING
        ct_mod             = lt_mod
    ).

    lo_srv_tor->modify( lt_mod ).

*    lo_trans_mgr->save(
*      IMPORTING
*      ev_rejected = DATA(lv_rejected)
*    ).

  ENDMETHOD.


  METHOD update_fu.
    DATA: lt_fu_keys      TYPE /bobf/t_frw_key,
          lt_del_keys     TYPE /bobf/t_frw_key,
          lt_fu_root      TYPE /scmtms/t_tor_root_k,
          lt_fu_stop      TYPE /scmtms/t_tor_stop_k,
          lt_fu_item_data TYPE /scmtms/t_tor_item_tr_k,
          ls_fu_item      TYPE /scmtms/s_tor_item_tr_k,
          lt_fu_item      TYPE /scmtms/t_tor_item_tr_k,
          lt_mod          TYPE /bobf/t_frw_modification,
          lv_volume       TYPE /scmtms/qua_gro_vol_val VALUE 0,
          lv_weight       TYPE /scmtms/qua_gro_wei_val VALUE 0,
          lv_amount       TYPE i VALUE 0,
          lv_counter      TYPE i,
          lt_unique_ids   TYPE string_table.

    DATA(lo_srv_tor) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    INSERT VALUE #( key = is_update-fu_key ) INTO TABLE lt_fu_keys.

    lo_srv_tor->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
      IMPORTING
        et_data                 = lt_fu_root
    ).

    READ TABLE lt_fu_root INTO DATA(ls_fu_root) WITH KEY key = is_update-fu_key.

    lo_srv_tor->retrieve_by_association(
          EXPORTING
            iv_node_key             = /scmtms/if_tor_c=>sc_node-root
            it_key                  = lt_fu_keys
            iv_association          = /scmtms/if_tor_c=>sc_association-root-stop_first_and_last
            iv_fill_data            = abap_true
          IMPORTING
            et_data                 = lt_fu_stop
        ).

    DATA(lo_trq) = NEW zcl_awc_trq( ).

    LOOP AT lt_fu_stop ASSIGNING FIELD-SYMBOL(<ls_fu_stop>).
      IF <ls_fu_stop>-stop_cat EQ 'O'.
        <ls_fu_stop>-req_start  = zcl_awc_general=>convert_into_tz(
                                           iv_from_tz = is_update-src_time_zone_code
                                           iv_to_tz   = 'UTC'
                                           iv_from_ts = CONV #( is_update-pic_ear_req )
                                         ).
        <ls_fu_stop>-req_end    = zcl_awc_general=>convert_into_tz(
                                          iv_from_tz = is_update-src_time_zone_code
                                          iv_to_tz   = 'UTC'
                                          iv_from_ts = CONV #( is_update-pic_lat_req )
                                        ).
      ELSEIF <ls_fu_stop>-stop_cat EQ 'I'.
        <ls_fu_stop>-req_start  = zcl_awc_general=>convert_into_tz(
                                           iv_from_tz = is_update-des_time_zone_code
                                           iv_to_tz   = 'UTC'
                                           iv_from_ts = CONV #( is_update-del_ear_req )
                                         ).
        <ls_fu_stop>-req_end    = zcl_awc_general=>convert_into_tz(
                                          iv_from_tz = is_update-des_time_zone_code
                                          iv_to_tz   = 'UTC'
                                          iv_from_ts = CONV #( is_update-del_lat_req )
                                        ).
      ENDIF.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_update_multi(
      EXPORTING
        iv_node            = /scmtms/if_tor_c=>sc_node-stop
        it_data            = lt_fu_stop
        iv_autofill_fields = abap_false
      CHANGING
        ct_mod             = lt_mod
    ).

    lo_srv_tor->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_message      = DATA(lo_message)
    ).

    CLEAR lt_mod.

    lo_srv_tor->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_fu_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-item_tr
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_fu_item_data
    ).

    READ TABLE lt_fu_item_data INTO DATA(ls_fu_item_fur) WITH KEY item_cat = 'FUR'.

    LOOP AT lt_fu_item_data ASSIGNING FIELD-SYMBOL(<ls_fu_item_data>) WHERE key NE ls_fu_item_fur-key AND item_cat = 'PKG'.
      READ TABLE is_update-trq_item INTO DATA(ls_update) WITH KEY item_key = <ls_fu_item_data>-key .
      IF sy-subrc <> 0.
        INSERT VALUE #( key = <ls_fu_item_data>-key ) INTO TABLE lt_del_keys.
        ls_fu_root-zz_qty_chg_portal = 'X'.
      ENDIF.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_delete_multi(
      EXPORTING
        iv_node       = /scmtms/if_tor_c=>sc_node-item_tr
        it_keys       = lt_del_keys
      CHANGING
        ct_mod        = lt_mod
    ).

    LOOP AT lt_del_keys ASSIGNING FIELD-SYMBOL(<ls_del_key>).
      LOOP AT lt_fu_item_data ASSIGNING <ls_fu_item_data> WHERE item_parent_key = <ls_del_key>-key.
        <ls_fu_item_data>-item_parent_key = ls_fu_item_fur-key.
        <ls_fu_item_data>-length = 0.
        <ls_fu_item_data>-height = 0.
        <ls_fu_item_data>-width  = 0.
        <ls_fu_item_data>-gro_wei_val = 0.
        <ls_fu_item_data>-gro_vol_val = 0.
        <ls_fu_item_data>-qua_pcs_val = 0.

        INSERT <ls_fu_item_data> INTO TABLE lt_fu_item.
      ENDLOOP.
    ENDLOOP.

    LOOP AT lt_fu_item_data ASSIGNING <ls_fu_item_data> WHERE key NE ls_fu_item_fur-key AND item_cat NE 'PRD'.
      LOOP AT is_update-trq_item ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE item_key = <ls_fu_item_data>-key.
        <ls_fu_item_data>-qua_pcs_val = <ls_item>-qua_pcs_val.
        <ls_fu_item_data>-qua_pcs_uni = <ls_item>-qua_pcs_uni.

        <ls_fu_item_data>-measuom = <ls_item>-measuom.
        <ls_fu_item_data>-length = <ls_item>-length.
        <ls_fu_item_data>-height = <ls_item>-height.
        <ls_fu_item_data>-width = <ls_item>-width.

        <ls_fu_item_data>-gro_wei_val = <ls_item>-gro_wei_val * <ls_item>-qua_pcs_val.
        <ls_fu_item_data>-gro_wei_uni = <ls_item>-gro_wei_uni.

        <ls_fu_item_data>-gro_vol_val = <ls_item>-gro_vol_val.
        <ls_fu_item_data>-gro_vol_uni = <ls_item>-gro_vol_uni.
        <ls_fu_item_data>-zz_stackability = <ls_item>-maxstack.

*        DATA(lv_fu_prd_id) = <ls_item>-prd_id.
*        SHIFT lv_fu_prd_id LEFT DELETING LEADING '0'.
*
*        <ls_fu_item_data>-item_descr  = lv_fu_prd_id.
*        <ls_fu_item_data>-product_id  = lv_fu_prd_id.

        INSERT <ls_fu_item_data> INTO TABLE lt_fu_item.
      ENDLOOP.
    ENDLOOP.

    LOOP AT is_update-trq_item ASSIGNING <ls_item> WHERE item_cat NE 'PRD'.
      lv_volume = lv_volume + ( <ls_item>-height * <ls_item>-width * <ls_item>-length * <ls_item>-qua_pcs_val ).
      lv_weight = lv_weight + ( <ls_item>-gro_wei_val * <ls_item>-qua_pcs_val ).
      lv_amount = lv_amount + <ls_item>-qua_pcs_val.
    ENDLOOP.

    ls_fu_item_fur-gro_vol_val = lv_volume.
    ls_fu_item_fur-gro_wei_val = lv_weight.
    ls_fu_item_fur-qua_pcs_val = lv_amount.

    ls_fu_root-gro_vol_val = lv_volume.
    ls_fu_root-gro_wei_val = lv_weight.
    ls_fu_root-qua_pcs_val = lv_amount.

    INSERT ls_fu_item_fur INTO TABLE lt_fu_item.

    /scmtms/cl_mod_helper=>mod_update_multi(
      EXPORTING
      iv_node        = /scmtms/if_tor_c=>sc_node-item_tr
      it_data        = lt_fu_item
        iv_autofill_fields = abap_false
      CHANGING
        ct_mod             = lt_mod
    ).

    lo_srv_tor->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_message      = DATA(lo_mesage)
    ).

    CLEAR lt_mod.
    CLEAR lt_fu_item.

    DATA(lo_mat) = NEW zcl_awc_material( ).

    LOOP AT is_update-trq_item ASSIGNING <ls_item> WHERE item_key IS INITIAL.
      lv_counter = 1.

      ls_fu_item-key = lo_srv_tor->get_new_key( ).
      ls_fu_item-root_key = is_update-fu_key.
      ls_fu_item-parent_key = is_update-fu_key.
      ls_fu_item-item_parent_key = ls_fu_item_fur-key.

      ls_fu_item-qua_pcs_val = <ls_item>-qua_pcs_val.
      ls_fu_item-qua_pcs_uni = 'PAL'.

      ls_fu_item-measuom = <ls_item>-measuom.
      ls_fu_item-length = <ls_item>-length.
      ls_fu_item-height = <ls_item>-height.
      ls_fu_item-width = <ls_item>-width.

      ls_fu_item-gro_wei_val = <ls_item>-gro_wei_val  * <ls_item>-qua_pcs_val.
      ls_fu_item-gro_wei_uni = <ls_item>-gro_wei_uni.

      ls_fu_item-gro_vol_val = <ls_item>-gro_vol_val.
      ls_fu_item-gro_vol_uni = <ls_item>-gro_vol_uni.
      ls_fu_item-zz_stackability = <ls_item>-maxstack.

      DATA(lv_prd_id) = <ls_item>-prd_id.
      SHIFT lv_prd_id LEFT DELETING LEADING '0'.

      DATA(lv_prd_id_unique) = |{ lv_prd_id }_{ lv_counter }|.

      WHILE line_exists( is_update-trq_item[ prd_id = lv_prd_id_unique ] ) OR line_exists( lt_unique_ids[ table_line = lv_prd_id_unique ] ).
        ADD 1 TO lv_counter.
        lv_prd_id_unique = |{ lv_prd_id }_{ lv_counter }|.
      ENDWHILE.

      ls_fu_item-main_cargo_item = abap_true.
      ls_fu_item-item_descr      = lv_prd_id.
      ls_fu_item-item_cat        = ms_trq_rel_data-item_cat.
      ls_fu_item-item_type       = ms_trq_rel_data-item_cat.

" ToDo
*      DATA(lv_pkg_tco) = lo_mat->get_pkg_tco_by_prd_id( lv_prd_id ).
*      IF lv_pkg_tco IS NOT INITIAL.
*        ls_fu_item-package_tco  = lv_pkg_tco.
*      ENDIF.

      ls_fu_item-package_id      = lv_prd_id_unique.
      APPEND lv_prd_id_unique TO lt_unique_ids.

      INSERT ls_fu_item INTO TABLE lt_fu_item.
      ls_fu_root-zz_qty_chg_portal = 'X'.
    ENDLOOP.

    /scmtms/cl_mod_helper=>mod_create_multi(
      EXPORTING
        iv_node        = /scmtms/if_tor_c=>sc_node-item_tr
        it_data        = lt_fu_item
        iv_association = /scmtms/if_tor_c=>sc_association-root-item_tr
        iv_source_node = /scmtms/if_tor_c=>sc_node-root
      CHANGING
        ct_mod         = lt_mod
     ).

    /scmtms/cl_mod_helper=>mod_update_single(
      EXPORTING
        is_data            = ls_fu_root
        iv_node            = /scmtms/if_tor_c=>sc_node-root
        iv_autofill_fields = abap_false
      CHANGING
        ct_mod             = lt_mod
    ).

    lo_srv_tor->modify(
      EXPORTING
        it_modification = lt_mod
      IMPORTING
        eo_message      = DATA(lo_msage)
    ).

    set_add_address( is_update = is_update ).

    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
         EXPORTING
           iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
         IMPORTING
           eo_message             = lo_message
       ).

    new zcl_awc_general( )->check_bopf_messages( lo_message ).

    update_text_from_fu(
      EXPORTING
        iv_fu_key            = CONV #( is_update-fu_key )   " NodeID
        iv_reference_nr      = is_update-reference_nr    " Textinhalt
        iv_shipping_noti_nr  = is_update-shipping_noti_nr    " Textinhalt
        iv_shipping_noti_doc = is_update-shipping_noti_doc    " Textinhalt
        iv_add_note          = is_update-add_note
    ).
  ENDMETHOD.


  METHOD update_text_from_fu.
    TYPES key_range TYPE RANGE OF /bobf/conf_key.

    DATA: lr_text_keys    TYPE key_range,
          ls_text         TYPE /bobf/d_txctxt,
          ls_text_content TYPE /bobf/d_txccon.

    DATA(lo_attachment) = NEW zcl_awc_attachment( ).

    SELECT SINGLE * FROM /bobf/d_txcroot INTO @DATA(ls_text_root) WHERE host_key = @iv_fu_key.
    IF ls_text_root IS INITIAL.
      lo_attachment->add_notes(
        EXPORTING
          iv_reference_nr      = iv_reference_nr
          iv_shipping_noti_nr  = iv_shipping_noti_nr
          iv_shipping_noti_doc = iv_shipping_noti_doc
          iv_add_note          = iv_add_note
          iv_fu_root_key       = iv_fu_key
      ).
    ENDIF.
    SELECT * FROM /bobf/d_txctxt INTO TABLE @DATA(lt_text) WHERE parent_key = @ls_text_root-db_key.

    IF lt_text IS INITIAL.
      EXIT.
    ENDIF.

    LOOP AT lt_text ASSIGNING FIELD-SYMBOL(<ls_text>).
      INSERT VALUE #( sign = 'I' option = 'EQ' low = <ls_text>-db_key ) INTO TABLE lr_text_keys.
    ENDLOOP.
    SELECT * FROM /bobf/d_txccon INTO TABLE @DATA(lt_text_content) WHERE parent_key IN @lr_text_keys.

    IF lt_text_content IS INITIAL.
      EXIT.
    ENDIF.

    READ TABLE lt_text INTO ls_text WITH KEY text_type = ms_add_info-reference_nr.
    IF ls_text IS NOT INITIAL.
      READ TABLE lt_text_content INTO ls_text_content WITH KEY parent_key = ls_text-db_key.
      IF ls_text_content IS NOT INITIAL.
        ls_text_content-text = iv_reference_nr.
        UPDATE /bobf/d_txccon FROM ls_text_content.
      ENDIF.
    ELSE.
      lo_attachment->add_note(
        EXPORTING
          iv_text_type = ms_add_info-reference_nr " Textart
          iv_text      = iv_reference_nr    " Textinhalt
          iv_fu_key    = iv_fu_key   " NodeID
      ).
    ENDIF.

    READ TABLE lt_text INTO ls_text WITH KEY text_type = ms_add_info-shipping_noti_doc.
    IF ls_text IS NOT INITIAL.
      READ TABLE lt_text_content INTO ls_text_content WITH KEY parent_key = ls_text-db_key.
      IF ls_text_content IS NOT INITIAL.
        ls_text_content-text = iv_shipping_noti_doc.
        UPDATE /bobf/d_txccon FROM ls_text_content.
      ENDIF.
    ELSE.
      lo_attachment->add_note(
        EXPORTING
          iv_text_type = ms_add_info-shipping_noti_doc  " Textart
          iv_text      = iv_shipping_noti_doc   " Textinhalt
          iv_fu_key    = iv_fu_key    " NodeID
      ).
    ENDIF.

    READ TABLE lt_text INTO ls_text WITH KEY text_type = ms_add_info-shipping_noti_nr.
    IF ls_text IS NOT INITIAL.
      READ TABLE lt_text_content INTO ls_text_content WITH KEY parent_key = ls_text-db_key.
      IF ls_text_content IS NOT INITIAL.
        ls_text_content-text = iv_shipping_noti_nr.
        UPDATE /bobf/d_txccon FROM ls_text_content.
      ENDIF.
    ELSE.
      lo_attachment->add_note(
         EXPORTING
           iv_text_type = ms_add_info-shipping_noti_nr  " Textart
           iv_text      = iv_shipping_noti_nr   " Textinhalt
           iv_fu_key    = iv_fu_key    " NodeID
       ).
    ENDIF.

    READ TABLE lt_text INTO ls_text WITH KEY text_type = ms_add_info-add_note.
    IF ls_text IS NOT INITIAL.
      READ TABLE lt_text_content INTO ls_text_content WITH KEY parent_key = ls_text-db_key.
      IF ls_text_content IS NOT INITIAL.
        ls_text_content-text = iv_add_note.
        UPDATE /bobf/d_txccon FROM ls_text_content.
      ENDIF.
    ELSE.
      lo_attachment->add_note(
        EXPORTING
          iv_text_type  = ms_add_info-add_note
          iv_text       = iv_add_note
          iv_fu_key     = iv_fu_key
       ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
