public with sharing class CampaignLineItemHistoryFactory
{


    public List<CampaignLineItemHistory>createCampaignItemHistoryForItem(String id)
    {
        al.SoqlBuilder query = new al.SoqlBuilder().selectx(new Set<Object> {'POG__c', 'POGChanged__c', 'LastModifiedDate', 'Inventory__c', 'InventoryChanged__c', 'Id', 'Forecast__c', 'ForecastChanged__c', 'CreatedDate', 'CreatedById','CreatedBy.name', 'Agreed__c', 'AgreedChanged__c'})
        .fromx('TacticalPlanElementHistory__c')
        .wherex
        (
            new al.FieldCondition( 'CampaignLineItem__c' ).equals( id )
        )
        .orderByx(new al.OrderBy('CreatedDate desc'))
        .limitx(200);

        List<CampaignLineItemHistory>history = new List<CampaignLineItemHistory>();
        for(CampaignLineItemHistory__c h : Database.query(query.toSOQL()))
        {
            history.add(new CampaignLineItemHistory(h));
        }

        return history;
    }
}