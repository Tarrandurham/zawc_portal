class ZCL_Z_AWC_TIME_SLOT_DPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_DATA
  abstract
  create public .

public section.

  interfaces /IWBEP/IF_SB_DPC_COMM_SERVICES .
  interfaces /IWBEP/IF_SB_GEN_DPC_INJECTION .
  interfaces IF_SADL_GW_DPC_UTIL .
  interfaces IF_SADL_GW_EXTENSION_CONTROL .
  interfaces IF_SADL_GW_QUERY_CONTROL .

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~DELETE_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_IS_CONDITIONAL_IMPLEMENTED
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_IS_CONDI_IMPLE_FOR_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~PATCH_ENTITY
    redefinition .
protected section.

  data mo_injection type ref to /IWBEP/IF_SB_GEN_DPC_INJECTION .

  methods ETDSAPPSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETDSAPP
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETDSAPPSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETDSAPPSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETDSAPP
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETDSAPPSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_Z_AWC_TIME_SLOT_MPC=>TT_ETDSAPP
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETDSAPPSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETDSAPP
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETREFDOCSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETREFDOC
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETREFDOCSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETREFDOCSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETREFDOC
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETREFDOCSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_Z_AWC_TIME_SLOT_MPC=>TT_ETREFDOC
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETREFDOCSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETREFDOC
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETSLOTASSIGNSET_CREATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_C optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETSLOTASSIGN
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETSLOTASSIGNSET_DELETE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_D optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETSLOTASSIGNSET_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETSLOTASSIGN
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETSLOTASSIGNSET_GET_ENTITYSET
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_FILTER_SELECT_OPTIONS type /IWBEP/T_MGW_SELECT_OPTION
      !IS_PAGING type /IWBEP/S_MGW_PAGING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IT_ORDER type /IWBEP/T_MGW_SORTING_ORDER
      !IV_FILTER_STRING type STRING
      !IV_SEARCH_STRING type STRING
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITYSET optional
    exporting
      !ET_ENTITYSET type ZCL_Z_AWC_TIME_SLOT_MPC=>TT_ETSLOTASSIGN
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_CONTEXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
  methods ETSLOTASSIGNSET_UPDATE_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY_U optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
      !IO_DATA_PROVIDER type ref to /IWBEP/IF_MGW_ENTRY_PROVIDER optional
    exporting
      !ER_ENTITY type ZCL_Z_AWC_TIME_SLOT_MPC=>TS_ETSLOTASSIGN
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .

  methods CHECK_SUBSCRIPTION_AUTHORITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_AWC_TIME_SLOT_DPC IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
    CAST /iwbep/if_mgw_appl_srv_runtime( if_sadl_gw_dpc_util~get_dpc( ) )->create_deep_entity(
                   EXPORTING io_tech_request_context = io_tech_request_context
                             io_data_provider        = io_data_provider
                             io_expand               = io_expand
                   IMPORTING er_deep_entity          = er_deep_entity ).
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_CRT_ENTITY_BASE
*&* This class has been generated on 16.10.2020 09:58:16 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_Z_AWC_TIME_SLOT_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA etdsappset_create_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etdsapp.
 DATA etrefdocset_create_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etrefdoc.
 DATA etslotassignset_create_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etslotassign.
 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  EtDsappSet
*-------------------------------------------------------------------------*
     WHEN 'EtDsappSet'.
*     Call the entity set generated method
    etdsappset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = etdsappset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = etdsappset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtRefdocSet
*-------------------------------------------------------------------------*
     WHEN 'EtRefdocSet'.
*     Call the entity set generated method
    etrefdocset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = etrefdocset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = etrefdocset_create_entity
      CHANGING
        cr_data = er_entity
   ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtSlotassignSet
*-------------------------------------------------------------------------*
     WHEN 'EtSlotassignSet'.
*     Call the entity set generated method
    etslotassignset_create_entity(
         EXPORTING iv_entity_name     = iv_entity_name
                   iv_entity_set_name = iv_entity_set_name
                   iv_source_name     = iv_source_name
                   io_data_provider   = io_data_provider
                   it_key_tab         = it_key_tab
                   it_navigation_path = it_navigation_path
                   io_tech_request_context = io_tech_request_context
       	 IMPORTING er_entity          = etslotassignset_create_entity
    ).
*     Send specific entity data to the caller interfaces
    copy_data_to_ref(
      EXPORTING
        is_data = etslotassignset_create_entity
      CHANGING
        cr_data = er_entity
   ).

  when others.
    super->/iwbep/if_mgw_appl_srv_runtime~create_entity(
       EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         io_data_provider   = io_data_provider
         it_key_tab = it_key_tab
         it_navigation_path = it_navigation_path
      IMPORTING
        er_entity = er_entity
  ).
ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~DELETE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_DEL_ENTITY_BASE
*&* This class has been generated on 16.10.2020 09:58:16 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_Z_AWC_TIME_SLOT_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  EtDsappSet
*-------------------------------------------------------------------------*
      when 'EtDsappSet'.
*     Call the entity set generated method
     etdsappset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtRefdocSet
*-------------------------------------------------------------------------*
      when 'EtRefdocSet'.
*     Call the entity set generated method
     etrefdocset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtSlotassignSet
*-------------------------------------------------------------------------*
      when 'EtSlotassignSet'.
*     Call the entity set generated method
     etslotassignset_delete_entity(
          EXPORTING iv_entity_name     = iv_entity_name
                    iv_entity_set_name = iv_entity_set_name
                    iv_source_name     = iv_source_name
                    it_key_tab         = it_key_tab
                    it_navigation_path = it_navigation_path
                    io_tech_request_context = io_tech_request_context
     ).

   when others.
     super->/iwbep/if_mgw_appl_srv_runtime~delete_entity(
        EXPORTING
          iv_entity_name = iv_entity_name
          iv_entity_set_name = iv_entity_set_name
          iv_source_name = iv_source_name
          it_key_tab = it_key_tab
          it_navigation_path = it_navigation_path
 ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION.
    if_sadl_gw_dpc_util~get_dpc( )->execute_action( EXPORTING io_tech_request_context = io_tech_request_context
                                                    IMPORTING er_data                 = er_data ).
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY.
*&-----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_GETENTITY_BASE
*&* This class has been generated  on 16.10.2020 09:58:16 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_Z_AWC_TIME_SLOT_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA etdsappset_get_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etdsapp.
 DATA etrefdocset_get_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etrefdoc.
 DATA etslotassignset_get_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etslotassign.
 DATA lv_entityset_name TYPE string.
 DATA lr_entity TYPE REF TO data.       "#EC NEEDED

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  EtDsappSet
*-------------------------------------------------------------------------*
      WHEN 'EtDsappSet'.
*     Call the entity set generated method
          etdsappset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etdsappset_get_entity
                         es_response_context = es_response_context
          ).

        IF etdsappset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etdsappset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  EtRefdocSet
*-------------------------------------------------------------------------*
      WHEN 'EtRefdocSet'.
*     Call the entity set generated method
          etrefdocset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etrefdocset_get_entity
                         es_response_context = es_response_context
          ).

        IF etrefdocset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etrefdocset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  EtSlotassignSet
*-------------------------------------------------------------------------*
      WHEN 'EtSlotassignSet'.
*     Call the entity set generated method
          etslotassignset_get_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etslotassignset_get_entity
                         es_response_context = es_response_context
          ).

        IF etslotassignset_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etslotassignset_get_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.

      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~get_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITYSET.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TMP_ENTITYSET_BASE
*&* This class has been generated on 16.10.2020 09:58:16 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_Z_AWC_TIME_SLOT_DPC_EXT
*&-----------------------------------------------------------------------------------------------*
 DATA etdsappset_get_entityset TYPE zcl_z_awc_time_slot_mpc=>tt_etdsapp.
 DATA etrefdocset_get_entityset TYPE zcl_z_awc_time_slot_mpc=>tt_etrefdoc.
 DATA etslotassignset_get_entityset TYPE zcl_z_awc_time_slot_mpc=>tt_etslotassign.
 DATA lv_entityset_name TYPE string.

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  EtDsappSet
*-------------------------------------------------------------------------*
   WHEN 'EtDsappSet'.
*     Call the entity set generated method
      etdsappset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = etdsappset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = etdsappset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtRefdocSet
*-------------------------------------------------------------------------*
   WHEN 'EtRefdocSet'.
*     Call the entity set generated method
      etrefdocset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = etrefdocset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = etrefdocset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

*-------------------------------------------------------------------------*
*             EntitySet -  EtSlotassignSet
*-------------------------------------------------------------------------*
   WHEN 'EtSlotassignSet'.
*     Call the entity set generated method
      etslotassignset_get_entityset(
        EXPORTING
         iv_entity_name = iv_entity_name
         iv_entity_set_name = iv_entity_set_name
         iv_source_name = iv_source_name
         it_filter_select_options = it_filter_select_options
         it_order = it_order
         is_paging = is_paging
         it_navigation_path = it_navigation_path
         it_key_tab = it_key_tab
         iv_filter_string = iv_filter_string
         iv_search_string = iv_search_string
         io_tech_request_context = io_tech_request_context
       IMPORTING
         et_entityset = etslotassignset_get_entityset
         es_response_context = es_response_context
       ).
*     Send specific entity data to the caller interface
      copy_data_to_ref(
        EXPORTING
          is_data = etslotassignset_get_entityset
        CHANGING
          cr_data = er_entityset
      ).

    WHEN OTHERS.
      super->/iwbep/if_mgw_appl_srv_runtime~get_entityset(
        EXPORTING
          iv_entity_name = iv_entity_name
          iv_entity_set_name = iv_entity_set_name
          iv_source_name = iv_source_name
          it_filter_select_options = it_filter_select_options
          it_order = it_order
          is_paging = is_paging
          it_navigation_path = it_navigation_path
          it_key_tab = it_key_tab
          iv_filter_string = iv_filter_string
          iv_search_string = iv_search_string
          io_tech_request_context = io_tech_request_context
       IMPORTING
         er_entityset = er_entityset ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_IS_CONDITIONAL_IMPLEMENTED.
    TRY.
        rv_conditional_active = if_sadl_gw_dpc_util~get_dpc( )->get_is_conditional_implemented(
                                               iv_operation_type  = iv_operation_type
                                               iv_entity_set_name = iv_entity_set_name ).
      CATCH /iwbep/cx_mgw_tech_exception /iwbep/cx_mgw_busi_exception.
        rv_conditional_active = super->/iwbep/if_mgw_appl_srv_runtime~get_is_conditional_implemented(
                                       iv_operation_type     = iv_operation_type
                                       iv_entity_set_name    = iv_entity_set_name ).
    ENDTRY.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_IS_CONDI_IMPLE_FOR_ACTION.
    TRY.
        rv_conditional_active = if_sadl_gw_dpc_util~get_dpc( )->get_is_condi_imple_for_action( iv_action_name ).
      CATCH /iwbep/cx_mgw_tech_exception /iwbep/cx_mgw_busi_exception.
        rv_conditional_active = super->/iwbep/if_mgw_appl_srv_runtime~get_is_condi_imple_for_action( iv_action_name ).
    ENDTRY.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~PATCH_ENTITY.
    CASE io_tech_request_context->get_entity_set_name( ).
      WHEN 'EtDsappSet'
        OR 'EtRefdocSet'
        OR 'EtSlotassignSet'
      .
        CAST /iwbep/if_mgw_appl_srv_runtime( if_sadl_gw_dpc_util~get_dpc( ) )->patch_entity(
                       EXPORTING io_tech_request_context = io_tech_request_context
                                 io_data_provider        = io_data_provider
                       IMPORTING er_entity               = er_entity  ).
      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~patch_entity(
                       EXPORTING io_tech_request_context = io_tech_request_context
                                 io_data_provider        = io_data_provider
                                 iv_entity_name          = iv_entity_name
                                 iv_entity_set_name      = iv_entity_set_name
                                 iv_source_name          = iv_source_name
                                 it_key_tab              = it_key_tab
                                 it_navigation_path      = it_navigation_path
                       IMPORTING er_entity               = er_entity  ).
    ENDCASE.
  endmethod.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~UPDATE_ENTITY.
*&----------------------------------------------------------------------------------------------*
*&  Include           /IWBEP/DPC_TEMP_UPD_ENTITY_BASE
*&* This class has been generated on 16.10.2020 09:58:16 in client 100
*&*
*&*       WARNING--> NEVER MODIFY THIS CLASS <--WARNING
*&*   If you want to change the DPC implementation, use the
*&*   generated methods inside the DPC provider subclass - ZCL_Z_AWC_TIME_SLOT_DPC_EXT
*&-----------------------------------------------------------------------------------------------*

 DATA etdsappset_update_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etdsapp.
 DATA etrefdocset_update_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etrefdoc.
 DATA etslotassignset_update_entity TYPE zcl_z_awc_time_slot_mpc=>ts_etslotassign.
 DATA lv_entityset_name TYPE string.
 DATA lr_entity TYPE REF TO data. "#EC NEEDED

lv_entityset_name = io_tech_request_context->get_entity_set_name( ).

CASE lv_entityset_name.
*-------------------------------------------------------------------------*
*             EntitySet -  EtDsappSet
*-------------------------------------------------------------------------*
      WHEN 'EtDsappSet'.
*     Call the entity set generated method
          etdsappset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etdsappset_update_entity
          ).
       IF etdsappset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etdsappset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  EtRefdocSet
*-------------------------------------------------------------------------*
      WHEN 'EtRefdocSet'.
*     Call the entity set generated method
          etrefdocset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etrefdocset_update_entity
          ).
       IF etrefdocset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etrefdocset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
*-------------------------------------------------------------------------*
*             EntitySet -  EtSlotassignSet
*-------------------------------------------------------------------------*
      WHEN 'EtSlotassignSet'.
*     Call the entity set generated method
          etslotassignset_update_entity(
               EXPORTING iv_entity_name     = iv_entity_name
                         iv_entity_set_name = iv_entity_set_name
                         iv_source_name     = iv_source_name
                         io_data_provider   = io_data_provider
                         it_key_tab         = it_key_tab
                         it_navigation_path = it_navigation_path
                         io_tech_request_context = io_tech_request_context
             	 IMPORTING er_entity          = etslotassignset_update_entity
          ).
       IF etslotassignset_update_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
          copy_data_to_ref(
            EXPORTING
              is_data = etslotassignset_update_entity
            CHANGING
              cr_data = er_entity
          ).
        ELSE.
*         In case of initial values - unbind the entity reference
          er_entity = lr_entity.
        ENDIF.
      WHEN OTHERS.
        super->/iwbep/if_mgw_appl_srv_runtime~update_entity(
           EXPORTING
             iv_entity_name = iv_entity_name
             iv_entity_set_name = iv_entity_set_name
             iv_source_name = iv_source_name
             io_data_provider   = io_data_provider
             it_key_tab = it_key_tab
             it_navigation_path = it_navigation_path
          IMPORTING
            er_entity = er_entity
    ).
 ENDCASE.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~COMMIT_WORK.
* Call RFC commit work functionality
DATA lt_message      TYPE bapiret2. "#EC NEEDED
DATA lv_message_text TYPE BAPI_MSG.
DATA lo_logger       TYPE REF TO /iwbep/cl_cos_logger.
DATA lv_subrc        TYPE syst-subrc.

lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

  IF iv_rfc_dest IS INITIAL OR iv_rfc_dest EQ 'NONE'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
      wait   = abap_true
    IMPORTING
      return = lt_message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      DESTINATION iv_rfc_dest
    EXPORTING
      wait                  = abap_true
    IMPORTING
      return                = lt_message
    EXCEPTIONS
      communication_failure = 1000 MESSAGE lv_message_text
      system_failure        = 1001 MESSAGE lv_message_text
      OTHERS                = 1002.

  IF sy-subrc <> 0.
    lv_subrc = sy-subrc.
    /iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
        EXPORTING
          iv_subrc            = lv_subrc
          iv_exp_message_text = lv_message_text
          io_logger           = lo_logger ).
  ENDIF.
  ENDIF.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~GET_GENERATION_STRATEGY.
* Get generation strategy
  rv_generation_strategy = '1'.
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~LOG_MESSAGE.
* Log message in the application log
DATA lo_logger TYPE REF TO /iwbep/cl_cos_logger.
DATA lv_text TYPE /iwbep/sup_msg_longtext.

  MESSAGE ID iv_msg_id TYPE iv_msg_type NUMBER iv_msg_number
    WITH iv_msg_v1 iv_msg_v2 iv_msg_v3 iv_msg_v4 INTO lv_text.

  lo_logger = mo_context->get_logger( ).
  lo_logger->log_message(
    EXPORTING
     iv_msg_type   = iv_msg_type
     iv_msg_id     = iv_msg_id
     iv_msg_number = iv_msg_number
     iv_msg_text   = lv_text
     iv_msg_v1     = iv_msg_v1
     iv_msg_v2     = iv_msg_v2
     iv_msg_v3     = iv_msg_v3
     iv_msg_v4     = iv_msg_v4
     iv_agent      = 'DPC' ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~RFC_EXCEPTION_HANDLING.
* RFC call exception handling
DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.

lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).

/iwbep/cl_sb_gen_dpc_rt_util=>rfc_exception_handling(
  EXPORTING
    iv_subrc            = iv_subrc
    iv_exp_message_text = iv_exp_message_text
    io_logger           = lo_logger ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~RFC_SAVE_LOG.
  DATA lo_logger  TYPE REF TO /iwbep/cl_cos_logger.
  DATA lo_message_container TYPE REF TO /iwbep/if_message_container.

  lo_logger = /iwbep/if_mgw_conv_srv_runtime~get_logger( ).
  lo_message_container = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

  " Save the RFC call log in the application log
  /iwbep/cl_sb_gen_dpc_rt_util=>rfc_save_log(
    EXPORTING
      is_return            = is_return
      iv_entity_type       = iv_entity_type
      it_return            = it_return
      it_key_tab           = it_key_tab
      io_logger            = lo_logger
      io_message_container = lo_message_container ).
  endmethod.


  method /IWBEP/IF_SB_DPC_COMM_SERVICES~SET_INJECTION.
* Unit test injection
  IF io_unit IS BOUND.
    mo_injection = io_unit.
  ELSE.
    mo_injection = me.
  ENDIF.
  endmethod.


  method CHECK_SUBSCRIPTION_AUTHORITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'CHECK_SUBSCRIPTION_AUTHORITY'.
  endmethod.


  method ETDSAPPSET_CREATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->create_entity( EXPORTING io_data_provider        = io_data_provider
                                                             io_tech_request_context = io_tech_request_context
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETDSAPPSET_DELETE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->delete_entity( io_tech_request_context ).
  endmethod.


  method ETDSAPPSET_GET_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->get_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETDSAPPSET_GET_ENTITYSET.
    if_sadl_gw_dpc_util~get_dpc( )->get_entityset( EXPORTING io_tech_request_context = io_tech_request_context
                                                   IMPORTING et_data                 = et_entityset
                                                             es_response_context     = es_response_context ).
  endmethod.


  method ETDSAPPSET_UPDATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->update_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                             io_data_provider        = io_data_provider
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETREFDOCSET_CREATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->create_entity( EXPORTING io_data_provider        = io_data_provider
                                                             io_tech_request_context = io_tech_request_context
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETREFDOCSET_DELETE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->delete_entity( io_tech_request_context ).
  endmethod.


  method ETREFDOCSET_GET_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->get_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETREFDOCSET_GET_ENTITYSET.
    if_sadl_gw_dpc_util~get_dpc( )->get_entityset( EXPORTING io_tech_request_context = io_tech_request_context
                                                   IMPORTING et_data                 = et_entityset
                                                             es_response_context     = es_response_context ).
  endmethod.


  method ETREFDOCSET_UPDATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->update_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                             io_data_provider        = io_data_provider
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETSLOTASSIGNSET_CREATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->create_entity( EXPORTING io_data_provider        = io_data_provider
                                                             io_tech_request_context = io_tech_request_context
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETSLOTASSIGNSET_DELETE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->delete_entity( io_tech_request_context ).
  endmethod.


  method ETSLOTASSIGNSET_GET_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->get_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                IMPORTING es_data                 = er_entity ).
  endmethod.


  method ETSLOTASSIGNSET_GET_ENTITYSET.
    if_sadl_gw_dpc_util~get_dpc( )->get_entityset( EXPORTING io_tech_request_context = io_tech_request_context
                                                   IMPORTING et_data                 = et_entityset
                                                             es_response_context     = es_response_context ).
  endmethod.


  method ETSLOTASSIGNSET_UPDATE_ENTITY.
    if_sadl_gw_dpc_util~get_dpc( )->update_entity( EXPORTING io_tech_request_context = io_tech_request_context
                                                             io_data_provider        = io_data_provider
                                                   IMPORTING es_data                 = er_entity ).
  endmethod.


  method IF_SADL_GW_DPC_UTIL~GET_DPC.

    DATA(lv_sadl_xml) =
               |<?xml version="1.0" encoding="utf-16"?>| &
               |<sadl:definition xmlns:sadl="http://sap.com/sap.nw.f.sadl" syntaxVersion="V2" >| &
               | <sadl:dataSource type="BOPF" name="EtDsappSet" binding="/SCWM/DSAPP~ROOT" />| &
               | <sadl:dataSource type="BOPF" name="EtRefdocSet" binding="/SCWM/DSAPP~DSAPP_REFDOC" />| &
               | <sadl:dataSource type="BOPF" name="EtSlotassignSet" binding="/SCWM/DSAPP~DSAPP_SLOTASSIGN" />| &
               |<sadl:resultSet>| &
               |<sadl:structure name="EtDsappSet" dataSource="EtDsappSet" maxEditMode="EX" >| &
               | <sadl:query name="EntitySetDefault">| &
               | </sadl:query>| &
               | <sadl:attribute name="APP_TYPE" binding="APP_TYPE" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CHECKIN_TIME" binding="CHECKIN_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="DOCK_TIME" binding="DOCK_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="UNDOCK_TIME" binding="UNDOCK_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CHECKOUT_TIME" binding="CHECKOUT_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="NOTE" binding="NOTE" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="REFDOCNO" binding="REFDOCNO" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="LP_PARENT" binding="LP_PARENT" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="ROOT_KEY" binding="ROOT_KEY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="NUMBER_PACKAGES" binding="NUMBER_PACKAGES" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="PROD_GRP" binding="PROD_GRP" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CATEGORY" binding="CATEGORY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="LOADPOINT_IND" binding="LOADPOINT_IND" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="KEY" binding="KEY" isOutput="TRUE" isKey="TRUE" />| &
               | <sadl:attribute name="IN_YARD_LENGTH" binding="IN_YARD_LENGTH" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="RECURRING_IND" binding="RECURRING_IND" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="STAGING_IND" binding="STAGING_IND" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="PL_CHECKIN_TIME" binding="PL_CHECKIN_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CREATED_BY" binding="CREATED_BY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CREATED_ON" binding="CREATED_ON" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CARRCREAIND" binding="CARRCREAIND" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="LOADPOINT" binding="LOADPOINT" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CHANGED_BY" binding="CHANGED_BY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CHANGED_ON" binding="CHANGED_ON" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="EEW_DSAPP_ROOT" binding="EEW_DSAPP_ROOT" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="SCAC_CARR" binding="SCAC_CARR" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="START_TIME" binding="START_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="FINISH_TIME" binding="FINISH_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="SLOT_ROOT_KEY" binding="SLOT_ROOT_KEY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="DOCNO" binding="DOCNO" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CARRIER" binding="CARRIER" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="APP_LENGTH" binding="APP_LENGTH" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="TRANSMEANSID" binding="TRANSMEANSID" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="MTR" binding="MTR" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="MOTSCODE" binding="MOTSCODE" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="DRIVER" binding="DRIVER" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="CAPALLOC" binding="CAPALLOC" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="REQ_START_TIME" binding="REQ_START_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="REQ_FINISH_TIME" binding="REQ_FINISH_TIME" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="PARENT_KEY" binding="PARENT_KEY" isOutput="TRUE" isKey="FALSE" />| &
               | <sadl:attribute name="REQ_LENGTH" binding="REQ_LENGTH" isOutput="TRUE" isKey="FALSE" />| .
    lv_sadl_xml = |{ lv_sadl_xml }| &
             | <sadl:attribute name="PROCSTATUS" binding="PROCSTATUS" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:association name="ETREFDOCSET" binding="DSAPP_REFDOC" target="EtRefdocSet" cardinality="zeroToMany" />| &
             | <sadl:association name="ETSLOTASSIGNSET" binding="DSAPP_SLOTASSIGN" target="EtSlotassignSet" cardinality="zeroToMany" />| &
             |</sadl:structure>| &
             |<sadl:structure name="EtRefdocSet" dataSource="EtRefdocSet" maxEditMode="EX" >| &
             | <sadl:query name="EntitySetDefault">| &
             | </sadl:query>| &
             | <sadl:attribute name="KEY" binding="KEY" isOutput="TRUE" isKey="TRUE" />| &
             | <sadl:attribute name="PARENT_KEY" binding="PARENT_KEY" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="ROOT_KEY" binding="ROOT_KEY" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="REFDOCNO" binding="REFDOCNO" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="REFDOCCAT" binding="REFDOCCAT" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="REFBSKEY" binding="REFBSKEY" isOutput="TRUE" isKey="FALSE" />| &
             |</sadl:structure>| &
             |<sadl:structure name="EtSlotassignSet" dataSource="EtSlotassignSet" maxEditMode="EX" >| &
             | <sadl:query name="EntitySetDefault">| &
             | </sadl:query>| &
             | <sadl:attribute name="KEY" binding="KEY" isOutput="TRUE" isKey="TRUE" />| &
             | <sadl:attribute name="PARENT_KEY" binding="PARENT_KEY" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="ROOT_KEY" binding="ROOT_KEY" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="LOADPOINT" binding="LOADPOINT" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="START_TIME" binding="START_TIME" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="FINISH_TIME" binding="FINISH_TIME" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="SLOT_ROOT_KEY" binding="SLOT_ROOT_KEY" isOutput="TRUE" isKey="FALSE" />| &
             | <sadl:attribute name="CAPALLOC" binding="CAPALLOC" isOutput="TRUE" isKey="FALSE" />| &
             |</sadl:structure>| &
             |</sadl:resultSet>| &
             |</sadl:definition>| .
    ro_dpc = cl_sadl_gw_dpc_factory=>create_for_sadl( iv_sadl_xml   = lv_sadl_xml
               iv_timestamp         = 20201016075821
               iv_uuid              = 'Z_AWC_TIME_SLOT'
               io_query_control     = me
               io_extension_control = me
               io_context           = me->mo_context ).
  endmethod.


  method IF_SADL_GW_EXTENSION_CONTROL~SET_EXTENSION_MAPPING.
" Intended to be overwritten
RETURN.
  endmethod.


  method IF_SADL_GW_QUERY_CONTROL~SET_QUERY_OPTIONS.
" Intended to be overwritten
RETURN.
  endmethod.
ENDCLASS.
