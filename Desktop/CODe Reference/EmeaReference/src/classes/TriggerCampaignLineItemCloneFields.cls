public class TriggerCampaignLineItemCloneFields implements Triggers.Handler
{
  
  private static map<Id, ProductCatalogEntry__c> productCatalogEntriesStaticMap = new map<Id, ProductCatalogEntry__c>();
  private static map<Id, CampaignLineItem__c> campaignLineItemsStaticMap = new map<Id, CampaignLineItem__c>();
  
  public static void setNewCampaignLineItems(list<CampaignLineItem__c> newElements) {
    campaignLineItemsStaticMap.putAll(newElements);
  }
  
  public static map<Id, ProductCatalogEntry__c> getProductCatalogEntries(list<Id> productCatalogEntryRefList) {
    map<Id, ProductCatalogEntry__c> result = new map<Id, ProductCatalogEntry__c>();
    list<Id> finalFilter = new list<Id>();
    for (Id element: productCatalogEntryRefList) {
      if (!productCatalogEntriesStaticMap.keyset().contains(element)) {
        finalFilter.add(element);
      }
      else {
        result.put(element, productCatalogEntriesStaticMap.get(element));
      }
    }
    if (finalFilter.size() > 0) {
      list<ProductCatalogEntry__c> newElements = new list<ProductCatalogEntry__c>([SELECT Price__c, PriceOld__c, NUM_PriceGeneral__c
       FROM ProductCatalogEntry__c WHERE ID in :finalFilter]);
      result.putAll(newElements);
      productCatalogEntriesStaticMap.putAll(newElements);
    }
    
    return result;
  }
  
  public static map<Id, CampaignLineItem__c> getCampaignLineItems(list<Id> campaignLineItemsList) {
    map<Id, CampaignLineItem__c> result = new map<Id, CampaignLineItem__c>();
    list<Id> finalFilter = new list<Id>();
    for (Id element: campaignLineItemsList) {
      if (!campaignLineItemsStaticMap.keyset().contains(element)) {
        finalFilter.add(element);
      }
      else {
        result.put(element, campaignLineItemsStaticMap.get(element));
      }
    }
    if (finalFilter.size() > 0) {
      list<CampaignLineItem__c> newElements = new list<CampaignLineItem__c>([SELECT FinalOrderRef_RSA__r.Status_RSA__c from CampaignLineItem__c WHERE ID IN :finalFilter]);
      result.putAll(newElements);
      campaignLineItemsStaticMap.putAll(newElements);
    }
    return result;
  }
  
    public void handle()
    {
        if(SystemSettings__c.getValues('RSA_DISABLE_COPY_FIELDS_YES_NO') == null || 'Yes'.equalsIgnoreCase(SystemSettings__c.getValues('RSA_DISABLE_COPY_FIELDS_YES_NO').Value__c)) return;
        // Get Related account IDs
        Set<ID> ProductCatalogEntryIDs = new Set<ID>();
  
        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(cli.shouldCopy_RSA__c){
                ProductCatalogEntryIDs.add(cli.ProductCatalogEntryRef__c);
            }
        }

        if(ProductCatalogEntryIDs.size() == 0)return;
        // Get Related Product catalog Entry Information
        /*Map<ID,ProductCatalogEntry__c> productCatalogEntries = new Map<ID,ProductCatalogEntry__c>([
            SELECT
                // fields to be copied
                Price__c
            FROM
                ProductCatalogEntry__c
            WHERE
                ID in :ProductCatalogEntryIDs ]
        );*/
        
        Map<ID,ProductCatalogEntry__c> productCatalogEntries = getProductCatalogEntries(new list<Id>(ProductCatalogEntryIDs));
        
        /*Map<ID,CampaignLineItem__c> extendedInfo = new Map<ID,CampaignLineItem__c>([SELECT FinalOrderRef_RSA__r.Status_RSA__c from CampaignLineItem__c WHERE ID IN :trigger.newMap.keyset()]);*/
        Map<ID,CampaignLineItem__c> extendedInfo = getCampaignLineItems(new list<Id>(trigger.newMap.keyset()));
        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            
            //if(cli.shouldCopy_RSA__c && (cli.FinalOrderRef_RSA__c == null || extendedInfo.get(cli.ID).FinalOrderRef_RSA__r.Status_RSA__c == 'Draft')){

           if(cli.shouldCopy_RSA__c && (cli.FinalOrderRef_RSA__c == null || extendedInfo.get(cli.ID).FinalOrderRef_RSA__r.Status_RSA__c == 'Draft'|| cli.Price_copy__c == null)){
                // copy all fields we need
				
				if(('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) && productCatalogEntries.get(cli.ProductCatalogEntryRef__c).PriceOld__c!=null))
               		cli.Price_copy__c = productCatalogEntries.get(cli.ProductCatalogEntryRef__c).PriceOld__c;
               	else if(('General'.equalsIgnoreCase(cli.CatalogType_RSA__c) && productCatalogEntries.get(cli.ProductCatalogEntryRef__c).NUM_PriceGeneral__c!=null))
               		cli.Price_copy__c = productCatalogEntries.get(cli.ProductCatalogEntryRef__c).NUM_PriceGeneral__c;
                else
                	cli.Price_copy__c = productCatalogEntries.get(cli.ProductCatalogEntryRef__c).Price__c;              	
                cli.shouldCopy_RSA__c = false;
            }
        }
    }
}