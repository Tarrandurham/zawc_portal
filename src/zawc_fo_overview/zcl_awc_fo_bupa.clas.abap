class ZCL_AWC_FO_BUPA definition
  public
  final
  create public .

public section.

  methods GET_BUPA
    importing
      !IT_BUPA_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_BUPA_DATA type /BOFU/T_BUPA_ROOT_K .
  methods GET_CONTACT_INFO
    importing
      !IT_BUPA_KEYS type /BOBF/T_FRW_KEY
    returning
      value(RT_BUPA_CONTACT) type ZAWC_T_BUPA_CONTACT .
  methods CONSTRUCTOR .
protected section.
private section.

  class-data GO_BUPA_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  class-data GO_BUPA_ADDR_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  class-data GO_CONF type ref to /BOBF/IF_FRW_CONFIGURATION .
  data GO_TRANSACTION_MGR type ref to /BOBF/IF_TRA_TRANSACTION_MGR .
  class-data GO_SCMTMS_BUPA_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
ENDCLASS.



CLASS ZCL_AWC_FO_BUPA IMPLEMENTATION.


  METHOD constructor.

    go_bupa_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /bofu/if_bupa_constants=>sc_bo_key ).
    go_conf = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /bofu/if_bupa_constants=>sc_bo_key ).
    go_transaction_mgr = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

    go_scmtms_bupa_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /bofu/if_bupa_constants=>sc_bo_key ).

  ENDMETHOD.


  METHOD get_bupa.

    DATA: lt_bupa_keys TYPE /bobf/t_frw_key,
          lt_bupa_data TYPE /bofu/t_bupa_root_k.

*    INSERT VALUE #( key = iv_bupa_key ) INTO TABLE lt_bupa_keys.

    go_bupa_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-root
        it_key                  = it_bupa_key
*          iv_before_image         = ABAP_FALSE
*          iv_edit_mode            =
        iv_fill_data            = abap_true
*          iv_invalidate_cache     = ABAP_FALSE
*          it_requested_attributes =
        IMPORTING
*          eo_message              =
*          eo_change               =
          et_data                 = lt_bupa_data
*          et_failed_key           =
    ).

    et_bupa_data = lt_bupa_data.

*    READ TABLE lt_bupa_data INDEX 1 INTO es_bupa_data.
  ENDMETHOD.


  METHOD get_contact_info.

    DATA: lt_addressinformation_keys TYPE /bobf/t_frw_key,
          lt_email_data              TYPE /bofu/t_addr_emailk,
          lt_telephone_data          TYPE /bofu/t_addr_telephonek,
          lt_address_data            TYPE /bobf/t_epm_address_root,
          lt_address_keys            TYPE /bobf/t_frw_key,
          lt_bupa_contact            TYPE zawc_t_bupa_contact.

    FIELD-SYMBOLS: <fs_email_data>     TYPE /bofu/s_addr_emailk,
                   <fs_telephone_data> TYPE /bofu/s_addr_telephonek.

    go_bupa_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-root
        it_key                  = it_bupa_keys
        iv_association          = /bofu/if_bupa_constants=>sc_association-root-addressinformation
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
        et_target_key           = lt_addressinformation_keys
*        et_failed_key           =
    ).

    go_bupa_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-addressinformation
        it_key                  = lt_addressinformation_keys
        iv_association          = /bofu/if_bupa_constants=>sc_association-addressinformation-address
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
        et_target_key           = lt_address_keys
*        et_failed_key           =
    ).

    DATA(lv_address_to_email_assoc) = go_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bofu/if_addr_constants=>sc_association-root-email
                   iv_do_root_node_key = /bofu/if_bupa_constants=>sc_node-/bofu/address ).

    DATA(lv_address_to_phone_assoc) = go_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bofu/if_addr_constants=>sc_association-root-telephone
                   iv_do_root_node_key = /bofu/if_bupa_constants=>sc_node-/bofu/address ).

    go_bupa_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-/bofu/address
        it_key                  = lt_address_keys
        iv_association          = lv_address_to_email_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_email_data
     ).

    go_bupa_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /bofu/if_bupa_constants=>sc_node-/bofu/address
        it_key                  = lt_address_keys
        iv_association          = lv_address_to_phone_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_telephone_data
     ).

    LOOP AT lt_email_data ASSIGNING <fs_email_data>.
      LOOP AT lt_telephone_data ASSIGNING <fs_telephone_data> WHERE root_key = <fs_email_data>-root_key.
        INSERT VALUE #( key = <fs_email_data>-root_key
                        email = <fs_email_data>-uri
                        telephone = <fs_telephone_data>-formatted_number_text ) INTO TABLE rt_bupa_contact.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
