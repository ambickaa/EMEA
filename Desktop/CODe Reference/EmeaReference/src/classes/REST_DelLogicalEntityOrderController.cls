@RestResource(urlMapping='/getDeletedLogicalEntity/Order_5/*')
global with sharing class REST_DelLogicalEntityOrderController{

    @HttpPost
    global static REST_DelLogicalEntity_Order getDeletedOrders(REST_DelLogicalEntity_Order paramInfo)
    {
        REST_DelLogicalEntity_Order returned = new REST_DelLogicalEntity_Order();
        
        
        returned.Campaigns = new List<Campaign>();
        Map<ID,Campaign> paramInfoCampaigns = new Map<ID,Campaign>(paramInfo.Campaigns);
        Set<ID> paramInfoCampaignIDs = paramInfoCampaigns.keySet();
        
        Map<ID,Campaign> currentCampaigns;
        if(UtilREST.currentCampaignRsa!=null)
      		 currentCampaigns = new Map<ID,Campaign>([
		        SELECT ID FROM Campaign 
		        WHERE /*(ID IN :paramInfoCampaignIDs)AND */ (StatusCode__c=200) AND 
		        OwnerID=:Util.currentUser.ID AND Id=:UtilREST.currentCampaignRsa.ID]);
		else
			currentCampaigns = new Map<ID,Campaign> ();        
         
        Set<ID> currentCampaignIDs = currentCampaigns.keySet();
        
        paramInfoCampaignIDs.removeAll(currentCampaignIDs);
        for(ID i : paramInfoCampaignIDs){
            returned.Campaigns.add(paramInfoCampaigns.get(i));
        }

        returned.orders = new List<order__c>();
        Map<ID,order__c> paramInfoorders = new Map<ID,order__c>(paramInfo.orders);
        Set<ID> paramInfoorderIDs = paramInfoorders.keySet();
        
        Map<ID,order__c> currentorders;
        if(UtilREST.currentCampaignRsa!=null)
	        currentorders = new Map<ID,order__c>([
	        SELECT ID FROM order__c WHERE /*(ID IN :paramInfoorderIDs)
		        AND*/  CreatedDate >= :UtilREST.currentCampaignRSA.StartDate AND CreatedDate<=:UtilREST.currentCampaignRSA.EndDate
		        AND AccountRef_RSA__r.OwnerId =:Util.currentUser.ID
		        AND OwnerId =:Util.currentUser.ID
	        ]);
	    else
	    	currentorders = new Map<ID,order__c>();
	    	
        Set<ID> currentorderIDs = currentorders.keySet();
        
        paramInfoorderIDs.removeAll(currentorderIDs);
        for(ID i : paramInfoorderIDs){
            returned.orders.add(paramInfoorders.get(i));
        }
        
               
        returned.CampaignLineItems = new List<CampaignLineItem__c>();
        Map<ID,CampaignLineItem__c> paramInfoCampaignLineItems = new Map<ID,CampaignLineItem__c>(paramInfo.CampaignLineItems);
        Set<ID> paramInfoCampaignLineItemIDs = paramInfoCampaignLineItems.keySet();
       
        
        Map<ID,CampaignLineItem__c> currentCampaignLineItems;
        if(UtilREST.currentCampaignRSA!=null)        
	        currentCampaignLineItems= new Map<ID,CampaignLineItem__c>([
	        	SELECT ID FROM CampaignLineItem__c WHERE /*ID IN :paramInfoCampaignLineItemIDs
	     		     AND /*( ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.previousYearCatalogs
	                 OR */ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeSalesCatalogsRSA_CLI 
	                 AND OwnerId =:Util.currentUser.ID  AND CampaignRef__c = : UtilREST.currentCampaignRSA.ID 
	                 AND FarmRef__r.OwnerId =:Util.currentUser.ID
	                 AND CreatedDate >= :UtilREST.currentCampaignRSA.StartDate AND CreatedDate<=:UtilREST.currentCampaignRSA.EndDate                                	
	        	]);
        else
        	currentCampaignLineItems= new Map<ID,CampaignLineItem__c>();
       	
        Set<ID> currentCampaignLineItemIDs = currentCampaignLineItems.keySet();
        
        paramInfoCampaignLineItemIDs.removeAll(currentCampaignLineItemIDs);
        for(ID i : paramInfoCampaignLineItemIDs){
            returned.CampaignLineItems.add(paramInfoCampaignLineItems.get(i));
        }
 
 		//Consignments
 		
 		returned.consignments = new List<Consignment__c>();
        Map<ID,Consignment__c> paramInfoconsignments = new Map<ID,Consignment__c>(paramInfo.consignments);
        Set<ID> paramInfoconsignmentIDs = paramInfoconsignments.keySet();
        
        Map<ID,Consignment__c> currentconsignments;
        if(UtilREST.currentCampaignRsa!=null)
	        currentconsignments = new Map<ID,Consignment__c>([
	        	SELECT ID FROM Consignment__c WHERE ID IN : paramInfoconsignmentIDs
		        AND ProductCatalogEntryRef__r.ProductCatalogRef__c in : UtilREST.activeRegularCatalogRSA
		        AND UserRef__c =:Util.currentUser.ID
		        AND Status__c = 'Accepted'
	        ]);
	    else
	    	currentconsignments = new Map<ID,Consignment__c>();
	    	
        Set<ID> currentconsignmentIDs = currentconsignments.keySet();
        
        paramInfoconsignmentIDs.removeAll(currentconsignmentIDs);
        for(ID i : paramInfoconsignmentIDs){
            returned.consignments.add(paramInfoconsignments.get(i));
        }        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Order getExample()
    {
        REST_DelLogicalEntity_Order returned = new REST_DelLogicalEntity_Order();
        
        returned.orders = [ SELECT ID FROM Order__c ];
        returned.CampaignLineItems = [ SELECT ID FROM CampaignLineItem__c];
        returned.campaigns = [SELECT ID FROM Campaign ];
        returned.consignments = [ SELECT ID FROM Consignment__c where UserRef__c=:Util.currentUser.ID ];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Order {
        public List<Campaign> campaigns;
        public List<Order__c> orders;
        public List<CampaignLineItem__c> CampaignLineItems;
        public List<Consignment__c> consignments;
    }
    
    static testMethod void testRest() {
        // set up the request object
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/getDeletedLogicalEntity/Order_5';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');
        // Invoke the method directly
        
        REST_DelLogicalEntity_Order param = new REST_DelLogicalEntity_Order();
        param.campaigns = new List<Campaign>();
        param.orders = new List<Order__c>();
        param.CampaignLineItems = new List<CampaignLineItem__c>();
        param.consignments = new List<Consignment__c>();
        
        REST_DelLogicalEntityOrderController.getDeletedOrders(param);
    }
}