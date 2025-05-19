CLASS zcl_pntec_exchng_rates_db_get DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: ty_currency                TYPE i_ExchangeRateRawData-TargetCurrency,
           ty_currency_range          TYPE RANGE OF ty_currency,
           exchange_rate_result_type  TYPE zspntec_exchangerates_ent,
           exchange_rate_result_table TYPE STANDARD TABLE OF exchange_rate_result_type WITH EMPTY KEY.

    CLASS-METHODS:
      get_rates_list IMPORTING currency_range    TYPE ty_currency_range OPTIONAL
                     RETURNING VALUE(rates_list) TYPE zttpntec_exchangerates_ent.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_pntec_exchng_rates_db_get IMPLEMENTATION.

  METHOD get_rates_list.

    DATA: exchange_rates_table   TYPE STANDARD TABLE OF I_ExchangeRateRawData,
          exchange_rates_results TYPE exchange_rate_result_table,
          exchange_rate_result   TYPE exchange_rate_result_type,
          source_currency_range  TYPE ty_currency_range,
          start_date             TYPE d,
          inicial_data           TYPE d,
          days_to_substract      TYPE i.

    days_to_substract = 15.

    "Get Max Valid Date for Exchange Rates
    SELECT MAX( ValidityStartDate )
      FROM I_ExchangeRateRawData
     WHERE TargetCurrency IN @currency_range
      INTO @inicial_data.

    start_date = inicial_data - days_to_substract.

    "Get Exchange Rates for the given date range
    SELECT *
      FROM I_ExchangeRateRawData
     WHERE ValidityStartDate >= @start_date
       AND TargetCurrency IN @currency_range
      INTO TABLE @exchange_rates_table.

    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    "If Filter was supplied, get Source Currency based on Target Filter
    IF currency_range IS NOT INITIAL.
      source_currency_range = VALUE #( FOR exchg_rate IN exchange_rates_table
                                       ( sign = 'I' option = 'EQ' low = exchg_rate-SourceCurrency )
                                     ).

      SELECT *
        FROM I_ExchangeRateRawData
       WHERE ValidityStartDate >= @start_date
         AND SourceCurrency     IN @currency_range
         AND TargetCurrency     IN @source_currency_range
       APPENDING TABLE @exchange_rates_table.
    ENDIF.

    SORT exchange_rates_table BY ExchangeRateType SourceCurrency TargetCurrency ValidityStartDate DESCENDING.
    DELETE ADJACENT DUPLICATES FROM exchange_rates_table COMPARING ExchangeRateType SourceCurrency TargetCurrency.

    LOOP AT exchange_rates_table INTO DATA(raw_rate_data).
      CLEAR exchange_rate_result.
      exchange_rate_result-exchange_rate_type = raw_rate_data-ExchangeRateType.
      exchange_rate_result-source_currency    = raw_rate_data-SourceCurrency.
      exchange_rate_result-target_currency    = raw_rate_data-TargetCurrency.
      exchange_rate_result-effective_date     = raw_rate_data-ValidityStartDate.
      exchange_rate_result-number_of_source_currency_unit = raw_rate_data-NumberOfSourceCurrencyUnits.
      exchange_rate_result-number_of_target_currency_unit = raw_rate_data-NumberOfTargetCurrencyUnits.
      exchange_rate_result-indirect_quotation = raw_rate_data-ExchangeRate.
      exchange_rate_result-exchange_rate = raw_rate_data-ExchangeRate.

      IF raw_rate_data-ExchangeRate < 0.
        exchange_rate_result-indirect_quotation = abap_true.
      ELSE.
        exchange_rate_result-indirect_quotation = abap_false.
      ENDIF.

      APPEND exchange_rate_result TO exchange_rates_results.
    ENDLOOP.

    rates_list = exchange_rates_results.

  ENDMETHOD.

ENDCLASS.


"Rafa
*CLASS zcl_pntec_exchng_rates_db_get DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*
*    TYPES: exchange_rate_result_type  TYPE zspntec_exchangerates_ent,
*           exchange_rate_result_table TYPE STANDARD TABLE OF exchange_rate_result_type WITH EMPTY KEY.
*
*    CLASS-METHODS get_rates_list
*      IMPORTING
*        VALUE(i_target_currency_rng) TYPE s_currcode OPTIONAL
*      RETURNING
*        VALUE(rates_list)            TYPE zttpntec_exchangerates_ent.
*
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.
*
*CLASS zcl_pntec_exchng_rates_db_get IMPLEMENTATION.
*
*  METHOD get_rates_list.
*
*    TYPES: ty_target_range TYPE RANGE OF s_currcode.
*
*    DATA: exchange_rates_table   TYPE STANDARD TABLE OF I_ExchangeRateRawData,
*          exchange_rates_results TYPE exchange_rate_result_table,
*          exchange_rate_result   TYPE exchange_rate_result_type,
*          start_date             TYPE d,
*          inicial_data           TYPE d,
*          days_to_substract      TYPE i,
*          r_target_currency      TYPE ty_target_range.
*
*    days_to_substract = 15.
*
*    SELECT MAX( ValidityStartDate )
*           FROM I_ExchangeRateRawData
*           INTO @inicial_data.                          "#EC CI_NOWHERE
*
*    start_date = inicial_data - days_to_substract.
*
*    r_target_currency = VALUE #(
*      ( sign = 'I' option = 'EQ' low = 'BRL' )
*      ( sign = 'I' option = 'EQ' low = 'USD' )
*    ).
*
*    SELECT *
*      FROM I_ExchangeRateRawData
*      WHERE ValidityStartDate >= @start_date
*        AND TargetCurrency     IN @r_target_currency
*      INTO TABLE @exchange_rates_table.
*
*    SORT exchange_rates_table BY ExchangeRateType SourceCurrency TargetCurrency ValidityStartDate DESCENDING.
*
*    DELETE ADJACENT DUPLICATES FROM exchange_rates_table COMPARING ExchangeRateType SourceCurrency TargetCurrency.
*
*    LOOP AT exchange_rates_table INTO DATA(raw_rate_data).
*      CLEAR exchange_rate_result.
*      exchange_rate_result-exchange_rate_type = raw_rate_data-ExchangeRateType.
*      exchange_rate_result-source_currency    = raw_rate_data-SourceCurrency.
*      exchange_rate_result-target_currency    = raw_rate_data-TargetCurrency.
*      exchange_rate_result-effective_date     = raw_rate_data-ValidityStartDate.
*      exchange_rate_result-number_of_source_currency_unit = raw_rate_data-NumberOfSourceCurrencyUnits.
*      exchange_rate_result-number_of_target_currency_unit = raw_rate_data-NumberOfTargetCurrencyUnits.
*      exchange_rate_result-exchange_rate = raw_rate_data-ExchangeRate.
*
*      IF raw_rate_data-ExchangeRate < 0.
*        exchange_rate_result-indirect_quotation = abap_true.
*      ELSE.
*        exchange_rate_result-indirect_quotation = abap_false.
*      ENDIF.
*
*      APPEND exchange_rate_result TO exchange_rates_results.
*    ENDLOOP.
*
*    rates_list = exchange_rates_results.
*
*  ENDMETHOD.
*
*
*ENDCLASS.



"Primeira Versão
*CLASS zcl_pntec_exchng_rates_db_get DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*
*    TYPES: exchange_rate_result_type  TYPE zspntec_exchangerates_ent,
*           exchange_rate_result_table TYPE STANDARD TABLE OF exchange_rate_result_type WITH EMPTY KEY.
*
*    CLASS-METHODS:get_rates_list
*      RETURNING VALUE(rates_list) TYPE zttpntec_exchangerates_ent.
*
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.
*
*CLASS zcl_pntec_exchng_rates_db_get IMPLEMENTATION.
*
*  METHOD get_rates_list.
*
*    DATA: exchange_rates_table   TYPE STANDARD TABLE OF I_ExchangeRateRawData,
*          exchange_rates_results TYPE exchange_rate_result_table,
*          exchange_rate_result   TYPE exchange_rate_result_type,
*          start_date             TYPE d,
*          inicial_data           TYPE d,
*          days_to_substract      TYPE i.
*
*    days_to_substract = 15.
*
*    SELECT MAX( ValidityStartDate )
*           FROM I_ExchangeRateRawData
*           INTO @inicial_data.                          "#EC CI_NOWHERE
*
*    start_date = inicial_data - days_to_substract.
*
*    SELECT *
*        FROM I_ExchangeRateRawData
*        WHERE ValidityStartDate >= @start_date
*        INTO TABLE @exchange_rates_table.
*
*    SORT exchange_rates_table BY ExchangeRateType SourceCurrency TargetCurrency ValidityStartDate DESCENDING.
*    DELETE ADJACENT DUPLICATES FROM exchange_rates_table COMPARING ExchangeRateType SourceCurrency TargetCurrency.
*
*    LOOP AT exchange_rates_table INTO DATA(raw_rate_data).
*      CLEAR exchange_rate_result.
*      exchange_rate_result-exchange_rate_type = raw_rate_data-ExchangeRateType.
*      exchange_rate_result-source_currency    = raw_rate_data-SourceCurrency.
*      exchange_rate_result-target_currency    = raw_rate_data-TargetCurrency.
*      exchange_rate_result-effective_date     = raw_rate_data-ValidityStartDate.
*      exchange_rate_result-number_of_source_currency_unit = raw_rate_data-NumberOfSourceCurrencyUnits.
*      exchange_rate_result-number_of_target_currency_unit = raw_rate_data-NumberOfTargetCurrencyUnits.
*      exchange_rate_result-indirect_quotation = raw_rate_data-ExchangeRate.
*      exchange_rate_result-exchange_rate = raw_rate_data-ExchangeRate.
*
*      IF raw_rate_data-ExchangeRate < 0.
*        exchange_rate_result-indirect_quotation = abap_true.
*      ELSE.
*        exchange_rate_result-indirect_quotation = abap_false.
*      ENDIF.
*
*      APPEND exchange_rate_result TO exchange_rates_results.
*    ENDLOOP.
*
*    rates_list = exchange_rates_results.
*
*  ENDMETHOD.
*
*ENDCLASS.
