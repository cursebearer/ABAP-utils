CLASS zcl_pntec_exchng_rates_db_post DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS:
      save_exchange_rates IMPORTING exchange_rates_list TYPE zttpntec_exchangerates_ent
                          RETURNING VALUE(result)       TYPE cl_exchange_rates=>ty_messages.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      parse_exchange_structure IMPORTING exchange_rates_list TYPE zttpntec_exchangerates_ent
                               RETURNING VALUE(result)       TYPE cl_exchange_rates=>ty_exchange_rates.


ENDCLASS.

CLASS zcl_pntec_exchng_rates_db_post IMPLEMENTATION.


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

ENDCLASS.
