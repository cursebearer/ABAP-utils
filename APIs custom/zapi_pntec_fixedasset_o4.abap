@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption I_FixedAsset'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_PNTEC_FixedAsset as select from I_FixedAsset
{
    key CompanyCode,
    key MasterFixedAsset,
    key FixedAsset,
    FixedAssetDescription,
    'S'as Status,
      case
        when I_FixedAsset.CreationDate = $session.system_date then 'N'
        when I_FixedAsset.LastChangeDateTime <> I_FixedAsset.CreationDateTime then 'S'
        else 'N'
      end                   as Alteracao,
    'EMPRESA' as CampoVEnt
}

