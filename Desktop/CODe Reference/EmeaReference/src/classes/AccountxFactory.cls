public class AccountxFactory
{
    private static final List<String> CAMPAIGN_LINE_ITEM_FIELDS = new List<String> {'DistributorRef__c', 'DistributorRef__r.id', 'DistributorRef__r.Name'};
    public static final String ACREAGE_RT_PRODUCT = 'AcreagesPerProduct';
    
    // returns a list of Distributors that belongs to an account
    public List<Accountx>ceateListOfDistributorsForTheCurrentAccount()
    {
        List<Accountx>resultDistributors = new List<Accountx>();
        if(Util.currentCampaign <> null)
        {
            al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(CAMPAIGN_LINE_ITEM_FIELDS).fromx('CampaignLineItem__c');
            al.AndCondition aCondition = new al.AndCondition();
            aCondition.add(new al.FieldCondition('FarmRef__c', Util.currentAccount.id));
            aCondition.add(new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Sales') ));
            aCondition.add(new al.FieldCondition( 'CampaignRef__c' ).equals( Util.currentCampaign.id ));
            aCondition.add(new al.FieldCondition( 'Status__c' ).equals( 'Ordered / Discussed' ));
            aCondition.add(new al.FieldCondition( 'DistributorRef__c' ).notEquals( null ));
            aCondition.add(new al.FieldCondition( 'Type__c').equals( 'Charged' ));
            aBuilder.wherex(aCondition);
            aBuilder.groupByx('DistributorRef__c, DistributorRef__r.id, DistributorRef__r.Name');
            Set<Id>processedDistributors = new Set<Id>();

            for(AggregateResult a : Database.query(aBuilder.toSOQL()))
            {
                if(String.valueOf(a.get('DistributorRef__c')) <> null && !processedDistributors.contains(String.valueOf(a.get('DistributorRef__c'))))
                {
                    
                    resultDistributors.add(new Accountx(new Account(id = String.valueOf(a.get('DistributorRef__c')), Name = String.valueOf(a.get('name')))));
                }
            }
        }
        return resultDistributors;
    }
}