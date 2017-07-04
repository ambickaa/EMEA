public with sharing class CampaignLineItemFactory implements AccountListObjectFactory
{
    public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {

        al.SoqlBuilder query = new al.SoqlBuilder()
        .selectx(new Set<Object>
        {
            'ProductRef__c', 'ProductRef__r.Name', 'POG__c', 'Status__c ', 'Inventory__c', 'Type__c', 'DE_isPremium__c' ,'PlantingDensity__c', 'DistributorRef__c', 'PoS__c', 'Id', 'Forecast__c', 'FarmRef__c', 'ChargedElement__c', 'CampaignRef__c', 'Agreed__c',

            'FreeOfChargeElement__c', 'FreeOfChargeElement__r.Status__c', 'FreeOfChargeElement__r.FreeOfChargeElement__c', 'FreeOfChargeElement__r.NextPeriodeElement__c', 'FreeOfChargeElement__r.ProductRef__c',  'FreeOfChargeElement__r.ProductRef__r.Name', 'FreeOfChargeElement__r.POG__c', 'FreeOfChargeElement__r.Inventory__c', 'FreeOfChargeElement__r.Id', 'FreeOfChargeElement__r.Forecast__c', 'FreeOfChargeElement__r.FarmRef__c', 'FreeOfChargeElement__r.ChargedElement__c', 'FreeOfChargeElement__r.CampaignRef__c', 'FreeOfChargeElement__r.Agreed__c',

            'NextPeriodeElement__c', 'NextPeriodeElement__r.NextPeriodeElement__c', 'NextPeriodeElement__r.ProductRef__c', 'NextPeriodeElement__r.ProductRef__r.Name', 'NextPeriodeElement__r.POG__c', 'NextPeriodeElement__r.Inventory__c', 'NextPeriodeElement__r.Id', 'NextPeriodeElement__r.Forecast__c', 'NextPeriodeElement__r.FarmRef__c', 'NextPeriodeElement__r.ChargedElement__c', 'NextPeriodeElement__r.CampaignRef__c', 'NextPeriodeElement__r.Agreed__c',

            'NextPeriodeElement__r.FreeOfChargeElement__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.FreeOfChargeElement__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.NextPeriodeElement__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.ProductRef__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.ProductRef__r.Name', 'NextPeriodeElement__r.FreeOfChargeElement__r.POG__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.Inventory__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.Id', 'NextPeriodeElement__r.FreeOfChargeElement__r.Forecast__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.FarmRef__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.ChargedElement__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.CampaignRef__c', 'NextPeriodeElement__r.FreeOfChargeElement__r.Agreed__c',
            /* French change */
            'NoteTK__c','CommercialPhase__c','ForecastLow__c','Forecast__c','PDP_Allocation__c','Price_Copy__c','ProductCatalogEntryRef__r.Product_Name__c',' ProductCatalogEntryRef__r.Vendor__c','NUM_ORDERED_CY_QTY__c','NUM_INVOICED_CY_QTY__c','NUM_DELIVERED_CY_QTY__c','Treatment__c'
            /* French change */
        })
        .fromx('CampaignLineItem__c');

        List<AccountListObjectWrapper> result = new List<CampaignLineItem>();
        for(CampaignLineItem__c t : Database.query(query.toSOQL()))
        {
            result.add( new CampaignLineItem(t));
        }
        return result;
    }
    public AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
        return null;
    }
}