CLASS zcl_nlhsrates_import_rates DEFINITION FINAL PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

  PRIVATE SECTION.
    METHODS: handle_post IMPORTING request  TYPE REF TO if_web_http_request
                                   response TYPE REF TO if_web_http_response.
ENDCLASS.



CLASS zcl_nlhsrates_import_rates IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    DATA(http_method) = request->get_method( ).

    CASE http_method.
      WHEN 'POST'.
        me->handle_post( request  = request
                         response = response ).

      WHEN OTHERS.
        "Implement Others Methods if necessary
        response->set_status( if_web_http_status=>method_not_allowed ).

    ENDCASE.
  ENDMETHOD.

  METHOD handle_post.
    DATA(rates_parser_ref) = NEW zcl_nlrates_exc_rates_parser( ).

    "Parse Body To Internal Structure
    DATA(exchange_rates_req) = rates_parser_ref->deserialize( request->get_text( ) ).

    "Persist Data
    DATA(result_messages) = NEW zcl_nlrates_exc_rates_persist( )->save_exchange_rates( exchange_rates_req-exchange_rates ).

    "Serialize Response
    DATA(json_body_resp) = rates_parser_ref->serialize( result_messages ).

    "Set Response
    TRY.
        response->set_text( json_body_resp ).
        response->set_status( if_web_http_status=>ok ).
        response->set_content_type( 'application/json' ).

        IF line_exists( result_messages[ type = 'E' ] ).
          response->set_status( if_web_http_status=>internal_server_error ).
        ENDIF.

      CATCH cx_web_message_error INTO DATA(message_error).
        response->set_text( |{ '{ "message" : ' }"{ message_error->get_text( ) }" { '}' }| ).
        response->set_status( if_web_http_status=>internal_server_error ).

    ENDTRY.
  ENDMETHOD.

ENDCLASS.