public class TriggerCampaignLineItemCreateHistory  implements Triggers.Handler
{
    Map<Id, CampaignLineItem__c> processedTacticalPlanElements = new Map<Id, CampaignLineItem__c>();
    public void handle()
    {
        // for all tactical plans add history if needed
        List<CampaignLineItemHistory__c> aNewHistoryRecords = new List<CampaignLineItemHistory__c>();
        List<CampaignLineItemHistory__c> aNewHistoryRecordsRSA = new List<CampaignLineItemHistory__c>();

        if(!trigger.isDelete)
        {
            for (CampaignLineItem__c aCampaignLineItem : (List<CampaignLineItem__c>)Trigger.new)
            {
                if (Trigger.isInsert)
                {
                    if(aCampaignLineItem.country__c!=null && !aCampaignLineItem.country__c.equalsIgnoreCase('South Africa'))
                        aNewHistoryRecords.addAll(createCampaignLineItem(aCampaignLineItem));
                    else
                        aNewHistoryRecordsRSA.addAll(createCampaignLineItemRSA(aCampaignLineItem));             
                }else if (Trigger.isUpdate)
                {
                    if(aCampaignLineItem.country__c!=null && !aCampaignLineItem.country__c.equalsIgnoreCase('South Africa'))              
                        aNewHistoryRecords.addAll(createCampaignLineItem((CampaignLineItem__c)Trigger.oldMap.get(aCampaignLineItem.id), aCampaignLineItem));
                    else
                        aNewHistoryRecordsRSA.addAll(createCampaignLineItemRSA((CampaignLineItem__c)Trigger.oldMap.get(aCampaignLineItem.id), aCampaignLineItem));                  
                }           
            }
        }else
        {
            for (CampaignLineItem__c aCampaignLineItem : (List<CampaignLineItem__c>)Trigger.old)
            {
                aNewHistoryRecordsRSA.addAll(deleteCampaignLineItemRSA(aCampaignLineItem)); 
            }                                       
        }
                    
        // save new History Records
        
        if(aNewHistoryRecords.size()>0)
            upsert aNewHistoryRecords;
        if(aNewHistoryRecordsRSA.size()>0)
        {
            try{
                upsert aNewHistoryRecordsRSA PK_RSA__c; // PK_RSA__c is CampaignLineItem ID, this is possible because ID although they were deleted, never are re-used.
            }
            catch(Exception e){
                
            }
        }
    }
    
    // create History by compairing old and new Records
    private List<CampaignLineItemHistory__c> createCampaignLineItem(CampaignLineItem__c theOldRecord, CampaignLineItem__c theNewRecord)
    {
        List<CampaignLineItemHistory__c> aResultCampaignHistory = new List<CampaignLineItemHistory__c>();
        List<String> aCompaignFields = 'Agreed,Forecast,POG,Inventory'.split(',');
        
        Boolean anIsChange = false;
        CampaignLineItemHistory__c aCampaignHistory = new CampaignLineItemHistory__c(CampaignLineItem__c = theNewRecord.id);
        for (String aKey : aCompaignFields)
        {
            aCampaignHistory.put(aKey + '__c', theNewRecord.get(aKey + '__c'));
            if (theOldRecord == null || (theNewRecord.get(aKey + '__c') != theOldRecord.get(aKey + '__c')))
            {
                aCampaignHistory.put(aKey + 'Changed__c', true);
                anIsChange = true;
            }
        }
        if (anIsChange)
        {
            aResultCampaignHistory.add(aCampaignHistory);
        }
        return aResultCampaignHistory;
    }
    
    private List<CampaignLineItemHistory__c> deleteCampaignLineItemRSA (CampaignLineItem__c theOldRecord)
    {
        List<CampaignLineItemHistory__c> aResultCampaignHistory = new List<CampaignLineItemHistory__c>();
        
        CampaignLineItemHistory__c aCampaignHistory = new CampaignLineItemHistory__c(CampaignLineItem__c = theOldRecord.id, PK_RSA__c=(String)theOldRecord.id);
        aCampaignHistory.put('Agreed__c', 0);           
        aCampaignHistory.put('PoG__c', 0);          
        aResultCampaignHistory.add(aCampaignHistory); 
                
        return aResultCampaignHistory;              
    }

    // for RSA we need a unique record containing relevant data
    private List<CampaignLineItemHistory__c> createCampaignLineItemRSA(CampaignLineItem__c theOldRecord, CampaignLineItem__c theNewRecord)
    {
        List<CampaignLineItemHistory__c> aResultCampaignHistory = new List<CampaignLineItemHistory__c>();
        List<String> aCompaignFields = 'Agreed,Forecast,POG,Inventory,PreliminaryOrderRef_RSA,FinalOrderRef_RSA,ProductRef,ProductCatalogEntryRef,FarmRef,CampaignRef'.split(',');
        
        Boolean anIsChange = false;
        CampaignLineItemHistory__c aCampaignHistory = new CampaignLineItemHistory__c(CampaignLineItem__c = theNewRecord.id, PK_RSA__c=(String)theNewRecord.id);
        for (String aKey : aCompaignFields)
        {
            aCampaignHistory.put(aKey + '__c', theNewRecord.get(aKey + '__c'));
            
            //check if CLI is in a Preliminary for first time to save a copy
            //we create a copy of the first Agreed and Preliminary (to cover case an item is moved to another preliminary, or removed from a Preliminary)
            //add logic to trigger aCampaignHistoy before insert not to allow to modify AgreedCopy and PreliminaryOrderCopy!!
            //if old values !=null, new values = old values :D
                        
            if (theOldRecord == null || (theNewRecord.get(aKey + '__c') != theOldRecord.get(aKey + '__c')))
            {
                anIsChange = true;
            }
        }
        
        if(theNewRecord.get('PreliminaryOrderRef_RSA__c')!=null && ( theOldRecord==null || theOldRecord.get('PreliminaryOrderRef_RSA__c')==null))
        {
                aCampaignHistory.put('AgreedCopy__c', theNewRecord.get('Agreed__C'));
                aCampaignHistory.put('PreliminaryOrderRef_RSACopy__c', theNewRecord.get('PreliminaryOrderRef_RSA__c'));
        }   
        
        //cancelled order, let's save preliminary for historic reasons
        
        if (anIsChange)
        {
            aResultCampaignHistory.add(aCampaignHistory);
        }
        return aResultCampaignHistory;
    }
    
    // create History for new Record
    private List<CampaignLineItemHistory__c> createCampaignLineItem(CampaignLineItem__c theNewRecord)
    {
        return createCampaignLineItem(null, theNewRecord);
    }
    
    private List<CampaignLineItemHistory__c> createCampaignLineItemRSA(CampaignLineItem__c theNewRecord)
    {
        return createCampaignLineItemRSA(null, theNewRecord);
    }
    
    
}