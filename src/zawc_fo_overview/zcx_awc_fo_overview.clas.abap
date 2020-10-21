class ZCX_AWC_FO_OVERVIEW definition
  public
  inheriting from /IWBEP/CX_MGW_BUSI_EXCEPTION
  final
  create public .

public section.

  interfaces IF_T100_DYN_MSG .

  constants:
    begin of FO_CONFIRMATION_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '000',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FO_CONFIRMATION_FAILED .
  constants:
    begin of FO_REJECTION_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FO_REJECTION_FAILED .
  constants:
    begin of EVENT_REPORTING_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of EVENT_REPORTING_FAILED .
  constants:
    begin of AMOUNT_REPORTING_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of AMOUNT_REPORTING_FAILED .
  constants:
    begin of VEHICLE_ASSIGNMENT_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of VEHICLE_ASSIGNMENT_FAILED .
  constants:
    begin of STOP_MOVEMENT_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of STOP_MOVEMENT_FAILED .
  constants:
    begin of ANNO_RESPONSE_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ANNO_RESPONSE_FAILED .
  constants:
    begin of FO_ALREADY_CONFIRMED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '007',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FO_ALREADY_CONFIRMED .
  constants:
    begin of FU_UNASSIGN_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FU_UNASSIGN_FAILED .
  constants:
    begin of FU_ASSIGNING_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '009',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of FU_ASSIGNING_FAILED .
  constants:
    begin of NOTE_CREATION_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '010',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NOTE_CREATION_FAILED .
  constants:
    begin of ATTACHMENT_CREATION_FAILED,
      msgid type symsgid value 'ZAWC_FO_OVERVIEW',
      msgno type symsgno value '011',
      attr1 type scx_attrname value 'MSG_ID',
      attr2 type scx_attrname value 'MSG_NO',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ATTACHMENT_CREATION_FAILED .
  data MSG_ID type SYMSGID .
  data MSG_NO type SYMSGNO .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MESSAGE_CONTAINER type ref to /IWBEP/IF_MESSAGE_CONTAINER optional
      !HTTP_STATUS_CODE type /IWBEP/MGW_HTTP_STATUS_CODE default GCS_HTTP_STATUS_CODES-BAD_REQUEST
      !HTTP_HEADER_PARAMETERS type /IWBEP/T_MGW_NAME_VALUE_PAIR optional
      !SAP_NOTE_ID type /IWBEP/MGW_SAP_NOTE_ID optional
      !MSG_CODE type STRING optional
      !ENTITY_TYPE type STRING optional
      !MESSAGE type BAPI_MSG optional
      !MESSAGE_UNLIMITED type STRING optional
      !FILTER_PARAM type STRING optional
      !OPERATION_NO type I optional
      !MSG_ID type SYMSGID optional
      !MSG_NO type SYMSGNO optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_AWC_FO_OVERVIEW IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MESSAGE_CONTAINER = MESSAGE_CONTAINER
HTTP_STATUS_CODE = HTTP_STATUS_CODE
HTTP_HEADER_PARAMETERS = HTTP_HEADER_PARAMETERS
SAP_NOTE_ID = SAP_NOTE_ID
MSG_CODE = MSG_CODE
ENTITY_TYPE = ENTITY_TYPE
MESSAGE = MESSAGE
MESSAGE_UNLIMITED = MESSAGE_UNLIMITED
FILTER_PARAM = FILTER_PARAM
OPERATION_NO = OPERATION_NO
.
me->MSG_ID = MSG_ID .
me->MSG_NO = MSG_NO .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
