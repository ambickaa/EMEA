public with sharing class GiveAwayFactory implements AccountListObjectFactory
{
    
    public Set<String>selectFields
    {
        get
        {
            if(selectFields == null)
            {
                selectFields = new Set<String> { 'OwnerId', 'id', 'ProductRef__c', 'ProductRef__r.Name', 'Status__c'};
            }
            return selectFields;
        }
        set;
    }
    
    
    public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {

        List<AccountListObjectWrapper> result = new List<CampaignLineItem>();
        if(Util.currentCampaign != null && Util.currentCampaign.id != null)
        {
            al.SoqlBuilder query = new al.SoqlBuilder()
            .selectx(selectFields)
            .fromx('CampaignLineItem__c')
            .wherex(
                new al.AndCondition()
                .add
                (
                    new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:GiveAway') )
                )
                .add
                (
                    new al.FieldCondition( 'CampaignRef__c' ).equals( Util.currentCampaign.id )
                )
                .add
                (
                    new al.FieldCondition('FarmRef__c').equals(accountId)
                )
            );
            
           // Util.addErrorMessage(query.toSOQL());
            
            for(CampaignLineItem__c t : Database.query(query.toSOQL()))
            {
                result.add( new CampaignLineItem(t));
            }
        }
        return result;
    }
    public AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
        CampaignLineItem cli = new CampaignLineItem();
        cli.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:GiveAway');
        cli.record.FarmRef__c = accountId;
        cli.record.CampaignRef__c = Util.currentCampaign.id;
        return cli;
    }
    
    public Set<String>queryFields
    {
        get
        {
            if(queryFields == null)
            {
                queryFields = new Set<String>();
            }
            return queryFields;
        } set;}
    
}