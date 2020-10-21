class ZCL_AWC_FO_ATTACHMENT definition
  public
  final
  create public .

public section.

  methods UPDATE_EVENT_NOTE
    importing
      !IV_TEXT_TYPE type /BOBF/TXC_TEXT_TYPE
      !IV_TEXT type /BOBF/TEXT_CONTENT
      !IV_EVENT_KEY type /BOBF/CONF_KEY
      !IV_FO_KEY type /BOBF/CONF_KEY .
  methods ADD_NOTE_TO_EVENT
    importing
      !IV_TEXT_TYPE type /BOBF/TXC_TEXT_TYPE
      !IV_TEXT type /BOBF/TEXT_CONTENT
      !IV_EVENT_KEY type /BOBF/CONF_KEY
      !IV_FO_KEY type /BOBF/CONF_KEY .
  methods GET_ATTACHMENTS
    importing
      !IT_FO_KEYS type /BOBF/T_FRW_KEY
    exporting
      !ET_ATTACHMENT type ZAWC_T_FO_ATTACHMENT .
  methods CONSTRUCTOR .
  methods DELETE_ATTACHMENT
    importing
      !IV_ATTACHMENT_KEY type /BOBF/CONF_KEY .
  methods ADD_ATTACHMENT_TO_FO
    importing
      !IV_ROOT_KEY type /BOBF/CONF_KEY
      !IS_MEDIA type ZAWC_S_FO_ATTACHMENT optional .
  methods ADD_NOTE_TO_FO
    importing
      !IV_TEXT_TYPE type /BOBF/TXC_TEXT_TYPE
      !IV_TEXT type /BOBF/TEXT_CONTENT
      !IV_FO_KEY type /BOBF/CONF_KEY
    exporting
      !ES_NOTE type ZAWC_S_FO_NOTE .
  methods GET_NOTES_FROM_FO
    importing
      !IT_FO_KEYS type /BOBF/T_FRW_KEY
    exporting
      !ET_FO_NOTE type ZAWC_T_FO_NOTE .
  methods GET_NOTES_FROM_EVENT
    importing
      !IT_EVENT_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_FO_NOTE type ZAWC_T_FO_NOTE .
protected section.
private section.

  data GO_TRANSACTION_MGR type ref to /BOBF/IF_TRA_TRANSACTION_MGR .
  class-data GO_TOR_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  class-data GO_ATT_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
  class-data GO_CONF type ref to /BOBF/IF_FRW_CONFIGURATION .

  methods GET_ATTACHMENT_LIST
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_DOCUMENT type /BOBF/T_ATF_DOCUMENT_K .
  methods GET_ATTACHMENT_CONTENT
    importing
      !IT_ATF_DOC_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_DOCUMENT_CONTENT type /BOBF/T_ATF_FILE_CONTENT_K .
ENDCLASS.



CLASS ZCL_AWC_FO_ATTACHMENT IMPLEMENTATION.


  METHOD add_attachment_to_fo.
    CONSTANTS c_att_folder_att_schema TYPE string VALUE 'DEFAULT'. ##NO_TEXT.
    CONSTANTS c_att_folder_storage_category TYPE string VALUE 'BS_ATF_DB'. ##NO_TEXT.

    CONSTANTS c_att_param_name              TYPE string VALUE 'File' ##NO_TEXT.
    CONSTANTS c_att_param_language_code TYPE string VALUE 'DE'. ##NO_TEXT.
    CONSTANTS c_att_param_att_type TYPE string VALUE 'ATCMT'. ##NO_TEXT.
    CONSTANTS c_att_param_att_schema TYPE string VALUE 'DEFAULT'. ##NO_TEXT.

    DATA: lt_tor_root_key              TYPE /bobf/t_frw_key,
          lt_attachment_key            TYPE /bobf/t_frw_key,
          lt_tor_id                    TYPE STANDARD TABLE OF /scmtms/tor_id,
          lt_filename                  TYPE STANDARD TABLE OF char255,
          lt_mod                       TYPE /bobf/t_frw_modification,

          ls_parameters                TYPE /bobf/s_atf_a_create_file,
          ls_attachment_folder         TYPE /bobf/s_atf_root_k,
          lr_s_parameters              TYPE REF TO data,

          lv_add_attachment_action_key TYPE /bobf/conf_key,
          lv_creation_time             TYPE string.

    INSERT VALUE #( key = iv_root_key ) INTO TABLE lt_tor_root_key.

    "--------------------------------------------------------------------------------"
    " Try to get an existing instance of the node ATTACHMENTFOLDER for the current TOR BO.
    " If no instance is available (normally in cases where no attachments were added to
    " this document before), an instance is created.
    "--------------------------------------------------------------------------------"
    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_tor_root_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-attachmentfolder
      IMPORTING
        et_target_key           = lt_attachment_key
    ).

    IF lt_attachment_key IS INITIAL.
      ls_attachment_folder-key = /bobf/cl_frw_factory=>get_new_key( ).
      ls_attachment_folder-parent_key = iv_root_key.
      ls_attachment_folder-root_key = iv_root_key.

      ls_attachment_folder-user_id_cr = sy-uname.
      CONCATENATE sy-datum sy-uzeit INTO lv_creation_time.
      ls_attachment_folder-datetime_cr = lv_creation_time.

      ls_attachment_folder-att_exists_ind = abap_true.
      ls_attachment_folder-host_bo_key = /scmtms/if_tor_c=>sc_bo_key.
      ls_attachment_folder-host_node_key = /scmtms/if_tor_c=>sc_node-root.
      ls_attachment_folder-host_key = iv_root_key.

      ls_attachment_folder-att_schema = c_att_folder_att_schema.
      ls_attachment_folder-storage_category = c_att_folder_storage_category.
      ls_attachment_folder-allow_attachment = abap_true.

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_attachment_folder
          iv_node        = /scmtms/if_tor_c=>sc_node-attachmentfolder
          iv_association = /scmtms/if_tor_c=>sc_association-root-attachmentfolder
          iv_source_node = /scmtms/if_tor_c=>sc_node-root
        CHANGING
         ct_mod          = lt_mod
      ).

      go_tor_srv_mgr->modify(
        EXPORTING
          it_modification = lt_mod
        IMPORTING
          eo_message      = DATA(lo_message)
      ).

      INSERT VALUE #( key = ls_attachment_folder-key ) INTO TABLE lt_attachment_key.
    ENDIF.

    "--------------------------------------------------------------------------------"
    " Get action key for delegated object node instance
    "--------------------------------------------------------------------------------"
    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_act
        iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_action-root-create_file
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
      RECEIVING
        ev_content_key      = lv_add_attachment_action_key
    ).

    "--------------------------------------------------------------------------------"
    "Populate the parameter structure and call action
*    "--------------------------------------------------------------------------------"
    IF is_media IS NOT INITIAL.
      ls_parameters-file_name = is_media-filename.
      ls_parameters-name = c_att_param_name.
      ls_parameters-description_language_code = c_att_param_language_code.
      ls_parameters-mime_code = is_media-mimetype.
      ls_parameters-attachment_type = c_att_param_att_type.
      ls_parameters-attachment_schema = c_att_param_att_schema.

      ls_parameters-alternative_name = is_media-filename.
      ls_parameters-content = is_media-value.
      ls_parameters-description_content = is_media-description.

      GET REFERENCE OF ls_parameters INTO lr_s_parameters.

      go_tor_srv_mgr->do_action(
        EXPORTING
          iv_act_key           = lv_add_attachment_action_key
          is_parameters        = lr_s_parameters
          it_key               = lt_attachment_key
          IMPORTING
            eo_message        = DATA(lo_act_message)
            et_failed_key     = DATA(lt_act_failed_key)
      ).
    ENDIF.
    "--------------------------------------------------------------------------------"
    " Persist on DB
    "--------------------------------------------------------------------------------"
    go_transaction_mgr->save(
      IMPORTING
        eo_message  = DATA(lo_sav_message)
        ev_rejected = DATA(lv_rejected)
    ).

    IF lv_rejected IS INITIAL.
      "fill exporting structure..
*      es_attachment-attachment_key =
    ELSE.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_message
          is_textid  = zcx_awc_fo_overview=>attachment_creation_failed                " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
        ).
    ENDIF.
  ENDMETHOD.


  METHOD add_note_to_event.
    DATA:
      lv_language_key           TYPE laiso VALUE 'DE',
      lv_text_type              TYPE /bobf/txc_text_type,
      lv_text_assoc_key         TYPE /bobf/conf_key,
      lv_text_content_assoc_key TYPE /bobf/conf_key,
      lv_text_node_key          TYPE /bobf/conf_key,
      lv_text_content_node_key  TYPE /bobf/conf_key,

      ls_text_root              TYPE /bobf/s_txc_root_k,
      ls_text_text              TYPE /bobf/s_txc_txt_k,
      ls_text_content           TYPE /bobf/s_txc_con_k,

      lt_mod                    TYPE /bobf/t_frw_modification,
      lt_event_key              TYPE /bobf/t_frw_key,
      lt_text_collection_key    TYPE /bobf/t_frw_key,

      lo_change                 TYPE REF TO /bobf/if_tra_change,
      lo_message                TYPE REF TO /bobf/if_frw_message,

      ls_t_content              TYPE /bobf/d_txccon.

    FIELD-SYMBOLS:
      <ls_text_root_key> TYPE /bobf/s_frw_key.

    INSERT VALUE #( key = iv_event_key ) INTO TABLE lt_event_key.

    get_notes_from_event(
      EXPORTING
        it_event_key = lt_event_key
      IMPORTING
        et_fo_note   = DATA(lt_event_note)
    ).

    "--------------------------------------------------------------------------------"
    " Get runtime keys for DO nodes and associations
    "--------------------------------------------------------------------------------"

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_content_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_assoc_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_content_assoc_key
    ).

    IF lt_event_note IS INITIAL.

      "Create text root
      ls_text_root-key = /bobf/cl_frw_factory=>get_new_key( ).
      ls_text_root-parent_key = iv_event_key.
      ls_text_root-root_key = iv_fo_key.

      ls_text_root-host_bo_key = /scmtms/if_tor_c=>sc_bo_key.
      ls_text_root-host_node_key = /scmtms/if_tor_c=>sc_node-executioninformation.
      ls_text_root-host_key = iv_fo_key.

      ls_text_root-text_schema_id = 'DEFAULT'.
      ls_text_root-text_exists_ind = abap_true.

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_text_root
          iv_node        = /scmtms/if_tor_c=>sc_node-executionnotes
          iv_association = /scmtms/if_tor_c=>sc_association-executioninformation-executionnotes
          iv_source_node = /scmtms/if_tor_c=>sc_node-executioninformation
        CHANGING
          ct_mod         = lt_mod
      ).

      APPEND INITIAL LINE TO lt_text_collection_key ASSIGNING <ls_text_root_key>.
      <ls_text_root_key>-key = ls_text_root-key.

      "--------------------------------------------------------------------------------"
      "Create text node
      "--------------------------------------------------------------------------------"
      ls_text_text-key = /bobf/cl_frw_factory=>get_new_key( ).
      ls_text_text-parent_key = <ls_text_root_key>-key.
      ls_text_text-root_key = iv_fo_key.

      ls_text_text-text_type = iv_text_type.
      ls_text_text-language_code = sy-langu.

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_text_text
          iv_node        = lv_text_node_key
          iv_association = lv_text_assoc_key
          iv_source_node = /scmtms/if_tor_c=>sc_node-executionnotes
        CHANGING
          ct_mod         = lt_mod
      ).

      "--------------------------------------------------------------------------------"
      " Create text_content node
      "--------------------------------------------------------------------------------"
      ls_text_content-key = /bobf/cl_frw_factory=>get_new_key( ).
      ls_text_content-parent_key = ls_text_text-key.
      ls_text_content-root_key =  iv_fo_key.

      ls_text_content-text = iv_text.

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_text_content
          iv_node        = lv_text_content_node_key
          iv_association = lv_text_content_assoc_key
          iv_source_node = lv_text_node_key
        CHANGING
          ct_mod         = lt_mod
      ).

      IF lt_mod IS NOT INITIAL.
        "--------------------------------------------------------------------------------"
        " Modify the BOPF buffer
        "--------------------------------------------------------------------------------"
        go_tor_srv_mgr->modify(
           EXPORTING
             it_modification = lt_mod
           IMPORTING
             eo_message = lo_message
         ).
      ENDIF.

      "--------------------------------------------------------------------------------"
      " Persist changes on database
      "--------------------------------------------------------------------------------"
      go_transaction_mgr->save(
              EXPORTING
                iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
              IMPORTING
                ev_rejected            = DATA(lo_rejected)
                eo_change              = lo_change
                eo_message             = lo_message
            ).

    ELSE.

      READ TABLE lt_event_note INDEX 1 INTO DATA(ls_event_note).
      IF sy-subrc = 0.

        ls_t_content-db_key     = ls_event_note-note_key.
        ls_t_content-parent_key = ls_event_note-text_key.
        ls_t_content-root_key   = iv_fo_key.
        ls_t_content-text       = iv_text.

        UPDATE /bobf/d_txccon FROM ls_t_content.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD add_note_to_fo.
    DATA:
      lv_language_key           TYPE laiso VALUE 'DE',
      lv_text_type              TYPE /bobf/txc_text_type,
      lv_text_assoc_key         TYPE /bobf/conf_key,
      lv_text_content_assoc_key TYPE /bobf/conf_key,
      lv_text_node_key          TYPE /bobf/conf_key,
      lv_text_content_node_key  TYPE /bobf/conf_key,

      ls_text_root              TYPE /bobf/s_txc_root_k,
      ls_text_text              TYPE /bobf/s_txc_txt_k,
      ls_text_content           TYPE /bobf/s_txc_con_k,

      lt_mod                    TYPE /bobf/t_frw_modification,
      lt_tor_key                TYPE /bobf/t_frw_key,
      lt_text_collection_key    TYPE /bobf/t_frw_key,

      lo_change                 TYPE REF TO /bobf/if_tra_change,
      lo_message                TYPE REF TO /bobf/if_frw_message.

    FIELD-SYMBOLS:
      <ls_text_root_key> TYPE /bobf/s_frw_key.

    INSERT VALUE #( key = iv_fo_key ) INTO TABLE lt_tor_key.

    "Create text root
    ls_text_root-key = /bobf/cl_frw_factory=>get_new_key( ).
    ls_text_root-parent_key = iv_fo_key."<ls_fwo_keys>-key.
    ls_text_root-root_key = iv_fo_key."<ls_fwo_keys>-key.

    ls_text_root-host_bo_key = /scmtms/if_tor_c=>sc_bo_key.
    ls_text_root-host_node_key = /scmtms/if_tor_c=>sc_node-root.
    ls_text_root-host_key = iv_fo_key."<ls_fwo_keys>-key.

    ls_text_root-text_schema_id = 'DEFAULT'.
    ls_text_root-text_exists_ind = abap_true.

    /scmtms/cl_mod_helper=>mod_create_single(
      EXPORTING
        is_data        = ls_text_root
        iv_node        = /scmtms/if_tor_c=>sc_node-textcollection
        iv_association = /scmtms/if_tor_c=>sc_association-root-textcollection
        iv_source_node = /scmtms/if_tor_c=>sc_node-root
      CHANGING
        ct_mod         = lt_mod
    ).

    APPEND INITIAL LINE TO lt_text_collection_key ASSIGNING <ls_text_root_key>.
    <ls_text_root_key>-key = ls_text_root-key.

    "--------------------------------------------------------------------------------"
    " Get runtime keys for DO nodes and associations
    "--------------------------------------------------------------------------------"

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_content_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_assoc_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_content_assoc_key
    ).

    "--------------------------------------------------------------------------------"
    "Create text node
    "--------------------------------------------------------------------------------"
    ls_text_text-key = /bobf/cl_frw_factory=>get_new_key( ).
    ls_text_text-parent_key = <ls_text_root_key>-key.
    ls_text_text-root_key = <ls_text_root_key>-key.

    ls_text_text-text_type = iv_text_type.
    ls_text_text-language_code = sy-langu.

    /scmtms/cl_mod_helper=>mod_create_single(
      EXPORTING
        is_data        = ls_text_text
        iv_node        = lv_text_node_key
        iv_association = lv_text_assoc_key
        iv_source_node = /scmtms/if_tor_c=>sc_node-textcollection
      CHANGING
        ct_mod         = lt_mod
    ).

    "--------------------------------------------------------------------------------"
    " Create text_content node
    "--------------------------------------------------------------------------------"
    ls_text_content-key = /bobf/cl_frw_factory=>get_new_key( ).
    ls_text_content-parent_key = ls_text_text-key.
    ls_text_content-root_key =  <ls_text_root_key>-key.

    ls_text_content-text = iv_text.

    /scmtms/cl_mod_helper=>mod_create_single(
      EXPORTING
        is_data        = ls_text_content
        iv_node        = lv_text_content_node_key
        iv_association = lv_text_content_assoc_key
        iv_source_node = lv_text_node_key
      CHANGING
        ct_mod         = lt_mod
    ).

    "--------------------------------------------------------------------------------"
    " Modify the BOPF buffer
    "--------------------------------------------------------------------------------"
    go_tor_srv_mgr->modify(
       EXPORTING
         it_modification = lt_mod
       IMPORTING
         eo_message = lo_message
     ).

    "--------------------------------------------------------------------------------"
    " Persist changes on database
    "--------------------------------------------------------------------------------"
    go_transaction_mgr->save(
               EXPORTING
                 iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
               IMPORTING
                 ev_rejected            = DATA(lv_rejected)
                 eo_change              = lo_change
                 eo_message             = lo_message
             ).

    IF lv_rejected IS INITIAL.
      es_note-note_key  = ls_text_content-key.
      es_note-key       = iv_fo_key.
      es_note-txt_type  = iv_text_type.
      es_note-text      = iv_text.
    ELSE.
      NEW zcl_awc_fo_overview_helper( )->raise_exception(
        EXPORTING
          io_message = lo_message
          is_textid  = zcx_awc_fo_overview=>note_creation_failed                " T100 Schlüssel mit Abbildung der Parameter auf Attributnamen
      ).
    ENDIF.
  ENDMETHOD.


  METHOD constructor.

    go_tor_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    go_conf = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    go_transaction_mgr = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).

  ENDMETHOD.


  method DELETE_ATTACHMENT.
    DELETE FROM /BOBF/D_ATF_DO WHERE db_key = iv_attachment_key.
  endmethod.


  METHOD get_attachments.

    DATA: lt_document_keys TYPE /bobf/t_frw_key,
          lt_fo_keys       TYPE /bobf/t_frw_key,
          lt_attachment    TYPE zawc_t_fo_attachment.


    get_attachment_list(
      EXPORTING
        it_fu_key   = it_fo_keys    " AWC Key
      IMPORTING
        et_document = DATA(lt_document)
    ).

    LOOP AT lt_document ASSIGNING FIELD-SYMBOL(<fs_document>).
      INSERT VALUE #( key = <fs_document>-key ) INTO TABLE lt_document_keys.
    ENDLOOP.

    get_attachment_content(
      EXPORTING
        it_atf_doc_key      = lt_document_keys
      IMPORTING
        et_document_content = DATA(lt_document_content)
    ).

    LOOP AT lt_document_content ASSIGNING FIELD-SYMBOL(<fs_document_content>).

      READ TABLE lt_document ASSIGNING <fs_document> WITH KEY key = <fs_document_content>-key.

      INSERT VALUE #(
                      attachment_key  = <fs_document>-key
                      key          = <fs_document_content>-root_key
                      mimetype        = <fs_document>-mimecode
                      filename        = <fs_document>-alternative_name
                      value           = <fs_document_content>-content
                      filesize        = <fs_document>-filesize_content
                      datetime_cr     = <fs_document>-datetime_cr
                      user_id_cr      = <fs_document>-user_id_cr
                      description     = <fs_document>-description
                    ) INTO TABLE lt_attachment.
    ENDLOOP.

    et_attachment = lt_attachment.
  ENDMETHOD.


  METHOD GET_ATTACHMENT_CONTENT.
    DATA: lt_attachment_key        TYPE /bobf/t_frw_key,
          lv_assoc_atf_doc_key     TYPE /bobf/conf_key,
          lv_assoc_doc_content_key TYPE /bobf/conf_key,
          lv_doc_content_node_key  TYPE /bobf/conf_key,
          lt_document_content      TYPE /bobf/t_atf_file_content_k.

    go_conf->get_content_key_mapping(
    EXPORTING
      iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
      iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_association-document-file_content
     iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
    RECEIVING
      ev_content_key      = lv_assoc_doc_content_key
  ).

    go_conf->get_content_key_mapping(
       EXPORTING
         iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
         iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_node-document
         iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
       RECEIVING
         ev_content_key      = lv_doc_content_node_key
     ).

    go_tor_srv_mgr->retrieve_by_association(
     EXPORTING
       iv_node_key             = lv_doc_content_node_key
       it_key                  = it_atf_doc_key
       iv_association          = lv_assoc_doc_content_key
       iv_fill_data            = abap_true
     IMPORTING
       et_data                 = lt_document_content
   ).
    et_document_content = lt_document_content.
  ENDMETHOD.


  METHOD get_attachment_list.
    DATA: lt_attachment_key TYPE /bobf/t_frw_key,
          lt_document       TYPE /bobf/t_atf_document_k.

    DATA(lo_conf) = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    "--------------------------------------------------------------------------------"
    " Try to get an existing instance of the node ATTACHMENTFOLDER for the current TOR BO.
    " If no instance is available (normally in cases where no attachments were added to
    " this document before), an instance is created.
    "--------------------------------------------------------------------------------"
    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fu_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-attachmentfolder
      IMPORTING
        et_key_link             = DATA(lt_tor_to_attach_key_link)
        et_target_key           = lt_attachment_key
    ).

    "--------------------------------------------------------------------------------"
    " Get association key for delegated object node instance
    DATA(lv_assoc_atf_doc_key) = lo_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_association-root-document
       iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-attachmentfolder
        it_key                  = lt_attachment_key
        iv_association          = lv_assoc_atf_doc_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_document
        et_key_link             = DATA(lt_attach_to_doc_key_link)
    ).

    LOOP AT lt_document INTO DATA(ls_document)." WHERE visibility_type = 'X'.
      APPEND ls_document TO et_document.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_notes_from_event.

    DATA : lt_event_keys       TYPE /bobf/t_frw_key,
           lt_tor_text_data    TYPE /bobf/t_txc_txt_k,
           lt_tor_text_key     TYPE /bobf/t_frw_key,
           lt_tor_note_content TYPE /bobf/t_txc_con_k,
           lt_text_col         TYPE /bobf/t_txc_root_k.


*    INSERT VALUE #( key = iv_event_key ) INTO TABLE lt_event_keys.
    lt_event_keys = it_event_key.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executioninformation
        it_key                  = lt_event_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-executioninformation-executionnotes
        iv_fill_data            = abap_true
      IMPORTING
        et_target_key           = DATA(lt_tor_textcollection_key)
        et_data                 = lt_text_col
    ).

*-- Association Key of ROOT->TEXT
    DATA(lv_tor_to_txtcol_assoc) = go_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
                   iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executionnotes
        it_key                  = lt_tor_textcollection_key
        iv_association          = lv_tor_to_txtcol_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_text_data
        et_target_key           = lt_tor_text_key
     ).

*-- Association Key of TEXT->TEXT_CONTENT
    DATA(lv_txtcol_to_txtcontent_assoc) = go_conf->get_content_key_mapping(
                    iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                    iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
                    iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).


    DATA(lv_txtcol_to_key_assoc) = go_conf->get_content_key_mapping(
             iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
             iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
             iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).

    go_tor_srv_mgr->retrieve_by_association(
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
        READ TABLE lt_text_col ASSIGNING FIELD-SYMBOL(<fs_text_col>) WITH KEY key = <ls_tor_text_data>-parent_key.

        INSERT VALUE #( note_key      = <ls_tor_text_data>-key
                        key           = <ls_tor_text_data>-root_key
                        txt_type      = <ls_tor_text_data>-text_type
                        text          = <ls_tor_note_content>-text
                        datetime_cr	  = <ls_tor_text_data>-datetime_cr
                        user_id_cr    = <ls_tor_text_data>-user_id_cr
                        datetime_ch	  = <ls_tor_text_data>-datetime_ch
                        user_id_ch    = <ls_tor_text_data>-user_id_ch
                        event_key     = <fs_text_col>-parent_key
                      ) INTO TABLE et_fo_note.
      ENDLOOP.
  ENDMETHOD.


  METHOD get_notes_from_fo.

    DATA : lt_fo_keys          TYPE /bobf/t_frw_key,
           lt_tor_text_data    TYPE /bobf/t_txc_txt_k,
           lt_tor_text_key     TYPE /bobf/t_frw_key,
           lt_tor_note_content TYPE /bobf/t_txc_con_k,
           lt_fo_data          TYPE /scmtms/t_tor_root_k.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = it_fo_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-root-textcollection
      IMPORTING
        et_target_key           = DATA(lt_tor_textcollection_key)
    ).

    go_tor_srv_mgr->retrieve(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root                 " Node
        it_key                  = it_fo_keys                 " Key Table
        iv_fill_data            = abap_true        " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
      IMPORTING
        et_data                 = lt_fo_data
    ).

*-- Association Key of ROOT->TEXT
    DATA(lv_tor_to_txtcol_assoc) = go_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
                   iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-textcollection
        it_key                  = lt_tor_textcollection_key
        iv_association          = lv_tor_to_txtcol_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_text_data
*        et_target_key           = lt_tor_text_key
     ).

    LOOP AT lt_tor_text_data ASSIGNING FIELD-SYMBOL(<fs_tor_text_data>) WHERE internal_ind = ''.
      INSERT VALUE #( key = <fs_tor_text_data>-key ) INTO TABLE lt_tor_text_key.
    ENDLOOP.

*-- Association Key of TEXT->TEXT_CONTENT
    DATA(lv_txtcol_to_txtcontent_assoc) = go_conf->get_content_key_mapping(
                    iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                    iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
                    iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).


    DATA(lv_txtcol_to_key_assoc) = go_conf->get_content_key_mapping(
             iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
             iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
             iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection ).

    go_tor_srv_mgr->retrieve_by_association(
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

      READ TABLE lt_fo_data ASSIGNING FIELD-SYMBOL(<fs_fo_data>) WITH KEY key = <ls_tor_text_data>-root_key.

      IF <ls_tor_text_data> IS ASSIGNED AND <fs_fo_data> IS ASSIGNED.
        INSERT VALUE #( note_key      = <ls_tor_text_data>-key
                        key           = <ls_tor_text_data>-root_key
                        txt_type      = <ls_tor_text_data>-text_type
                        text          = <ls_tor_note_content>-text
                        datetime_cr	  = <ls_tor_text_data>-datetime_cr
                        user_id_cr    = <ls_tor_text_data>-user_id_cr
                        datetime_ch	  = <ls_tor_text_data>-datetime_ch
                        user_id_ch    = <ls_tor_text_data>-user_id_ch
                        tor_id        = <fs_fo_data>-tor_id
                      ) INTO TABLE et_fo_note.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD update_event_note.

    DATA : lt_event_keys             TYPE /bobf/t_frw_key,
           lt_tor_text_data          TYPE /bobf/t_txc_txt_k,
           lt_tor_text_key           TYPE /bobf/t_frw_key,
           lt_tor_note_content       TYPE /bobf/t_txc_con_k,
           lt_text_col               TYPE /bobf/t_txc_root_k,
           ls_text_text              TYPE /bobf/s_txc_txt_k,
           ls_text_content           TYPE /bobf/s_txc_con_k,
           lv_text_type              TYPE /bobf/txc_text_type,
           lv_text_assoc_key         TYPE /bobf/conf_key,
           lt_mod                    TYPE /bobf/t_frw_modification,
           lv_text_content_assoc_key TYPE /bobf/conf_key,
           lv_text_node_key          TYPE /bobf/conf_key,
           ls_t_content              TYPE /bobf/d_txccon,
           lv_text_content_node_key  TYPE /bobf/conf_key.

    INSERT VALUE #( key = iv_event_key )  INTO TABLE lt_event_keys.

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executioninformation
        it_key                  = lt_event_keys
        iv_association          = /scmtms/if_tor_c=>sc_association-executioninformation-executionnotes
        iv_fill_data            = abap_true
      IMPORTING
        et_target_key           = DATA(lt_tor_textcollection_key)
        et_data                 = lt_text_col
    ).

*-- Association Key of ROOT->TEXT
    DATA(lv_tor_to_txtcol_assoc) = go_conf->get_content_key_mapping(
                   iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                   iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
                   iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-executionnotes
        it_key                  = lt_tor_textcollection_key
        iv_association          = lv_tor_to_txtcol_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_text_data
        et_target_key           = lt_tor_text_key
     ).

    READ TABLE lt_tor_text_data INDEX 1 INTO DATA(ls_text).

*-- Association Key of TEXT->TEXT_CONTENT
    DATA(lv_txtcol_to_txtcontent_assoc) = go_conf->get_content_key_mapping(
                    iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
                    iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
                    iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).


    DATA(lv_txtcol_to_key_assoc) = go_conf->get_content_key_mapping(
             iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
             iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
             iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_content_node_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_assoc_key
    ).

    go_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-text-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-executionnotes
      RECEIVING
        ev_content_key      = lv_text_content_assoc_key
    ).

    go_tor_srv_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = lv_txtcol_to_key_assoc
        it_key                  = lt_tor_text_key
        iv_association          = lv_txtcol_to_txtcontent_assoc
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_tor_note_content
    ).

    READ TABLE lt_tor_note_content INDEX 1 INTO DATA(ls_content).
    "--------------------------------------------------------------------------------"
    " Create text_content node
    "--------------------------------------------------------------------------------"
    ls_t_content-db_key = ls_content-key. "/bobf/cl_frw_factory=>get_new_key( ).
    ls_t_content-parent_key = ls_text-key.
    ls_t_content-root_key =  iv_fo_key.

    ls_t_content-text = iv_text.

*    /scmtms/cl_mod_helper=>mod_update_single(
*      EXPORTING
*        is_data        = ls_text_content
*        iv_node        = lv_text_content_node_key
*        iv_key         = ls_text_content-key
*        iv_bo_key      = /bobf/if_txc_c=>sc_bo_key
**        iv_association = lv_text_content_assoc_key
**        iv_source_node = lv_text_node_key
*      CHANGING
*        ct_mod         = lt_mod
*    ).

    UPDATE /bobf/d_txccon FROM ls_t_content.

    "--------------------------------------------------------------------------------"
    " Modify the BOPF buffer
    "--------------------------------------------------------------------------------"
    go_tor_srv_mgr->modify(
       EXPORTING
         it_modification = lt_mod
       IMPORTING
         eo_message = DATA(lo_mod_message)
     ).

    "--------------------------------------------------------------------------------"
    " Persist changes on database
    "--------------------------------------------------------------------------------"
    go_transaction_mgr->save(
            EXPORTING
              iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
            IMPORTING
              ev_rejected            = DATA(lo_rejected)
              eo_change              = DATA(lo_sav_change)
              eo_message             = DATA(lo_sav_message)
          ).
  ENDMETHOD.
ENDCLASS.
