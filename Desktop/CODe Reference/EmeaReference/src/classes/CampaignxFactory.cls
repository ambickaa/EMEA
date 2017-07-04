public class CampaignxFactory implements AccountListObjectFactory
{
    
    public Set<String>selectFields
    {
        get
        {
            if(selectFields == null)
            {
                selectFields = new Set<String> { 'id','Name','Type','EndDate','Status'};
            }
            return selectFields;
        }
        set;
    }
    
    public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {
        List<AccountListObjectWrapper> result = new List<Campaignx>();
        Set<String>campaignIds = new Set<String>();

        for( CampaignMember c: [SELECT CampaignId FROM CampaignMember WHERE Contact.AccountId =:accountId ] )
        {
            if( !campaignIds.contains( String.valueOf( c.CampaignId ) ) )
            {
                campaignIds.add( String.valueOf( c.CampaignId ) );
            }
        }

        List<String>campaignIdString = new List<String>();
        campaignIdString.addAll( campaignIds );

        if( campaignIdString.size()>0 )
        {
            al.SoqlBuilder query = new al.SoqlBuilder()
            .selectx( selectFields )
            .fromx( 'Campaign' )
            .wherex
            (
                new al.AndCondition()
                .add
                (
                    new al.SetCondition( 'id' ).INX( campaignIdString )
                )
            );

            //System.assert(false, query.toSOQL());
            for( Campaign c : Database.query( query.toSOQL() ) )
            {
                result.add( new Campaignx( c ) );
            }
        }

        return result;
    }

    public AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
        return null;
    }
    
    
    public List<Campaignx.CamapignDuplicates> getCampaignDuplicates(FieldSetMemberxManager selectFieldManager)
    {
        
        List<Campaignx.CamapignDuplicates>duplicateCampaigns = new List<Campaignx.CamapignDuplicates>();
        Map<String, Campaignx.CamapignDuplicates>campaignDuplicateMap = new Map<String, Campaignx.CamapignDuplicates>();
        List<AggregateResult>duplicateUserDivisionKeys = [SELECT OwnerId, DivisionRef__c, CountryRef__c FROM Campaign WHERE StatusCode__c = 200 GROUP BY OwnerId, DivisionRef__c, CountryRef__c HAVING Count(id) > 1 ];
        al.OrCondition orCondition = new al.OrCondition();
        
        if(duplicateUserDivisionKeys.size()>0)
        {
            for(AggregateResult a : duplicateUserDivisionKeys)
            {
                orCondition
                .add
                (
                    new al.AndCondition()
                    .add
                    (
                        new al.FieldCondition( 'OwnerId' ).equals(String.valueOf(a.get('OwnerId')))
                    )
                    .add
                    (
                        new al.FieldCondition( 'DivisionRef__c' ).equals(String.valueOf(a.get('DivisionRef__c')))
                    )
                    .add
                    (
                        new al.FieldCondition( 'StatusCode__c' ).equals(200)
                    )
                    .add
                    (
                        new al.FieldCondition( 'CountryRef__c' ).equals((String.valueOf(a.get('CountryRef__c'))))
                    )
                );
                    
            }
            Set<String>selectFields = selectFieldManager.getSOQLFields();
            selectFields.add('ownerId');
            selectFields.add('Id');
            selectFields.add('DivisionRef__c');
            selectFields.add('CountryRef__c');
            al.SoqlBuilder query = new al.SoqlBuilder().selectx(selectFields).fromx('Campaign').wherex(orCondition).orderbyx(new al.OrderBy('owner.name, CountryRef__c'));
            
            
            for(Campaign c : Database.query(query.toSOQL()))
            {
                String recordKey = String.valueOf(c.DivisionRef__c)+String.valueOf(c.OwnerId)+String.valueOf(c.CountryRef__c);
                if(!campaignDuplicateMap.containsKey(recordKey))
                {
                    campaignDuplicateMap.put(recordKey, new Campaignx.CamapignDuplicates());
                    duplicateCampaigns.add(campaignDuplicateMap.get(recordKey));
                }
                
                campaignDuplicateMap.get(recordKey).add(c);
            }
        }
        return duplicateCampaigns;
    }
}