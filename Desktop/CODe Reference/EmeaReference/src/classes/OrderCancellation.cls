global class OrderCancellation{
    public class cancelOrderException extends Exception {}
    webservice static void cancelOrder (list<Id> ordersId,list<String> cancellationReasons){
        Savepoint sp = Database.setSavepoint();
        try{
            map<Id,String>mapOrders = new map<Id,String>();
            map<Id,String> typeOrders = new map<Id,String> ();
            set<Id> Accounts= new set<Id>();
            for (Integer i=0;i<ordersId.size();i++){
                mapOrders.put(ordersId[i],cancellationReasons[i]);
            }
            list<Order__c> cancelledOrders = [SELECT Id, Status_RSA__c,Cancellation_Reason_RSA__c,AccountRef_RSA__c, type_RSA__c FROM Order__c WHERE Id in :ordersId];
           
           
            /* new final order development don't need it 
            list<Order__C> cancelledTaxOrders = new list<Order__c>();
            list<Order__c> cancelledRegularOrders = new list<Order__c>();
   
            for(Order__c o: cancelledOrders){
                Accounts.add(o.AccountRef_RSA__c);
                if (o.type_RSA__c == 'Tax'){
                    cancelledTaxOrders.add(o);
                }
                if (o.type_RSA__c == 'Regular' ){
                    cancelledRegularOrders.add(o);
                }
            }
            
          
            for(Order__c o: [SELECT ID,Status_RSA__c, AccountRef_RSA__c,type_RSA__c FROM Order__c where AccountRef_RSA__c in: Accounts and ID not in: ordersId ])
            {
                
                if(o.Status_RSA__c!='Cancelled' && o.Status_RSA__c!='Closed' &&
                ((o.Type_RSA__c == 'Tax' && cancelledTaxOrders.size()>0)||(o.Type_RSA__c == 'Regular' && cancelledRegularOrders.size() > 0))){
                   throw new cancelOrderException(' Pending Orders not cancelled or not closed for account');
                }
                
            }*/
            //cancel orders
            for (Order__c o:cancelledOrders){
                o.status_RSA__c = 'Cancelled';
                o.Cancellation_Reason_RSA__c = mapOrders.get(o.id);
            }
            update cancelledOrders;
            
            //Clone CLI
            list<CampaignLineItem__c>currentCLI = [
                SELECT 
                    Account_Status__c,Agreed_And_Visited__c,Agreed_Charged__c,
                    Agreed_FOC__c,Agreed__c,BagSizeConversion_RSA__c,
                    CampaignBudget_RSA__c,CampaignLineItemGroupRef__c,CampaignRef__c,
                    CatalogType_RSA__c,ChargedElement__c,Collaboratore_IT__c,
                    ContactRef__c,CreatedById,CreatedDate,
                    DecisionMaker__c,DistributorRef__c,
                    FarmRef__c,FinalOrderRef_RSA__c,ForecastLow__c,
                    ForecastPlusOne__c,Forecast_Charged__c,Forecast_FOC__c,
                    Forecast__c,FreeOfChargeElement__c,GlobalStock_RSA__c,
                    Id,idDevice__c,InfluencerRef__c,Inventory__c,IsDeleted,
                    LastActivityDate,LastModifiedById,LastModifiedDate,
                    Name,NextPeriodeElement__c,OwnerId,
                    PartnerDealerRef__c,PersonalStock_RSA__c,PlantingDensity__c,
                    POG_Agreed__c,POG_FOC__c,POG__c,PoS__c,
                    PreliminaryOrderRef_RSA__c,PreviousPeriodeElement__c,Price_Copy__c,
                    ProductCatalogEntryRef__c,ProductRef__c,Provider__c,
                    QuantityFOC__c,Quantity__c,RecordTypeId,
                    Status__c,SystemModstamp,TotalPriceGiveAway__c,
                    TotalPrice_RSA__c,TotalPrice__c,Treatment__c,
                    Type__c,Ultrashort_Irrigation_RSA__c,WarrantyAcreages__c,Yield__c
                FROM 
                    CampaignLineItem__c
                WHERE
                    FinalOrderRef_RSA__c in :ordersId];
                    
            list<CampaignLineItem__c>CLI2insert = new list<CampaignLineItem__c>();
            list<CampaignLineItem__c>CLI2update = new list<CampaignLineItem__c>();
            for (CampaignLineItem__c cli: currentCLI){
                CampaignLineItem__c aux = cli.clone();
                //  release final order ref. for new campaign line item
                aux.preliminaryOrderRef_RSA__c = null;
                //  release preliminary order ref. for current campaign line item
                cli.FinalOrderRef_RSA__c = null;
                CLI2insert.add(aux);
                CLI2update.add(cli);
            }

			TriggerCampaignLineItemUpdateStockOnline.fromRest=true;            
            insert CLI2insert;
            update CLI2update;
        }
        catch(Exception e){        	
            Database.rollback(sp);
            throw e;
        }
    }
    
    webservice static void generatePDF(){
        REST_OrderPdfGenerator.generateSignedPdfs();
    }
    

}