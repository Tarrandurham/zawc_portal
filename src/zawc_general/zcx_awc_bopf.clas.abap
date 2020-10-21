class ZCX_AWC_BOPF definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .
  interfaces IF_T100_MESSAGE .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional .
  methods GET_MESSAGES
    returning
      value(RT_MESSAGE) type /BOBF/T_FRW_MESSAGE_K .
  methods SET_MESSAGE
    importing
      !IO_MESSAGE type ref to /BOBF/IF_FRW_MESSAGE .
  methods GET_MESSAGE_OBJECT
    returning
      value(RO_MESSAGES) type ref to /BOBF/IF_FRW_MESSAGE .
protected section.
private section.

  data MO_MESSAGE type ref to /BOBF/IF_FRW_MESSAGE .
ENDCLASS.



CLASS ZCX_AWC_BOPF IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.


  METHOD get_messages.

    IF me->mo_message IS NOT INITIAL.

      me->mo_message->get_messages(
        EXPORTING
          iv_severity             = /bobf/cm_frw=>co_severity_error
          iv_consistency_messages = abap_true
          iv_action_messages      = abap_true
        IMPORTING
          et_message              = rt_message
      ).

    ENDIF.

  ENDMETHOD.


  METHOD get_message_object.

    IF me->mo_message IS INITIAL.

      me->mo_message = /bobf/cl_frw_factory=>get_message( ).

    ENDIF.

    ro_messages = me->mo_message.

  ENDMETHOD.


  METHOD set_message.

    me->mo_message = io_message.

  ENDMETHOD.
ENDCLASS.
