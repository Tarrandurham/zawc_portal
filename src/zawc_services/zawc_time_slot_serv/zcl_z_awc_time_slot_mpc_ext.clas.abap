class ZCL_Z_AWC_TIME_SLOT_MPC_EXT definition
  public
  inheriting from ZCL_Z_AWC_TIME_SLOT_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_Z_AWC_TIME_SLOT_MPC_EXT IMPLEMENTATION.


  METHOD define.

    super->define( ).

    DATA(lo_entity_type) = model->get_entity_type( 'EtDsapp' ).
*
*    lo_entity_type->get_property( 'DbKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'ParentKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'RootKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'SlotRootKey' )->disable_conversion( ).

    lo_entity_type->get_property( 'StartTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'FinishTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'ReqStartTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'ReqFinishTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'CheckinTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'DockTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'UndockTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'CheckoutTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'PlCheckinTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'CreatedOn' )->disable_conversion( ).
    lo_entity_type->get_property( 'ChangedOn' )->disable_conversion( ).
    lo_entity_type->get_property( 'AppLength' )->disable_conversion( ).
    lo_entity_type->get_property( 'ReqLength' )->disable_conversion( ).
    lo_entity_type->get_property( 'InYardLength' )->disable_conversion( ).

    lo_entity_type = model->get_entity_type( 'EtSlotassign' ).

    lo_entity_type->get_property( 'StartTime' )->disable_conversion( ).
    lo_entity_type->get_property( 'FinishTime' )->disable_conversion( ).
*    lo_entity_type->get_property( 'DbKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'ParentKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'RootKey' )->disable_conversion( ).

    lo_entity_type = model->get_entity_type( 'EtRefdoc' ).

*    lo_entity_type->get_property( 'DbKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'ParentKey' )->disable_conversion( ).
*    lo_entity_type->get_property( 'RootKey' )->disable_conversion( ).

  ENDMETHOD.
ENDCLASS.
