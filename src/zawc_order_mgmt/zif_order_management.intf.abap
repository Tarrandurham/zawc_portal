INTERFACE zif_order_management
  PUBLIC .

  CONSTANTS:
    BEGIN OF c_auth_check,
      create  TYPE char2  VALUE '01' ##NO_TEXT,
      update  TYPE char2  VALUE '02' ##NO_TEXT,
      display TYPE char2  VALUE '03' ##NO_TEXT,
      delete  TYPE char2  VALUE '06' ##NO_TEXT,
      id      TYPE char5  VALUE 'ACTVT' ##NO_TEXT,
      object  TYPE Char10 VALUE 'Z_ORDER' ##NO_TEXT,
    END OF c_auth_check.

endinterface.
