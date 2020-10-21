class ZCL_AWC_FO_VEHICLE definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods GET_VEHICLE_RES_FOR_CARR
    importing
      !IT_CARRIER type /BOFU/T_BUPA_RELSHIP_K
    returning
      value(RT_VEHICLE_RESOURCE) type /SCMTMS/T_RES_VEH_ROOT_K .
protected section.
private section.

  class-data GO_VEH_SRV_MGR type ref to /BOBF/IF_TRA_SERVICE_MANAGER .
ENDCLASS.



CLASS ZCL_AWC_FO_VEHICLE IMPLEMENTATION.


  METHOD constructor.
    go_veh_srv_mgr = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( iv_bo_key = /scmtms/if_res_vehicle_c=>sc_bo_key ).
  ENDMETHOD.


METHOD get_vehicle_res_for_carr.

    DATA: lt_selpar      TYPE /bobf/t_frw_query_selparam,
          lt_vehicle_res TYPE /scmtms/t_res_veh_root_k.

    go_veh_srv_mgr->query(
      EXPORTING
        iv_query_key            = /scmtms/if_res_vehicle_c=>sc_query-root-qu_by_attributes
        it_selection_parameters = lt_selpar
        iv_fill_data            = abap_true
     IMPORTING
       et_data                 = lt_vehicle_res
*       et_key                  = DATA(lt_key)
       ).

    LOOP AT it_carrier INTO DATA(ls_carrier).
*      CONCATENATE '000' ls_carrier-partner INTO ls_carrier-partner.
      LOOP AT lt_vehicle_res INTO DATA(ls_vehicle_res) WHERE owner = ls_carrier-partner.
        APPEND ls_vehicle_res TO rt_vehicle_resource.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
