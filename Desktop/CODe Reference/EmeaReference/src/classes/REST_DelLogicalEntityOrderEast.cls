@RestResource(urlMapping='/getDeletedLogicalEntity/OrderEast/*')
global with sharing class REST_DelLogicalEntityOrderEast{

    @HttpPost
    global static REST_DelLogicalEntity_Order getDeletedOrders(REST_DelLogicalEntity_Order paramInfo)
    {
        REST_DelLogicalEntity_Order returned = new REST_DelLogicalEntity_Order();
        
		List<ID> activeCampaigns = new List<ID>();		
        Id OSRCampaign=UtilREST.OSRCurrentCampaign;
        Id CornCampaign=UtilREST.CornCurrentCampaign;
		
        returned.Campaigns = new List<Campaign>();
        Map<ID,Campaign> paramInfoCampaigns = new Map<ID,Campaign>(paramInfo.Campaigns);
        Set<ID> paramInfoCampaignIDs = paramInfoCampaigns.keySet();
        
        
        Set<ID> currentCampaignIDs = UtilREST.activeCampaigns; 
        
        paramInfoCampaignIDs.removeAll(currentCampaignIDs);
        for(ID i : paramInfoCampaignIDs){
            returned.Campaigns.add(paramInfoCampaigns.get(i));
        }
    
        returned.orders = new List<order__c>();
        Map<ID,order__c> paramInfoorders = new Map<ID,order__c>(paramInfo.orders);
        Set<ID> paramInfoorderIDs = paramInfoorders.keySet();
        
		//must be modified in the future and add a link to year 
        Map<ID,order__c> currentorders = new Map<ID,order__c>([SELECT ID FROM order__c WHERE ID IN :paramInfoorderIDs]);
        Set<ID> currentorderIDs = currentorders.keySet();
        
        paramInfoorderIDs.removeAll(currentorderIDs);
        for(ID i : paramInfoorderIDs){
            returned.orders.add(paramInfoorders.get(i));
        }
               
        returned.CampaignLineItems = new List<CampaignLineItem__c>();
        Map<ID,CampaignLineItem__c> paramInfoCampaignLineItems = new Map<ID,CampaignLineItem__c>(paramInfo.CampaignLineItems);
        Set<ID> paramInfoCampaignLineItemIDs = paramInfoCampaignLineItems.keySet();
        

		
		Set<ID> currentCampaignLineItemIDs = new Set<ID>();
		
		for(CampaignLineItem__c cli :[
			SELECT ID, CampaignRef__c, CampaignName__c FROM CampaignLineItem__c 
			WHERE ID IN :paramInfoCampaignLineItemIDs AND ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeSalesCatalogs_CLI
			AND CampaignRef__c!=null AND FarmRef__r.Name!=null AND ProductCatalogEntryRef__c!=null AND ProductRef__c!=null						
		])
		{	
			if(cli.CampaignName__c.contains('OSR') && cli.CampaignRef__c!=OSRCampaign)
          	  		cli.CampaignRef__c=OSRCampaign;
          	if(cli.CampaignName__c.contains('Corn') && cli.CampaignRef__c!=CornCampaign )
          	  		cli.CampaignRef__c=CornCampaign;		
			if(cli.CampaignRef__c!=null)
				currentCampaignLineItemIDs.add(cli.Id);
		}
				       
        paramInfoCampaignLineItemIDs.removeAll(currentCampaignLineItemIDs);
        for(ID i : paramInfoCampaignLineItemIDs){
            returned.CampaignLineItems.add(paramInfoCampaignLineItems.get(i));
        }              
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Order getExample()
    {
        REST_DelLogicalEntity_Order returned = new REST_DelLogicalEntity_Order();
        
        returned.campaigns = [SELECT ID FROM Campaign LIMIT 2];
        returned.orders = [SELECT ID FROM Order__c LIMIT 2];
        returned.campaignlineItems = [SELECT ID FROM CampaignLineItem__c LIMIT 2];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Order {
        public List<Campaign> campaigns;
        public List<Order__c> orders;
        public List<CampaignLineItem__c> CampaignLineItems;
    }
    
   
}