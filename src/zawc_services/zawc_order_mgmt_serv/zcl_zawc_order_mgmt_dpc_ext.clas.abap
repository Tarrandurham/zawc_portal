class ZCL_ZAWC_ORDER_MGMT_DPC_EXT definition
  public
  inheriting from ZCL_ZAWC_ORDER_MGMT_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_STREAM
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_STREAM
    redefinition .
protected section.

  methods ETATTACHMENTSET_DELETE_ENTITY
    redefinition .
  methods ETATTACHMENTSET_GET_ENTITYSET
    redefinition .
  methods ETDAYSOPENSET_GET_ENTITYSET
    redefinition .
  methods ETDESLOCSET_GET_ENTITY
    redefinition .
  methods ETDESLOCSET_GET_ENTITYSET
    redefinition .
  methods ETFREIGHTUNITSET_GET_ENTITYSET
    redefinition .
  methods ETMATERIALSET_GET_ENTITY
    redefinition .
  methods ETMATERIALSET_GET_ENTITYSET
    redefinition .
  methods ETSRCLOCSET_GET_ENTITY
    redefinition .
  methods ETSRCLOCSET_GET_ENTITYSET
    redefinition .
  methods ETTRANSITTIMESET_GET_ENTITYSET
    redefinition .
  methods ETTRQHEADSET_DELETE_ENTITY
    redefinition .
  methods ETTRQHEADSET_GET_ENTITY
    redefinition .
  methods ETTRQITEMSET_GET_ENTITYSET
    redefinition .
  methods ETCHARGESSET_GET_ENTITY
    redefinition .
private section.

  methods CHECK_AUTHORITY
    importing
      !IV_AUTH_TYPE type CHAR2
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION .
ENDCLASS.



CLASS ZCL_ZAWC_ORDER_MGMT_DPC_EXT IMPLEMENTATION.


METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
  DATA ls_create_trq TYPE zsawc_create_trq.


  SELECT * FROM zdawc_trq_rel_da INTO TABLE @DATA(lt_trq_rel_data).

  READ TABLE lt_trq_rel_data INTO DATA(ls_trq_rel_data) INDEX 1.

  io_data_provider->read_entry_data(
    IMPORTING
      es_data      = ls_create_trq
  ).


  IF iv_source_name = 'EtTrqhead'.
    TRY.
        IF ls_create_trq-fu_key IS NOT INITIAL AND ls_create_trq-btd_tco EQ ls_trq_rel_data-btd_tco_fwo. "zif_awc_constants=>c_btd_tco_fwo.
          check_authority( zif_order_management=>c_auth_check-update ).

          NEW zcl_awc_trq( )->update_trq(
            EXPORTING
              is_update = ls_create_trq    " Create TRQ DEEP INSERT
            IMPORTING
              es_update = ls_create_trq    " Create TRQ DEEP INSERT
          ).
        ELSEIF ls_create_trq-trq_key IS INITIAL.

          check_authority( zif_order_management=>c_auth_check-create ).

          NEW zcl_awc_trq( )->create_trq(
            EXPORTING
              is_create =  ls_create_trq   " Create TRQ DEEP INSERT
            IMPORTING
              ev_trq_key    = ls_create_trq-trq_key   " AWC Key
              ev_trq_id     = ls_create_trq-trq_id
              ev_fu_key     = ls_create_trq-fu_key
              ev_fu_id      = ls_create_trq-fu_id
          ).
        ELSE.

          check_authority( zif_order_management=>c_auth_check-update ).

          NEW zcl_awc_fu( )->update_fu( ls_create_trq ).
        ENDIF.

      CATCH zcx_awc_bopf INTO DATA(lo_ex).

        LOOP AT lo_ex->get_messages( ) ASSIGNING FIELD-SYMBOL(<ls_messages>).

          mo_context->get_message_container( )->add_message_text_only(
            EXPORTING
              iv_msg_type               = /iwbep/cl_cos_logger=>error
              iv_msg_text               = CONV #( <ls_messages>-message->get_longtext( ) )
          ).

        ENDLOOP.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = mo_context->get_message_container( )
            http_status_code  = /iwbep/cx_mgw_busi_exception=>gcs_http_status_codes-bad_request.
    ENDTRY.




  ELSEIF iv_source_name = 'EtCharges'.

    check_authority( zif_order_management=>c_auth_check-create ).

    NEW zcl_awc_trq( )->create_temp_trq(
      EXPORTING
        is_create =  ls_create_trq
      IMPORTING
        ev_trq_key    = ls_create_trq-trq_key   " AWC Key
        ev_trq_id     = ls_create_trq-trq_id
        ev_fu_key     = ls_create_trq-fu_key
        ev_fu_id      = ls_create_trq-fu_id
        et_charges  = ls_create_trq-trq_charges
    ).
READ TABLE ls_create_trq-trq_charges INTO DATA(ls_charges) INDEX 1.

ls_create_trq-net_amount = ls_charges-net_amount.
ls_create_trq-NET_AMOUNT_LCL = ls_charges-net_amount_lcl.
ls_create_trq-LCL_CURRENCY = ls_charges-LCL_CURRENCY.
ls_create_trq-DOC_CURRENCY = ls_charges-doc_CURRENCY.

  ENDIF.

ls_create_trq-earliest_due_date = sy-datum.

  copy_data_to_ref(
  EXPORTING
    is_data = ls_create_trq
  CHANGING
    cr_data = er_deep_entity
).


ENDMETHOD.


METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

  DATA: ls_media TYPE zsawc_attachment,
        lv_slug  TYPE string.
  DATA vc_date(10).
  DATA vc_time(8).

  check_authority( zif_order_management=>c_auth_check-create ).

  SPLIT iv_slug AT ';' INTO: DATA(lv_fu_key) DATA(lv_filename).

  WRITE sy-datum USING EDIT MASK '__-__-____' TO vc_date.
  WRITE sy-uzeit USING EDIT MASK '__-__-__' TO vc_time.
  lv_filename = |{ lv_filename }_{ vc_date }_{ vc_time }|.

  ls_media-mimetype = is_media_resource-mime_type.
  ls_media-value = is_media_resource-value.
  ls_media-filename = lv_filename.


  TRY.

      NEW zcl_awc_attachment( )->add_attachment_to_fu(
        EXPORTING
          iv_root_key = CONV #( lv_fu_key )     " NodeID
          is_media    = ls_media    " AWC structure for attachment
      ).

    CATCH zcx_awc_bopf INTO DATA(lo_ex).

      LOOP AT lo_ex->get_messages( ) ASSIGNING FIELD-SYMBOL(<ls_messages>).

        mo_context->get_message_container( )->add_message_text_only(
          EXPORTING
            iv_msg_type               = /iwbep/cl_cos_logger=>error
            iv_msg_text               = CONV #( <ls_messages>-message->get_longtext( ) )
        ).

      ENDLOOP.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = mo_context->get_message_container( )
          http_status_code  = /iwbep/cx_mgw_busi_exception=>gcs_http_status_codes-bad_request.

  ENDTRY.
  copy_data_to_ref(
    EXPORTING
      is_data = ls_media
    CHANGING
      cr_data = er_entity
  ).
ENDMETHOD.


METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
  DATA:
    BEGIN OF ls_param,
      fukey TYPE string,
      createdlvp TYPE string,
    END OF ls_param.

  DATA: lt_fu      TYPE zt_awc_fu,
        ls_fu      TYPE zsawc_fu,
        lt_fu_keys TYPE /bobf/t_frw_key.

  TYPES: BEGIN OF ty_split,
           fu_key TYPE zawc_key,
         END OF ty_split.
  DATA lt_split TYPE TABLE OF ty_split.

  CASE io_tech_request_context->get_function_import_name( ).
    WHEN 'ReleaseFreightUnit'.

      check_authority( zif_order_management=>c_auth_check-update ).

      io_tech_request_context->get_converted_parameters(
        IMPORTING
          es_parameter_values = ls_param
      ).

      SPLIT ls_param-fukey AT ';' INTO TABLE lt_split.

      LOOP AT lt_split ASSIGNING FIELD-SYMBOL(<ls_split>).
        INSERT VALUE #( key = <ls_split>-fu_key ) INTO TABLE lt_fu_keys.
      ENDLOOP.

      IF ls_param-createdlvp = 'createdlvp'.
      TRY.
         NEW zcl_awc_fu( )->create_dlvp( lt_fu_keys ).


          ENDTRY.

      ENDIF.
      TRY.
          NEW zcl_awc_fu( )->release_fus( lt_fu_keys ).

        CATCH zcx_awc_bopf INTO DATA(lo_ex).

          LOOP AT lo_ex->get_messages( ) ASSIGNING FIELD-SYMBOL(<ls_messages>).

            mo_context->get_message_container( )->add_message_text_only(
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_text               = CONV #( <ls_messages>-message->get_longtext( ) )
            ).

          ENDLOOP.

          RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
            EXPORTING
              message_container = mo_context->get_message_container( )
              http_status_code  = /iwbep/cx_mgw_busi_exception=>gcs_http_status_codes-bad_request.

      ENDTRY.

      LOOP AT lt_fu_keys ASSIGNING FIELD-SYMBOL(<ls_fu_key>).
        GET TIME STAMP FIELD DATA(ts).
        ls_fu-fu_key  = <ls_fu_key>-key.
        ls_fu-status  = 'C'.
        ls_fu-earliest_due_date = sy-datum.
        ls_fu-last_due_date     = sy-datum.
        ls_fu-pic_ear_req = ts.
        ls_fu-pic_lat_req = ts.
        ls_fu-del_ear_req = ts.
        ls_fu-del_lat_req = ts.
        INSERT ls_fu INTO TABLE lt_fu.
      ENDLOOP.

      copy_data_to_ref(
        EXPORTING
          is_data = lt_fu
        CHANGING
          cr_data = er_data
      ).

    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.


METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.
    DATA: ls_stream         TYPE ty_s_media_resource,
          lv_attachment_key TYPE zawc_key,
          lv_fu_key         TYPE zawc_key.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lt_keys) = io_tech_request_context->get_keys( ).

    IF io_tech_request_context->get_entity_set_name( ) EQ 'EtAttachmentSet'.

      READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>) WITH KEY name = 'ATTACHMENT_KEY'.
      IF sy-subrc = 0.
        lv_attachment_key = <fs_key>-value.
      ENDIF.

      READ TABLE lt_keys ASSIGNING <fs_key> WITH KEY name = 'FU_KEY'.
      IF sy-subrc = 0.
        lv_fu_key = <fs_key>-value.
      ENDIF.

      NEW zcl_awc_attachment( )->get_attachments(
        EXPORTING
          iv_fu_key    = CONV #( lv_fu_key )   " NodeID
        IMPORTING
          et_attachment = DATA(lt_attachment)    " AWC
      ).

      READ TABLE lt_attachment INTO DATA(ls_attachment) WITH KEY attachment_key = lv_attachment_key.
      IF sy-subrc = 0.
        ls_stream-value     = ls_attachment-value.
        ls_stream-mime_type = ls_attachment-mimetype.

        DATA(lv_http_value) = |inline; filename="{ ls_attachment-filename }.pdf";|.

        IF ls_attachment-mimetype = 'application/pdf'.
          DATA http_header TYPE ihttpnvp.
          http_header-name = 'Content-Disposition'.
          http_header-value = lv_http_value.
          set_header( is_header = http_header ).
        ENDIF.

        IF ls_stream IS NOT INITIAL.
          copy_data_to_ref(   EXPORTING is_data = ls_stream
                              CHANGING  cr_data = er_stream ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD check_authority.
    AUTHORITY-CHECK OBJECT zif_order_management=>c_auth_check-object ID zif_order_management=>c_auth_check-id FIELD iv_auth_type.
    IF sy-subrc <> 0.
      DATA(lv_msg_var) = SWITCH symsgv(
                                        iv_auth_type

                                          WHEN zif_order_management=>c_auth_check-display THEN TEXT-001
                                          WHEN zif_order_management=>c_auth_check-create  THEN TEXT-002
                                          WHEN zif_order_management=>c_auth_check-update  THEN TEXT-003
                                          WHEN zif_order_management=>c_auth_check-delete  THEN TEXT-004

                                      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = CONV #( lv_msg_var ).

      mo_context->get_message_container( )->reset( ).
    ENDIF.
  ENDMETHOD.


  METHOD etattachmentset_delete_entity.
    DATA: ls_values TYPE zsawc_attachment.

    check_authority( zif_order_management=>c_auth_check-delete ).

    io_tech_request_context->get_converted_keys(
        IMPORTING
          es_key_values = ls_values
          ).

    NEW zcl_awc_attachment( )->delete_attachment( CONV #( ls_values-attachment_key ) ).
  ENDMETHOD.


  METHOD etattachmentset_get_entityset.
    DATA ls_values TYPE zsawc_attachment.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.

    ELSE.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).
      NEW zcl_awc_attachment( )->get_attachments(
        EXPORTING
          iv_fu_key    = CONV #( ls_values-fu_key )   " NodeID
        IMPORTING
          et_attachment = DATA(lt_attachments)    " AWC
      ).

      LOOP AT lt_attachments ASSIGNING FIELD-SYMBOL(<ls_attachment>).
        INSERT VALUE #( attachment_key  = <ls_attachment>-attachment_key
                        fu_key          = <ls_attachment>-fu_key
                        filename        = <ls_attachment>-filename
                        filesize        = <ls_attachment>-filesize
                        mimetype        = <ls_attachment>-mimetype
                      ) INTO TABLE et_entityset.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD etchargesset_get_entity.
*
*    DATA: ls_values   TYPE zsawc_trq_head,
*          ls_trq_head TYPE zsawc_trq_head.
*
*    check_authority( zif_order_management=>c_auth_check-display ).
*
*    io_tech_request_context->get_converted_keys(
*    IMPORTING
*      es_key_values = ls_values
*      ).
*
*    NEW zcl_awc_fu( )->get_fu(
*      EXPORTING
*        iv_fu_key  = CONV #( ls_values-fu_key )   " NodeID
*      IMPORTING
*        es_trq_head = er_entity   " AWC
*    ).
  ENDMETHOD.


  method ETDAYSOPENSET_GET_ENTITYSET.
    DATA ls_values TYPE zsawc_location.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.

    ELSE.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).
      NEW zcl_awc_location( )->get_days_open(
        EXPORTING
          iv_loc_key    = ls_values-key " AWC Key
        IMPORTING
          et_days_open  = et_entityset   " AWC Des LOC
      ).
    ENDIF.
  endmethod.


  method ETDESLOCSET_GET_ENTITY.
    DATA ls_awc_loc TYPE zsawc_location.

    check_authority( zif_order_management=>c_auth_check-display ).

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_awc_loc
    ).

    IF ls_awc_loc IS NOT INITIAL.
        NEW zcl_awc_location( )->get_location(
          EXPORTING
            iv_loc_key = conv #( ls_awc_loc-key )
          IMPORTING
            es_awc_loc = ls_awc_loc                 " Location structure for AWC
        ).
    ENDIF.

    er_entity = ls_awc_loc.
  endmethod.


METHOD etdeslocset_get_entityset.
    DATA: ls_values TYPE zsawc_des_loc,
     lt_awc_loc TYPE zt_awc_des_loc.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.
      NEW zcl_awc_location( )->get_des_loc( IMPORTING et_awc_loc = lt_awc_loc ).
    ELSE.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).
      NEW zcl_awc_location( )->get_des_loc_by_src_loc(
        EXPORTING
          iv_src_loc_key = ls_values-key " AWC Key
        IMPORTING
          et_awc_loc     = lt_awc_loc    " AWC Des LOC
      ).
    ENDIF.

*   map Filter Select Options to Range-Table
    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'LOCATION_ID'.
    IF sy-subrc = 0.
      DATA(lr_LocationId) = <ls_filter_select_options>-select_options.
    ENDIF.

    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'NAME1'.
    IF sy-subrc = 0.
      DATA(lr_Name1) = <ls_filter_select_options>-select_options.
    ENDIF.

    LOOP AT lt_awc_loc ASSIGNING FIELD-SYMBOL(<ls_awc_loc>) WHERE location_id IN lr_locationid OR name1 IN lr_name1.
      INSERT <ls_awc_loc> INTO TABLE et_entityset.
    ENDLOOP.
  ENDMETHOD.


METHOD etfreightunitset_get_entityset.

*  AUTHORITY-CHECK OBJECT 'ZAWC_SCN01'
*           ID 'ACTVT' FIELD '03'.
*  IF sy-subrc <> 0.
*    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container.
*
*    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
*      RECEIVING
*        ro_message_container = lo_message_container.
*
*    CALL METHOD lo_message_container->add_message
*      EXPORTING
*        iv_msg_type               = /iwbep/cl_cos_logger=>warning
*        iv_msg_text               = TEXT-001
*        iv_msg_id                 = 'ZAWC'
*        iv_msg_number             = '001'
*        iv_add_to_response_header = abap_true.
*
*    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
*      EXPORTING
*        message_container = lo_message_container.
*
*    EXIT.
*  ENDIF.

  IF io_tech_request_context->has_inlinecount( ) = abap_false.

    " get the $skip and $top value
    DATA(lv_top)  = io_tech_request_context->get_top( ).
    DATA(lv_skip) = io_tech_request_context->get_skip( ).

    " map Filter Select Options to Range-Table
    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
    DATA(lt_orderby) = io_tech_request_context->get_orderby( ).

    NEW zcl_awc_fu( )->get_fus(
      EXPORTING
        it_orderby                = lt_orderby
        it_filter_select_options  = lt_filter_select_options
        iv_skip                   = lv_skip
        iv_top                    = CONV #( lv_top )
      IMPORTING
        et_fu = et_entityset
    ).

  ENDIF.


*METHOD etfreightunitset_get_entityset.
*    DATA: lt_fu   TYPE zt_awc_fu,
*          lv_date TYPE d,
*          lv_time TYPE t VALUE '235959',
*          lv_ts   TYPE ts.
*
*    FIELD-SYMBOLS <ls_fu> TYPE zsawc_fu.
*
*   check_authority( zif_order_management=>c_auth_check-display ).
*
*
*    NEW zcl_awc_fu( )->get_fus(
*      IMPORTING
*        et_fu = lt_fu    " AWC
*    ).
*
**   map Filter Select Options to Range-Table
*    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
*    DATA: lt_orderby TYPE /iwbep/t_mgw_tech_order,
*          ls_orderby LIKE LINE OF lt_orderby.
*
*    lt_orderby = io_tech_request_context->get_orderby( ).
*
*    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'FU_ID'.
*    IF sy-subrc = 0.
*      DATA(lr_fu_id) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'BTD_ID'.
*    IF sy-subrc = 0.
*      DATA(lr_btd_id) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'STATUS'.
*    IF sy-subrc = 0.
*      DATA(lr_status) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'EARLIEST_DUE_DATE'.
*    IF sy-subrc = 0.
*      DATA(lr_earliest_due_date) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'LAST_DUE_DATE'.
*    IF sy-subrc = 0.
*      DATA(lr_last_due_date) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'SRC_LOCATION_ID'.
*    IF sy-subrc = 0.
*      DATA(lr_src_loc_id) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'DES_LOCATION_ID'.
*    IF sy-subrc = 0.
*      DATA(lr_des_loc_id) = <ls_filter_select_options>-select_options.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'PIC_EAR_REQ'.
*    IF sy-subrc = 0.
*      DATA(lr_pic_ear) = <ls_filter_select_options>-select_options.
*      READ TABLE lr_pic_ear INTO DATA(ls_pic_ear) INDEX 1.
*
*      IF ls_pic_ear-option EQ 'EQ'.
*        lv_ts = ls_pic_ear-low.
*      ELSEIF ls_pic_ear-option EQ 'BT'.
*        lv_ts = ls_pic_ear-high.
*      ENDIF.
*
*      lv_ts = lv_ts(8).
*      lv_date = lv_ts.
*
*      CONVERT DATE lv_date TIME lv_time
*              INTO TIME STAMP DATA(lv_pic_ear_high) TIME ZONE 'UTC'.
*
*      DELETE TABLE lr_pic_ear FROM ls_pic_ear.
*
*      INSERT VALUE #( sign   = 'I'
*                      option = 'BT'
*                      low    = ls_pic_ear-low
*                      high   = lv_pic_ear_high
*                      ) INTO TABLE lr_pic_ear.
*    ENDIF.
*
*    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'DEL_EAR_REQ'.
*    IF sy-subrc = 0.
*      DATA(lr_del_ear) = <ls_filter_select_options>-select_options.
*
*      READ TABLE lr_del_ear INTO DATA(ls_del_ear) INDEX 1.
*
*      IF ls_del_ear-option EQ 'EQ'.
*        lv_ts = ls_del_ear-low.
*      ELSEIF ls_del_ear-option EQ 'BT'.
*        lv_ts = ls_del_ear-high.
*      ENDIF.
*
*      lv_ts = lv_ts(8).
*      lv_date = lv_ts.
*
*      CONVERT DATE lv_date TIME lv_time
*              INTO TIME STAMP DATA(lv_del_ear_high) TIME ZONE 'UTC'.
*
*      DELETE TABLE lr_del_ear FROM ls_del_ear.
*
*      INSERT VALUE #( sign   = 'I'
*                      option = 'BT'
*                      low    = ls_del_ear-low
*                      high   = lv_del_ear_high
*                      ) INTO TABLE lr_del_ear.
*    ENDIF.
*
*    LOOP AT lt_fu ASSIGNING <ls_fu> WHERE
*      status            IN lr_status AND
*      earliest_due_date IN lr_earliest_due_date AND
*      fu_id             IN lr_fu_id AND
*      btd_id            IN lr_btd_id AND
*      last_due_date     IN lr_last_due_date AND
*      src_location_id   IN lr_src_loc_id AND
*      des_location_id   IN lr_des_loc_id AND
*      pic_ear_req       IN lr_pic_ear AND
*      del_ear_req       IN lr_del_ear.
*      INSERT <ls_fu> INTO TABLE et_entityset.
*    ENDLOOP.
*
*    IF lr_earliest_due_date IS NOT INITIAL.
*      SORT et_entityset STABLE BY earliest_due_date.
*    ENDIF.
*
*    READ TABLE lt_orderby INTO ls_orderby INDEX 1.
*    IF sy-subrc = 0.
*      IF ls_orderby-order = 'desc'.
*        CASE ls_orderby-property.
*          WHEN 'FU_ID'.
*            SORT et_entityset DESCENDING BY fu_id.
*          WHEN 'BTD_ID'.
*            SORT et_entityset DESCENDING BY btd_id.
*          WHEN 'SRC_LOCATION_ID'.
*            SORT et_entityset DESCENDING BY src_location_id.
*          WHEN 'DES_LOCATION_ID'.
*            SORT et_entityset DESCENDING BY des_location_id.
*          WHEN 'PIC_EAR_REQ'.
*            SORT et_entityset DESCENDING BY pic_ear_req.
*          WHEN 'DEL_EAR_REQ'.
*            SORT et_entityset DESCENDING BY del_ear_req.
*          WHEN 'LAST_DUE_DATE'.
*            SORT et_entityset DESCENDING BY last_due_date.
*          WHEN 'PKG_AVAILABLE'.
*            SORT et_entityset DESCENDING BY pkg_available.
*        ENDCASE.
*      ELSEIF ls_orderby-order = 'asc'.
*        CASE ls_orderby-property.
*          WHEN 'FU_ID'.
*            SORT et_entityset ASCENDING BY fu_id.
*          WHEN 'BTD_ID'.
*            SORT et_entityset ASCENDING BY btd_id.
*          WHEN 'SRC_LOCATION_ID'.
*            SORT et_entityset ASCENDING BY src_location_id.
*          WHEN 'DES_LOCATION_ID'.
*            SORT et_entityset ASCENDING BY des_location_id.
*          WHEN 'PIC_EAR_REQ'.
*            SORT et_entityset ASCENDING BY pic_ear_req.
*          WHEN 'DEL_EAR_REQ'.
*            SORT et_entityset ASCENDING BY del_ear_req.
*          WHEN 'LAST_DUE_DATE'.
*            SORT et_entityset ASCENDING BY last_due_date.
*          WHEN 'PKG_AVAILABLE'.
*            SORT et_entityset ASCENDING BY pkg_available.
*        ENDCASE.
*      ENDIF.
*    ENDIF.
*
*  ENDMETHOD.
ENDMETHOD.


  METHOD etmaterialset_get_entity.
    DATA ls_awc_mat TYPE zsawc_material.

    check_authority( zif_order_management=>c_auth_check-display ).

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_awc_mat
    ).

    IF ls_awc_mat IS NOT INITIAL.
        NEW zcl_awc_material( )->get_material(
          EXPORTING
            iv_mat_key = CONV #( ls_awc_mat-key )
          IMPORTING
            es_awc_mat = ls_awc_mat
        ).
      er_entity = ls_awc_mat.
    ENDIF.
  ENDMETHOD.


  METHOD etmaterialset_get_entityset.
    DATA: ls_values  TYPE zsawc_material,
          lt_awc_mat TYPE zt_awc_material.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.
      NEW zcl_awc_material( )->get_materials_by_prd_group(
        IMPORTING
          et_awc_mat = lt_awc_mat    " Tabellentyp ZSAWC_MATERIAL
      ).
    ENDIF.

    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'INTERNAL_ID'.
    IF sy-subrc = 0.
      DATA(lr_internalid) = <ls_filter_select_options>-select_options.
    ENDIF.

    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'DESCRIPTION'.
    IF sy-subrc = 0.
      DATA(lr_des) = <ls_filter_select_options>-select_options.
    ENDIF.

    LOOP AT lt_awc_mat ASSIGNING FIELD-SYMBOL(<ls_awc_mat>) WHERE internal_id IN lr_internalid OR description IN lr_des.
      INSERT <ls_awc_mat> INTO TABLE et_entityset.
    ENDLOOP.
  ENDMETHOD.


  method ETSRCLOCSET_GET_ENTITY.
    DATA ls_awc_loc TYPE zsawc_location.

    check_authority( zif_order_management=>c_auth_check-display ).

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_awc_loc
    ).

    IF ls_awc_loc IS NOT INITIAL.
        NEW zcl_awc_location( )->get_location(
          EXPORTING
            iv_loc_key = CONV #( ls_awc_loc-key )
          IMPORTING
            es_awc_loc = ls_awc_loc
        ).
      er_entity = ls_awc_loc.
    ENDIF.
  endmethod.


  method ETSRCLOCSET_GET_ENTITYSET.

    check_authority( zif_order_management=>c_auth_check-display ).

    NEW zcl_awc_location( )->GET_SRC_LOC_BY_BP( IMPORTING et_awc_loc = DATA(lt_awc_loc) ).

*   map Filter Select Options to Range-Table
    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter_select_options>) WITH TABLE KEY property = 'LOCATION_ID'.
    IF sy-subrc = 0.
      DATA(lr_LocationId) = <ls_filter_select_options>-select_options.
    ENDIF.
    READ TABLE lt_filter_select_options ASSIGNING <ls_filter_select_options> WITH TABLE KEY property = 'NAME1'.
    IF sy-subrc = 0.
      DATA(lr_Name1) = <ls_filter_select_options>-select_options.
    ENDIF.

    LOOP AT lt_awc_loc ASSIGNING FIELD-SYMBOL(<ls_awc_loc>) WHERE location_id in lr_locationid OR name1 in lr_name1.
      INSERT <ls_awc_loc> INTO TABLE et_entityset.
    ENDLOOP.
  endmethod.


  METHOD ettransittimeset_get_entityset.
    DATA ls_values TYPE zsawc_transit_time.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).
      NEW zcl_awc_location( )->get_transit_time(
        IMPORTING
          et_transit_time = et_entityset                  " aWC transit time
      ).
    ELSE.

    ENDIF.
  ENDMETHOD.


  METHOD ettrqheadset_delete_entity.
    DATA: ls_values   TYPE zsawc_trq_head.

    check_authority( zif_order_management=>c_auth_check-delete ).

    io_tech_request_context->get_converted_keys(
    IMPORTING
      es_key_values = ls_values
      ).

    TRY.

        NEW zcl_awc_trq( )->cancel_trq( CONV #( ls_values-fu_key ) ).

      CATCH zcx_awc_bopf INTO DATA(lo_ex).

        LOOP AT lo_ex->get_messages( ) ASSIGNING FIELD-SYMBOL(<ls_messages>).

          mo_context->get_message_container( )->add_message_text_only(
            EXPORTING
              iv_msg_type               = /iwbep/cl_cos_logger=>error
              iv_msg_text               = CONV #( <ls_messages>-message->get_longtext( ) )
          ).

        ENDLOOP.

        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = mo_context->get_message_container( )
            http_status_code  = /iwbep/cx_mgw_busi_exception=>gcs_http_status_codes-bad_request.

    ENDTRY.

  ENDMETHOD.


  METHOD ettrqheadset_get_entity.
    DATA: ls_values   TYPE zsawc_trq_head,
          ls_trq_head TYPE zsawc_trq_head.

    check_authority( zif_order_management=>c_auth_check-display ).

    io_tech_request_context->get_converted_keys(
    IMPORTING
      es_key_values = ls_values
      ).

    new zcl_awc_fu( )->get_fu(
      EXPORTING
        iv_fu_key  = conv #( ls_values-fu_key )   " NodeID
      IMPORTING
        es_trq_head = er_entity   " AWC
    ).

  ENDMETHOD.


  METHOD ettrqitemset_get_entityset.
    DATA: ls_values  TYPE zsawc_trq_item,
          lt_fu_keys TYPE /bobf/t_frw_key.

    check_authority( zif_order_management=>c_auth_check-display ).

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS INITIAL.

    ELSE.
      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).

      INSERT VALUE #( key = ls_values-fu_key ) into TABLE lt_fu_keys.

      NEW zcl_awc_fu( )->get_items_by_fu(
        EXPORTING
          it_fu_keys = lt_fu_keys  " AWC Key
        IMPORTING
          et_items   = DATA(lt_item)     " AWC TRQ ITEM
      ).

      et_entityset = lt_item.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
