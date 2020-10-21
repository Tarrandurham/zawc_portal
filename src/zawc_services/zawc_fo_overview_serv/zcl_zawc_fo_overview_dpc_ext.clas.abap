CLASS zcl_zawc_fo_overview_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zawc_fo_overview_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_stream
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~execute_action
        REDEFINITION .
    METHODS /iwbep/if_mgw_appl_srv_runtime~get_stream
        REDEFINITION .
  PROTECTED SECTION.

    METHODS etattachmentset_delete_entity
        REDEFINITION .
    METHODS etattachmentset_get_entityset
        REDEFINITION .
    METHODS etdropdownset_get_entityset
        REDEFINITION .
    METHODS eteventset_create_entity
        REDEFINITION .
    METHODS eteventset_get_entity
        REDEFINITION .
    METHODS eteventset_get_entityset
        REDEFINITION .
    METHODS eteventset_update_entity
        REDEFINITION .
    METHODS etfreightorderse_get_entity
        REDEFINITION .
    METHODS etfreightorderse_get_entityset
        REDEFINITION .
    METHODS etitemset_get_entity
        REDEFINITION .
    METHODS etitemset_get_entityset
        REDEFINITION .
    METHODS etitemset_update_entity
        REDEFINITION .
    METHODS etnoteset_create_entity
        REDEFINITION .
    METHODS etnoteset_get_entityset
        REDEFINITION .
    METHODS etstopset_get_entityset
        REDEFINITION .
    METHODS etitemset_delete_entity
        REDEFINITION .
  PRIVATE SECTION.

    METHODS entityset_filter
      IMPORTING
        !it_filter_select_options TYPE /iwbep/t_mgw_select_option
        !iv_entity_name           TYPE string
      CHANGING
        !ct_entityset             TYPE table .
    METHODS entityset_order
      IMPORTING
        !it_order       TYPE /iwbep/t_mgw_tech_order
        !iv_entity_name TYPE string
      CHANGING
        !ct_entityset   TYPE table .
ENDCLASS.



CLASS ZCL_ZAWC_FO_OVERVIEW_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_stream.

    DATA: ls_attachment TYPE zawc_s_fo_attachment.

    SPLIT iv_slug AT ';' INTO: DATA(lv_fo_key) DATA(lv_filename) DATA(lv_description).

    ls_attachment-filename = lv_filename.
    ls_attachment-mimetype = is_media_resource-mime_type.
    ls_attachment-value = is_media_resource-value.
    ls_attachment-user_id_cr = sy-uname.
    ls_attachment-description = lv_description.

    NEW zcl_awc_fo_attachment( )->add_attachment_to_fo(
      EXPORTING
        iv_root_key = CONV #( lv_fo_key )    " NodeID
        is_media    = ls_attachment    " AWC structure for attachment
    ).

    copy_data_to_ref(
      EXPORTING
        is_data = ls_attachment
      CHANGING
        cr_data = er_entity
    ).

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.

    DATA:
      BEGIN OF ls_keys,
        fokey          TYPE string,
        eventkey       TYPE string,
        amountprf      TYPE /scmtms/tend_amount_pref,
        tendreqnr      TYPE /scmtms/tend_req_nr,
        stopkey        TYPE /bobf/conf_key,
        predecessorkey TYPE /bobf/conf_key,
        successorkey   TYPE /bobf/conf_key,
        vehkey         TYPE /bobf/conf_key,
        rejreasoncode  TYPE /scmtms/rej_reason_code,
      END OF ls_keys.

    DATA: lt_keys        TYPE /bobf/t_frw_key,
          lv_import_name TYPE /iwbep/mgw_tech_name,
          lv_text        TYPE string.

    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container,
          lo_exception         TYPE REF TO zcx_awc_fo_overview.

    CLEAR er_data.

    TYPES: BEGIN OF ty_split,
             key TYPE zawc_key,
           END OF ty_split.
    DATA lt_split TYPE TABLE OF ty_split.

    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
      RECEIVING
        ro_message_container = lo_message_container.

    io_tech_request_context->get_converted_parameters(
      IMPORTING
        es_parameter_values = ls_keys
    ).

    IF ls_keys-fokey IS NOT INITIAL.
      SPLIT ls_keys-fokey AT ';' INTO TABLE lt_split.
    ENDIF.

    IF ls_keys-eventkey IS NOT INITIAL.
      SPLIT ls_keys-eventkey AT ';' INTO TABLE lt_split.
    ENDIF.

    LOOP AT lt_split ASSIGNING FIELD-SYMBOL(<fs_split>).
      INSERT VALUE #( key = <fs_split>-key ) INTO TABLE lt_keys.
    ENDLOOP.

    lv_import_name = io_tech_request_context->get_function_import_name( ).

    CASE lv_import_name.
      WHEN 'ConfirmFreightOrder'.
        TRY.
            NEW zcl_awc_freight_order( )->confirm_fo( it_fo_keys = lt_keys ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            lo_message_container->add_message(
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_id                 = 'AWC'
                iv_msg_number             = '000'
                iv_msg_text               = CONV #( lv_text )
                iv_add_to_response_header = abap_true
            ).
        ENDTRY.

      WHEN 'RejectFreightOrder'.
        TRY.
            NEW zcl_awc_freight_order( )->reject_fo(
              EXPORTING
                it_fo_keys = lt_keys
                 ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            lo_message_container->add_message(
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_id                 = 'AWC'
                iv_msg_number             = '001'
                iv_msg_text               = CONV #( lv_text )
                iv_add_to_response_header = abap_true
                ).
        ENDTRY.

      WHEN 'RevokeEvent'.
        NEW zcl_awc_fo_event( )->revoke_event( it_event_keys = lt_keys ).

      WHEN 'RejectAnnouncement'.
        TRY.
            NEW zcl_awc_freight_order( )->confirm_reject_anno(
              EXPORTING
                iv_amountprf   = ls_keys-amountprf                 " Ausschreibung: übermittelter Preis in bevorzugter Währung
                iv_tend_req_nr = ls_keys-tendreqnr                 " Frachtanfragennummer
*                iv_rej_reason  = ls_keys-rejreasoncode
                iv_conf_flag   = 'R'
            ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            CALL METHOD lo_message_container->add_message
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_text               = CONV #( lv_text )
                iv_msg_id                 = 'COLL_PORTAL'
                iv_msg_number             = '004'
                iv_add_to_response_header = abap_true. "add the message to the header
        ENDTRY.

      WHEN 'ConfirmAnnouncement'.
        TRY.
            NEW zcl_awc_freight_order( )->confirm_reject_anno(
              EXPORTING
                iv_amountprf   = ls_keys-amountprf                 " Ausschreibung: übermittelter Preis in bevorzugter Währung
                iv_tend_req_nr = ls_keys-tendreqnr                 " Frachtanfragennummer
                iv_conf_flag   = 'C'                               " Einstelliges Kennzeichen
            ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            CALL METHOD lo_message_container->add_message
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_text               = CONV #( lv_text )
                iv_msg_id                 = 'COLL_PORTAL'
                iv_msg_number             = '003'
                iv_add_to_response_header = abap_true. "add the message to the header
        ENDTRY.

      WHEN 'MoveStop'.
        TRY.
            NEW zcl_awc_fo_stop( )->move_stop(
              EXPORTING
                iv_fo_key          = CONV #( ls_keys-fokey )                " NodeID
                iv_successor_key   = ls_keys-successorkey                 " NodeID
                iv_predecessor_key = ls_keys-predecessorkey                 " NodeID
                iv_stop_key        = ls_keys-stopkey                 " NodeID
            ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            CALL METHOD lo_message_container->add_message
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_text               = CONV #( lv_text )
                iv_msg_id                 = 'COLL_PORTAL'
                iv_msg_number             = '002'
                iv_add_to_response_header = abap_true. "add the message to the header
        ENDTRY.

      WHEN 'AssignVehicle'.
        TRY.
            NEW zcl_awc_freight_order( )->assign_vehicle(
              EXPORTING
                iv_fo_key  = CONV #( ls_keys-fokey )                " NodeID
                iv_veh_key = ls_keys-vehkey                         " NodeID
            ).
          CATCH zcx_awc_fo_overview INTO lo_exception.
            lv_text = lo_exception->get_text( ).

            CALL METHOD lo_message_container->add_message
              EXPORTING
                iv_msg_type               = /iwbep/cl_cos_logger=>error
                iv_msg_text               = CONV #( lv_text )
                iv_msg_id                 = 'COLL_PORTAL'
                iv_msg_number             = '001'
                iv_add_to_response_header = abap_true. "add the message to the header
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_stream.

    DATA: ls_stream         TYPE ty_s_media_resource,
          lv_attachment_key TYPE zawc_key,
          lv_fo_key         TYPE zawc_key.

    DATA(lt_keys) = io_tech_request_context->get_keys( ).

    IF io_tech_request_context->get_entity_set_name( ) EQ 'EtAttachmentSet'.

      READ TABLE lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>) WITH KEY name = 'ATTACHMENT_KEY'.
      IF sy-subrc = 0.
        lv_attachment_key = <fs_key>-value.
      ENDIF.

      READ TABLE lt_keys ASSIGNING <fs_key> WITH KEY name = 'KEY'.
      IF sy-subrc = 0.
        lv_fo_key = <fs_key>-value.
      ENDIF.

      NEW zcl_awc_attachment( )->get_attachments(
        EXPORTING
          iv_fu_key    = CONV #( lv_fo_key )
        IMPORTING
          et_attachment = DATA(lt_attachment)
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


  METHOD entityset_filter.

* generic method to filter any entityset table of the corresponding model.

    DATA:
      lx_root         TYPE REF TO cx_root,
      lo_data_descr   TYPE REF TO cl_abap_datadescr,
      lo_table_descr  TYPE REF TO cl_abap_tabledescr,
      lo_dp_facade    TYPE REF TO /iwbep/cl_mgw_dp_facade,  "/IWBEP/IF_MGW_DP_FACADE,
      lo_model        TYPE REF TO /iwbep/if_mgw_odata_re_model,
      ls_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_s_mgw_odata_property,
      lt_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_t_mgw_odata_properties,
      ls_filter_sel   TYPE /iwbep/s_mgw_select_option,
      lv_entity_name  TYPE /iwbep/med_external_name,
      lv_tabix        TYPE i,
      lv_type         TYPE string.

    FIELD-SYMBOLS:
      <fs_val>  TYPE data,
      <fs_data> TYPE data.

* Pre-check.
    CHECK lines( it_filter_select_options ) > 0.

* 'Type-cast' datatype.
    lv_entity_name = iv_entity_name.

* Get type of table.
    TRY.
*   Get DP facade.
        lo_dp_facade ?= me->/iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*   Get Model
        lo_model = lo_dp_facade->/iwbep/if_mgw_dp_int_facade~get_model( ).
*   Get Entity Properties.
        lt_entity_props = lo_model->get_entity_type( lv_entity_name )->get_properties( ).

*   Traverse filters.
        LOOP AT it_filter_select_options INTO ls_filter_sel.
*     Map Model Property to ABAP field name.
          READ TABLE lt_entity_props INTO ls_entity_props
          WITH KEY technical_name = ls_filter_sel-property.
          IF sy-subrc = 0.
*       Evaluate (single) Property filter on EntitySet.
            LOOP AT ct_entityset ASSIGNING <fs_data>.
              lv_tabix = sy-tabix.
*         Get Property value.
              ASSIGN COMPONENT ls_entity_props-technical_name OF STRUCTURE <fs_data> TO <fs_val>.
              IF sy-subrc = 0 AND <fs_val> IS ASSIGNED.
*           Evaluate i'th filter (not adhering to filter => delete).
                IF <fs_val> NOT IN ls_filter_sel-select_options.
*             Delete from table, when not adhering to filter.
                  DELETE ct_entityset INDEX lv_tabix.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      CATCH cx_root INTO lx_root.
*        me->raise_exception_from_message( 'Error in method ENTITYSET_FILTER :' && lx_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.


  METHOD entityset_order.
* generic method to sort any entityset table of the corresponding model.

    DATA:
      lx_root         TYPE REF TO cx_root,
      lo_data_descr   TYPE REF TO cl_abap_datadescr,
      lo_table_descr  TYPE REF TO cl_abap_tabledescr,
      lo_dp_facade    TYPE REF TO /iwbep/cl_mgw_dp_facade,  "/IWBEP/IF_MGW_DP_FACADE,
      lo_model        TYPE REF TO /iwbep/if_mgw_odata_re_model,
      ls_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_s_mgw_odata_property,
      lt_entity_props TYPE /iwbep/if_mgw_odata_re_prop=>ty_t_mgw_odata_properties,
      ls_order        TYPE /iwbep/s_mgw_tech_order,
      lv_entity_name  TYPE /iwbep/med_external_name,
      lv_type         TYPE string,
      ls_sortorder    TYPE abap_sortorder,
      lt_sortorder    TYPE abap_sortorder_tab.

* Pre-check.
    CHECK lines( it_order ) > 0.

* 'Type-cast' datatype.
    lv_entity_name = iv_entity_name.

* Get type of table.
    TRY.
*   Get DP facade.
        lo_dp_facade ?= me->/iwbep/if_mgw_conv_srv_runtime~get_dp_facade( ).
*   Get Model
        lo_model = lo_dp_facade->/iwbep/if_mgw_dp_int_facade~get_model( ).
*   Get Entity Properties.
        lt_entity_props = lo_model->get_entity_type( lv_entity_name )->get_properties( ).
*   Convert sorting table ('OData' -> ABAP).
        LOOP AT it_order INTO ls_order.
*     Map Model Property to ABAP field name.
          READ TABLE lt_entity_props INTO ls_entity_props
          WITH KEY technical_name = ls_order-property.
          IF sy-subrc = 0.
*       Build ABAP sort order table.
            CLEAR ls_sortorder.
            ls_sortorder-name = ls_entity_props-technical_name.
            IF to_upper( ls_order-order ) = 'DESC'.
              ls_sortorder-descending = abap_true.
            ENDIF.
            APPEND ls_sortorder TO lt_sortorder.
          ELSE.
*       Consider raising exception !.
          ENDIF.
        ENDLOOP.
*   Perform sorting.
        IF lines( lt_sortorder ) > 0.
          SORT ct_entityset BY (lt_sortorder).
        ENDIF.

      CATCH cx_root INTO lx_root.
*        me->raise_exception_from_message( 'Error in method ENTITYSET_ORDER :' && lx_root->get_text( ) ).
    ENDTRY.

  ENDMETHOD.


  METHOD etattachmentset_delete_entity.

    DATA: ls_values TYPE zawc_s_fo_attachment.

    io_tech_request_context->get_converted_keys(
    IMPORTING
      es_key_values = ls_values
      ).

    NEW zcl_awc_fo_attachment( )->delete_attachment( CONV #( ls_values-attachment_key ) ).
  ENDMETHOD.


  METHOD etattachmentset_get_entityset.

    DATA: ls_values  TYPE zawc_s_fo_attachment,
          lt_fo_keys TYPE /bobf/t_frw_key.

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS NOT INITIAL.

      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).

      INSERT VALUE #( key = ls_values-key ) INTO TABLE lt_fo_keys.

      DATA(lt_fu_keys) = NEW zcl_awc_freight_order( )->get_assigned_fus( it_fo_keys = lt_fo_keys ).

*      READ TABLE lt_fu_keys INDEX 1 INTO DATA(ls_fu_keys).

      LOOP AT lt_fu_keys INTO DATA(ls_fu_keys).
        APPEND ls_fu_keys TO lt_fo_keys.
      ENDLOOP.

      NEW zcl_awc_fo_attachment( )->get_attachments(
        EXPORTING
          it_fo_keys     = lt_fo_keys    " NodeID
        IMPORTING
          et_attachment = DATA(lt_attachment)    " Anhang von Frachteinheiten
      ).

*      LOOP AT lt_attachment INTO DATA(ls_attachment) WHERE key = ls_values-key OR key = ls_fu_keys-key.
*        APPEND ls_attachment TO et_entityset.
*      ENDLOOP.

      MOVE-CORRESPONDING lt_attachment TO et_entityset.
    ENDIF.

  ENDMETHOD.


  METHOD etdropdownset_get_entityset.

    DATA: ls_dropdown_data TYPE zawc_s_fo_dropdown,
          lt_view_data     TYPE STANDARD TABLE OF /scmtms/v_torevt,
          lv_view_name     TYPE dd02v-tabname VALUE '/SCMTMS/V_TOREVT'.

    DATA(lo_tor_srv_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<fs_list_filter>) WITH TABLE KEY property = 'LIST_ID'.
    IF sy-subrc = 0.
      DATA(lr_fo_list) = <fs_list_filter>-select_options.
    ENDIF.

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<fs_fo_filter>) WITH TABLE KEY property = 'FO_KEY'.
    IF sy-subrc = 0.
      DATA(lr_fo_key) = <fs_fo_filter>-select_options.
    ENDIF.

    READ TABLE lr_fo_list INDEX 1 INTO DATA(ls_fo_list).
    READ TABLE lr_fo_key INDEX 1 INTO DATA(ls_fo_key).

    DATA(lv_list_id) = ls_fo_list-low.
    DATA(lv_fo_key)  = ls_fo_key-low.

    CASE lv_list_id.
      WHEN 'Eventcode'.
        SELECT SINGLE tor_type FROM /scmtms/d_torrot INTO @DATA(lv_tor_type) WHERE db_key = @lv_fo_key.
        CALL FUNCTION 'VIEW_GET_DATA'
          EXPORTING
            view_name = lv_view_name
          TABLES
            data      = lt_view_data.


        LOOP AT lt_view_data INTO DATA(ls_view_data) WHERE type = lv_tor_type.
          INSERT VALUE #( list_id     = lv_list_id
                          data_key    = ls_view_data-event_code
                          data_descr  = ls_view_data-event_desc
                          fo_key      = lv_fo_key
                          key         = lo_tor_srv_mgr->get_new_key( ) ) INTO TABLE et_entityset.
        ENDLOOP.
      WHEN 'EventLocation'.
        NEW zcl_awc_fo_stop( )->get_stops_by_fo(
          EXPORTING
            iv_fo_key   = CONV #( lv_fo_key )   " NodeID
          IMPORTING
            et_fo_stops = DATA(lt_fo_stops)     " Tabellentyp Abschnitte
        ).
      WHEN 'VehicleRes'.
        DATA(lt_carriers)     = NEW zcl_awc_freight_order( )->get_carrier_for_user( ).
        DATA(lt_vehicle_res)  = NEW zcl_awc_fo_vehicle( )->get_vehicle_res_for_carr( it_carrier = lt_carriers ).

        LOOP AT lt_vehicle_res INTO DATA(ls_vehicle_res).
          INSERT VALUE #( list_id     = lv_list_id
                          data_key    = ls_vehicle_res-key
                          data_descr  = ls_vehicle_res-platenumber
                          key         = lo_tor_srv_mgr->get_new_key( ) ) INTO TABLE et_entityset.
        ENDLOOP.

      WHEN 'RejReason'.
        SELECT * FROM /scmtms/c_rejrnt INTO TABLE @DATA(lt_rej_reason).

        LOOP AT lt_rej_reason INTO DATA(ls_rej_reason) WHERE langu = sy-langu.
          INSERT VALUE #( list_id     = lv_list_id
                          data_key    = ls_rej_reason-rej_reason_code
                          data_descr  = ls_rej_reason-descr
                          key         = lo_tor_srv_mgr->get_new_key( ) ) INTO TABLE et_entityset.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.


  METHOD eteventset_create_entity.

    DATA: ls_values            TYPE zawc_s_fo_event,
          lo_exception         TYPE REF TO zcx_awc_fo_overview,
          lo_message_container TYPE REF TO /iwbep/if_message_container,
          lv_text              TYPE string.

    io_data_provider->read_entry_data(
      IMPORTING
        es_data                      = ls_values
    ).
    TRY.
        NEW zcl_awc_fo_event( )->create_event(
          EXPORTING
            is_event_data = ls_values
          IMPORTING
            es_event_data = DATA(ls_event_data)
        ).
      CATCH zcx_awc_fo_overview INTO lo_exception.
        lv_text = lo_exception->get_text( ).

        lo_message_container->add_message(
      EXPORTING
        iv_msg_type               = /iwbep/cl_cos_logger=>error
        iv_msg_id                 = 'AWC'
        iv_msg_number             = '002'
        iv_msg_text               = CONV #( lv_text )
        iv_add_to_response_header = abap_true
        ).
    ENDTRY.

    er_entity = ls_event_data.

  ENDMETHOD.


  METHOD eteventset_get_entity.

    DATA: ls_key_values TYPE zawc_s_fo_event.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_key_values
    ).

    NEW zcl_awc_fo_event( )->get_event_by_key(
      EXPORTING
        iv_event_key = CONV #( ls_key_values-key )   " NodeID
      IMPORTING
        es_event     = er_entity    " Ereignisse von Frachtaufträgen
    ).

  ENDMETHOD.


  METHOD eteventset_get_entityset.

    DATA: ls_values TYPE zawc_s_fo_data.

    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values = ls_values
    ).

    NEW zcl_awc_fo_event( )->get_events_by_fo(
      EXPORTING
        iv_fo_key = CONV #( ls_values-key )    " NodeID
      IMPORTING
        et_event  = et_entityset    " Tabellentyp Ereignisse
    ).

  ENDMETHOD.


  METHOD eteventset_update_entity.
    DATA: ls_entry_data        TYPE zawc_s_fo_event,
          lo_exception         TYPE REF TO zcx_awc_fo_overview,
          lo_message_container TYPE REF TO /iwbep/if_message_container,
          lv_text              TYPE string,
          lt_event_keys        TYPE /bobf/t_frw_key.

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = ls_entry_data
    ).

    INSERT VALUE #( key = ls_entry_data-key ) INTO TABLE lt_event_keys.

    IF ls_entry_data-comment IS NOT INITIAL.
      NEW zcl_awc_fo_attachment( )->add_note_to_event(
        EXPORTING
          iv_text_type = 'TOREM'
          iv_text      = ls_entry_data-comment
          iv_event_key = CONV #( ls_entry_data-key )
          iv_fo_key    = CONV #( ls_entry_data-root_key )
      ).
    ENDIF.

    er_entity = ls_entry_data.
  ENDMETHOD.


  METHOD etfreightorderse_get_entity.

    DATA: ls_key_values TYPE zawc_s_fo_data.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_key_values
    ).

    NEW zcl_awc_freight_order( )->get_fo(
      EXPORTING
        iv_fo_key  = CONV #( ls_key_values-key )   " NodeID
      IMPORTING
        es_fo_data = er_entity
    ).
  ENDMETHOD.


  METHOD etfreightorderse_get_entityset.

    DATA: ls_fo_data       TYPE zawc_s_fo_data,
          lv_is_conf       TYPE boolean,
          lv_app_indicator TYPE c.

    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
    DATA(lt_orderby) = io_tech_request_context->get_orderby( ).

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<fs_conf_filter>) WITH TABLE KEY property = 'CONFIRMATION'.
    IF sy-subrc = 0.
      DATA(lr_fo_conf_status) = <fs_conf_filter>-select_options.
      lv_app_indicator = 'C'.
    ENDIF.

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<fs_exec_filter>) WITH TABLE KEY property = 'EXECUTION'.
    IF sy-subrc = 0.
      DATA(lr_fo_exec_status) = <fs_exec_filter>-select_options.
      lv_app_indicator = 'E'.
    ENDIF.

    READ TABLE lt_filter_select_options ASSIGNING FIELD-SYMBOL(<fs_anno_filter>) WITH TABLE KEY property = 'ANNOUNCEMENT'.
    IF sy-subrc = 0.
      DATA(lr_fo_anno_status) = <fs_anno_filter>-select_options.
      lv_app_indicator = 'A'.
    ENDIF.

    DELETE lt_filter_select_options WHERE property = 'EXECUTION' OR property = 'CONFIRMATION' OR property = 'ANNOUNCEMENT'.

    READ TABLE lr_fo_anno_status INDEX 1 INTO DATA(ls_fo_anno_status).

    READ TABLE lr_fo_conf_status INDEX 1 INTO DATA(ls_fo_conf_status).

    READ TABLE lr_fo_exec_status INDEX 1 INTO DATA(ls_fo_exec_status).

    NEW zcl_awc_freight_order( )->get_fos(
      EXPORTING
        iv_app_indicator  = lv_app_indicator
        iv_anno_status    = ls_fo_anno_status-low
        iv_conf_status    = ls_fo_conf_status-low
        iv_exec_status    = ls_fo_exec_status-low
      IMPORTING
        et_fo_data = DATA(lt_fo_data)    " Tabellentyp Frachtauftrag
    ).

    MOVE-CORRESPONDING lt_fo_data TO et_entityset.

    IF lv_app_indicator = 'A'.
      MOVE-CORRESPONDING lt_fo_data TO et_entityset.
    ENDIF.

    IF lt_filter_select_options IS NOT INITIAL.
      me->entityset_filter(
        EXPORTING
          it_filter_select_options = lt_filter_select_options
          iv_entity_name           = iv_entity_name
        CHANGING
          ct_entityset             = et_entityset
      ).
    ENDIF.
    IF lt_orderby IS NOT INITIAL.
      me->entityset_order(
        EXPORTING
          it_order       = lt_orderby
          iv_entity_name = iv_entity_name
        CHANGING
          ct_entityset   = et_entityset
      ).
    ENDIF.

  ENDMETHOD.


  METHOD etitemset_delete_entity.

    DATA: ls_values  TYPE zawc_s_fo_item,
          lt_fu_keys TYPE /bobf/t_frw_key.

    DATA: lo_message_container TYPE REF TO /iwbep/if_message_container,
          lo_exception         TYPE REF TO zcx_awc_fo_overview.

    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
      RECEIVING
        ro_message_container = lo_message_container.

    io_tech_request_context->get_converted_keys(
    IMPORTING
      es_key_values = ls_values
      ).

    INSERT VALUE #( key = ls_values-key ) INTO TABLE lt_fu_keys.

    TRY.
        NEW zcl_awc_fo_item( )->delete_fu_assignments( it_fu_keys = lt_fu_keys ).
      CATCH zcx_awc_fo_overview INTO lo_exception.
        DATA(lv_text) = lo_exception->get_text( ).

        CALL METHOD lo_message_container->add_message
          EXPORTING
            iv_msg_type               = /iwbep/cl_cos_logger=>error
            iv_msg_text               = CONV #( lv_text )
            iv_msg_id                 = 'COLL_PORTAL'
            iv_msg_number             = '006'
            iv_add_to_response_header = abap_true. "add the message to the header
    ENDTRY.

  ENDMETHOD.


  METHOD etitemset_get_entity.


    DATA: ls_key_values TYPE zawc_s_fo_item.

    io_tech_request_context->get_converted_keys(
      IMPORTING
        es_key_values = ls_key_values
    ).

    NEW zcl_awc_fo_item( )->get_item_by_key(
      EXPORTING
        iv_item_key = CONV #( ls_key_values-key )
      IMPORTING
        es_item_data = er_entity
    ).

  ENDMETHOD.


  METHOD etitemset_get_entityset.

    DATA: ls_values TYPE zawc_s_fo_data.

    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values = ls_values
    ).

    NEW zcl_awc_fo_item( )->get_items_by_fo(
      EXPORTING
        iv_fo_key   = CONV #( ls_values-key )    " NodeID
      IMPORTING
        et_fo_items = et_entityset    " Tabellentyp Items
    ).

  ENDMETHOD.


  METHOD etitemset_update_entity.
    DATA: ls_entry_data        TYPE zawc_s_fo_item,
          lt_veh_keys          TYPE /bobf/t_frw_key,
          lt_veh_data          TYPE /scmtms/t_res_veh_root_k,
          lo_exception         TYPE REF TO zcx_awc_fo_overview,
          lo_message_container TYPE REF TO /iwbep/if_message_container,
          lv_text              TYPE string.

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = ls_entry_data
    ).

    READ TABLE it_key_tab INTO DATA(ls_key_tab) WITH KEY name = 'ItemKey'.
    IF sy-subrc = 0.
      DATA(lv_fu_key) = ls_key_tab-value.
    ENDIF.

    INSERT VALUE #( key = ls_entry_data-parent_key ) INTO TABLE lt_veh_keys.


*    NEW zcl_awc_fo_item( )->reassign_fu(
*      EXPORTING
*        iv_fu_key = CONV #( lv_fu_key )                 " NodeID
*        iv_fo_key = CONV #( ls_entry_data-parent_key )                 " NodeID
*    ).

    TRY.
        NEW zcl_awc_fo_item( )->update_act_val( is_update_fo_item = ls_entry_data ).
      CATCH zcx_awc_fo_overview INTO lo_exception.
        lv_text = lo_exception->get_text( ).

        lo_message_container->add_message(
          EXPORTING
          iv_msg_type               = /iwbep/cl_cos_logger=>error
          iv_msg_id                 = 'AWC'
          iv_msg_number             = '003'
          iv_msg_text               = CONV #( lv_text )
          iv_add_to_response_header = abap_true
          ).

    ENDTRY.

    er_entity = ls_entry_data.

  ENDMETHOD.


  METHOD etnoteset_create_entity.
    DATA: ls_values     TYPE zawc_s_fo_note,
          lo_attachment TYPE REF TO zcl_awc_fo_attachment,
          lc_type1      TYPE /bobf/txc_text_type VALUE 'Z4CO1'. "'Z4CO1',

    CREATE OBJECT lo_attachment.

    io_data_provider->read_entry_data(
      IMPORTING
        es_data = ls_values
    ).

    IF ls_values-note_type EQ 'FO'.

      lo_attachment->add_note_to_fo(
        EXPORTING
          iv_text_type = lc_type1 "ls_values-txt_type    " Textart
          iv_text      = ls_values-text    " Textinhalt
          iv_fo_key    = CONV #( ls_values-key )    " NodeID
          IMPORTING
            es_note = DATA(ls_note)
      ).
    ELSEIF ls_values-note_type EQ 'EV'.

    ENDIF.

    er_entity = ls_note.
  ENDMETHOD.


  METHOD etnoteset_get_entityset.
    DATA: ls_values  TYPE zawc_s_fo_note,
          lt_fo_keys TYPE /bobf/t_frw_key.

    DATA(lv_source_entity) = io_tech_request_context->get_source_entity_type_name( ).

    IF lv_source_entity IS NOT INITIAL.

      io_tech_request_context->get_converted_source_keys(
        IMPORTING
          es_key_values = ls_values
      ).

      INSERT VALUE #( key = ls_values-key ) INTO TABLE lt_fo_keys.

      DATA(lt_fu_keys) = NEW zcl_awc_freight_order( )->get_assigned_fus( it_fo_keys = lt_fo_keys ).

      READ TABLE lt_fu_keys INDEX 1 INTO DATA(ls_fu_keys).

      APPEND ls_fu_keys TO lt_fo_keys.

      NEW zcl_awc_fo_attachment( )->get_notes_from_fo(
        EXPORTING
          it_fo_keys  = lt_fo_keys    " AWC Key
        IMPORTING
          et_fo_note = DATA(lt_notes)    " Tabellentyp Note
      ).

      et_entityset = lt_notes.

    ENDIF.
  ENDMETHOD.


  METHOD etstopset_get_entityset.
    DATA: ls_key_values TYPE zawc_s_fo_data.

    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
    DATA(lt_orderby) = io_tech_request_context->get_orderby( ).

    io_tech_request_context->get_converted_source_keys(
      IMPORTING
        es_key_values = ls_key_values
    ).

    NEW zcl_awc_fo_stop( )->get_stops_by_fo(
      EXPORTING
        iv_fo_key   = CONV #( ls_key_values-key )    " NodeID
      IMPORTING
        et_fo_stops = et_entityset    " Tabellentyp Abschnitte
    ).

    IF lt_filter_select_options IS NOT INITIAL.
      me->entityset_filter(
        EXPORTING
          it_filter_select_options = lt_filter_select_options
          iv_entity_name           = iv_entity_name
        CHANGING
          ct_entityset             = et_entityset
      ).
    ENDIF.
    IF lt_orderby IS NOT INITIAL.
      me->entityset_order(
        EXPORTING
          it_order       = lt_orderby
          iv_entity_name = iv_entity_name
        CHANGING
          ct_entityset   = et_entityset
      ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
