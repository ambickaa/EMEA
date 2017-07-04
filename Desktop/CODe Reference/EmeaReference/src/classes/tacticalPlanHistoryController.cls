public with sharing class tacticalPlanHistoryController
{
    public OpportunityLineItem oli {get; set;}

    public al.SoqlBuilder getSOQL()
    {
        al.SoqlBuilder query = new al.SoqlBuilder()
        .selectx( new Set<Object> {'Forecast_FOC__c', 'Forecast__c', 'Agreed_FOC__c','Forecast_50__c', 'POG_FOC__c','Confirmed_Sales__c',
                                   'Type__c'
                                  } )
        .fromx( 'OpportunityLineItem' )
        .Wherex
        (
            new al.AndCondition()
            .add
            (
                new al.FieldCondition( 'id' ).equals( Util.urlParameters.get( 'id' ) )
            )
        )
        ;
        return query;
    }

    public tacticalPlanHistoryController()
    {
        oli = new OpportunityLineItem();

        for( OpportunityLineItem o : ( List<OpportunityLineItem> )Database.query( getSOQL().toSoql() ) )
        {
            oli = o;
        }
    }
}