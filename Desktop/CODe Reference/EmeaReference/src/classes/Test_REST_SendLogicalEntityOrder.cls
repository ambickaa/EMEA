@isTest
private class Test_REST_SendLogicalEntityOrder {

    public static testMethod void TestSendOrders() {
     
        Test_REST_DataFactoryEast.TestData();
        test.StartTest();
        REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_OrderObject>();
        
            Order__c ppoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'),shouldCopy_RSA__c=false);
            
            Order__c ffoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed',
                                          PreliminaryOrderRef_RSA__c= ppoo.id, shouldCopy_RSA__c=false,
                                          RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'));            
       
        REST_OrderObject rord = new REST_OrderObject(); 
            rord.action='Insert';    
            rord.preliminaryOrderIdDevice=0; 
            rord.Order=ppoo;                          
            params.orders.add(rord);
            
        REST_OrderObject rford = new REST_OrderObject(); 
            rford.action='Insert';    
            rford.preliminaryOrderIdDevice=0; 
            rford.Order = ffoo;                         
            params.orders.add(rford);          

        REST_OrderObject rordu = new REST_OrderObject();     
            rordu.action='Update'; 
            rordu.preliminaryOrderIdDevice=0; 
            rordu.LastModifiedDate=system.now(); 
            rordu.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, Signed_RSA__c, shouldCopy_RSA__c
                          FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.poList.get(19).id ];
            params.orders.add(rordu);
        
        REST_OrderObject rfordu = new REST_OrderObject();     
            rfordu.action='Update'; 
            rfordu.preliminaryOrderIdDevice=0; 
            rfordu.LastModifiedDate=system.now(); 
            rfordu.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, shouldCopy_RSA__c, EarlyPayment_RSA__c, 
                           EarlyDelivery_RSA__c, Signed_RSA__c, PreliminaryOrderRef_RSA__c
                           FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.foList.get(18).id  ];
            params.orders.add(rfordu);      
      
        REST_OrderObject rordud = new REST_OrderObject();     
            rordud.action='Delete'; 
            rordud.preliminaryOrderIdDevice=0; 
            rordud.LastModifiedDate=system.now(); 
            rordud.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, Signed_RSA__c,shouldCopy_RSA__c
                          FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.poList.get(17).id ];
        params.orders.add(rordud);
        
        REST_OrderObject rfordud = new REST_OrderObject();     
            rfordud.action='Delete'; 
            rfordud.preliminaryOrderIdDevice=0; 
            rfordud.LastModifiedDate=system.now(); 
            rfordud.order=[SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, shouldCopy_RSA__c, EarlyPayment_RSA__c, 
                           EarlyDelivery_RSA__c, Signed_RSA__c, PreliminaryOrderRef_RSA__c
                           FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.foList.get(16).id  ];
        params.orders.add(rfordud);       
      
        params.campaignLineItems = new list<REST_CampaignLineItemObject>(); 
        
              CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),
                                                              Forecast__c=100, Ownerid=Util.currentUser.ID, Agreed__c=200,
                                                              ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id,
                                                              PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id,
                                                              CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged',
                                                              PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id,
                                                              PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                                                              FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);                        
             
        REST_CampaignLineItemObject rcli = new REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
              rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);            
    
        REST_CampaignLineItemObject rcliu = new REST_CampaignLineItemObject();     
            rcliu.action='Update'; 
            rcliu.preliminaryOrderIdDevice=0; 
            rcliu.FinalOrderIdDevice=0;    
            rcliu.LastModifiedDate=system.now(); 
            rcliu.CampaignLineItem=[SELECT LastModifiedDate,Id,RecordTypeId, Forecast__c, Ownerid, Agreed__c, ProductCatalogEntryRef__c,
                                    PoG__c, FarmRef__c, CampaignRef__c, Type__c,  PlantingDensity__c, ProductRef__c,PreliminaryOrderRef_RSA__c,
                                    FinalOrderRef_RSA__c
                                    FROM CampaignLineItem__c WHERE Id=:Test_REST_DataFactoryEast.tList.get(1).id];
                                    
        params.campaignLineItems.add(rcliu);            
            
        REST_CampaignLineItemObject rclid = new REST_CampaignLineItemObject();     
            rclid.action='Delete';       
            rclid.preliminaryOrderIdDevice=0; 
            rclid.FinalOrderIdDevice=0;    
            rclid.LastModifiedDate=system.now(); 
            rclid.CampaignLineItem=[SELECT LastModifiedDate,Id,RecordTypeId, Forecast__c, Ownerid, Agreed__c, ProductCatalogEntryRef__c,
                                    PoG__c, FarmRef__c, CampaignRef__c, Type__c,  PlantingDensity__c, ProductRef__c,PreliminaryOrderRef_RSA__c,
                                    FinalOrderRef_RSA__c
                                    FROM CampaignLineItem__c WHERE Id=:Test_REST_DataFactoryEast.tList.get(2).id];
        params.campaignLineItems.add(rclid);     
         
        REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderController.sendOrders(params);      

      /*  for(REST_SendLogicalEntityOrderController.REST_OrderObject clio : outOrder.orders)
          System.assertEquals(100,clio.statusCode);}        
        for(REST_SendLogicalEntityOrderController.REST_CampaignLineItemObject clio : outOrder.campaignLineItems)
          System.assertEquals(100,clio.statusCode);}*/
       test.stopTest();
                  
    }

      
     public static testMethod void PrevDel() {
        
        Test_REST_DataFactoryEast.TestData();
                
        test.startTest();
        
        Order__c Ordtest = new Order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.Farm.id, Status_RSA__c='Draft', 
                                         RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));
        insert OrdTest;
        
        CampaignLineItem__c CLITest= new CampaignLineItem__c(RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=100,
                                                             Agreed__c=200, PoG__c=300,FarmRef__c= Test_REST_DataFactoryEast.Farm.id, 
                                                             ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                                                             CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', 
                                                             PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(1).id);                        
        insert CLITest;
    
        REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_OrderObject>();
        params.campaignLineItems = new list<REST_CampaignLineItemObject>();
        
        REST_OrderObject rord = new REST_OrderObject(); 
        rord.action='Delete';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_CampaignLineItemObject rcli = new REST_CampaignLineItemObject(); 
        rcli.action='Delete';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);
        
        delete CLITest;
        delete OrdTest;

        REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderController.sendOrders(params);      
        System.assertEquals(201,outOrder.statusCode);    
        for(REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(201,clio.statusCode);}
        for(REST_OrderObject clio : outOrder.orders){
          System.assertEquals(201,clio.statusCode);}
        test.stoptest();                 
  }
  public static testMethod void MisMatch() {
        
        Test_REST_DataFactoryEast.TestData();
                        
        test.startTest();
    
        Order__c Ordtest = new Order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.Farm.id, Status_RSA__c='Draft', 
                                         RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));
        insert OrdTest;
        CampaignLineItem__c CLITest= new CampaignLineItem__c(RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=100,
                                                             Agreed__c=200, PoG__c=300,FarmRef__c= Test_REST_DataFactoryEast.Farm.id, 
                                                             ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                                                             CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', 
                                                             PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(1).id);                       
        insert CLITest;
    
        REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_OrderObject>();
        params.campaignLineItems = new list<REST_CampaignLineItemObject>();
        
        REST_OrderObject rord = new REST_OrderObject(); 
        rord.action='Update';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_CampaignLineItemObject rcli = new REST_CampaignLineItemObject(); 
        rcli.action='Update';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);
        
        update CLITest;
        update OrdTest;

        REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderController.sendOrders(params);      
        System.assertEquals(200,outOrder.statusCode);    
        for(REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(200,clio.statusCode);}
        for(REST_OrderObject clio : outOrder.orders){
          System.assertEquals(200,clio.statusCode);}
        test.stoptest();                 
  } 
  public static testMethod void DML() {
        
        Test_REST_DataFactoryEast.TestData();
                        
        test.startTest();
    
        Order__c Ordtest = new Order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.Farm.id, Status_RSA__c='Draft', 
                                         RecordTypeID=Util.recordtype.get('Order__c:PreliminaryOrder'));
        insert OrdTest;
        CampaignLineItem__c CLITest= new CampaignLineItem__c(RecordTypeID=Util.recordType.get('CampaignLineItem__c:Sales'), Forecast__c=100,
                                                             Agreed__c=200, PoG__c=300,FarmRef__c= Test_REST_DataFactoryEast.Farm.id, 
                                                             ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(1).id, 
                                                             CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', 
                                                             PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(1).id);                        
        insert CLITest;
    
        REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_OrderObject>();
        params.campaignLineItems = new list<REST_CampaignLineItemObject>();
        
        REST_OrderObject rord = new REST_OrderObject(); 
        rord.action='Insert';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_CampaignLineItemObject rcli = new REST_CampaignLineItemObject(); 
        rcli.action='Insert';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);

        REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderController.sendOrders(params);      
        System.assertEquals(999,outOrder.statusCode);    
        for(REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(998,clio.statusCode);}
        for(REST_OrderObject clio : outOrder.orders){
          System.assertEquals(999,clio.statusCode);}
        test.stoptest();                 
  }                   
}