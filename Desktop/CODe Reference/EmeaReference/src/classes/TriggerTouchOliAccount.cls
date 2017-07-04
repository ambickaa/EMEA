public with sharing class TriggerTouchOliAccount implements Triggers.Handler
{

    //touch accounts of the inserted/udpated opp line items
    public void handle()
    {
        System.debug( LoggingLevel.INFO, 'Post insert / update handling ' + Trigger.new );
        Set<Id> oppIds = new Set<Id>();

        for( OpportunityLineItem oli: ( List<OpportunityLineItem> )Trigger.new )
        {
            oppIds.add( oli.opportunityid );
        }

        Map<Id,Account> mapAccs = new Map<Id,Account>();

        for( Opportunity o : [select id, accountid from Opportunity where id in : oppIds ] )
        {
            if( !mapAccs.containskey( o.accountid ) )
            {
                mapAccs.put( o.accountid,new Account( id = o.accountid ) );
            }
        }

        if( mapAccs.size()>0 )
        {
            update mapAccs.values();
        }
    }
}