CLASS zcl_pntec_exchange__dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_pntec_exchange__dpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity
        REDEFINITION .
  PROTECTED SECTION.

    METHODS exchangeratedata_get_entity
        REDEFINITION .
    METHODS exchangeratedata_get_entityset
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_pntec_exchange__dpc_ext IMPLEMENTATION.


  METHOD exchangeratedata_get_entity.
  ENDMETHOD.


  METHOD exchangeratedata_get_entityset.

    DATA: currency_range TYPE zcl_pntec_exchng_rates_db_get=>ty_currency_range.


    TRY.
        DATA(target_filter) = it_filter_select_options[ property = 'TargetCurrency' ]-select_options.
        MOVE-CORRESPONDING target_filter TO currency_range.

      CATCH cx_sy_itab_line_not_found.
        "do nothing / nix tun
    ENDTRY.

    DATA(exchange_rates_list) = zcl_pntec_exchng_rates_db_get=>get_rates_list( currency_range ).

    et_entityset = VALUE #( FOR exchange_rate IN exchange_rates_list
                            ( rate_ref                       = ''
                              source_currency                = exchange_rate-source_currency
                              target_currency                = exchange_rate-target_currency
                              exchange_rate_type             = exchange_rate-exchange_rate_type
                              number_of_source_currency_unit = exchange_rate-number_of_source_currency_unit
                              number_of_target_currency_unit = exchange_rate-number_of_target_currency_unit
                              indirect_quotation             = exchange_rate-indirect_quotation ) ).

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA: deep_entity         TYPE zcl_pntec_exchange__mpc_ext=>ty_deep_entity, "zspntec_exchng_rate_data_deep.
          exchange_rates_list TYPE zttpntec_exchangerates_ent.

    "Efetua Parse dos dados do OData para Estrutura
    io_data_provider->read_entry_data( IMPORTING es_data = deep_entity ).

    exchange_rates_list = VALUE #( FOR rate IN deep_entity-exchangerateslist (
                                    exchange_rate_type             = rate-exchange_rate_type
                                    source_currency                = rate-source_currency
                                    target_currency                = rate-target_currency
                                    effective_date                 = rate-effective_date
                                    exchange_rate                  = rate-exchange_rate
                                    number_of_source_currency_unit = rate-number_of_source_currency_unit
                                    number_of_target_currency_unit = rate-number_of_target_currency_unit
                                    indirect_quotation             = rate-indirect_quotation ) ).

    DATA(lt_messages) = NEW zcl_pntec_exchng_rates_db_post( )->save_exchange_rates( exchange_rates_list ).

    "Gere Estrutura de Retorno
    me->copy_data_to_ref( EXPORTING is_data = deep_entity
                           CHANGING cr_data = er_deep_entity ).

  ENDMETHOD.
ENDCLASS.


"Rafa
*CLASS zcl_pntec_exchange__dpc_ext DEFINITION
*  PUBLIC
*  INHERITING FROM zcl_pntec_exchange__dpc
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*
*    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity
*        REDEFINITION .
*  PROTECTED SECTION.
*
*    METHODS exchangeratedata_get_entity
*        REDEFINITION .
*    METHODS exchangeratedata_get_entityset
*        REDEFINITION .
*  PRIVATE SECTION.
*ENDCLASS.
*
*
*
*CLASS zcl_pntec_exchange__dpc_ext IMPLEMENTATION.
*
*
*  METHOD exchangeratedata_get_entity.
*  ENDMETHOD.
*
*
*  METHOD exchangeratedata_get_entityset.
*
*    DATA(lt_filter_select_options) = io_tech_request_context->get_filter( )->get_filter_select_options( ).
*
*    DATA(lt_target_currency_rng) = /iwbep/cl_mgw_dpc_util=>get_filter_select_options(
*                                    it_filter_select_options = lt_filter_select_options
*                                    iv_property              = 'TargetCurrency' ).
*
*    DATA(exchange_rates_list) = zcl_pntec_exchng_rates_db_get=>get_rates_list(
*                                  i_target_currency_rng = lt_target_currency_rng ).
*
*    et_entityset = VALUE #( FOR exchange_rate IN exchange_rates_list
*                            ( rate_ref                       = ''
*                              source_currency                = exchange_rate-source_currency
*                              target_currency                = exchange_rate-target_currency
*                              exchange_rate_type             = exchange_rate-exchange_rate_type
*                              number_of_source_currency_unit = exchange_rate-number_of_source_currency_unit
*                              number_of_target_currency_unit = exchange_rate-number_of_target_currency_unit
*                              indirect_quotation             = exchange_rate-indirect_quotation ) ).
*
*  ENDMETHOD.
*
*
*
*  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
*
*    DATA: deep_entity         TYPE zcl_pntec_exchange__mpc_ext=>ty_deep_entity,
*          exchange_rates_list TYPE zttpntec_exchangerates_ent.
*
*    io_data_provider->read_entry_data( IMPORTING es_data = deep_entity ).
*
*    exchange_rates_list = VALUE #( FOR rate IN deep_entity-exchangerateslist (
*                                    exchange_rate_type             = rate-exchange_rate_type
*                                    source_currency                = rate-source_currency
*                                    target_currency                = rate-target_currency
*                                    effective_date                 = rate-effective_date
*                                    exchange_rate                  = rate-exchange_rate
*                                    number_of_source_currency_unit = rate-number_of_source_currency_unit
*                                    number_of_target_currency_unit = rate-number_of_target_currency_unit
*                                    indirect_quotation             = rate-indirect_quotation ) ).
*
*    DATA(lt_messages) = NEW zcl_pntec_exchng_rates_db_post( )->save_exchange_rates( exchange_rates_list ).
*
*    me->copy_data_to_ref( EXPORTING is_data = deep_entity
*                           CHANGING cr_data = er_deep_entity ).
*
*  ENDMETHOD.
*ENDCLASS.



"Primeira versão
*class ZCL_PNTEC_EXCHANGE__DPC_EXT definition
*  public
*  inheriting from ZCL_PNTEC_EXCHANGE__DPC
*  create public .
*
*public section.
*
*  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*    redefinition .
*protected section.
*
*  methods EXCHANGERATEDATA_GET_ENTITY
*    redefinition .
*  methods EXCHANGERATEDATA_GET_ENTITYSET
*    redefinition .
*  PRIVATE SECTION.
*ENDCLASS.
*
*
*
*CLASS ZCL_PNTEC_EXCHANGE__DPC_EXT IMPLEMENTATION.
*
*
*  METHOD exchangeratedata_get_entity.
*  ENDMETHOD.
*
*
*  METHOD exchangeratedata_get_entityset.
*
*    DATA(exchange_rates_list) = NEW zcl_pntec_exchng_rates_db_get( )->get_rates_list( ).
*
*    et_entityset = VALUE #( FOR exchange_rate iN exchange_rates_list
*                            ( rate_ref                       = ''
*                              source_currency                = exchange_rate-source_currency
*                              target_currency                = exchange_rate-target_currency
*                              exchange_rate_type             = exchange_rate-exchange_rate_type
*                              number_of_source_currency_unit = exchange_rate-number_of_source_currency_unit
*                              number_of_target_currency_unit = exchange_rate-number_of_target_currency_unit
*                              indirect_quotation             = exchange_rate-indirect_quotation ) ).
*
*  ENDMETHOD.
*
*
*  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
*
*    DATA: deep_entity TYPE zcl_pntec_exchange__mpc_ext=>ty_deep_entity, "zspntec_exchng_rate_data_deep.
*          exchange_rates_list TYPE zttpntec_exchangerates_ent.
*
*    "Efetua Parse dos dados do OData para Estrutura
*    io_data_provider->read_entry_data( IMPORTING es_data = deep_entity ).
*
*    exchange_rates_list = VALUE #( FOR rate IN deep_entity-exchangerateslist (
*                                    exchange_rate_type             = rate-exchange_rate_type
*                                    source_currency                = rate-source_currency
*                                    target_currency                = rate-target_currency
*                                    effective_date                 = rate-effective_date
*                                    exchange_rate                  = rate-exchange_rate
*                                    number_of_source_currency_unit = rate-number_of_source_currency_unit
*                                    number_of_target_currency_unit = rate-number_of_target_currency_unit
*                                    indirect_quotation             = rate-indirect_quotation ) ).
*
*    DATA(lt_messages) = NEW zcl_pntec_exchng_rates_db_post( )->save_exchange_rates( exchange_rates_list ).
*
*    "Gere Estrutura de Retorno
*    me->copy_data_to_ref( EXPORTING is_data = deep_entity
*                           CHANGING cr_data = er_deep_entity ).
*
*  ENDMETHOD.
*ENDCLASS.
