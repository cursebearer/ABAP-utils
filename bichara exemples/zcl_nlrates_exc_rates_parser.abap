CLASS zcl_nlrates_exc_rates_parser DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS:
      deserialize IMPORTING request_body  TYPE string
                  RETURNING VALUE(result) TYPE zsnlrates_imp_rates_request,

      serialize IMPORTING structure_data TYPE data
                RETURNING VALUE(result)  TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_nlrates_exc_rates_parser IMPLEMENTATION.
  METHOD deserialize.

    DATA: exchange_rates_req TYPE zsnlrates_imp_rates_request.

    /ui2/cl_json=>deserialize( EXPORTING json        = request_body
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                CHANGING data        = exchange_rates_req ).


    "Result Structure
    result = exchange_rates_req.

  ENDMETHOD.

  METHOD serialize.

    /ui2/cl_json=>serialize( EXPORTING data        = structure_data
                                       pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                             RECEIVING r_json      = result ).

  ENDMETHOD.

ENDCLASS.