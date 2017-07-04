public with sharing class TacticalPlanHistoryFactory {


  public List<CampaignLineItemHistory> createTacticalPlanElementHistoryForElement(String id)
  {
    
    al.SoqlBuilder query = new al.SoqlBuilder()
                         .selectx( new Set<Object> {'id', 'createdDate', 'createdBy.name', 'Forecast__c', 'Agreed__c', 'POG__c', 'Inventory__c'} )
                         .fromx( 'CampaignLineItemHistory__c' )
                               .wherex
                               (
                                   new al.AndCondition()
                                   .add
                                   (
                                       new al.FieldCondition( 'CampaignLineItem__c' ).equals( Id )
                                   )
                               )
                              .orderByx(new al.OrderBy('CreatedDate'))
                               ;
        List<CampaignLineItemHistory>result = new List<CampaignLineItemHistory>();

        for( CampaignLineItemHistory__c c : Database.query( query.toSOQL() ) )
        {
            result.add( new CampaignLineItemHistory( c ) );
        }

        return result;
  }
}