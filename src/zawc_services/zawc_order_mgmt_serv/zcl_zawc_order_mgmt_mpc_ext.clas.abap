class ZCL_ZAWC_ORDER_MGMT_MPC_EXT definition
  public
  inheriting from ZCL_ZAWC_ORDER_MGMT_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZAWC_ORDER_MGMT_MPC_EXT IMPLEMENTATION.


METHOD define.

  super->define( ).

* Content Type setzen für Medium
  DATA(lx_entity) = model->get_entity_type( iv_entity_name = 'EtAttachment' ).

  IF lx_entity IS BOUND.
    DATA(lx_property) = lx_entity->get_property( iv_property_name = 'AttachmentKey' ).

    lx_property->set_as_content_type( ).
  ENDIF.

  lx_entity = model->get_entity_type( iv_entity_name = 'EtTrqitem' ).
  lx_entity->get_property( 'GrossVolume' )->disable_conversion( ).
  lx_entity->get_property( 'GrossWeight' )->disable_conversion( ).
  lx_entity->get_property( 'QuaPcsVal' )->disable_conversion( ).

  lx_entity = model->get_entity_type( iv_entity_name = 'EtCharges' ).
  lx_entity->get_property( 'NetAmount' )->disable_conversion( ).
  lx_entity->get_property( 'TotalAmount' )->disable_conversion( ).

ENDMETHOD.
ENDCLASS.
