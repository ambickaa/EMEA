public virtual class TacticalPlanCountryFactory {

    public Set<String>selectFields
    {
        get
        {
            if(selectFields == null)
            {
                
                selectFields = new Set<String> { 'id', 'DE_DistributorRef__c', 'LKP_DistributorRefST__c', 'ProductCatalogEntryRef__r.DE_isPremium__c', 'ProductCatalogEntryRef__r.DE_Sorten__c', 'FarmRef__r.PrimaryDistributor__c', 'DE_isPremium__c', 'ProductRef__c', 'Quantity__c', 'ProductRef__r.Name', 'ProductCatalogEntryRef__c', 'ForecastLow__c', 'ForecastPlusOne__c ','POG__c', 'Inventory__c', 'Treatment__c', 'Status__c ', 'Inventory__c', 'Type__c', 'PlantingDensity__c', 'DistributorRef__c', 'PoS__c', 'Forecast__c', 'FarmRef__c', 'ChargedElement__c', 'CampaignRef__c', 'Agreed__c', 'FreeOfChargeElement__c', 'OwnerID', 'ProductRef__r.ProductDisplayName__c'};
                //Beg France Change (Add fields: )
                //Original: Set<String> selectFieldsFrance = new Set<String> {'Provider__c ','Humidity__c','NoteTK__c','CommercialPhase__c','ForecastLow__c','Forecast__c','PDP_Allocation__c','Price_Copy__c','ProductCatalogEntryRef__r.Product_Name__c',' ProductCatalogEntryRef__r.Vendor__c',' SAP_UNITS_ORDERED__c','SAP_UNITS_PAID__c','SAP_UNITS_SHIPPED__c','Treatment__c'};
                Set<String> selectFieldsFrance = new Set<String> {'Provider__c ','Humidity__c','NoteTK__c','CommercialPhase__c','ForecastLow__c','Forecast__c','PDP_Allocation__c','Price_Copy__c','ProductCatalogEntryRef__r.Product_Name__c',' ProductCatalogEntryRef__r.Vendor__c','NUM_ORDERED_CY_QTY__c','NUM_INVOICED_CY_QTY__c','NUM_DELIVERED_CY_QTY__c','Treatment__c'};                
                //End France Change
                selectFields.addAll(selectFieldsFrance);
                
            }
            return selectFields;
        }
        set;
    }
    
    private Map<ID,Campaign> campaignsInfo = new Map<ID,Campaign>();
    // generates SOQL QUERY for current Campaign and Last Campaign Line Items
    public al.SoqlBuilder generateQuery()
    {
        // Campaign Condition
        al.OrCondition campaignCondition = new al.OrCondition();

        if(Util.countryView.isAccountSharingEnabled){
            if(Util.currentCampaign <> null)
            {    
                al.AndCondition campaignAndCondition = new al.AndCondition();
                
                campaignAndCondition.add
                (
                    new al.FieldCondition( 'StatusCode__c' ).equals(200)
                );
                campaignAndCondition.add 
                (
                    new al.FieldCondition( 'DE_Season__c' ).equals( Util.currentCampaign.DE_Season__c )
                );
                campaignAndCondition.add
                (
                    new al.FieldCondition( 'DivisionRef__c' ).equals( Util.currentDivision.ID )
                );
              al.SoqlBuilder cQuery = new al.SoqlBuilder();
              cQuery
                    .selectx(new Set<String>{'StatusCode__c','DE_Season__c'})
                    .fromx('Campaign')
                    .wherex
                    (
                        campaignAndCondition
                    );
                Map<ID,Campaign> tempMap = new Map<ID,Campaign>(new TacticalPlanCountryFactoryWithoutSharing().getCampaigns(cQuery.toSoql()));
                campaignCondition.add(new al.SetCondition('CampaignRef__c').inx(new List<ID>(tempMap.keyset()))); 
                campaignsInfo.putAll(tempMap);
                
//                    campaignCondition.add(campaignAndCondition);
            }
            if(Util.previewsCampaign <> null)
            {
                al.AndCondition campaignAndCondition = new al.AndCondition();
                al.OrCondition campaignOrCondition = new al.OrCondition();
                
                campaignAndCondition.add
                (
                    new al.FieldCondition( 'StatusCode__c' ).equals(300)

                );
                campaignAndCondition.add
                (
                    new al.FieldCondition( 'DE_Season__c' ).equals( Util.previewsCampaign.DE_Season__c )
                );
                campaignAndCondition.add
                (
                    new al.FieldCondition( 'DivisionRef__c' ).equals( Util.currentDivision.ID )
                );
                
                al.SoqlBuilder cQuery = new al.SoqlBuilder();
                cQuery
                    .selectx(new Set<String>{'StatusCode__c','DE_Season__c'})
                    .fromx('Campaign')
                    .wherex
                    (
                        campaignAndCondition
                    );
                Map<ID,Campaign> tempMap = new Map<ID,Campaign>(new TacticalPlanCountryFactoryWithoutSharing().getCampaigns(cQuery.toSoql()));
                campaignCondition.add
                (
                    new al.AndCondition()
                    
                       .add ( new al.SetCondition( 'CampaignRef__c' ).inx(new List<ID>(tempMap.keyset())) )
                       .add (  
                       
                               new al.OrCondition()
                               
                                  .add(  
                                           new al.AndCondition()
                                                .add(new al.FieldCondition('Division__c').notEquals('Corn'))
                                                .add(new al.FieldCondition('Division__c').notEquals('OSR'))
                                    )
                                  .add ( new al.AndCondition()
                                  
                                          .add(new al.FieldCondition('POG__c').greaterThan(0))
                                          .add(  
                                                   new al.OrCondition()
                                                        .add(new al.FieldCondition('Division__c').Equals('Corn'))
                                                        .add(new al.FieldCondition('Division__c').Equals('OSR'))
                                              )
                                       )
                             )
                    );  
                    
                campaignsInfo.putAll(tempMap);
//                campaignCondition.add(campaignAndCondition);             
            }   
        }else{
            if(Util.currentCampaign <> null)
            {
                campaignCondition.add
                (
                    new al.FieldCondition( 'CampaignRef__c' ).equals( Util.currentCampaign.id )
                );
            }
            
            if(Util.previewsCampaign <> null)
            {
                
                campaignCondition.add
                (
                    new al.AndCondition()
                    
                       .add ( new al.FieldCondition( 'CampaignRef__c' ).equals( Util.previewsCampaign.id ) )
                       .add (  
                       
                               new al.OrCondition()
                               
                                  .add(  
                                           new al.AndCondition()
                                                .add(new al.FieldCondition('Division__c').notEquals('Corn'))
                                                .add(new al.FieldCondition('Division__c').notEquals('OSR'))
                                    )
                                  .add ( new al.AndCondition()
                                  
                                          .add(new al.FieldCondition('POG__c').greaterThan(0))
                                          .add(  
                                                   new al.OrCondition()
                                                        .add(new al.FieldCondition('Division__c').Equals('Corn'))
                                                        .add(new al.FieldCondition('Division__c').Equals('OSR'))
                                              )
                                       )
                             )
                );                        
                                  
                                               
               
                
            }
        }
        
        // Generate SOQL
        al.SoqlBuilder query = new al.SoqlBuilder();
        query
        .selectx(selectFields)
        .fromx('CampaignLineItem__c')
        .wherex
        (
            new al.AndCondition()
            .add
            (
                new al.FieldCondition( 'FarmRef__c' ).equals(Util.currentAccount.id)
            )
             .add
            (
                new al.FieldCondition( 'RecordTypeId' ).equals( Util.recordType.get('CampaignLineItem__c:Sales') )
            )
            .add
            (
                campaignCondition
            )
        );
       // Util.addInfoMessage(query.toSoql());
        system.debug('QUERY TEST ' +query);
        return query;
    }
    
    public Map<String, CampaignLineItem>prevCCampaignLineItems = new Map<String, CampaignLineItem>();
    public Map<String, CampaignLineItem>prevFOCCampaignLineItems = new Map<String, CampaignLineItem>();
    
    public Map<String, CampaignLineItem>nextCCampaignLineItems = new Map<String, CampaignLineItem>();
    public Map<String, CampaignLineItem>nextFOCCampaignLineItems = new Map<String, CampaignLineItem>();
    
    public void sortCampaignLineItemsAndCreateMapsFromIt()
    {
        for(CampaignLineItem__c crecord : Database.query(generateQuery().toSOQL()))
            {
                CampaignLineItem c = new CampaignLineItem(crecord);
                if(Util.countryView.isAccountSharingEnabled){
                    c.record.CampaignRef__r = campaignsInfo.get(c.record.campaignRef__c);
                }
                if(Util.currentCampaign <> null && (c.record.CampaignRef__c == Util.currentCampaign.id || (Util.countryView.isAccountSharingEnabled && c.record.CampaignRef__r.StatusCode__c == 200 && c.record.CampaignRef__r.DE_Season__c == Util.currentCampaign.DE_Season__c)))
                {
                    if(c.record.Type__c == 'Charged')
                    {
                        while(nextCCampaignLineItems.containsKey(c.key))
                        {
                            c.key+='C';
                        }
                        nextCCampaignLineItems.put(c.key, c);
                    }
                    else
                    {
                        while(nextFOCCampaignLineItems.containsKey(c.key))
                        {
                            c.key+='C';
                        }
                        nextFOCCampaignLineItems.put(c.key, c);
                    }
                    
                }
                else if(Util.previewsCampaign <> null && (c.record.CampaignRef__c == Util.previewsCampaign.id || (Util.countryView.isAccountSharingEnabled && c.record.CampaignRef__r.StatusCode__c == 300 && c.record.CampaignRef__r.DE_Season__c == Util.previewsCampaign.DE_Season__c)))
                {
                    
                    
                    if(c.record.Type__c == 'Charged')
                    {
                        
                        while(prevCCampaignLineItems.containsKey(c.key))
                        {
                            c.key+='C';
                        }
                        prevCCampaignLineItems.put(c.key, c);
                    }
                    else
                    {
                        while(prevFOCCampaignLineItems.containsKey(c.key))
                        {
                            c.key+='C';
                        }
                        prevFOCCampaignLineItems.put(c.key, c);
                    }
                }
                
            }
    }
    private without sharing class TacticalPlanCountryFactoryWithoutSharing{
        public List<CampaignLineItem__c> query(String paramQuery){
            Map<ID,CampaignLineItem__c> allReturned = new Map<ID,CampaignLineItem__c>(((List<CampaignLineItem__c>)database.query(paramQuery)));
            
            List<CampaignLineItem__c> returned = new List<CampaignLineItem__c>();
            Util.addInfoMessage('162');
            for(UserRecordAccess ura : [SELECT recordID FROM UserRecordAccess WHERE UserID = :userInfo.getUserID() AND recordID in :allReturned.keyset() and hasReadAccess=true])
            {
                returned.add(allReturned.get(ura.recordID));
                Util.addInfoMessage(ura);
            }
            //return allReturned.values();
            return returned;
        }
        
        public List<Campaign> getCampaigns(String paramQuery){
            return (List<Campaign>)database.query(paramQuery);
        }
    }
}