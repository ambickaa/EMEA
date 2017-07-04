public class TrialManagementFactory implements AccountListObjectFactory
{
    
    public Set<String>selectFields
    {
        get
        {
            if(selectFields == null)
            {
                selectFields = new Set<String> { 'OwnerId', 'id', 'Status__c'};
            }
            return selectFields;
        }
        set;
    }
    
    public Set<String>innerSelectFields
    {
        get
        {
            if(innerSelectFields == null)
            {
                innerSelectFields = new Set<String> {'OwnerId', 'ProductRef__r.name', 'ProductRef__c', 'Status__c'};
            }
            return innerSelectFields;
        }
        set;
    }
    
    
    public Set<String>getSelectSet()
    {
        Set<String>result = new Set<String>();
        for(String s : selectFields)
        {
            result.add(s);
        }
        String innerString = '( SELECT id ';
        for(String s : innerSelectFields)
        {
            innerString+= ', '+s;
        }
        innerString+=' From CampaignLineItems__r) ';
        result.add(innerString);
        return result;
    }
    
    
    public List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {
        
        Util.addDebugMessage('****');
        
        List<AccountListObjectWrapper> result = new List<CampaignLineItemGroup>();
        
        if(Util.currentCampaign<> null && Util.currentCampaign.id <> null)
        {
            al.SoqlBuilder query = new al.SoqlBuilder();
            if(Util.countryView.isAccountSharingEnabled){
                query.selectx(new Set<Object>
                {
                    'CampaignLineItemGroupRef__c'
                })
                .fromx('CampaignLineItem__c')
                .wherex(
                    new al.AndCondition()
                    .add
                    (
                        new al.FieldCondition( 'ProductRef__r.DivisionRef__c' ).equals( Util.divisionId )
                    )
                    .add
                    (
                        new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Trial') )
                    )
                    .add
                    (
                        new al.SetCondition( 'CampaignRef__c' ).inx( new List<ID>(new TrialManagementFactoryWithoutSharing().campaigns() ) )
                    )
                    .add
                    (
                        new al.FieldCondition('FarmRef__c').equals(accountId)
                    )
                );
            }else{
            
                query.selectx(new Set<Object>
                {
                    'CampaignLineItemGroupRef__c'
                })
                .fromx('CampaignLineItem__c')
                .wherex(
                    new al.AndCondition()
                    .add
                    (
                        new al.FieldCondition( 'ProductRef__r.DivisionRef__c' ).equals( Util.divisionId )
                    )
                    .add
                    (
                        new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Trial') )
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
            }
            Set<Id>groupIds = new Set<Id>();
            
            Util.addDebugMessage(query.toSOQL());
            for( CampaignLineItem__c t : Database.query(query.toSOQL()))
            {

                groupIds.add(t.CampaignLineItemGroupRef__c);

            }
            List<String>groupIdsList = new List<String>();
            for(String id : groupIds)
            {
                groupIdsList.add(id);
            }
            if(groupIds.size()>0)
            {
                al.SoqlBuilder groupQuery = new al.SoqlBuilder()
                .selectx
                (
                    getSelectSet()
                )
                .fromx('CampaignLineItemGroup__c')
                .wherex
                (
                    new al.AndCondition()
                    .add
                    (
                        new al.SetCondition( 'Id' ).inx( groupIdsList )
                    )
                );
               
                for(CampaignLineItemGroup__c clig : Database.query(groupQuery.toSOQL()))
                {
                    result.add(new CampaignLineItemGroup(clig));
                }
            }

        }
        return result;
    }
    public AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
        CampaignLineItemGroup clig = new CampaignLineItemGroup();
        clig.record.RecordTypeId = Util.recordType.get('CampaignLineItemGroup__c:Trial');
        clig.record.AccountRef__c = accountId;
        clig.record.CampaignRef__c = Util.currentCampaign.id;
        for(Integer i =0; i<Integer.valueOf(Util.urlParameters.get('numberOfLines')); i++)
        {
            clig.addNewProductLine();
        }
        return clig;
    }
    private without sharing class TrialManagementFactoryWithoutSharing{
        public Set<ID> Campaigns(){
            return new Map<ID,Campaign>([SELECT ID FROM Campaign WHERE DivisionRef__c = :Util.currentDivision.ID AND YearV2__c = :Util.currentCampaign.YearV2__c AND DE_Season__c = :Util.currentCampaign.DE_Season__c]).keySet();
        }
    }
}