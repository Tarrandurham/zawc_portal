class ZCL_ZAWC_FO_OVERVIEW_MPC_EXT definition
  public
  inheriting from ZCL_ZAWC_FO_OVERVIEW_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZAWC_FO_OVERVIEW_MPC_EXT IMPLEMENTATION.


  METHOD define.

    super->define( ).

    DATA(lx_entity) = model->get_entity_type( iv_entity_name = 'EtAttachment' ).

    IF lx_entity IS BOUND.
      DATA(lx_property) = lx_entity->get_property( iv_property_name = 'Mimetype' ).

      lx_property->set_as_content_type( ).
    ENDIF.

    model->set_no_conversion( iv_no_conversion = abap_true ).

  ENDMETHOD.
ENDCLASS.
