/* 
    Class that takes care of filling PersonalStock_RSA__c and GlobalStock_RSA__c lookup fields accordingly
*/
public class TriggerCampaignLineItemFillStockLookups implements Triggers.Handler{
    
    private static map<Id, Campaign> campaignStaticMap = new map<Id, Campaign>();
    private static map<Id, User> usersStaticMap = new map<Id, User>();
    
    public static map<ID, Campaign> getCampaigns(list<Id> campaignsList) {
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
            list<Campaign> newElements = new list<Campaign>([SELECT TaxSalesPCMRef_RSA__c, SalesPCMRef__c, OwnerID, YearV2__c FROM Campaign WHERE ID IN :finalFilter]);
            result.putAll(newElements);
            campaignStaticMap.putAll(newElements);
        }
        return result;
    }

    public static map<ID, User> getUsers(list<Id> usersList) {
        map<ID, User> result = new map<ID, User>();
        list<Id> finalFilter = new list<Id>();
        for (Id element: usersList) {
            if (!usersStaticMap.keyset().contains(element)) {
                finalFilter.add(element);
            }
            else {
                result.put(element, usersStaticMap.get(element));
            }
        }
        if (finalFilter.size() > 0) {
            list<User> newElements = new list<User>([SELECT Managerid, ManagersManagerID_RSA__c FROM User WHERE ID IN :finalFilter]);
            result.putAll(newElements);
            usersStaticMap.putAll(newElements);
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
        Set<ID> campaignIDs = new Set<ID>();
        
        Set<ID> productCatalogEntryIDs = new Set<ID>();
        for (CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && ('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)|| 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c))){
                campaignIDs.add(cli.CampaignRef__c);
            }    
            
        }
        /*Map<ID,Campaign> campaignInfo = new Map<ID,Campaign>([SELECT TaxSalesPCMRef_RSA__c, SalesPCMRef__c, OwnerID, YearV2__c FROM Campaign WHERE ID IN :campaignIDs]);*/
        Map<ID,Campaign> campaignInfo = getCampaigns(new list<Id>(campaignIDs));
                
        
        Set<ID> usersInvolvedID = new Set<ID>();
        Set<ID> salesRep = new Set<ID>();
        
        for(Campaign c : campaignInfo.values()){
            usersInvolvedID.add(c.OwnerID);
            salesRep.add(c.OwnerID);
        }
        /*for(User u : [SELECT Managerid, ManagersManagerID_RSA__c FROM User WHERE ID in :usersInvolvedID]){*/
        for (User u : getUsers(new list<Id>(usersInvolvedID)).values()) {
            usersInvolvedID.add(u.ManagerID); 
            usersInvolvedID.add(u.ManagersManagerID_RSA__c);
        }
        
        /*Map<ID,User> usersInvolved = new Map<ID,User>([SELECT ManagerID, ManagersManagerID_RSA__c FROM User WHERE ID IN :usersInvolvedID]);*/
        Map<ID,User> usersInvolved = getUsers(new list<Id>(usersInvolvedID));
        
     
        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(cli.FarmRef__c != null &&
               TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) &&
               cli.CampaignRef__c != null &&
               cli.Type__c == 'Charged' &&
               campaignInfo.get(cli.CampaignRef__c).YearV2__c == UtilREST.currentYearRSA  )
            {
                productCatalogEntryIDs.add(cli.ProductCatalogEntryRef__c);
            }
            
        }
        
        Map<ID,Map<ID,ID>> stocksByUser = new Map<ID,Map<ID,ID>>();
        List<String> Hybrids = new List<String>();
        List<Id> ProductCatalogs = new List<Id>();
        
        for(Stock__c stock : [
                        SELECT 
                            User_RSA__c,
                            ProductCatalogEntryRef_RSA__c,
                            HybridName__c,
                            ProductCatalogId__c
                        FROM Stock__c 
                        WHERE 
                            User_RSA__c in :usersInvolvedID AND 
                            ProductCatalogEntryRef_RSA__c in :productCatalogEntryIDs
                             
                        ])
        {
            if(stocksByUser.get(stock.User_RSA__c) == null){
                stocksByUser.put(stock.User_RSA__c,new Map<ID,ID>{stock.ProductCatalogEntryRef_RSA__c => stock.id});
            }else{
                stocksByUser.get(stock.User_RSA__c).put(stock.ProductCatalogEntryRef_RSA__c,stock.id);
            }
            Hybrids.add(stock.HybridName__c);
            ProductCatalogs.add((ID)stock.ProductCatalogId__c);          
        }
        
        Map<String,Id> PKvsWarehouseId = new Map<String,Id> ();
        
        for(ConsignmentWarehouse__c  wh : [ SELECT PK__c FROM ConsignmentWarehouse__c WHERE UserRef__c in : salesRep AND Name in : Hybrids AND ProductCatalogRef__c in :ProductCatalogs ])
        {
            PKvsWarehouseId.put(wh.PK__c, wh.ID);
        }       

        for(CampaignLineItem__c cli : (List<CampaignLineItem__c>)trigger.new){
            if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && ('Tax'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c))){
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null &&
                   stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagersManagerID_RSA__c) != null){
                        cli.GlobalStock_RSA__c = stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagersManagerID_RSA__c).get(cli.ProductCatalogEntryRef__c);
                }
            }else if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && ('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)) && !cli.consigned__c ){
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null && 
                   stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagerID) != null){

                       cli.GlobalStock_RSA__c = stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagerID).get(cli.ProductCatalogEntryRef__c);
                }
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   stocksByUser.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null){
                        cli.PersonalStock_RSA__c = stocksByUser.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).get(cli.ProductCatalogEntryRef__c);
                }
            }else if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && ('Feb Receipt'.equalsIgnoreCase(cli.CatalogType_RSA__c) || 'Regular'.equalsIgnoreCase(cli.CatalogType_RSA__c)) && cli.consigned__c ){
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null && 
                   stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagerID) != null){
                       cli.GlobalStock_RSA__c = stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagerID).get(cli.ProductCatalogEntryRef__c);
                       if(PKvsWarehouseId.get(cli.HybridName__c+'-'+cli.OwnerId+'-'+cli.ProductCatalogId__c)!=null)
                            cli.ConsignedWarehouseRef__c =  PKvsWarehouseId.get(cli.HybridName__c+'-'+cli.OwnerId+'-'+cli.ProductCatalogId__c);               
                }
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   stocksByUser.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null){
                        cli.PersonalStock_RSA__c = stocksByUser.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).get(cli.ProductCatalogEntryRef__c);
                }                       
            
            }else if(TriggerCampaignLineItemHelper.rsa.contains(cli.FarmRef__c) && 'General'.equalsIgnoreCase(cli.CatalogType_RSA__c)){
                
                if(campaignInfo.get(cli.CampaignRef__c) != null &&
                   usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID) != null &&
                   stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagersManagerID_RSA__c) != null){
                        cli.GlobalStock_RSA__c = stocksByUser.get(usersInvolved.get(campaignInfo.get(cli.CampaignRef__c).OwnerID).ManagersManagerID_RSA__c).get(cli.ProductCatalogEntryRef__c);
                }  
            }
        }
    }



}