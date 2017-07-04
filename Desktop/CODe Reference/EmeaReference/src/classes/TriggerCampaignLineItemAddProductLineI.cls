/*
 * Class takes care of the relation between products and Product Catalog Entr. If there is a Camp linked
 *
 */



public class TriggerCampaignLineItemAddProductLineI  implements Triggers.Handler
{
    private static map<Id,Campaign> aCampaignStaticMap = new  map<Id, Campaign> ();
    private static boolean firstRun = true;
    private static boolean firstInsertRun = true;
    private static boolean firstUpdateRun = true;
    
    public static  map<Id,Campaign> getACampaign(list<Id> aCampaignRefList ){
        list<Id> finalFilter = new list<Id>();
        map<Id,Campaign> result = new map<Id,Campaign>();
        for (Id element: aCampaignRefList) {
            if (!aCampaignStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else{
                result.put(element, aCampaignStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<Campaign> newElements = new list<Campaign>([SELECT ID, SalesPCMRef__c, TrialPCMRef__c, CompetitorPCMRef__c, GiveAwayPCMRef__c FROM Campaign WHERE ID IN :finalFilter]);
            aCampaignStaticMap.putAll(newElements);
            result.putAll(newElements);
        }
        return result;
     }  
   

  
    
    
    public void handle()
    {

        if (trigger.isInsert){
            if (firstInsertRun){
                firstInsertRun = false;
            }else{
                return;
            }
        }else if(trigger.isUpdate){
            if (firstUpdateRun){
                firstUpdateRun = false;
            }else{
                return;
            }
        }


        //if (firstRun)
        //{
            firstRun = false;
            // collect campaign Ids
            // collect Product Ids
            Set<Id> aCampaignIds = new Set<Id>();
            Set<Id> aProductIds = new Set<Id>();
            
            for (CampaignLineItem__c aCampaignItem : (List<CampaignLineItem__c>)Trigger.new)
            {
                if (aCampaignItem.CampaignRef__c != null)
                {
                    aCampaignIds.add(aCampaignItem.CampaignRef__c);
                }
                if(aCampaignItem.ProductRef__c != null)
                {
                    aProductIds.add(aCampaignItem.ProductRef__c);
                }
            }
            // if Campaign Line Ids > 0 continue to find Product Catalogs
            if (aCampaignIds.size() > 0 && aProductIds.size() > 0)
            {
                Set<Id> aProductCatalogIds = new Set<Id>();
                /*Map<Id, Campaign> aCampaignMap = new Map<Id, Campaign>([
                        SELECT ID, SalesPCMRef__c, TrialPCMRef__c, CompetitorPCMRef__c, GiveAwayPCMRef__c 
                        FROM Campaign 
                        WHERE ID IN :aCampaignIds]);*/
                Map<Id, Campaign> aCampaignMap =getACampaign(new list<Id>(aCampaignIds));
                
                for (Campaign aCampaign : aCampaignMap.values())
                {
                    if(aCampaign.SalesPCMRef__c != null)
                    {
                        aProductCatalogIds.add(aCampaign.SalesPCMRef__c);
                    }
                    if(aCampaign.TrialPCMRef__c != null)
                    {
                        aProductCatalogIds.add(aCampaign.TrialPCMRef__c);
                    }
                    if(aCampaign.CompetitorPCMRef__c != null)
                    {
                        aProductCatalogIds.add(aCampaign.CompetitorPCMRef__c);
                    }
                    if(aCampaign.GiveAwayPCMRef__c != null)
                    {
                        aProductCatalogIds.add(aCampaign.GiveAwayPCMRef__c);
                    }
                }
                // collect product Catalog Entries related to campaigns
                Map<String, ProductCatalogEntry__c> aProductCatalogEntryMap = new Map<String, ProductCatalogEntry__c>();
                for (ProductCatalogEntry__c aProductCatalogEntry : [SELECT ProductCatalogRef__c, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductRef__c IN :aProductIds AND ProductCatalogRef__c = :aProductCatalogIds])
                {
                    aProductCatalogEntryMap.put(String.valueOf(aProductCatalogEntry.ProductCatalogRef__c) + String.valueOf(aProductCatalogEntry.ProductRef__c), aProductCatalogEntry);
                }
                
                for (CampaignLineItem__c aCampaignItem : (List<CampaignLineItem__c>)Trigger.new)
                {
                    if (aCampaignItem.CampaignRef__c != null)
                    {
                        Campaign aCurrentCampaign = aCampaignMap.get(aCampaignItem.CampaignRef__c);
                        // generate Keys For Campaign Line Items
                        String aGiveAwayKey = String.valueOf(aCurrentCampaign.GiveAwayPCMRef__c) + String.valueOf(aCampaignItem.ProductRef__c);
                        String aTrailKey = String.valueOf(aCurrentCampaign.TrialPCMRef__c) + String.valueOf(aCampaignItem.ProductRef__c);
                        String aCompetitorKey = String.valueOf(aCurrentCampaign.CompetitorPCMRef__c) + String.valueOf(aCampaignItem.ProductRef__c);
                        String aSalesKey = String.valueOf(aCurrentCampaign.SalesPCMRef__c) + String.valueOf(aCampaignItem.ProductRef__c);
                        
                        if (Util.recordTypeId.get(aCampaignItem.RecordTypeId) == 'CampaignLineItem__c:GiveAway' && aProductCatalogEntryMap.containsKey(aGiveAwayKey))
                        {
                            aCampaignItem.ProductCatalogEntryRef__c = aProductCatalogEntryMap.get(aGiveAwayKey).id;
                        } else if (Util.recordTypeId.get(aCampaignItem.RecordTypeId) == 'CampaignLineItem__c:Sales' )
                        {
                            if(aProductCatalogEntryMap.containsKey(aSalesKey))
                            {
                                aCampaignItem.ProductCatalogEntryRef__c = aProductCatalogEntryMap.get(aSalesKey).id;
                            //}else if(aProductCatalogEntryMap.containsKey(aCompetitorKey))
                           // {
                             //   aCampaignItem.ProductCatalogEntryRef__c = aProductCatalogEntryMap.get(aCompetitorKey).id;
                            } 
                        } else if (Util.recordTypeId.get(aCampaignItem.RecordTypeId) == 'CampaignLineItem__c:Trial')
                        {
                            if (aProductCatalogEntryMap.containsKey(aTrailKey))
                            {
                                aCampaignItem.ProductCatalogEntryRef__c = aProductCatalogEntryMap.get(aTrailKey).id;
                            } else if (aProductCatalogEntryMap.containsKey(aCompetitorKey))
                            {
                                aCampaignItem.ProductCatalogEntryRef__c = aProductCatalogEntryMap.get(aCompetitorKey).id;
                            }
                        }
                    }
                }
            }
        //}
    }
}