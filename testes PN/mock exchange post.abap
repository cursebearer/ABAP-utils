CLASS zcl_pntec_post_exchng_rates_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
 
  PUBLIC SECTION.
 
    INTERFACES if_oo_adt_classrun.
 
    METHODS:
      save_exchange_rates IMPORTING exchange_rates_list TYPE zttpntec_exchangerates_ent
                          RETURNING VALUE(result)       TYPE cl_exchange_rates=>ty_messages.
 
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      parse_exchange_structure IMPORTING exchange_rates_list TYPE zttpntec_exchangerates_ent
                               RETURNING VALUE(result)       TYPE cl_exchange_rates=>ty_exchange_rates,
 
      mock_exchange_rates_list RETURNING VALUE(rt_list) TYPE zttpntec_exchangerates_ent.
 
ENDCLASS.
 
 
 
CLASS ZCL_PNTEC_POST_EXCHNG_RATES_DB IMPLEMENTATION.
 
 
  METHOD save_exchange_rates.
 
    "Parse Structure to CL_EXCHANGE_RATES Structure
    DATA(exchange_rates) = me->parse_exchange_structure( exchange_rates_list ).
 
    "Put Data do Standard to Insert/Modify Exchange Rates
    result = cl_exchange_rates=>put( exchange_rates    = exchange_rates
                                     is_update_allowed = abap_true ).
 
  ENDMETHOD.
 
 
  METHOD parse_exchange_structure.
    LOOP AT exchange_rates_list ASSIGNING FIELD-SYMBOL(<exchange_rate>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<exchange_line>).
      <exchange_line>-rate_type   = <exchange_rate>-exchange_rate_type.
      <exchange_line>-from_curr   = <exchange_rate>-source_currency.
      <exchange_line>-to_currncy  = <exchange_rate>-target_currency.
      <exchange_line>-valid_from  = <exchange_rate>-effective_date.
 
 
      IF <exchange_rate>-indirect_quotation IS NOT INITIAL.
        <exchange_line>-exch_rate_v   = <exchange_rate>-exchange_rate.
        <exchange_line>-from_factor_v = <exchange_rate>-number_of_source_currency_unit.
        <exchange_line>-to_factor_v   = <exchange_rate>-number_of_target_currency_unit.
      ELSE.
        <exchange_line>-exch_rate   = <exchange_rate>-exchange_rate.
        <exchange_line>-from_factor = <exchange_rate>-number_of_source_currency_unit.
        <exchange_line>-to_factor   = <exchange_rate>-number_of_target_currency_unit.
      ENDIF.
 
      UNASSIGN <exchange_line>.
    ENDLOOP.
 
  ENDMETHOD.
 
 
  METHOD mock_exchange_rates_list.
    DATA: ls_rate TYPE LINE OF zttpntec_exchangerates_ent.
 
    CLEAR ls_rate.
    ls_rate-source_currency                    = 'USD'.
    ls_rate-target_currency                    = 'BRL'.
    ls_rate-exchange_rate_type                 = 'M'.
    ls_rate-effective_date                     = '20250119'.
    ls_rate-exchange_rate                      = '5.74520'.
    ls_rate-number_of_source_currency_unit     = '1'.
    ls_rate-number_of_target_currency_unit     = '1'.
    ls_rate-indirect_quotation                 = ''.
    APPEND ls_rate TO rt_list.
 
    CLEAR ls_rate.
    ls_rate-source_currency                    = 'BRL'.
    ls_rate-target_currency                    = 'USD'.
    ls_rate-exchange_rate_type                 = 'M'.
    ls_rate-effective_date                     = '20250119'.
    ls_rate-exchange_rate                      = '5.74520'.
    ls_rate-number_of_source_currency_unit     = '1'.
    ls_rate-number_of_target_currency_unit     = '1'.
    ls_rate-indirect_quotation                 = 'X'.
    APPEND ls_rate TO rt_list.
  ENDMETHOD.
 
METHOD if_oo_adt_classrun~main.
 
  DATA(mock) = mock_exchange_rates_list( ).
 
  cl_demo_output=>write_text( '--- Dados mockados ---' ).
  cl_demo_output=>write_data( mock ).
 
  DATA(result) = save_exchange_rates( mock ).
 
  cl_demo_output=>write_text( '--- Resultado da gravação ---' ).
  cl_demo_output=>write_data( result ).
 
  cl_demo_output=>display( ).
 
ENDMETHOD.
ENDCLASS.
