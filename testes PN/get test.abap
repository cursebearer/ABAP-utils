CLASS zcl_pntec_get_exchng_rates_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
 
  PUBLIC SECTION.
    "Teste tirar depois
    INTERFACES if_oo_adt_classrun.
 
    TYPES: ty_result_line  TYPE zspntec_exchangerates_ent,
           ty_result_table TYPE STANDARD TABLE OF ty_result_line WITH EMPTY KEY.
 
 
    CLASS-METHODS:get_rates_list
      RETURNING VALUE(rates_list) TYPE ZTTPNTEC_EXCHANGERATES_ENT.
 
 
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
 
 
 
CLASS zcl_pntec_get_exchng_rates_db IMPLEMENTATION.
 
  METHOD get_rates_list.
 
 
    DATA: exchange_rates_table TYPE STANDARD TABLE OF I_ExchangeRateRawData,
          lt_result            TYPE ty_result_table,
          ls_result            TYPE ty_result_line,
          start_date           TYPE sy-datum.
 
 
 
*    "Achar a função para cáluclo da data de 15 dias úteis
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = sy-datum
        days      = 15
        months    = 0
        signum    = '-'
        years     = 0
      IMPORTING
        calc_date = start_date.
    BREAK-POINT.
 
    "Teste
    DATA: lv_gdatu      TYPE c LENGTH 8 VALUE '20080604',  "Data existente na tabela para teste apagar depois
          lv_date_final TYPE d.  " ABAP.DATS
 
    "Converta para ABAP.DATS (apagar depois)
    lv_date_final = lv_gdatu.
 
 
    "Conversão necessária
    "lv_date_final = start_date.
 
 
    SELECT *
  FROM I_ExchangeRateRawData
  WHERE ValidityStartDate >= @lv_date_final
  INTO TABLE @exchange_rates_table.
 
 
    SORT exchange_rates_table BY SourceCurrency TargetCurrency ExchangeRateType ValidityStartDate DESCENDING.
    " SORT exchange_rates_table BY SourceCurrency  DESCENDING.
    DELETE ADJACENT DUPLICATES FROM exchange_rates_table COMPARING ExchangeRateType SourceCurrency TargetCurrency.
    " DELETE ADJACENT DUPLICATES FROM exchange_rates_table COMPARING  SourceCurrency .
 
    LOOP AT exchange_rates_table INTO DATA(ls_tcurr).
      CLEAR ls_result.
      ls_result-exchange_rate_type = ls_tcurr-ExchangeRateType.
      ls_result-source_currency    = ls_tcurr-SourceCurrency.
      ls_result-target_currency    = ls_tcurr-TargetCurrency.
      ls_result-effective_date     = ls_tcurr-ValidityStartDate.
      ls_result-exchange_rate      = ls_tcurr-ExchangeRate.
      ls_result-number_of_source_currency_unit = ls_tcurr-NumberOfSourceCurrencyUnits.
      ls_result-number_of_target_currency_unit = ls_tcurr-NumberOfTargetCurrencyUnits.
      ls_result-indirect_quotation = abap_false.
      APPEND ls_result TO lt_result.
    ENDLOOP.
 
    rates_list = lt_result.
 
  ENDMETHOD.
 
  METHOD if_oo_adt_classrun~main.
 
    DATA(lt_rates) = get_rates_list( ).
 
    LOOP AT lt_rates INTO DATA(ls_rate).
      out->write( |{ ls_rate-exchange_rate_type } { ls_rate-source_currency } -> { ls_rate-target_currency } | &&
                  |Data: { ls_rate-effective_date DATE = USER } | &&
                  |Taxa: { ls_rate-exchange_rate } | &&
                  |Ffact: { ls_rate-number_of_source_currency_unit } | &&
                  |Tfact: { ls_rate-number_of_target_currency_unit } | &&
                  |Indireta: { ls_rate-indirect_quotation }| ).
    ENDLOOP.
 
  ENDMETHOD.
 
ENDCLASS.
