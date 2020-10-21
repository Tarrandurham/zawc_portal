class ZCL_AWC_FO_LOCATION definition
  public
  final
  create public .

public section.

  methods GET_LOC_BY_UUID
    importing
      !IV_LOC_UUID type /SCMTMS/LOCUUID
    exporting
      !ES_LOC_DATA type /SCMTMS/S_BO_LOC_ROOT_K .
  methods GET_ADDR_BY_LOC
    importing
      !IT_LOC_UUID type /BOBF/T_FRW_KEY
    exporting
      !ET_LOC_DATA type ZAWC_T_FO_LOC .
  methods CONSTRUCTOR .
protected section.
private section.

  class-data GO_LOC_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  class-data GO_TOR_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .

  methods GET_LOC_KEY_BY_LOC_ID
    importing
      !IV_LOC_UUID type /SCMTMS/LOCUUID
    returning
      value(RV_LOC_KEY) type /BOBF/CONF_KEY .
ENDCLASS.



CLASS ZCL_AWC_FO_LOCATION IMPLEMENTATION.


  method CONSTRUCTOR.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    go_loc_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

  endmethod.


  METHOD get_addr_by_loc.

    DATA: lt_loc_keys     TYPE /bobf/t_frw_key,
          lt_geo_inf_keys TYPE /bobf/t_frw_key,
          lt_geo_inf      TYPE /scmtms/t_bo_loc_geoinfo_k,
          lt_addr_details TYPE /scmtms/t_bo_loc_addr_detailsk,
          lt_loc_data TYPE /scmtms/t_bo_loc_root_k.

*    DATA(lv_loc_key) = get_loc_key_by_loc_id( iv_loc_uuid = iv_loc_uuid ).

*    INSERT VALUE #( key = lv_loc_key ) INTO TABLE lt_loc_keys.

    go_loc_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = it_loc_uuid
*        iv_before_image         = abap_false
*        iv_edit_mode            = /bobf/if_conf_c=>sc_edit_read_only
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = abap_false
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_loc_data
*        et_failed_key           =
    ).
*    CATCH /bobf/cx_frw_contrct_violation.

    go_loc_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = it_loc_uuid
        iv_association          = /scmtms/if_location_c=>sc_association-root-selected_address_details
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
        et_data                 = lt_addr_details
*        et_key_link             =
*        et_target_key           =
*        et_failed_key           =
    ).


*    LOOP AT lt_geo_inf ASSIGNING FIELD-SYMBOL(<fs_geo_inf>).
*      INSERT VALUE #( key = <fs_geo_inf>-key ) INTO TABLE lt_geo_inf_keys.
*    ENDLOOP.
*
*
*    go_loc_srv_mgr->retrieve_by_association(
*      EXPORTING
*        iv_node_key             = /scmtms/if_location_c=>sc_node-geographical_information
*        it_key                  = lt_geo_inf_keys
*        iv_association          = /scmtms/if_location_c=>sc_association-geographical_information-selected_address_details
**        is_parameters           =
**        it_filtered_attributes  =
*        iv_fill_data            = abap_true
**        iv_before_image         = ABAP_FALSE
**        iv_invalidate_cache     = ABAP_FALSE
**        iv_edit_mode            =
**        it_requested_attributes =
*      IMPORTING
**        eo_message              =
**        eo_change               =
*        et_data                 = lt_addr_details
**        et_key_link             =
**        et_target_key           =
**        et_failed_key           =
*    ).

    LOOP AT lt_loc_data ASSIGNING FIELD-SYMBOL(<fs_loc_data>).
      READ TABLE lt_addr_details ASSIGNING FIELD-SYMBOL(<fs_addr_details>) WITH KEY parent_key = <fs_loc_data>-key.
      INSERT VALUE #( name1               = <fs_addr_details>-name1
                      country_code        = <fs_addr_details>-country_code
                      region              = <fs_addr_details>-region
                      city_name           = <fs_addr_details>-city_name
                      street_postal_code  = <fs_addr_details>-street_postal_code
                      street_name         = <fs_addr_details>-street_name
                      house_id            = <fs_addr_details>-house_id
                      time_zone_code      = <fs_loc_data>-time_zone_code
                      loc_uuid            = <fs_addr_details>-parent_key
                      ) INTO TABLE et_loc_data.
    ENDLOOP.
*    READ TABLE lt_addr_details INDEX 1 INTO DATA(ls_addr_details).
*    MOVE-CORRESPONDING ls_addr_details TO es_loc_data.
*    MOVE-CORRESPONDING ls_geo_inf to es_loc_data.

  ENDMETHOD.


  METHOD get_loc_by_uuid.

    DATA: lt_loc_data TYPE /scmtms/t_bo_loc_root_k,
          lt_loc_keys TYPE /bobf/t_frw_key.

    INSERT VALUE #( key = iv_loc_uuid ) INTO TABLE lt_loc_keys.

    go_loc_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = lt_loc_keys
*        iv_before_image         = ABAP_FALSE
*        iv_edit_mode            =
        iv_fill_data            = abap_true
*        iv_invalidate_cache     = ABAP_FALSE
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        eo_change               =
        et_data                 = lt_loc_data
*        et_failed_key           =
    ).

    READ TABLE lt_loc_data INDEX 1 INTO es_loc_data.

  ENDMETHOD.


  METHOD get_loc_key_by_loc_id.

    DATA lt_selpar TYPE /bobf/t_frw_query_selparam.

    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = iv_loc_uuid
                    attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_identifier-uuid
                    ) INTO TABLE lt_selpar.

    lo_srv_loc->query(
        EXPORTING
          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_identifier
          it_selection_parameters = lt_selpar
        IMPORTING
          et_key                  = DATA(lt_loc_key)
      ).
    READ TABLE lt_loc_key INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_loc_key>).
    IF sy-subrc = 0.
      rv_loc_key = <ls_loc_key>-key.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
