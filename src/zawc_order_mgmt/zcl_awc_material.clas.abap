class ZCL_AWC_MATERIAL definition
  public
  final
  create public .

public section.

  methods GET_MATERIAL
    importing
      !IV_MAT_KEY type /BOBF/CONF_KEY
    exporting
      !ES_AWC_MAT type ZSAWC_MATERIAL .
  methods GET_MAT_KEY_BY_MAT_ID
    importing
      !IV_MAT_ID type /SCMTMS/PRODUCT_ID
    returning
      value(RV_MAT_KEY) type /BOBF/CONF_KEY .
  methods GET_MATERIALS_BY_PRD_GROUP
    exporting
      !ET_AWC_MAT type ZT_AWC_MATERIAL .
  methods GET_MATERIALS_BY_SRC_LOC
    importing
      !IV_SRC_LOC_KEY type ZAWC_KEY
    exporting
      !ET_AWC_MAT type ZT_AWC_MATERIAL .
  methods GET_MAT_ID_BY_MAT_KEY
    importing
      !IV_MAT_KEY type /BOBF/CONF_KEY
    returning
      value(RV_MAT_ID) type /SCMTMS/PRODUCT_ID .
  methods CONSTRUCTOR .
  PROTECTED SECTION.
private section.

  data MS_OTH_REL_DATA type ZDAWC_OTH_REL_DA .
ENDCLASS.



CLASS ZCL_AWC_MATERIAL IMPLEMENTATION.


  METHOD constructor.

    SELECT  * FROM zdawc_oth_rel_da
      INTO TABLE @DATA(lt_oth_rel_data).

    READ TABLE lt_oth_rel_data INTO ms_oth_rel_data INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_oth_rel_data.
    ENDIF.

  ENDMETHOD.


  METHOD get_material.
    DATA: lt_mat_data     TYPE /scmtms/t_mat_root_k,
          lt_mat_qunit    TYPE /scmtms/t_mat_quan_unit_k,
          ls_awc_material TYPE zsawc_material,
          lt_mat_key      TYPE /bobf/t_frw_key.

    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_mat_key ) INTO TABLE lt_mat_key.

    lo_srv_mat->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_data
    ).

    lo_srv_mat->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_association          = /scmtms/if_mat_c=>sc_association-root-quantity_unit
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_qunit
    ).

    LOOP AT lt_mat_data ASSIGNING FIELD-SYMBOL(<ls_mat_data>).
      LOOP AT lt_mat_qunit ASSIGNING FIELD-SYMBOL(<ls_mat_qunit>) WHERE root_key = <ls_mat_data>-key.
        ls_awc_material = VALUE #( key = <ls_mat_data>-key
                        internal_id = <ls_mat_data>-internal_id
                        brgew = <ls_mat_qunit>-brgew
                        gewei = <ls_mat_qunit>-gewei
                        laeng = <ls_mat_qunit>-laeng
                        breit = <ls_mat_qunit>-breit
                        hoehe = <ls_mat_qunit>-hoehe
                        meabm = <ls_mat_qunit>-meabm
                        maxstack = <ls_mat_qunit>-maxstack
            ).
      ENDLOOP.
    ENDLOOP.

    es_awc_mat = ls_awc_material.
  ENDMETHOD.


  METHOD get_materials_by_prd_group.
    DATA: lt_mat_data     TYPE /scmtms/t_mat_root_k,
          lt_mat_qunit    TYPE /scmtms/t_mat_quan_unit_k,
          lt_mat_des      TYPE /scmtms/t_mat_description_k,
          lt_awc_material TYPE zt_awc_material,
          lt_mat_key      TYPE /bobf/t_frw_key.

    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

*    SELECT * FROM /sapapo/matgroup INTO TABLE @DATA(lt_mat_group) WHERE grptype = @ms_oth_rel_data-grptype AND groupvalue = @ms_oth_rel_data-groupvalue.

*    LOOP AT lt_mat_group ASSIGNING FIELD-SYMBOL(<ls_mat_group>).
*      DATA(lv_mat_key_c32) = /scmtms/cl_guid_convert=>c22_to_c32( <ls_mat_group>-matid ).
*      INSERT VALUE #( key = lv_mat_key_c32 ) INTO TABLE lt_mat_key.
*    ENDLOOP.

    lo_srv_mat->query(
      EXPORTING
        iv_query_key            = /scmtms/if_mat_c=>sc_query-root-query_by_attributes_all
*        it_filter_key           =
*        it_selection_parameters =
*        is_query_options        =
*        iv_fill_data            = abap_false
*        it_requested_attributes =
      IMPORTING
*        eo_message              =
*        es_query_info           =
*        et_data                 =
        et_key                  = lt_mat_key
    ).

    lo_srv_mat->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_data
    ).

    lo_srv_mat->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_association          = /scmtms/if_mat_c=>sc_association-root-quantity_unit
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_qunit
    ).

    lo_srv_mat->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_association          = /scmtms/if_mat_c=>sc_association-root-description
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_des
    ).

    LOOP AT lt_mat_data ASSIGNING FIELD-SYMBOL(<ls_mat_data>).
      LOOP AT lt_mat_qunit ASSIGNING FIELD-SYMBOL(<ls_mat_qunit>) WHERE root_key = <ls_mat_data>-key.
        LOOP AT lt_mat_des ASSIGNING FIELD-SYMBOL(<ls_mat_des>) WHERE parent_key = <ls_mat_data>-key AND langu = sy-langu.
          READ TABLE lt_awc_material TRANSPORTING NO FIELDS WITH KEY key = <ls_mat_data>-key.
          IF sy-subrc <> 0.
            IF <ls_mat_qunit>-meabm NE 'M'.
              /scmtms/cl_pln_common_func=>convert_quantity(
                 EXPORTING
                   iv_unit_from              = <ls_mat_qunit>-meabm
                   iv_unit_to                = 'M'
                   iv_quantity               = CONV #( <ls_mat_qunit>-laeng )
                 IMPORTING
                   ev_quantity               = DATA(lv_laeng)
               ).

              /scmtms/cl_pln_common_func=>convert_quantity(
                EXPORTING
                  iv_unit_from              = <ls_mat_qunit>-meabm
                  iv_unit_to                = 'M'
                  iv_quantity               = CONV #( <ls_mat_qunit>-breit )
                IMPORTING
                  ev_quantity               = DATA(lv_breit)
              ).

              /scmtms/cl_pln_common_func=>convert_quantity(
                EXPORTING
                  iv_unit_from              = <ls_mat_qunit>-meabm
                  iv_unit_to                = 'M'
                  iv_quantity               = CONV #( <ls_mat_qunit>-hoehe )
                IMPORTING
                  ev_quantity               = DATA(lv_hoehe)
              ).

              <ls_mat_qunit>-laeng = lv_laeng.
              <ls_mat_qunit>-breit = lv_breit.
              <ls_mat_qunit>-hoehe = lv_hoehe.
            ENDIF.

            INSERT VALUE #( key = <ls_mat_data>-key
                         internal_id = <ls_mat_data>-internal_id
                         brgew = <ls_mat_qunit>-brgew
                         gewei = <ls_mat_qunit>-gewei
                         laeng = <ls_mat_qunit>-laeng
                         breit = <ls_mat_qunit>-breit
                         hoehe = <ls_mat_qunit>-hoehe
                         meabm = 'M'
                         maxstack = <ls_mat_qunit>-maxstack
                         description = <ls_mat_des>-maktx
               ) INTO TABLE lt_awc_material.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    et_awc_mat = lt_awc_material.
  ENDMETHOD.


  METHOD get_materials_by_src_loc.
    DATA: lt_mat_data     TYPE /scmtms/t_mat_root_k,
          lt_mat_qunit    TYPE /scmtms/t_mat_quan_unit_k,
          lt_awc_material TYPE zt_awc_material,
          lt_mat_key      TYPE /bobf/t_frw_key.

    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

    DATA(lv_loc_key_c22) = /scmtms/cl_guid_convert=>c32_to_c22( iv_src_loc_key ).

    SELECT * FROM /sapapo/matloc INTO TABLE @DATA(lt_mat_loc) WHERE locid = @lv_loc_key_c22.

    LOOP AT lt_mat_loc ASSIGNING FIELD-SYMBOL(<ls_mat_loc>).
      DATA(lv_mat_key_c32) = /scmtms/cl_guid_convert=>c22_to_c32( <ls_mat_loc>-matid ).
      INSERT VALUE #( key = lv_mat_key_c32 ) INTO TABLE lt_mat_key.
    ENDLOOP.

    lo_srv_mat->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_data
    ).

    lo_srv_mat->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
        iv_association          = /scmtms/if_mat_c=>sc_association-root-quantity_unit
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_mat_qunit
    ).

    LOOP AT lt_mat_data ASSIGNING FIELD-SYMBOL(<ls_mat_data>).
      LOOP AT lt_mat_qunit ASSIGNING FIELD-SYMBOL(<ls_mat_qunit>) WHERE root_key = <ls_mat_data>-key.
        READ TABLE lt_awc_material TRANSPORTING NO FIELDS WITH KEY key = <ls_mat_data>-key.
        IF sy-subrc <> 0.
          INSERT VALUE #( key = <ls_mat_data>-key
                       src_loc_key = iv_src_loc_key
                       internal_id = <ls_mat_data>-internal_id
                       brgew = <ls_mat_qunit>-brgew
                       gewei = <ls_mat_qunit>-gewei
                       laeng = <ls_mat_qunit>-laeng
                       breit = <ls_mat_qunit>-breit
                       hoehe = <ls_mat_qunit>-hoehe
                       meabm = <ls_mat_qunit>-meabm
                       maxstack = <ls_mat_qunit>-maxstack

             ) INTO TABLE lt_awc_material.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    et_awc_mat = lt_awc_material.
  ENDMETHOD.


  METHOD get_mat_id_by_mat_key.
    DATA: lt_mat_data TYPE /scmtms/t_mat_root_k,
          lt_mat_key  TYPE /bobf/t_frw_key.

    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_mat_key ) INTO TABLE lt_mat_key.

    lo_srv_mat->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_mat_c=>sc_node-root
        it_key                  = lt_mat_key
      IMPORTING
        et_data                 = lt_mat_data
    ).

    READ TABLE lt_mat_data INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_mat_data>).
    IF sy-subrc = 0.
      rv_mat_id = <ls_mat_data>-internal_id.
    ENDIF.
  ENDMETHOD.


  METHOD get_mat_key_by_mat_id.
    DATA lt_selpar TYPE /bobf/t_frw_query_selparam.

    DATA(lo_srv_mat) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_mat_c=>sc_bo_key ).

    DATA: mat_id(40) TYPE c.
    mat_id = iv_mat_id.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = mat_id
      IMPORTING
        output = mat_id.

    INSERT VALUE #( sign            = 'I'
                    option          = 'EQ'
                    low             = mat_id
                    attribute_name  = /scmtms/if_mat_c=>sc_query_attribute-root-query_by_id-internal_id
                    ) INTO TABLE lt_selpar.

    lo_srv_mat->query(
        EXPORTING
          iv_query_key            = /scmtms/if_mat_c=>sc_query-root-query_by_id
          it_selection_parameters = lt_selpar
        IMPORTING
          et_key                  = DATA(lt_mat_key)
      ).
    READ TABLE lt_mat_key INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_mat_key>).
    IF sy-subrc = 0.
      rv_mat_key = <ls_mat_key>-key.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
