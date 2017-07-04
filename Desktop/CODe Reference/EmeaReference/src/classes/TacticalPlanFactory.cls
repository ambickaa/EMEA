public with sharing class TacticalPlanFactory implements AccountListObjectFactory
{
    private String campaignId;
    public TacticalPlanFactory()
    {
        if (Util.currentCampaign != null)
        {
            this.campaignId = Util.currentCampaign.id;
        }
    }
    
    public TacticalPlanFactory(Campaign inputCampaign)
    {
        if (inputCampaign != null)
        {
            this.campaignId = inputCampaign.id;
        }
    }
    
    
    public Set<String>selectFields
    {
        get
        {
            if(selectFields == null)
            {
                selectFields = new Set<String> { 'OwnerId', 'id', 'RecordTypeId', 'ProductRef__c', 'ProductRef__r.Name', 'PlantingDensity__c', 'Quantity__c'};
            }
            return selectFields;
        }
        set;
    }
    
    
    public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {
        List<AccountListObjectWrapper> result = new List<CampaignLineItem>();
        if (campaignId != null)
        {
            al.SoqlBuilder query;
            if(!Util.countryView.isAccountSharingEnabled)
            {
                query = new al.SoqlBuilder()
                .selectx(selectFields)
                .fromx('CampaignLineItem__c')
                .wherex(
                        new al.AndCondition()
                        .add
                        (
                            new al.FieldCondition( 'FarmRef__c' ).equals( accountId)
                        )
                        .add
                        (
                            new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Sales') )
                        )
                        .add
                        (
                            new al.FieldCondition( 'CampaignRef__c' ).equals( campaignId )
                        )
                    );
                //System.assert(false, query.toSOQL());
         
            }
            else
            {
            
                Campaign cmp= [SELECT YearV2__r.Name,DivisionRef__r.Name FROM Campaign WHERE ID=:campaignId ];                
                query = new al.SoqlBuilder()
                .selectx(selectFields)
                .fromx('CampaignLineItem__c')
                .wherex(
                        new al.AndCondition()
                        .add
                        (
                            new al.FieldCondition( 'FarmRef__c' ).equals( accountId)
                        )
                        .add
                        (
                            new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Sales') )
                        )
                        .add
                        (
                            new al.FieldCondition( 'Year__c' ).equals( cmp.YearV2__r.Name )
                        )
                        .add
                        (
                            new al.FieldCondition( 'CampaignName__c' ).likex('%'+cmp.DivisionRef__r.Name+'%' )
                        )
                        
                    );
            }
            
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
        cli.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
        cli.record.FarmRef__c = accountId;
        cli.record.CampaignRef__c = Util.currentCampaign.id;
        return cli;
    }
}