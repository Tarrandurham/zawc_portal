class ZCL_AWC_ATTACHMENT definition
  public
  final
  create public .

public section.

  methods ADD_NOTE
    importing
      !IV_TEXT_TYPE type /BOBF/TXC_TEXT_TYPE
      !IV_TEXT type /BOBF/TEXT_CONTENT
      !IV_FU_KEY type /BOBF/CONF_KEY
    raising
      ZCX_AWC_BOPF .
  methods ADD_ATTACHMENT_TO_TRQ_AND_FU
    importing
      !IV_ROOT_KEY type /BOBF/CONF_KEY
      !IS_MEDIA type ZSAWC_ATTACHMENT
    raising
      ZCX_AWC_BOPF .
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
  methods GET_ATTACHMENTS
    importing
      !IV_FU_KEY type /BOBF/CONF_KEY
    exporting
      !ET_ATTACHMENT type ZT_AWC_ATTACHMENT .
  methods GET_NOTES
    importing
      !IT_FU_KEY type /BOBF/T_FRW_KEY
    exporting
      !ET_TEXT_CONTENT type ZT_AWC_NOTE_CONTENT .
  methods DELETE_ATTACHMENT
    importing
      !IV_ATTACHMENT_KEY type /BOBF/CONF_KEY
    raising
      ZCX_AWC_BOPF .
  methods ADD_ATTACHMENT_TO_FU
    importing
      !IV_ROOT_KEY type /BOBF/CONF_KEY
      !IS_MEDIA type ZSAWC_ATTACHMENT optional
    raising
      ZCX_AWC_BOPF .
  methods ADD_NOTES
    importing
      !IV_REFERENCE_NR type /BOBF/TEXT_CONTENT
      !IV_SHIPPING_NOTI_NR type /BOBF/TEXT_CONTENT
      !IV_SHIPPING_NOTI_DOC type /BOBF/TEXT_CONTENT
      !IV_ADD_NOTE type /BOBF/TEXT_CONTENT
      !IV_FU_ROOT_KEY type /BOBF/CONF_KEY
    raising
      ZCX_AWC_BOPF .
  methods CONSTRUCTOR .
  PROTECTED SECTION.
private section.

  data MS_ADD_INFO type ZDAWC_ADD_INFO .

  methods ADD_ATTACHMENT_TO_TRQ
    importing
      !IV_ROOT_KEY type /BOBF/CONF_KEY
      !IS_MEDIA type ZSAWC_ATTACHMENT
    raising
      ZCX_AWC_BOPF .
ENDCLASS.



CLASS ZCL_AWC_ATTACHMENT IMPLEMENTATION.


  METHOD add_attachment_to_fu.
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_transaction_mgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
    DATA(lo_conf) = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    CONSTANTS c_att_folder_att_schema       TYPE string VALUE 'DEFAULT'. ##NO_TEXT.
    CONSTANTS c_att_folder_storage_category TYPE string VALUE 'BS_ATF_DB'. ##NO_TEXT.

    CONSTANTS c_att_param_name              TYPE string VALUE 'File' ##NO_TEXT.
    CONSTANTS c_att_param_language_code     TYPE string VALUE 'DE'. ##NO_TEXT.
    CONSTANTS c_att_param_att_type          TYPE string VALUE 'ATCMT'. ##NO_TEXT.
    CONSTANTS c_att_param_att_schema        TYPE string VALUE 'DEFAULT'. ##NO_TEXT.

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
    lo_tor_service_mgr->retrieve_by_association(
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

      lo_tor_service_mgr->modify(
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
    lo_conf->get_content_key_mapping(
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

      GET REFERENCE OF ls_parameters INTO lr_s_parameters.

      lo_tor_service_mgr->do_action(
        EXPORTING
          iv_act_key           = lv_add_attachment_action_key
          is_parameters        = lr_s_parameters
          it_key               = lt_attachment_key
      ).
    ENDIF.
    "--------------------------------------------------------------------------------"
    " Persist on DB
    "--------------------------------------------------------------------------------"
    lo_transaction_mgr->save(
      IMPORTING
        eo_message             = lo_message
    ).

    new zcl_awc_general( )->check_bopf_messages( lo_message ).
  ENDMETHOD.


  METHOD add_attachment_to_trq.
    DATA(lo_trq_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).
    DATA(lo_transaction_mgr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
    DATA(lo_conf) = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_trq_c=>sc_bo_key ).

    CONSTANTS c_att_folder_att_schema       TYPE string VALUE 'DEFAULT'. ##NO_TEXT.
    CONSTANTS c_att_folder_storage_category TYPE string VALUE 'BS_ATF_DB'. ##NO_TEXT.

    CONSTANTS c_att_param_name              TYPE string VALUE 'File' ##NO_TEXT.
    CONSTANTS c_att_param_language_code     TYPE string VALUE 'DE'. ##NO_TEXT.
    CONSTANTS c_att_param_att_type          TYPE string VALUE 'ATCMT'. ##NO_TEXT.
    CONSTANTS c_att_param_att_schema        TYPE string VALUE 'DEFAULT'. ##NO_TEXT.

    DATA: lt_trq_root_key              TYPE /bobf/t_frw_key,
          lt_attachment_key            TYPE /bobf/t_frw_key,
          lt_filename                  TYPE STANDARD TABLE OF char255,
          lt_mod                       TYPE /bobf/t_frw_modification,

          ls_parameters                TYPE /bobf/s_atf_a_create_file,
          ls_attachment_folder         TYPE /bobf/s_atf_root_k,
          lr_s_parameters              TYPE REF TO data,

          lv_add_attachment_action_key TYPE /bobf/conf_key,
          lv_creation_time             TYPE string.

    INSERT VALUE #( key = iv_root_key ) INTO TABLE lt_trq_root_key.

    "--------------------------------------------------------------------------------"
    " Try to get an existing instance of the node ATTACHMENTFOLDER for the current TRQ BO.
    " If no instance is available (normally in cases where no attachments were added to
    " this document before), an instance is created.
    "--------------------------------------------------------------------------------"
    lo_trq_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_trq_c=>sc_node-root
        it_key                  = lt_trq_root_key
        iv_association          = /scmtms/if_trq_c=>sc_association-root-attachmentfolder
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
      ls_attachment_folder-host_bo_key = /scmtms/if_trq_c=>sc_bo_key.
      ls_attachment_folder-host_node_key = /scmtms/if_trq_c=>sc_node-root.
      ls_attachment_folder-host_key = iv_root_key.

      ls_attachment_folder-att_schema = c_att_folder_att_schema.
      ls_attachment_folder-storage_category = c_att_folder_storage_category.
      ls_attachment_folder-allow_attachment = abap_true.

      /scmtms/cl_mod_helper=>mod_create_single(
        EXPORTING
          is_data        = ls_attachment_folder
          iv_node        = /scmtms/if_trq_c=>sc_node-attachmentfolder
          iv_association = /scmtms/if_trq_c=>sc_association-root-attachmentfolder
          iv_source_node = /scmtms/if_trq_c=>sc_node-root
        CHANGING
         ct_mod          = lt_mod
      ).

      lo_trq_service_mgr->modify( lt_mod ).

      INSERT VALUE #( key = ls_attachment_folder-key ) INTO TABLE lt_attachment_key.
    ENDIF.

    "--------------------------------------------------------------------------------"
    " Get action key for delegated object node instance
    "--------------------------------------------------------------------------------"
    lo_conf->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_act
        iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_action-root-create_file
        iv_do_root_node_key = /scmtms/if_trq_c=>sc_node-attachmentfolder
      RECEIVING
        ev_content_key      = lv_add_attachment_action_key
    ).

    "--------------------------------------------------------------------------------"
    "Populate the parameter structure and call action
    "--------------------------------------------------------------------------------"
    ls_parameters-file_name = is_media-filename.
    ls_parameters-name = c_att_param_name.
    ls_parameters-description_language_code = c_att_param_language_code.
    ls_parameters-mime_code = is_media-mimetype.
    ls_parameters-attachment_type = c_att_param_att_type.
    ls_parameters-attachment_schema = c_att_param_att_schema.

    ls_parameters-alternative_name = is_media-filename.

    ls_parameters-content = is_media-value.

    GET REFERENCE OF ls_parameters INTO lr_s_parameters.

    lo_trq_service_mgr->do_action(
      EXPORTING
        iv_act_key           = lv_add_attachment_action_key
        is_parameters        = lr_s_parameters
        it_key               = lt_attachment_key
         IMPORTING
        eo_change            = DATA(lo_change)
        eo_message           = DATA(lo_message)
    ).

    "--------------------------------------------------------------------------------"
    " Persist on DB
    "--------------------------------------------------------------------------------"
    lo_transaction_mgr->save(
      IMPORTING
        eo_message             = lo_message
    ).

    new zcl_awc_general( )->check_bopf_messages( lo_message ).
  ENDMETHOD.


  METHOD add_attachment_to_trq_and_fu.
    add_attachment_to_trq(
      EXPORTING
        iv_root_key = iv_root_key   " NodeID
        is_media    = is_media      " AWC structure for attachment
    ).

    NEW zcl_awc_fu( )->get_fu_keys_from_trq(
      EXPORTING
        iv_trq_key = iv_root_key    " NodeID
      IMPORTING
        et_fu_key  = DATA(lt_fu_key)    " NodeID
    ).

    LOOP AT lt_fu_key ASSIGNING FIELD-SYMBOL(<ls_fu_key>).
      add_attachment_to_fu(
        EXPORTING
          iv_root_key = <ls_fu_key>-key    " NodeID
          is_media    = is_media    " AWC structure for attachment
      ).
    ENDLOOP.
  ENDMETHOD.


  METHOD add_note.
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

    DATA(lo_trq_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_trq_c=>sc_bo_key ).

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_tor_key.

    "--------------------------------------------------------------------------------"
    " Try to get an existing instance of the node TEXT_COLLECTION for the current TOR BO.
    " If no instance is available (normally in cases where no notes were added to
    " this document before), an instance is created.
    "--------------------------------------------------------------------------------"
    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-root
        it_key                  = lt_tor_key
        iv_association          = /scmtms/if_tor_c=>sc_association-root-textcollection
      IMPORTING
        et_target_key           = lt_text_collection_key
    ).

    IF lt_text_collection_key IS INITIAL.
      READ TABLE lt_tor_key ASSIGNING FIELD-SYMBOL(<ls_fwo_keys>) INDEX 1.

      "Create text root
      ls_text_root-key = /bobf/cl_frw_factory=>get_new_key( ).
      ls_text_root-parent_key = <ls_fwo_keys>-key.
      ls_text_root-root_key = <ls_fwo_keys>-key.

      ls_text_root-host_bo_key = /scmtms/if_tor_c=>sc_bo_key.
      ls_text_root-host_node_key = /scmtms/if_tor_c=>sc_node-root.
      ls_text_root-host_key = <ls_fwo_keys>-key.

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
    ELSE.
      READ TABLE lt_text_collection_key ASSIGNING <ls_text_root_key> INDEX 1.
    ENDIF.

    "--------------------------------------------------------------------------------"
    " Get runtime keys for DO nodes and associations
    "--------------------------------------------------------------------------------"
    DATA(lo_tor_config) = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    lo_tor_config->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_node_key
    ).

    lo_tor_config->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
        iv_do_content_key   = /bobf/if_txc_c=>sc_node-text_content
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_content_node_key
    ).

    lo_tor_config->get_content_key_mapping(
      EXPORTING
        iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
        iv_do_content_key   = /bobf/if_txc_c=>sc_association-root-text
        iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-textcollection
      RECEIVING
        ev_content_key      = lv_text_assoc_key
    ).

    lo_tor_config->get_content_key_mapping(
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
    lo_tor_service_mgr->modify(
       EXPORTING
         it_modification = lt_mod
       IMPORTING
         eo_message = lo_message
     ).

    "--------------------------------------------------------------------------------"
    " Persist changes on database
    "--------------------------------------------------------------------------------"
    /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( )->save(
            EXPORTING
              iv_transaction_pattern = /bobf/if_tra_c=>gc_tp_save_and_continue
            IMPORTING
              ev_rejected            = DATA(lo_rejected)
              eo_change              = lo_change
              eo_message             = lo_message
          ).

    new zcl_awc_general( )->check_bopf_messages( lo_message ).
  ENDMETHOD.


  METHOD add_notes.

    add_note(
      EXPORTING
        iv_text_type = ms_add_info-reference_nr   " Textart
        iv_text      = iv_reference_nr    " Textinhalt
        iv_fu_key    = iv_fu_root_key    " NodeID
    ).

    add_note(
      EXPORTING
        iv_text_type = ms_add_info-shipping_noti_nr   " Textart
        iv_text      = iv_shipping_noti_nr   " Textinhalt
        iv_fu_key    = iv_fu_root_key    " NodeID
    ).

    add_note(
      EXPORTING
        iv_text_type = ms_add_info-shipping_noti_doc   " Textart
        iv_text      = iv_shipping_noti_doc   " Textinhalt
        iv_fu_key    = iv_fu_root_key    " NodeID
    ).

    add_note(
      EXPORTING
        iv_text_type  = ms_add_info-add_note
        iv_text       = iv_add_note
        iv_fu_key     = iv_fu_root_key
        ).
  ENDMETHOD.


  method CONSTRUCTOR.
    SELECT  * FROM zdawc_add_info
      INTO TABLE @DATA(lt_add_info).

    READ TABLE lt_add_info INTO ms_add_info INDEX 1.
    IF sy-subrc <> 0.
      CLEAR: ms_add_info.
    ENDIF.
  endmethod.


  method DELETE_ATTACHMENT.
    DELETE FROM /BOBF/D_ATF_DO WHERE db_key = iv_attachment_key.
  endmethod.


  METHOD get_attachments.
    DATA: lt_document_keys TYPE /bobf/t_frw_key,
          lt_fu_keys      TYPE /bobf/t_frw_key,
          lt_attachment    TYPE zt_awc_attachment.

    INSERT VALUE #( key = iv_fu_key ) INTO TABLE lt_fu_keys.

    get_attachment_list(
      EXPORTING
        it_fu_key                = lt_fu_keys    " AWC Key
      IMPORTING
        et_document               = DATA(lt_document)
    ).

    LOOP AT lt_document ASSIGNING FIELD-SYMBOL(<ls_document>).
      INSERT VALUE #( key = <ls_document>-key ) INTO TABLE lt_document_keys.
    ENDLOOP.

    get_attachment_content(
      EXPORTING
        it_atf_doc_key      = lt_document_keys    " NodeID
      IMPORTING
        et_document_content = DATA(lt_document_content)
    ).

    LOOP AT lt_document_content ASSIGNING FIELD-SYMBOL(<ls_document_content>).

      READ TABLE lt_document ASSIGNING <ls_document> WITH KEY key = <ls_document_content>-key.

      INSERT VALUE #(
                      attachment_key  = <ls_document>-key
                      fu_key          = <ls_document_content>-root_key
                      mimetype        = <ls_document>-mimecode
                      filename        = <ls_document>-alternative_name
                      value           = <ls_document_content>-content
                      filesize        = <ls_document>-filesize_content
                    ) INTO TABLE lt_attachment.
    ENDLOOP.

    et_attachment = lt_attachment.
  ENDMETHOD.


  METHOD get_attachment_content.
    DATA: lt_attachment_key        TYPE /bobf/t_frw_key,
          lv_assoc_atf_doc_key     TYPE /bobf/conf_key,
          lv_assoc_doc_content_key TYPE /bobf/conf_key,
          lv_doc_content_node_key  TYPE /bobf/conf_key,
          lt_document_content      TYPE /bobf/t_atf_file_content_k.

    DATA(lo_conf)            = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).

    lo_conf->get_content_key_mapping(
    EXPORTING
      iv_content_cat      = /bobf/if_conf_c=>sc_content_ass
      iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_association-document-file_content
     iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
    RECEIVING
      ev_content_key      = lv_assoc_doc_content_key
  ).

    lo_conf->get_content_key_mapping(
       EXPORTING
         iv_content_cat      = /bobf/if_conf_c=>sc_content_nod
         iv_do_content_key   = /bobf/if_attachment_folder_c=>sc_node-document
         iv_do_root_node_key = /scmtms/if_tor_c=>sc_node-attachmentfolder
       RECEIVING
         ev_content_key      = lv_doc_content_node_key
     ).

    lo_tor_service_mgr->retrieve_by_association(
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

    DATA(lo_tor_service_mgr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
    DATA(lo_conf) = /bobf/cl_frw_factory=>get_configuration( iv_bo_key = /scmtms/if_tor_c=>sc_bo_key ).

    "--------------------------------------------------------------------------------"
    " Try to get an existing instance of the node ATTACHMENTFOLDER for the current TOR BO.
    " If no instance is available (normally in cases where no attachments were added to
    " this document before), an instance is created.
    "--------------------------------------------------------------------------------"
    lo_tor_service_mgr->retrieve_by_association(
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

    lo_tor_service_mgr->retrieve_by_association(
      EXPORTING
        iv_node_key             = /scmtms/if_tor_c=>sc_node-attachmentfolder
        it_key                  = lt_attachment_key
        iv_association          = lv_assoc_atf_doc_key
        iv_fill_data            = abap_true
      IMPORTING
        et_data                 = lt_document
        et_key_link             = DATA(lt_attach_to_doc_key_link)
    ).

    et_document               = lt_document.
  ENDMETHOD.


  METHOD get_notes.

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
        it_key                  = it_fu_key
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
ENDCLASS.
