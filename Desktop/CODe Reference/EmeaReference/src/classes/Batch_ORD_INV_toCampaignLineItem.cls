//-------------
//Created by Support Team.
//
//This batch fills the CLI fields with the values coming from orders PY and CY and from CY invoices.
//----------------

global  with sharing class Batch_ORD_INV_toCampaignLineItem implements Database.batchable<sObject>,Database.AllowsCallouts{
    
    global String countryQuery;
    global String strCountry;
    global List <String> listUoM;
    global List <String> listDoc;
    global String strDiv;
    global String strCode;
    global String strOwner;
    global Date startCampaign;
    global Date startCampaignPY;
    global Date endCampaign;   
    global Boolean LastItem;
    global Date endCampaignPY; 
    global List <String> productsNotInCatalog;
    public DateTime initialTime = datetime.now();

    global Batch_ORD_INV_toCampaignLineItem (String q, String c, List <String> u, List <String> d, String s, String e, String o, String iniC, String endC, Boolean isLast){
        countryQuery = q;
        strCountry = c;
        listUoM = u;
        listDoc = d;
        strDiv = s;
        strCode = e;
        strOwner = o;
        LastItem = isLast;
        //For corn division consider fiscal year dates 
        if (strDiv == 'CORN'){
            FiscalYearSettings currentFY =[Select StartDate, EndDate from FiscalYearSettings where StartDate <= TODAY AND EndDate >= TODAY];
            startCampaign = currentFY.StartDate;
            endCampaign = currentFY.EndDate;
        }
        //for OSR division consider custom dates
        else{
            startCampaign = Date.parse(iniC);
            endCampaign = Date.parse(endC);
        }
        startCampaignPY = startCampaign.addYears(-1);        
        endCampaignPY = endCampaign.addYears(-1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(countryQuery);
    }
    global void execute(Database.BatchableContext BC,list<Account> scope)
    { 
        system.debug('******Start date: ' + startCampaign + '  & End date: ' + endCampaign); 
        system.debug('******Start date PY: ' + startCampaignPY + '  & End date: ' + endCampaignPY);

        map<Id,Account> accsMap=new map<Id,Account>();
        for(Account acc:scope)
        {
            accsMap.put(acc.Id,acc);
        } 
        
        //This map takes all the orders from CY in order to take all the invoices CY related
        map<string,id> ordersCY=new map<string,id>();
        //This map takes all the orders from PY in order to take all the invoices PY related
        map<string,id> ordersPY=new map<string,id>();

        map<string,string> productSAPcodes=new map<string,string>();
        
        map<Id,map<String,Decimal>> quantOrdersCYPerAccs=new map<Id,map<String,Decimal>>();
        map<Id,map<String,Decimal>> quantOrdersPYPerAccs=new map<Id,map<String,Decimal>>();
        map<Id,map<String,Decimal>> quantInvoicesCYPerAccs=new map<Id,map<String,Decimal>>();
        map<Id,map<String,Decimal>> quantInvoicesPYPerAccs=new map<Id,map<String,Decimal>>();

        map<Id,Id> responsibleSTperAccs=new map<Id,Id>();
       
        //query to recover all CY orders for S&T(div 17) //and Order.GC_Doc_Creation_Date__c = THIS_FISCAL_YEAR 
        //Update July 2016 - filter by account country name instead of sales org code
        for(orderItem item :[SELECT id,order.Id,order.accountid,order.account.LKP_Responsible_ST__c,order.account.LKP_Responsible_ST__r.IsActive,order.ShipTo_Acc_Integration_Key__c,order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c,order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive,order.name,order.GC_Integration_Key__c,
                             PricebookEntry.Product2.ProductSAPCode__c,Quantity, PricebookEntry.Product2.Name, Order.Account.CountryRef__r.Name 
                             FROM OrderItem where Order.Divison_Code__c = '17' and PricebookEntry.Product2.DivisionRef__r.Name =: strDiv 
                             AND Order.GC_Doc_Creation_Date__c >=: startCampaign AND Order.GC_Doc_Creation_Date__c <=: endCampaign
                             AND Order.GC_Document_Type_Descr__c IN: listDoc 
                             //AND Order.Sales_Org_Code__c =: strCode
                             AND Order.Account.CountryRef__r.Name =: strCountry
                             AND GC_Sales_UoM_Text__c IN: listUoM
                             AND GC_Rejection_Reason_Descr__c ='' AND (order.accountid in: scope or order.ShipTo_Acc_Integration_Key__c in: scope)])
                             //AND Order.GC_Document_Type_Descr__c IN: listDoc AND Order.Sales_Org_Code__c =: strCode AND GC_Sales_UoM_Text__c IN: listUoM
                             //AND GC_Rejection_Reason_Descr__c ='' AND (order.accountid in: scope or order.ShipTo_Acc_Integration_Key__c in: scope)])
        {
            productSAPcodes.put(item.PricebookEntry.Product2.ProductSAPCode__c,item.PricebookEntry.Product2.Id);
            ordersCY.put(item.order.GC_Integration_Key__c, item.OrderId); //This map will be used to get the related CY invoices
            
            string SAPcode='ORDCY_' + item.PricebookEntry.Product2.ProductSAPCode__c;

            system.debug('+++Country: ' + item.Order.Account.CountryRef__r.Name);
            system.debug('+++Country2: ' + strCountry);
            
            //Compare accounts in scope with order field Account
            //if account is in scope recover products, quantities and responsibles
            if(accsMap.containsKey(item.order.accountId)) 
            {                  
                map<string,Decimal> ordProdsPerAcc=quantOrdersCYPerAccs.get(item.order.accountid);
                if(ordProdsPerAcc==null) ordProdsPerAcc=new map<string,Decimal>();
                
                if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                {
                    Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                    ordProdsPerAcc.put(SAPcode, oldValue + item.Quantity);
                } else {
                    ordProdsPerAcc.put(SAPcode,item.Quantity);
                }
                quantOrdersCYPerAccs.put(item.order.accountId, ordProdsPerAcc);
                if(item.order.account.LKP_Responsible_ST__c != null && item.order.account.LKP_Responsible_ST__r.IsActive)
                    	responsibleSTperAccs.put(item.order.accountId, item.order.account.LKP_Responsible_ST__c);
                
            }//else if(accsMap.containsKey(item.order.ShipTo_Acc_Integration_Key__c)) //Compare accounts in scope with order field Ship-to

            if(item.order.accountId != item.order.ShipTo_Acc_Integration_Key__c){

                if(accsMap.containsKey(item.order.ShipTo_Acc_Integration_Key__c)) //Compare accounts in scope with order field Ship-to
                {
                    map<String,Decimal> ordProdsPerAcc=quantOrdersCYPerAccs.get(item.order.ShipTo_Acc_Integration_Key__c);
                    if(ordProdsPerAcc==null) ordProdsPerAcc=new map<String,Decimal>();
                    
                    if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                    {
                        Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                        ordProdsPerAcc.put(SAPcode, oldValue + item.Quantity);
                    } else {                    
                        ordProdsPerAcc.put(SAPcode,item.Quantity);
                    }
                    quantOrdersCYPerAccs.put(item.order.ShipTo_Acc_Integration_Key__c, ordProdsPerAcc);
                    if(item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c != null && item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
                    	responsibleSTperAccs.put(item.order.ShipTo_Acc_Integration_Key__c, item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c);
                }
            } 
        }

        //query to recover all PY orders for S&T(div 17) //and Order.GC_Doc_Creation_Date__c = LAST_FISCAL_YEAR
        //Update July 2016 - filter by account country name instead of sales org code
        for(orderItem Item :[SELECT id,order.name,order.account.LKP_Responsible_ST__c,order.account.LKP_Responsible_ST__r.IsActive,GC_Integration_Key__c,order.ShipTo_Acc_Integration_Key__c,order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c,order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive,order.GC_Integration_Key__c,
                             PricebookEntry.Product2.ProductSAPCode__c,PricebookEntry.Product2.Name,Quantity,order.GC_Doc_Creation_Date__c,order.AccountId 
                             FROM OrderItem where Order.Divison_Code__c = '17' AND PricebookEntry.Product2.DivisionRef__r.Name =: strDiv 
                             AND Order.GC_Doc_Creation_Date__c >=: startCampaignPY AND Order.GC_Doc_Creation_Date__c <=: endCampaignPY
                             AND Order.GC_Document_Type_Descr__c IN: listDoc 
                             //AND Order.Sales_Org_Code__c =: strCode
                             AND Order.Account.CountryRef__r.Name =: strCountry
                             AND GC_Sales_UoM_Text__c IN :listUoM
                             AND GC_Rejection_Reason_Descr__c ='' AND (order.accountid in:scope or order.ShipTo_Acc_Integration_Key__c in: scope)])
        {
            productSAPCodes.put(item.PricebookEntry.Product2.ProductSAPCode__c,item.PricebookEntry.Product2.Id);
            ordersPY.put(item.order.GC_Integration_Key__c, item.OrderId); //This map will be used to get the related PY invoices 

             string SAPcode='ORDPY_' + item.PricebookEntry.Product2.ProductSAPCode__c;
            
            //Compare accounts in scope with order field Account
            if(accsMap.containsKey(item.order.accountId)) 
            {
                map<String,Decimal> ordProdsPerAcc=quantOrdersPYPerAccs.get(item.order.accountid);
                if(ordProdsPerAcc==null) ordProdsPerAcc=new map<String,Decimal>();
                
                if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                {
                    Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                    ordProdsPerAcc.put(SAPcode, oldValue + item.Quantity);
                } else {                    
                    ordProdsPerAcc.put(SAPcode,item.Quantity);
                }
                quantOrdersPYPerAccs.put(item.order.accountId, ordProdsPerAcc);
                if(item.order.account.LKP_Responsible_ST__c != null && item.order.account.LKP_Responsible_ST__r.IsActive)
                	responsibleSTperAccs.put(item.order.accountId, item.order.account.LKP_Responsible_ST__c);
            }//else if(accsMap.containsKey(item.order.ShipTo_Acc_Integration_Key__c)) //Compare accounts in scope with order field Ship-to
            
            if(item.order.accountId != item.order.ShipTo_Acc_Integration_Key__c){

                if(accsMap.containsKey(item.order.ShipTo_Acc_Integration_Key__c)) //Compare accounts in scope with order field Ship-to
                {
                    map<String,Decimal> ordProdsPerAcc=quantOrdersPYPerAccs.get(item.order.ShipTo_Acc_Integration_Key__c);
                    if(ordProdsPerAcc==null) ordProdsPerAcc=new map<String,Decimal>();
                    
                    if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                    {
                        Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                        ordProdsPerAcc.put(SAPcode, oldValue + item.Quantity);
                    } else {                    
                        ordProdsPerAcc.put(SAPcode,item.Quantity);
                    }
                    quantOrdersPYPerAccs.put(item.order.ShipTo_Acc_Integration_Key__c, ordProdsPerAcc);
                    if (item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c != null && item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
                    	responsibleSTperAccs.put(item.order.ShipTo_Acc_Integration_Key__c, item.order.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c);
                }
            }
        }                    
        
        //query to recover all CY invoices for S&T(div 17) that have orders CY
        for(Invoice_Line_Item__c item: [SELECT GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c,GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c, GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__r.IsActive,
        								GC_Invoice_Integration_Key__r.GC_Order_Number__c, GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c,
        								GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c, GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive,
        								GC_Item_Code__c,GC_Quantity__c,GC_Item_Descr__c, GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c
                                        FROM Invoice_Line_Item__c 
                                        WHERE GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c >=: startCampaign AND GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c <=: endCampaign
                                        AND GC_Invoice_Integration_Key__r.GC_Order_Number__c IN :ordersCY.keySet()
                                        AND GC_UOM_Line_Item_Descr__c IN :listUoM])
        {
            productSAPCodes.put(item.GC_Item_Code__c,item.GC_Item_Descr__c) ;
            string SAPcode='INV_'+ item.GC_Item_Code__c;
            Decimal negQty;
            
            //Compare accounts in scope with invoice field Account
            if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c)) 
            {                
                map<String,Decimal> ordProdsPerAcc=quantInvoicesCYPerAccs.get(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c);
                if(ordProdsPerAcc==null) ordProdsPerAcc=new  map<String,Decimal> ();
                if(ordProdsPerAcc.containsKey(SAPcode))
                {
                    Decimal oldValue=ordProdsPerAcc.get(SAPcode);

                    if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c == 'Cancellation of Inv'){
                        ordProdsPerAcc.put(SAPcode, oldValue - item.GC_Quantity__c);
                    } else {
                        ordProdsPerAcc.put(SAPcode, oldValue + item.GC_Quantity__c);
                    }
                } else {
                    if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c == 'Cancellation of Inv'){
                        negQty = item.GC_Quantity__c*(-1);
                        ordProdsPerAcc.put(SAPcode,negQty);
                    } else {
                        ordProdsPerAcc.put(SAPcode,item.GC_Quantity__c);
                    }
                }
                quantInvoicesCYPerAccs.put(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c, ordProdsPerAcc);
                if(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c != null && item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
                	responsibleSTperAccs.put(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c, item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c);
            }//else if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c)) //Compare accounts in scope with invoice field Ship-to
            
            if(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c != item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c)
            {
                //Compare accounts in scope with invoice field Ship-to                
                if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c))
                {
                    map<String,Decimal> ordProdsPerAcc=quantInvoicesCYPerAccs.get(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c);
                    if(ordProdsPerAcc==null) ordProdsPerAcc=new  map<String,Decimal> ();
                    
                    if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                    {
                        Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                        ordProdsPerAcc.put(SAPcode, oldValue + item.GC_Quantity__c);
                    } else {                    
                        ordProdsPerAcc.put(SAPcode,item.GC_Quantity__c);
                    }
                    quantInvoicesCYPerAccs.put(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c, ordProdsPerAcc);
                    if(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c != null && item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
                    	responsibleSTperAccs.put(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c, item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c);
                }
            } 
        }

        //query to recover all PY invoices for S&T(div 17) that have orders PY
        for(Invoice_Line_Item__c item: [SELECT GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c,GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c,GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__r.IsActive,
        								GC_Invoice_Integration_Key__r.GC_Order_Number__c, GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c,
        								GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c,GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive,
        								GC_Item_Code__c,GC_Quantity__c,GC_Item_Descr__c, GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c
                                        FROM Invoice_Line_Item__c 
                                        WHERE GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c >=: startCampaignPY AND GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c <=: endCampaignPY
                                        AND GC_Invoice_Integration_Key__r.GC_Order_Number__c IN :ordersPY.keySet()
                                        AND GC_UOM_Line_Item_Descr__c IN :listUoM])
        {
            productSAPCodes.put(item.GC_Item_Code__c,item.GC_Item_Descr__c) ;
            string SAPcode='INVPY_'+ item.GC_Item_Code__c;
            Decimal negQty;
            
            //Compare accounts in scope with invoice field Account
            if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c)) 
            {                
                map<String,Decimal> ordProdsPerAcc=quantInvoicesPYPerAccs.get(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c);
                if(ordProdsPerAcc==null) ordProdsPerAcc=new  map<String,Decimal> ();
                if(ordProdsPerAcc.containsKey(SAPcode))
                {
                    Decimal oldValue=ordProdsPerAcc.get(SAPcode);

                    if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c == 'Cancellation of Inv'){
                        ordProdsPerAcc.put(SAPcode, oldValue - item.GC_Quantity__c);
                    } else {
                        ordProdsPerAcc.put(SAPcode, oldValue + item.GC_Quantity__c);
                    }
                } else {
                    if(item.GC_Invoice_Integration_Key__r.GC_Invoice_Type_Descr__c == 'Cancellation of Inv'){
                        negQty = item.GC_Quantity__c*(-1);
                        ordProdsPerAcc.put(SAPcode,negQty);
                    } else {
                        ordProdsPerAcc.put(SAPcode,item.GC_Quantity__c);
                    }
                }
                quantInvoicesPYPerAccs.put(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c, ordProdsPerAcc);
                if(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c != null && item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
					responsibleSTperAccs.put(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c, item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__r.LKP_Responsible_ST__c);
            }
            
            if(item.GC_Invoice_Integration_Key__r.GC_Account_Integration_Key__c != item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c)
            {
                //Compare accounts in scope with invoice field Ship-to                
                if(accsMap.containsKey(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c))
                {
                    map<String,Decimal> ordProdsPerAcc=quantInvoicesPYPerAccs.get(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c);
                    if(ordProdsPerAcc==null) ordProdsPerAcc=new  map<String,Decimal> ();
                    
                    if(ordProdsPerAcc!=null && ordProdsPerAcc.containsKey(SAPcode))
                    {
                        Decimal oldValue=ordProdsPerAcc.get(SAPcode);
                        ordProdsPerAcc.put(SAPcode, oldValue + item.GC_Quantity__c);
                    } else {                    
                        ordProdsPerAcc.put(SAPcode,item.GC_Quantity__c);
                    }
                    quantInvoicesPYPerAccs.put(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c, ordProdsPerAcc);
                    if(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c != null && item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__r.IsActive)
                    	responsibleSTperAccs.put(item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__c, item.GC_Invoice_Integration_Key__r.ShipTo_Acc_Integration_Key__r.LKP_Responsible_ST__c);
                }
            } 
        }        
             
        //map with existing CLIs on account with record type 'Dist/Ret/PoS'
        map<String,CampaignLineItem__c> CLIsMap=new map<String,CampaignLineItem__c>();
         for (CampaignLineItem__c item :[SELECT id,name,Type__c,FarmRef__c,ProductCatalogEntryRef__r.FRML_ProductCode__c,ProductRef__r.ProductSAPCode__c,NUM_ORDERED_CY_QTY__c,
                                        NUM_INVOICED_CY_QTY__c,NUM_ORDERED_PY_QTY__c,NUM_INVOICED_PY_QTY__c
                                        FROM CampaignLineItem__c
                                        WHERE Type__c = 'Charged'
                                        AND CampaignRef__r.IsActive = true
                                        AND RecordtypeId = :Util.recordType.get('CampaignLineItem__c:Sales')
                                        AND Status__c!='Cancelled'
                                        AND FarmRef__c in: scope])
        {
            CLIsMap.put(item.FarmRef__c +'_'+item.ProductRef__r.ProductSAPCode__c, item);
        }

        //map with all info of related products by SAP code
        map<string,Product2> ProductInfo=new map<string,Product2>();
        for(Product2 item:[select id,Name,ProductSAPCode__c,DivisionRef__c from Product2 where ProductSAPCode__c in: productSAPcodes.keySet()])
        {
            ProductInfo.put(item.ProductSAPCode__c, item);
            system.debug('Product code to be treated: ' + item.ProductSAPCode__c);
        }
        
        //Get default UserID that will be set as CLI owner for new CLIs that may be inserted
        system.debug('++Owner Id for: ' + strCountry + ' is: ' + strOwner);
        id ownerId=strOwner;
        
        //recover active campaigns and catalogs from  all users responsibles and also for default owner
        Set<Id> activeCatalogs = new set<Id>();
        Set<Id> responsibles = new set<Id>();
        map<Id,Id> usersAndCampaigns=new map<Id,Id>();

        for(Id user: responsibleSTperAccs.values()){
                responsibles.add(user);
        }
        responsibles.add(ownerId);
        system.debug('IDs for Responsibles S&T: ' + responsibles);

        //for( campaign camp:[Select id,DivisionRef__c, SalesPCMRef__c from campaign where ownerId=:ownerId and IsActive=True ])
        for(Campaign camp:[SELECT id,DivisionRef__c, SalesPCMRef__c,ownerid
        FROM Campaign
        WHERE ownerId in: responsibles and IsActive = true and DivisionRef__r.name=: strDiv AND RecordTypeId = :Util.recordType.get('Campaign:Sales_camp')])
        {
            activeCatalogs.add(camp.SalesPCMRef__c);
            //usersAndCampaigns.put(camp.DivisionRef__c, camp.id);
            usersAndCampaigns.put(camp.ownerid, camp.id);
        }

        system.debug('Campaigns: ' + usersAndCampaigns.values());
        system.debug('Users and campaigns: ' + usersAndCampaigns); 

        //map with existing PCEs for the involved products by SAP code
        map<string,ProductCatalogEntry__c> ProdCatEntries=new map<string,ProductCatalogEntry__c>();
        for(ProductCatalogEntry__c item:[select id,ProductRef__c,ProductRef__r.ProductSAPCode__c,ProductRef__r.DivisionRef__c from ProductCatalogEntry__c where ProductRef__r.ProductSAPCode__c in: productSAPcodes.keySet() and ProductCatalogRef__c in: activeCatalogs])
        {
            ProdCatEntries.put(item.ProductRef__r.ProductSAPCode__c, item);
        }

        //join all products in one map
        map<Id,map<String,Decimal>> allElementsToUps=new map<Id,map<String,Decimal>>();
        for(account acc:scope) 
        {
            map<String,Decimal> allToUps=new map<String,Decimal>();
            if(quantOrdersCYPerAccs.get(acc.id)!=null) allToUps.putAll(quantOrdersCYPerAccs.get(acc.id)); 
            if(quantOrdersPYPerAccs.get(acc.id)!=null) allToUps.putAll(quantOrdersPYPerAccs.get(acc.id));
            if(quantInvoicesCYPerAccs.get(acc.id)!=null) allToUps.putAll(quantInvoicesCYPerAccs.get(acc.id));
            if(quantInvoicesPYPerAccs.get(acc.id)!=null) allToUps.putAll(quantInvoicesPYPerAccs.get(acc.id));
            
            allElementsToUps.put(acc.id,allToUps);
        }
        
        map<string,list<CampaignLineItem__c>> finalCLIs=new map<string,list<CampaignLineItem__c>>();
        
        //call to method upsertCLIs
        finalCLIs=upsertCLIs(CLIsMap,allElementsToUps,ownerId,Util.recordType.get('CampaignLineItem__c:Sales'),usersAndCampaigns,ProdCatEntries,ProductInfo,responsibleSTperAccs);
        list<CampaignLineItem__c> CLIstoUpd=new list<CampaignLineItem__c>();
        list<CampaignLineItem__c> CLIstoIns=new list<CampaignLineItem__c>();
        CLIstoUpd=finalCLIs.get('UpdateList');
        CLIstoIns=finalCLIs.get('InsertList');
        system.debug('Update size: ' + CLIstoUpd.size());
        system.debug('Insert size: ' + CLIstoIns.size());
        update CLIstoUpd;
        insert CLIstoIns;
        
    }
    global void finish(Database.BatchableContext BC)
    {
        if (LastItem==true){
            SystemSettings__c triggersoff = SystemSettings__c.getInstance('IgnoreTriggers_Cli');
            triggersoff.Value__c = 'false';
            Update triggersoff;
        }

        string BodyText = '';
        if (productsNotInCatalog != null){
            BodyText += '*****************************************************'+'\n'+'*******Product SAP codes not in Sales catalog********'+'\n';
            for(String productSAPcode : productsNotInCatalog){
                BodyText += productSAPcode +'\n';
            }
        }

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.

        // Send email to userEmail indicating if the process did not finish correctly
        if (a.Status == 'Failed' || a.NumberOfErrors>0)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {string.valueof(Util.currentUser.Email)});
            mail.setSenderDisplayName('eCIP 2.0 Dist AP');
            mail.setSubject('Process for Ordered PY/CY and Shipped PY/CY data for ' + strCountry + ' has failed.');
            mail.setPlainTextBody ('The batch Apex job for '+ strCountry + ' processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.' + '\n \r Job Id that failed: ' + a.Id + '\n' + BodyText);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        //Send email to userEmail indicating if the process finished correctly
        } else {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {string.valueof(Util.currentUser.Email)});
            mail.setSenderDisplayName('eCIP 2.0 Dist AP');
            mail.setSubject('Process for Ordered PY/CY and Shipped PY/CY data for ' + strCountry + ' has finished successfully.');
            mail.setPlainTextBody('The batch Apex job for ' + strCountry + '\n \r' + 'The process was initiated on: ' + string.valueof(initialTime) + '\n' +'The process was finished on: ' + string.valueof(datetime.now()) +'\n' + BodyText);       
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }  

    }

    //Input data to method upsertCLIs
    //1. map with CLIs. The key for this map is formed by 'AccountId_ProductSAPCode'
    //2. join 4 created maps (orders PY, orders CY, invoices PY and invoices CY) in one map. The map is formed by (AccountId, (XXX_ProductSAPCode,Quantity))
    //3. Country Lead Id
    //4. Campaign Sales Record Type Id
    //5. All campaigns activate for default user and responsibles
    //6. map with PCE for all products found on orders and invoices. The map is formed by (ProductSAPCode, PCE)
    //7. map with info from products
    public map<string,list<CampaignLineItem__c>> upsertCLIs(map<string,CampaignLineItem__c> incomeCLIs, map<Id,map<String,Decimal>> incomeSumProd, Id ownerId, Id rt, map<id,id> ownerCamps, map<string,ProductCatalogEntry__c> PCEs, map<string,Product2> products, map<Id,Id> AccResponsiblesST )
    {
        map<string,list<CampaignLineItem__c>> mapToReturn=new map<string,list<CampaignLineItem__c>>();
        list<CampaignLineItem__c> clisToUps=new list<CampaignLineItem__c>();
        map<string,CampaignLineItem__c> CLIsToUpdMAP= new map<string,CampaignLineItem__c>();
        map<string,CampaignLineItem__c> CLIsToInsMAP= new map<string,CampaignLineItem__c>();
        String campaignOwner;
        
        //Boolean for controlling updates
        Boolean ToUpdate;
        
        //for each AccountId coming from the joined 4 maps get the product SAP code and quantity
        for(id accId:incomeSumProd.keySet())
        {
            map<String,Decimal> totalByProds= new map<String,Decimal>();
            totalByProds=incomeSumProd.get(accId);
            //total by product is a map with product SAP code as Key and quantities
            for(String prodSAPcode:totalByProds.keySet())
            {
                String mapKey=accId+ '_'+ prodSAPcode.substringAfter('_');
                
                ToUpdate = false;

                //check if the CLI already exist and we can update it
                if(incomeCLIs.containsKey(mapKey))
                {
                    CampaignLineItem__c incomCLI;
                    if(!CLIsToUpdMAP.containsKey(mapKey)) incomCLI=incomeCLIs.get(mapKey);
                    else incomCLI=CLIsToUpdMAP.get(mapKey);
                    if(prodSAPcode.substringBefore('_')=='ORDCY' && incomCLI.NUM_ORDERED_CY_QTY__c!= totalByProds.get(prodSAPcode))
                    {
                        incomCLI.NUM_ORDERED_CY_QTY__c= totalByProds.get(prodSAPcode);
						ToUpdate = true;
                    }
                    if(prodSAPcode.substringBefore('_')=='ORDPY' && incomCLI.NUM_ORDERED_PY_QTY__c!= totalByProds.get(prodSAPcode))
                    {
                        incomCLI.NUM_ORDERED_PY_QTY__c= totalByProds.get(prodSAPcode);
						ToUpdate = true;
                    }
                    if(prodSAPcode.substringBefore('_')=='INV' && incomCLI.NUM_INVOICED_CY_QTY__c!= totalByProds.get(prodSAPcode))
                    {
                        incomCLI.NUM_INVOICED_CY_QTY__c= totalByProds.get(prodSAPcode);
						ToUpdate = true;
                    }
                    if(prodSAPcode.substringBefore('_')=='INVPY' && incomCLI.NUM_INVOICED_PY_QTY__c!= totalByProds.get(prodSAPcode))
                    {
                        incomCLI.NUM_INVOICED_PY_QTY__c= totalByProds.get(prodSAPcode);
                        ToUpdate = true;
                    }
					if(ToUpdate)
                    	CLIsToUpdMAP.put(mapKey,incomCLI);                  
                    
                } else {//if the CLIs does not exist it must be created
                    if(PCEs.get(prodSAPcode.substringAfter('_'))!=null)
                    {
                        CampaignLineItem__c newCLI=new CampaignLineItem__c();
                        if(CLIsToInsMAP.containsKey(mapKey)) newCLI=CLIsToInsMAP.get(mapKey);
                        else
                        {
                            newCLI.FarmRef__c=accId;
                            newCLI.Type__c='Charged';
                            newCLI.RecordTypeId=rt;
                            
                            if(AccResponsiblesST.containsKey(accId) && AccResponsiblesST.get(accId) != null) campaignOwner = AccResponsiblesST.get(accId);
                            else campaignOwner=ownerId;                            

                            //if the product has no PCE for CY we must creat the CLI without PCE                  
                            if(PCEs.containsKey(prodSAPcode.substringAfter('_'))){
                                ProductCatalogEntry__c PCERef=PCEs.get(prodSAPcode.substringAfter('_'));  
                                newCLI.ProductCatalogEntryRef__c=PCERef.ID;
                                system.debug('PCE: ' + PCERef.ID);
                                system.debug('Product Division with PCE: ' + PCERef.ProductRef__r.DivisionRef__c);
                                newCLI.CampaignRef__c=ownerCamps.get(campaignOwner);
                                newCLI.ProductRef__c=PCERef.ProductRef__c;
                            } else {
                                Product2 prodRef=products.get(prodSAPcode.substringAfter('_'));
                                productsNotInCatalog.add(prodSAPcode.substringAfter('_'));
                                system.debug('Product: ' + products.get(prodSAPcode.substringAfter('_')));
                                system.debug('Product Division w/o PCE: ' + prodRef.DivisionRef__c);
                                newCLI.CampaignRef__c=ownerCamps.get(prodRef.DivisionRef__c);
                                newCLI.ProductRef__c=prodRef.Id;
                            }
                            newCLI.OwnerId=campaignOwner;
                        }
                        if(prodSAPcode.substringBefore('_')=='ORDCY')
                        {
                            newCLI.NUM_ORDERED_CY_QTY__c= totalByProds.get(prodSAPcode);                                                                      
                        }
                        if(prodSAPcode.substringBefore('_')=='ORDPY' )
                        {
                            newCLI.NUM_ORDERED_PY_QTY__c= totalByProds.get(prodSAPcode);
                        }
                        if(prodSAPcode.substringBefore('_')=='INV' )
                        {
                            newCLI.NUM_INVOICED_CY_QTY__c= totalByProds.get(prodSAPcode);                        
                        }
                        if(prodSAPcode.substringBefore('_')=='INVPY' )
                        {
                            newCLI.NUM_INVOICED_PY_QTY__c= totalByProds.get(prodSAPcode);                        
                        }
                        if(newCli.CampaignRef__c != null)
                        	CLIsToInsMAP.put(mapKey, newCLI);
                    }
                }                
            }            
        }

        List <CampaignLineItem__c> CLIsToUpd= new List <CampaignLineItem__c>();
        CLIsToUpd=CLIsToUpdMAP.values();

        mapToReturn.put('UpdateList',CLIsToUpd);
        system.debug('CLIs to update: ' + CLIsToUpd);
        
        list<CampaignLineItem__c> CLIsToIns= new list<CampaignLineItem__c>();
        CLIsToIns=CLIsToInsMAP.values();
        mapToReturn.put('InsertList',CLIsToIns);
        system.debug('CLIs to insert: ' + CLIsToIns);

        return mapToReturn;
    }
}