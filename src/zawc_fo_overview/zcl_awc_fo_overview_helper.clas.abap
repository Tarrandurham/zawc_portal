CLASS zcl_awc_fo_overview_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS raise_exception
      IMPORTING
        !io_message TYPE REF TO /bobf/if_frw_message OPTIONAL
        !is_textid  LIKE if_t100_message=>t100key
      RAISING
        zcx_awc_fo_overview .
    METHODS convert_into_tz
      IMPORTING
        !iv_from_tz     TYPE tzonref-tzone
        !iv_to_tz       TYPE tzonref-tzone
        !iv_from_ts     TYPE char14
      RETURNING
        VALUE(rv_to_ts) TYPE char14 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AWC_FO_OVERVIEW_HELPER IMPLEMENTATION.


  METHOD convert_into_tz.

    DATA: tstp TYPE timestamp.

    DATA(lv_date) = iv_from_ts+0(8).
    DATA(lv_time) = iv_from_ts+8.

    CONVERT DATE lv_date TIME lv_time INTO TIME STAMP tstp TIME ZONE iv_from_tz.

    CONVERT TIME STAMP tstp TIME ZONE iv_to_tz INTO DATE lv_date TIME lv_time.

    CONCATENATE lv_date lv_time INTO rv_to_ts.

  ENDMETHOD.


  METHOD raise_exception.

    DATA: lv_msg_id TYPE symsgid,
          lv_msg_no TYPE symsgno.

    IF io_message IS BOUND.
      io_message->get_messages(
        EXPORTING
          iv_severity             = 'E'
*          iv_consistency_messages = abap_true
*          iv_action_messages      = abap_true
        IMPORTING
          et_message              = DATA(lt_message)
      ).

      READ TABLE lt_message INDEX 1 INTO DATA(ls_message).
      IF sy-subrc = 0.
        lv_msg_id = ls_message-message->if_t100_message~t100key-msgid.
        lv_msg_no = ls_message-message->if_t100_message~t100key-msgno.
      ENDIF.
    ENDIF.

    RAISE EXCEPTION TYPE zcx_awc_fo_overview
      EXPORTING
        textid = is_textid
        msg_id = lv_msg_id
        msg_no = lv_msg_no.
  ENDMETHOD.
ENDCLASS.
