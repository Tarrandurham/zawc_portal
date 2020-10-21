class ZCL_AWC_LOCATION definition
  public
  final
  create public .

public section.

  methods GET_LOCATION
    importing
      !IV_LOC_KEY type /BOBF/CONF_KEY
    exporting
      !ES_AWC_LOC type ZSAWC_LOCATION .
  methods GET_LOC_KEY_BY_LOC_ID
    importing
      !IV_LOC_ID type /SCMTMS/LOCATION_ID
    returning
      value(RV_LOC_KEY) type /BOBF/CONF_KEY .
  methods GET_SRC_LOC_BY_BP
    exporting
      !ET_AWC_LOC type ZT_AWC_LOCATION .
  methods GET_DES_LOC
    exporting
      !ET_AWC_LOC type ZT_AWC_DES_LOC .
  methods GET_DES_LOC_BY_SRC_LOC
    importing
      !IV_SRC_LOC_KEY type ZAWC_KEY
    exporting
      !ET_AWC_LOC type ZT_AWC_DES_LOC .
  methods GET_LOC_DATA
    importing
      !IT_LOC_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_LOC_DATA type /SCMTMS/T_BO_LOC_ROOT_K .
  methods GET_ADRESS_INFO
    importing
      !IT_LOC_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_LOC_ADRESS type /SCMTMS/T_BO_LOC_ADDR_DETAILSK
      !ET_GEO_ADRESS_KEY_LINK type /BOBF/T_FRW_KEY_LINK .
  methods CONSTRUCTOR .
  methods GET_DAYS_OPEN
    importing
      !IV_LOC_KEY type ZAWC_KEY
    exporting
      !ET_DAYS_OPEN type ZT_AWC_DAYS_OPEN .
  methods GET_TRANSIT_TIME
    exporting
      !ET_TRANSIT_TIME type ZT_AWC_TRANSIT_TIME .
  PROTECTED SECTION.
private section.

  data MS_OTH_REL_DATA type ZDAWC_OTH_REL_DA .
ENDCLASS.



CLASS ZCL_AWC_LOCATION IMPLEMENTATION.


  METHOD constructor.

    SELECT  * FROM zdawc_oth_rel_da
      INTO TABLE @DATA(lt_oth_rel_data).

    READ TABLE lt_oth_rel_data INTO ms_oth_rel_data INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_oth_rel_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_adress_info.
    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    lo_srv_loc->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = it_loc_key
        iv_association          = /SCMTMS/IF_LOCATION_C=>sc_association-root-selected_address_details
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = et_loc_adress
        et_key_link             = et_geo_adress_key_link
    ).
  ENDMETHOD.


  METHOD get_days_open.
    DATA(lv_loc_id) = /scmtms/cl_loc_helper=>return_ident_for_loc_key( CONV #( iv_loc_key ) ).

    TRY .
        DATA(ls_res) = zcl_4flow_apo_res_acc=>mo_acc->fetch_res_by_name_and_type(
                     iv_name = CONV #( lv_loc_id )
                     iv_type = '10'
                   ).

      CATCH zcx_4flow_apo_res_acc.
        ls_res = zcl_4flow_apo_res_acc=>mo_acc->fetch_res_by_name_and_type(
                        iv_name = 'HOLIDAY_4FLOW'
                        iv_type = '10'
                      ).
    ENDTRY.

    zcl_4flow_apo_res_acc=>mo_acc->retrieve_timelist_from_res(
      EXPORTING
        iv_resuid    = ls_res-resuid
      IMPORTING
        et_timelist  = DATA(lt_timelist)
    ).

    LOOP AT lt_timelist ASSIGNING FIELD-SYMBOL(<ls_timelist>).
      IF <ls_timelist>-begda >= sy-datum.
        INSERT VALUE #( dates     = <ls_timelist>-begda
                        loc_key   = iv_loc_key
                        location_id = lv_loc_id
                      ) INTO TABLE et_days_open.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_des_loc.
    DATA: lt_loc_data     TYPE /scmtms/t_bo_loc_root_k,
          lt_awc_location TYPE zt_awc_des_loc.

    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    lo_srv_loc->query(
        EXPORTING
          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_identifier
        IMPORTING
          et_key                  = DATA(lt_loc_key)
      ).

    lo_srv_loc->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = lt_loc_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_loc_data
    ).

*    lo_srv_loc->retrieve_by_association(
*      EXPORTING
*        iv_node_key             = /scmtms/if_location_c=>sc_node-root
*        it_key                  = lt_loc_key
*        iv_association          = /scmtms/if_location_c=>sc_association-root-geographical_information
*        iv_fill_data            = abap_false
*      IMPORTING
*        et_key_link             = DATA(lt_loc_geo_key_link)
*        et_target_key           = DATA(lt_loc_geo_key)
*    ).
*
*    lo_srv_loc->retrieve_by_association(
*      EXPORTING
*        iv_node_key             = /scmtms/if_location_c=>sc_node-geographical_information
*        it_key                  = lt_loc_geo_key
*        iv_association          = /scmtms/if_location_c=>sc_association-geographical_information-selected_address_details
*        iv_fill_data            = abap_true
*      IMPORTING
*        et_data                 = lt_loc_adress
*        et_key_link             = DATA(lt_geo_adress_key_link)
*    ).

    get_adress_info(
      EXPORTING
        it_loc_key             = lt_loc_key
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
    ).

    SELECT * FROM z4flow_ddd_inb INTO TABLE @DATA(lt_4flow_dddt).

    LOOP AT lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_loc_data>).
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_key_link>) WITH KEY source_key = <ls_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_loc_adress>) WITH KEY root_key = <ls_key_link>-target_key.
          IF sy-subrc = 0.
            READ TABLE lt_4flow_dddt INTO DATA(ls_4flow_dddt) WITH KEY dest_loc = <ls_loc_data>-location_id.
            IF sy-subrc = 0.
              READ TABLE lt_loc_data INTO DATA(ls_loc_data_for_des) WITH KEY location_id = ls_4flow_dddt-sour_loc.
              IF sy-subrc = 0.
                INSERT VALUE #( key                 = <ls_loc_data>-key
                                location_id         = <ls_loc_data>-location_id
                                name1               = <ls_loc_adress>-name1
                                country_code        = <ls_loc_adress>-country_code
                                region              = <ls_loc_adress>-region
                                city_name           = <ls_loc_adress>-city_name
                                street_postal_code  = <ls_loc_adress>-street_postal_code
                                street_name         = <ls_loc_adress>-street_name
                                house_id            =  <ls_loc_adress>-house_id
                                time_zone_code      = <ls_loc_data>-time_zone_code
                                src_loc_key         = ls_loc_data_for_des-key
                ) INTO TABLE lt_awc_location.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
    ENDLOOP.

    et_awc_loc = lt_awc_location.

  ENDMETHOD.


  METHOD get_des_loc_by_src_loc.
    DATA: lt_des_loc_key  TYPE /bobf/t_frw_key,
          lt_selpar       TYPE /scmtms/cl_loc_helper=>ty_t_locno_range,
          lt_awc_location TYPE zt_awc_des_loc.

    "get the LocationId from LocUUID
    DATA(iv_src_loc_id) = /scmtms/cl_loc_helper=>return_ident_for_loc_key( CONV #( iv_src_loc_key ) ).

    "Get the destination locations from the source location
    SELECT * FROM z4flow_ddd_inb INTO TABLE @DATA(lt_4flow_dddt) WHERE sour_loc = @iv_src_loc_id AND valid_to >= @sy-datum.

    LOOP AT lt_4flow_dddt ASSIGNING FIELD-SYMBOL(<ls_4flow_dddt>).
      INSERT VALUE #( sign            = 'I'
                      option          = 'EQ'
                       low            = <ls_4flow_dddt>-dest_loc
                    ) INTO TABLE lt_selpar.
    ENDLOOP.

    /scmtms/cl_loc_helper=>get_locations_by_locno(
      EXPORTING
        it_locno_range = lt_selpar
      IMPORTING
        et_locations   = DATA(lt_des_loc)
    ).

    LOOP AT lt_des_loc ASSIGNING FIELD-SYMBOL(<ls_des_loc>).
      APPEND INITIAL LINE TO lt_des_loc_key ASSIGNING FIELD-SYMBOL(<ls_des_loc_key>).
      <ls_des_loc_key>-key = <ls_des_loc>-locuuid.
    ENDLOOP.

    get_loc_data(
      EXPORTING
        it_loc_key  = lt_des_loc_key
      IMPORTING
        et_loc_data = DATA(lt_loc_data)
    ).


    get_adress_info(
      EXPORTING
        it_loc_key             = lt_des_loc_key
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
    ).

    "Loop at the destination locations and fill the structure for odata entity
    LOOP AT lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_loc_data>).
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_key_link>) WITH KEY source_key = <ls_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_loc_adress>) WITH KEY key = <ls_key_link>-target_key.
          IF sy-subrc = 0.
            INSERT VALUE #( key                 = <ls_loc_data>-key
                            location_id         = <ls_loc_data>-location_id
                            name1               = <ls_loc_adress>-name1
                            country_code        = <ls_loc_adress>-country_code
                            region              = <ls_loc_adress>-region
                            city_name           = <ls_loc_adress>-city_name
                            street_postal_code  = <ls_loc_adress>-street_postal_code
                            street_name         = <ls_loc_adress>-street_name
                            house_id            = <ls_loc_adress>-house_id
                            time_zone_code      = <ls_loc_data>-time_zone_code
                            src_loc_key         = iv_src_loc_key
            ) INTO TABLE lt_awc_location.
          ENDIF.
      ENDIF.
    ENDLOOP.

    et_awc_loc = lt_awc_location.
  ENDMETHOD.


  METHOD get_location.
    DATA: lt_loc_key      TYPE /bobf/t_frw_key,
          lt_loc_data     TYPE /scmtms/t_bo_loc_root_k,
          ls_awc_location TYPE zsawc_location.

    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_loc_key ) INTO TABLE lt_loc_key.

    lo_srv_loc->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = lt_loc_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_loc_data
    ).

    get_adress_info(
      EXPORTING
        it_loc_key             = lt_loc_key
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
    ).

    LOOP AT lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_loc_data>).
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_key_link>) WITH KEY source_key = <ls_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_loc_adress>) WITH KEY key = <ls_key_link>-target_key.
          IF sy-subrc = 0.
            ls_awc_location = VALUE #( key                = <ls_loc_data>-key
                                       location_id        = <ls_loc_data>-location_id
                                       name1              = <ls_loc_adress>-name1
                                       country_code       = <ls_loc_adress>-country_code
                                       region             = <ls_loc_adress>-region
                                       city_name          = <ls_loc_adress>-city_name
                                       street_postal_code = <ls_loc_adress>-street_postal_code
                                       street_name        = <ls_loc_adress>-street_name
                                       house_id           =  <ls_loc_adress>-house_id
                                       time_zone_code     = <ls_loc_data>-time_zone_code
            ).
          ENDIF.
        ENDIF.
    ENDLOOP.

    es_awc_loc = ls_awc_location.

  ENDMETHOD.


  METHOD get_loc_data.
    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    lo_srv_loc->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_location_c=>sc_node-root
        it_key                  = it_loc_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = et_loc_data
    ).
  ENDMETHOD.


  METHOD get_loc_key_by_loc_id.
    DATA lt_selpar TYPE /bobf/t_frw_query_selparam.

    DATA(lo_srv_loc) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_location_c=>sc_bo_key ).

    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = iv_loc_id
                    attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_identifier-location_id
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


  METHOD get_src_loc_by_bp.
    DATA lt_selpar  TYPE        /bobf/t_frw_query_selparam.
    DATA lt_bp      TYPE        /scmtms/t_bupa_q_uname_result.
    DATA lt_bp_data TYPE        /bofu/t_bupa_root_k.
    DATA lt_bp_rel  TYPE        /bofu/t_bupa_relship_k.
    DATA lt_awc_location TYPE zt_awc_location.

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
      IF <ls_bp_rel>-relationshipcategory EQ ms_oth_rel_data-bp_realship. "zif_awc_constants=>c_bp_realship.
        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = <ls_bp_rel>-relshp_partner
                        attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_business_partne-business_partner_id
                    ) INTO TABLE lt_selpar.
      ENDIF.
    ENDLOOP.

    IF lt_selpar IS INITIAL.
      RETURN.
    ENDIF.

    lo_srv_loc->query(
        EXPORTING
          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_business_partne
          it_selection_parameters = lt_selpar
        IMPORTING
          et_key                  = DATA(lt_loc_key)
      ).

    get_loc_data(
      EXPORTING
        it_loc_key  = lt_loc_key
      IMPORTING
        et_loc_data = DATA(lt_loc_data)
    ).

    get_adress_info(
      EXPORTING
        it_loc_key             = lt_loc_key
      IMPORTING
        et_loc_adress          = DATA(lt_loc_adress)
        et_geo_adress_key_link = DATA(lt_key_link)
    ).

    LOOP AT lt_loc_data ASSIGNING FIELD-SYMBOL(<ls_loc_data>).
      READ TABLE lt_key_link ASSIGNING FIELD-SYMBOL(<ls_key_link>) WITH KEY source_key = <ls_loc_data>-root_key.
      IF sy-subrc = 0.
          READ TABLE lt_loc_adress ASSIGNING FIELD-SYMBOL(<ls_loc_adress>) WITH KEY key = <ls_key_link>-target_key.
          IF sy-subrc = 0.
            INSERT VALUE #( key                = <ls_loc_data>-key
                            location_id        = <ls_loc_data>-location_id
                            name1              = <ls_loc_adress>-name1
                            country_code       = <ls_loc_adress>-country_code
                            region             = <ls_loc_adress>-region
                            city_name          = <ls_loc_adress>-city_name
                            street_postal_code = <ls_loc_adress>-street_postal_code
                            street_name        = <ls_loc_adress>-street_name
                            house_id           = <ls_loc_adress>-house_id
                            time_zone_code     = <ls_loc_data>-time_zone_code
            ) INTO TABLE lt_awc_location.
          ENDIF.
        ENDIF.
    ENDLOOP.

    et_awc_loc = lt_awc_location.
  ENDMETHOD.


  METHOD get_transit_time.

    TYPES:
      BEGIN OF ts_loc_id,
        id TYPE /scmtms/location_id,
      END OF ts_loc_id .

    TYPES:
      tt_loc_id TYPE STANDARD TABLE OF ts_loc_id WITH KEY id.

    DATA: lt_selpar  TYPE        /bobf/t_frw_query_selparam,
          lt_bp      TYPE        /scmtms/t_bupa_q_uname_result,
          lt_bp_data TYPE        /bofu/t_bupa_root_k,
          lt_bp_rel  TYPE        /bofu/t_bupa_relship_k,
          lt_loc_id  TYPE tt_loc_id.

    DATA lr_loc_id TYPE RANGE OF /scmtms/source_location.



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
      IF <ls_bp_rel>-relationshipcategory EQ ms_oth_rel_data-bp_realship. "zif_awc_constants=>c_bp_realship.
        INSERT VALUE #( sign            = 'I'
                        option          = 'EQ'
                        low             = <ls_bp_rel>-relshp_partner
                        attribute_name  = /scmtms/if_location_c=>sc_query_attribute-root-query_by_business_partne-business_partner_id
                    ) INTO TABLE lt_selpar.
      ENDIF.
    ENDLOOP.

    lo_srv_loc->query(
        EXPORTING
          iv_query_key            = /scmtms/if_location_c=>sc_query-root-query_by_business_partne
          it_selection_parameters = lt_selpar
        IMPORTING
          et_key                  = DATA(lt_loc_key)
      ).


*    LOOP AT lt_loc_key ASSIGNING FIELD-SYMBOL(<ls_loc_key>).
*      DATA(lv_loc_id) = /scmtms/cl_loc_helper=>return_ident_for_loc_key( <ls_loc_key>-key ).
*      INSERT VALUE #( sign = 'I'
*                      option = 'EQ'
*                      low = lv_loc_id
*                      ) into TABLE lr_loc_id.
*    ENDLOOP.
    lr_loc_id = VALUE #( FOR ls_loc_key IN lt_loc_key
                          ( sign    = 'I'
                            option  = 'EQ'
                            low     = /scmtms/cl_loc_helper=>return_ident_for_loc_key( ls_loc_key-key ) ) ).

    IF lr_loc_id IS INITIAL.
      EXIT.
    ENDIF.

    SELECT * FROM z4flow_ddd_inb INTO TABLE @DATA(lt_z4flow_dddt) WHERE sour_loc IN @lr_loc_id AND valid_to >= @sy-datum.

    SORT lt_z4flow_dddt BY sour_loc ASCENDING dest_loc ASCENDING duration DESCENDING.

    LOOP AT lt_z4flow_dddt ASSIGNING FIELD-SYMBOL(<ls_z4flow>).
      CLEAR lt_loc_id.
      INSERT VALUE #( id = <ls_z4flow>-sour_loc ) INTO TABLE lt_loc_id.
      INSERT VALUE #( id = <ls_z4flow>-dest_loc ) INTO TABLE lt_loc_id.

      /scmtms/cl_trq_helper=>convert_loc_id_to_key(
        EXPORTING
          it_loc_id     = lt_loc_id
        IMPORTING
          et_loc_key_id = DATA(lt_loc_keys)
      ).

      READ TABLE lt_loc_keys INTO DATA(ls_source) WITH KEY id = <ls_z4flow>-sour_loc.
      READ TABLE lt_loc_keys INTO DATA(ls_destin) WITH KEY id = <ls_z4flow>-dest_loc.
      READ TABLE et_transit_time INTO DATA(ls_transit_time) WITH KEY src_loc_key = ls_source-key des_loc_key = ls_destin-key.

      IF sy-subrc NE 0.
        INSERT VALUE #( src_loc_key  = ls_source-key
                        des_loc_key  = ls_destin-key
                        transit_time = <ls_z4flow>-duration / 10000
                        valid_from   = <ls_z4flow>-valid_from
                      ) INTO TABLE et_transit_time.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
