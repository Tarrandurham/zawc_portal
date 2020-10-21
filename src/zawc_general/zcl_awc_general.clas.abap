class ZCL_AWC_GENERAL definition
  public
  final
  create public .

public section.

  class-methods CONVERT_INTO_TZ
    importing
      !IV_FROM_TZ type TZONREF-TZONE
      !IV_TO_TZ type TZONREF-TZONE
      !IV_FROM_TS type CHAR14
    returning
      value(RV_TO_TS) type CHAR14 .
  methods CHECK_BOPF_MESSAGES
    importing
      !IO_MESSAGE type ref to /BOBF/IF_FRW_MESSAGE
    raising
      ZCX_AWC_BOPF .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AWC_GENERAL IMPLEMENTATION.


  METHOD check_bopf_messages.

    IF io_message IS NOT INITIAL.

      io_message->get_messages(
        EXPORTING
          iv_severity             = /bobf/cm_frw=>co_severity_error
          iv_consistency_messages = abap_true
          iv_action_messages      = abap_true
        IMPORTING
          et_message              = DATA(lt_message)
      ).

    ENDIF.

    IF lt_message IS NOT INITIAL.
      DATA(lo_ex_bopf) = NEW zcx_awc_bopf( ).

      lo_ex_bopf->set_message( io_message ).

      RAISE EXCEPTION lo_ex_bopf..

    ENDIF.

  ENDMETHOD.


  method CONVERT_INTO_TZ.

    DATA: tstp TYPE timestamp.

    DATA(lv_date) = iv_from_ts+0(8).
    DATA(lv_time) = iv_from_ts+8.

    CONVERT DATE lv_date TIME lv_time INTO TIME STAMP tstp TIME ZONE iv_from_tz.

    CONVERT TIME STAMP tstp TIME ZONE iv_to_tz INTO DATE lv_date TIME lv_time.

    CONCATENATE lv_date lv_time into rv_to_ts.

  endmethod.
ENDCLASS.
