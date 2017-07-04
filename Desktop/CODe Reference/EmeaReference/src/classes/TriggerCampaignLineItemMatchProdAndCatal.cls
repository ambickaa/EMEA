public class TriggerCampaignLineItemMatchProdAndCatal implements Triggers.Handler{
	
	private static map<Id, Campaign> campaignStaticMap = new map<Id, Campaign>();
	
	public static map<Id, Campaign> getCampaigns(list<Id> campaignsList) {
		map<ID, Campaign> result = new map<ID, Campaign>();
		list<Id> finalFilter = new list<Id>();
		for (Id element: campaignsList) {
			if (!campaignStaticMap.keyset().contains(element)) {
				finalFilter.add(element);
			}
			else {
				result.put(element, campaignStaticMap.get(element));
			}
		}
		if (finalFilter.size() > 0) {
			list<Campaign> newElements = new list<Campaign>([SELECT TaxSalesPCMRef_RSA__c, SalesPCMRef__c FROM Campaign WHERE Id IN :finalFilter]);
			result.putAll(newElements);
			campaignStaticMap.putAll(newElements);
		}
		return result;
	}
	
    public void handle(){
        
        Set<ID> accountsUsed = new Set<ID>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(cli.FarmRef__c != null)accountsUsed.add(cli.FarmRef__c);
        }
        TriggerCampaignLineItemHelper.add(accountsUsed);
        if(TriggerCampaignLineItemHelper.rsa.isEmpty())return;
        Map<ID,List<ID>> productCatalogs = new Map<ID,List<ID>>(); // Map<CatalogID,List<ProductIDs>> used
        // Get Catalog Info
        Set<ID> campaignIDs = new Set<ID>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new)
        {
            if(	TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) 
            	&& 
	            	(	'Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) 
	            		||  'Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) 
	            		|| 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)
	            		|| 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c)
	            	)
            	)
            {
                campaignIDs.add(cli.CampaignRef__c);
            }
        }
        /*Map<ID,Campaign> campaignInfo = new Map<ID,Campaign>([SELECT TaxSalesPCMRef_RSA__c, SalesPCMRef__c FROM Campaign WHERE ID IN :campaignIDs]);*/
        Map<ID,Campaign> campaignInfo = getCampaigns(new list<Id>(campaignIDs));

        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if('Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c)){
                if(productCatalogs.get(campaignInfo.get(cli.CampaignRef__c).TaxSalesPCMRef_RSA__c) == null){
                    productCatalogs.put(campaignInfo.get(cli.CampaignRef__c).TaxSalesPCMRef_RSA__c,new List<ID>{cli.ProductRef__c});
                }else{
                    productCatalogs.get(campaignInfo.get(cli.CampaignRef__c).TaxSalesPCMRef_RSA__c).add(cli.ProductRef__c);
                }
            }else if('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)){
                if(productCatalogs.get(campaignInfo.get(cli.CampaignRef__c).SalesPCMRef__c) == null){
                    productCatalogs.put(campaignInfo.get(cli.CampaignRef__c).SalesPCMRef__c,new List<ID>{cli.ProductRef__c});
                }else{
                    productCatalogs.get(campaignInfo.get(cli.CampaignRef__c).SalesPCMRef__c).add(cli.ProductRef__c);
                }
            }
        }
        
        Map<ID,Map<ID,ID>> masterCatalog = new Map<ID,Map<ID,ID>>(); // Map<CatalogID, Map<ProductID, ProductCatalogEntryID (Associated)>>
        for(ID currentID : productCatalogs.keyset()){
            masterCatalog.put(currentID,new Map<ID,ID>());
            for(ProductCatalogEntry__c pce : [SELECT ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c = :currentID AND ProductRef__c in :productCatalogs.get(currentID)]){
                masterCatalog.get(currentID).put(pce.ProductRef__c,pce.ID);
            }
        }
        
        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if('Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c)){
                cli.ProductCatalogEntryRef__c = masterCatalog.get(campaignInfo.get(cli.CampaignRef__c).TaxSalesPCMRef_RSA__c).get(cli.ProductRef__c);
            }else if('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)){
                cli.ProductCatalogEntryRef__c = masterCatalog.get(campaignInfo.get(cli.CampaignRef__c).SalesPCMRef__c).get(cli.ProductRef__c);
            
            }
        }
    }
    
}