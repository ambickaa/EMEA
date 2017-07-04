/*

Fill StockRef__c lookup with the proper Regular Stock ID

*/

public class TriggerConsignmentFillStockLookups implements Triggers.Handler{


	Map<ID,ID> StockIds = new Map<ID,ID>();  //PCE vs STOCK
	Map<ID,ID> Managers = new Map<ID,ID>();  // SalesRep vs Manager
	SET <ID> UserIds = new SET <ID>();
	SET <ID> ManagerIds = new SET<ID>();
	SET <ID> PCEs = new SET<ID>();
	Map<ID, Map<ID,ID>> pceVsStockAndMngr = new Map<ID, Map<ID,ID>> ();  // Map<PCE,MAP<Manager,Stock>>>
	
    public void handle()
    {
    	for(Consignment__c con :  (List<Consignment__c>)trigger.new)
    	{
    		// add just needed users
    		UserIds.add(con.UserRef__c);
    		PCEs.add(con.ProductCatalogEntryRef__c);
    	}
   		    	
    	for(User usr: [SELECT ID, ManagerId FROM User WHERE ID in: UserIds])
    	{
    		Managers.put(usr.ID,usr.ManagerId);
    		ManagerIds.add(usr.ManagerID);   		
    	}
    	    	
   		if(trigger.isInsert || trigger.isUpdate)
   		{
   			for(Stock__c stk: [SELECT ID, ProductCatalogEntryRef_RSA__c, User_RSA__c FROM Stock__c WHERE User_RSA__c in:ManagerIds and ProductCatalogEntryRef_RSA__c in:PCEs])
   			{
   				if(pceVsStockAndMngr.get(stk.ProductCatalogEntryRef_RSA__c)==null)
   					pceVsStockAndMngr.put(stk.ProductCatalogEntryRef_RSA__c, new Map<Id,Id>{stk.User_RSA__c => stk.ID});
   				else
   					pceVsStockAndMngr.get(stk.ProductCatalogEntryRef_RSA__c).put(stk.User_RSA__c, stk.ID);
   			}
   			
   			for(Consignment__c con:  (List<Consignment__c>)trigger.new )
   			{  	
   				if(!pceVsStockAndMngr.isEmpty() && pceVsStockAndMngr.keyset().contains(con.ProductCatalogEntryRef__c))
   					if(pceVsStockAndMngr.get(con.ProductCatalogEntryRef__c).get(Managers.get(con.UserRef__c))!=null)			
   						con.GlobalStockRef__c=pceVsStockAndMngr.get(con.ProductCatalogEntryRef__c).get(Managers.get(con.UserRef__c));
   			}
   		}
    }
}