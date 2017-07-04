/*
	Assigns ConsignmentWareHouse record if exists, if not, creates a new one
*/
public with sharing class TriggerConsignmentAssignWarehouse implements Triggers.Handler {

public void handle()
	{
		Map<String, Id> PKVsHybrid= new Map<String,Id>();
		List<Consignment__c> consignmentToCheck = new List<Consignment__c>();
		List<Consignment__c> consignmentToCheck2 = new List<Consignment__c>();
		Map <String, consignmentWarehouse__c> warehouseToInsert= new Map<String, consignmentWarehouse__c>();
		Set<String> newPkToInsert = new Set<String>();
		
		Set<String> HybridPks = new Set<String> ();
		
		for (Consignment__c con : (List<Consignment__c>)trigger.new)
		{
			if(con.WarehouseRef__c==null && con.HybridName__c!=null && con.UserRef__c!=null && con.ProductCatalogId__c!=null )
      		{
      		
				HybridPks.add(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c);
				consignmentToCheck.add(con);		
			}			
		}
				
		for (consignmentWarehouse__c cw : [SELECT ID, PK__c FROM consignmentWarehouse__c WHERE PK__c in: HybridPks])
		{
			PKVsHybrid.put(cw.PK__c,cw.ID);
		}	
		
		for(Consignment__c con : consignmentToCheck )
		{
			if(con.WarehouseRef__c==null && con.HybridName__c!=null && con.UserRef__c!=null && con.ProductCatalogId__c!=null )			
			{
				if(PKVsHybrid.get(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c)!=null)
					con.WarehouseRef__c=PKVsHybrid.get(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c);
				else if(!newPkToInsert.contains(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c))
				{  
					consignmentWarehouse__c temp = new consignmentWarehouse__c(Name=con.HybridName__c, UserRef__c=con.UserRef__c, ProductCatalogRef__c=con.ProductCatalogId__c);
					warehouseToInsert.put(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c,temp);
					consignmentToCheck2.add(con);
					newPkToInsert.add(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c);
				}
			}
		}
		
		insert warehouseToInsert.values(); 		
		
		for(Consignment__c con : consignmentToCheck2)  
		{
			if(con.WarehouseRef__c==null && con.HybridName__c!=null && con.UserRef__c!=null && con.ProductCatalogId__c!=null )			
			{
				if(warehouseToInsert.get(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c).Id!=null)
					con.WarehouseRef__c=warehouseToInsert.get(con.HybridName__c+'-'+con.UserRef__c+'-'+con.ProductCatalogId__c).ID;
			}
		}
		 
	}


}