@isTest
public class Test_REST_SendLogicalEntityOrderEast{
        
        public static testMethod void TestSendOrders() {
     
        test.StartTest();
        
        Test_REST_DataFactoryEast.TestData();
        
        test.stopTest();
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        
        Order__c ppoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'),shouldCopy_RSA__c=false);
            
        Order__c ffoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', PreliminaryOrderRef_RSA__c= ppoo.id, shouldCopy_RSA__c=false, RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'));
       
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject();
            rord.action='Insert';
            rord.preliminaryOrderIdDevice=0;
            rord.Order=ppoo;
            params.orders.add(rord);
            
        REST_SendLogicalEntityOrderEast.REST_OrderObject rford = new REST_SendLogicalEntityOrderEast.REST_OrderObject();
            rford.action='Insert';
            rford.preliminaryOrderIdDevice=0;
            rford.Order = ffoo;
            params.orders.add(rford);

        REST_SendLogicalEntityOrderEast.REST_OrderObject rordu = new REST_SendLogicalEntityOrderEast.REST_OrderObject();
            rordu.action='Update'; 
            rordu.preliminaryOrderIdDevice=0; 
            rordu.LastModifiedDate=system.now(); 
            rordu.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, Signed_RSA__c, shouldCopy_RSA__c FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.poList.get(19).id ];
            params.orders.add(rordu);
        
        REST_SendLogicalEntityOrderEast.REST_OrderObject rfordu = new REST_SendLogicalEntityOrderEast.REST_OrderObject();     
            rfordu.action='Update'; 
            rfordu.preliminaryOrderIdDevice=0; 
            rfordu.LastModifiedDate=system.now(); 
            rfordu.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, shouldCopy_RSA__c, EarlyPayment_RSA__c, 
                           EarlyDelivery_RSA__c, Signed_RSA__c, PreliminaryOrderRef_RSA__c
                           FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.foList.get(18).id  ];
            params.orders.add(rfordu);      
      
        REST_SendLogicalEntityOrderEast.REST_OrderObject rordud = new REST_SendLogicalEntityOrderEast.REST_OrderObject();     
            rordud.action='Delete'; 
            rordud.preliminaryOrderIdDevice=0; 
            rordud.LastModifiedDate=system.now(); 
            rordud.order= [SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, Signed_RSA__c,shouldCopy_RSA__c
                          FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.poList.get(17).id ];
        params.orders.add(rordud);
        
        REST_SendLogicalEntityOrderEast.REST_OrderObject rfordud = new REST_SendLogicalEntityOrderEast.REST_OrderObject();     
            rfordud.action='Delete'; 
            rfordud.preliminaryOrderIdDevice=0; 
            rfordud.LastModifiedDate=system.now(); 
            rfordud.order=[SELECT Id, LastModifiedDate,AccountRef_RSA__c, Status_RSA__c, RecordTypeID, shouldCopy_RSA__c, EarlyPayment_RSA__c, 
                           EarlyDelivery_RSA__c, Signed_RSA__c, PreliminaryOrderRef_RSA__c
                           FROM Order__c WHERE ID=:Test_REST_DataFactoryEast.foList.get(16).id  ];
        params.orders.add(rfordud);       
      
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
              CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),
                                                              Forecast__c=100, Ownerid=Util.currentUser.ID, Agreed__c=200,
                                                              ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id,
                                                              PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id,
                                                              CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged',
                                                              PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id,
                                                              PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                                                              FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);                        
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
              rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);            
    
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcliu = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject();     
            rcliu.action='Update'; 
            rcliu.preliminaryOrderIdDevice=0; 
            rcliu.FinalOrderIdDevice=0;    
            rcliu.LastModifiedDate=system.now(); 
            rcliu.CampaignLineItem=[SELECT LastModifiedDate,Id,RecordTypeId, Forecast__c, Ownerid, Agreed__c, ProductCatalogEntryRef__c,
                                    PoG__c, FarmRef__c, CampaignRef__c, Type__c,  PlantingDensity__c, ProductRef__c,PreliminaryOrderRef_RSA__c,
                                    FinalOrderRef_RSA__c, PoS__c, DistributorRef__c 
                                    FROM CampaignLineItem__c WHERE Id=:Test_REST_DataFactoryEast.tList.get(1).id];
                                    
        params.campaignLineItems.add(rcliu);            
            
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rclid = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject();     
            rclid.action='Delete';       
            rclid.preliminaryOrderIdDevice=0; 
            rclid.FinalOrderIdDevice=0;    
            rclid.LastModifiedDate=system.now(); 
            rclid.CampaignLineItem=[SELECT LastModifiedDate,Id,RecordTypeId, Forecast__c, Ownerid, Agreed__c, ProductCatalogEntryRef__c,
                                    PoG__c, FarmRef__c, CampaignRef__c, Type__c,  PlantingDensity__c, ProductRef__c,PreliminaryOrderRef_RSA__c,
                                    FinalOrderRef_RSA__c, PoS__c, DistributorRef__c 
                                    FROM CampaignLineItem__c WHERE Id=:Test_REST_DataFactoryEast.tList.get(2).id];
        params.campaignLineItems.add(rclid);     
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);      

        //for(REST_SendLogicalEntityOrderEast.REST_OrderObject clio : outOrder.orders){
          //System.assertEquals(100,clio.statusCode);}        
        //for(REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          //System.assertEquals(100,clio.statusCode);}                  
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
    
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>();
        
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
        rord.action='Delete';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
        rcli.action='Delete';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);
        
        delete CLITest;
        delete OrdTest;

        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);      
        System.assertEquals(201,outOrder.statusCode);    
        for(REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(201,clio.statusCode);}
        for(REST_SendLogicalEntityOrderEast.REST_OrderObject clio : outOrder.orders){
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
    
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>();
        
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
        rord.action='Update';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
        rcli.action='Update';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);
        
        update CLITest;
        update OrdTest;

        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);      
        System.assertEquals(200,outOrder.statusCode);    
        for(REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(200,clio.statusCode);}
        for(REST_SendLogicalEntityOrderEast.REST_OrderObject clio : outOrder.orders){
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
    
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>();
        
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
        rord.action='Insert';    
        rord.preliminaryOrderIdDevice=0; 
        rord.Order = Ordtest;                         
        params.orders.add(rord);

        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
        rcli.action='Insert';    
        rcli.preliminaryOrderIdDevice=0; 
        rcli.FinalOrderIdDevice=0;      
        rcli.CampaignLineItem=CLITest;              
        params.campaignLineItems.add(rcli);

        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);      
        System.assertEquals(999,outOrder.statusCode);    
        for(REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject clio : outOrder.campaignLineItems){
          System.assertEquals(998,clio.statusCode);}
        for(REST_SendLogicalEntityOrderEast.REST_OrderObject clio : outOrder.orders){
          System.assertEquals(999,clio.statusCode);}
        test.stoptest();                 
  }

        public static testMethod void TestValidationRule() {
        
        Test_REST_DataFactoryEast.TestData();

        test.StartTest();

        User currentuser = [SELECT Id, Alias FROM User where Id=:userinfo.getuserId()];
        currentuser.alias='test';
        update currentuser;
        
        
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        
        Order__c ppoo = new order__c(AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'),shouldCopy_RSA__c=false);
       
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
            rord.action='Insert';    
            rord.preliminaryOrderIdDevice=0; 
            rord.Order=ppoo;                          
            params.orders.add(rord);         
      
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
              CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'), Forecast__c=100, Ownerid=currentuser.ID, Agreed__c=200, ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id, PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id, CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', PlantingDensity__c= '200', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id, PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id, FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
            rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);
        test.stopTest();

    }

        public static testMethod void TestFINALorderfailed() {
        
        Test_REST_DataFactoryEast.TestData();

        test.StartTest();

        User currentuser = [SELECT Id, Name, Alias FROM User where Id=:userinfo.getuserId()];
        currentuser.alias='test';
        update currentuser;        
        
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();

        Order__c ffoo = new order__c( Name='Test Order', AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', shouldCopy_RSA__c=false, RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'), PreliminaryOrderRef_RSA__c='a055700000oVNxx');  

        REST_SendLogicalEntityOrderEast.REST_OrderObject rford = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
            rford.action='Insert';    
            rford.preliminaryOrderIdDevice=0; 
            rford.Order = ffoo;                         
            params.orders.add(rford);

        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
          CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'), Forecast__c=100, Ownerid=currentuser.ID, Agreed__c=200, ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id, PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id, CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id, PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id, FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
            rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);
        test.stopTest();

    }

        public static testMethod void TestPRELIMorderfailed() {
        
        Test_REST_DataFactoryEast.TestData();

        test.StartTest();

        User currentuser = [SELECT Id, Name, Alias FROM User where Id=:userinfo.getuserId()];
        currentuser.alias='test';
        update currentuser;        
        
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();

        Order__c pfoo = new order__c( Name='Test Order 2', AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', shouldCopy_RSA__c=false, RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'), PreliminaryOrderRef_RSA__c='a055700000oVNxx', Ownerid='00557000435UUr6');  

        REST_SendLogicalEntityOrderEast.REST_OrderObject prford = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
            prford.action='Insert';    
            prford.preliminaryOrderIdDevice=0; 
            prford.Order = pfoo;
            params.orders.add(prford); 

        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
          CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'), Forecast__c=100, Ownerid=currentuser.ID, Agreed__c=200, ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id, PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id, CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged', PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id, PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id, FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
            rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);
        test.stopTest();
    }

        public static testMethod void TestCLIfailed() {
        
        Test_REST_DataFactoryEast.TestData();

        test.StartTest();

        User currentuser = [SELECT Id, Alias FROM User where Id=:userinfo.getuserId()];
        currentuser.alias='test';
        update currentuser;
        
        
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        
        Order__c ppoo = new order__c(AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'),shouldCopy_RSA__c=false);
       
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject(); 
            rord.action='Insert';    
            rord.preliminaryOrderIdDevice=0; 
            rord.Order=ppoo;                          
            params.orders.add(rord);         
      
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
        CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Seas'), Forecast__c=100, Ownerid='00557000435UUr6', Agreed__c=200, ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id, PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id, Type__c= 'Charged', PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id, PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id, FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
            rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);
        test.stopTest();
    }

        public static testMethod void TestSendOrdersSigned() {
     
        test.StartTest();

        String Signature = '/9j/4AAQSkZJRgABAQAASABIAAD/4QBYRXhpZgAATU0AKgAAAAgAAgESAAMAAAABAAEAAIdpAAQAAAABAAAAJgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAABV6ADAAQAAAABAAAAdgAAAAD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/8AAEQgAdgFXAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/bAEMAHBwcHBwcMBwcMEQwMDBEXERERERcdFxcXFxcdIx0dHR0dHSMjIyMjIyMjKioqKioqMTExMTE3Nzc3Nzc3Nzc3P/bAEMBIiQkODQ4YDQ0YOacgJzm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubm5v/dAAQAFv/aAAwDAQACEQMRAD8A6SiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigD/0OkooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA/9HpKKKKACiiigAooooAKKKKACiiigAooooAKKKKACio5ZY4EMkrBVHc08EMAw5B5oAWiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//0ukooooAKKKKACiiigAooooAKKKKACiiigAqpdXsFov7w5Y9FHU1Wu71/M+yWY3THqey/Wn21hDa5mlO+TqXagDIuINSu5Enli3JnIjzjA96sNqd8sotlgUSdgDnH5VPJeT3jmDT+g+9Ieg+lXbSyitFO35nP3mPU0AW13bRu4OOfrS0UUAFFFFABRRRQAUUUUAFFFIzKilnIAHUmgBaKrC9tD0lT8xSNe2ajJlT86ALVFZEus2q/LCDK3YAVpQPJJEryrsYjlfSgCWiiigAooooAKKKKACiiigAooooAKKKKACiiigD/9PpKKKKACiiigAooooAKKKKACiig5xxQAVHMjyRMiNsYjAPpWRLNqlov2iYxsgPKjjj2NINQuL8+XYJt/vO3agCYGz0mLBO52692Y1GILvUTvu8xQ9ox1P1q1bafFA3myEySnqzf0q+SFBY9uaAGxxpEgjjAVR0AqKe6httvmnG84FZ7ar5g22kTu56ZGBSJpfngy6gxeRvQ4C/SgDZqvNdW8AzLIo9s8/lVH+x7fu8h/4FU0Wl2UR3CPJ9W5oAqtqV1MC1lAWQfxN3+gpw1YY5glz6YrY6cCigDI+2ahNxb2233c4o+z6rNzLOsfsgrXooAyPsWpf8/f8A47SGy1I/8vf6VsUUAZAttVA2/aV+u3mj+y3l/wCPud5B6DgVr1HLLHChklIVR3NAFX+zbED/AFS8VkyLbzSG302FWYfekIyq1YLXGqnamYrbue7VrwwxW8YjiXaooAqWenQ2g3fekPVj/StCiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//U6SiiigAooooAKKKKACiiigAqpdm8CgWYUknkt2q3RQBkx6ZvYS37mZvT+EVqKioMIAB7U6igAooooAKKKKACiiigAooooAKKKKACijpyayJr6W4c22nDc38T/wAK0AWru+itflPzyHog6mqkdlNduLjUTwPuxjoPrVm0sI7b94x3ynq56/hV+gBAABgcAUtFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/V6SiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAqKaaKBDJKwVRUN3eRWabn5Y/dUdTVCGzmvJBdah0/hj7D60AN/wBJ1U94rb/x5q14YYrdBHEoVRUvTgUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAH/1ukooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAqnf3X2O3MwG45wPqauVj65/x5f8CFAC2Fpvxf3J8yRxkeij2rXqrY/wDHnF/uCrVABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAf/9k=';
        
        Test_REST_DataFactoryEast.TestData();
        
        test.stopTest();
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder params = new REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder();
        params.statuscode=null;
        params.statusDescription='';
        params.Orders = new list<REST_SendLogicalEntityOrderEast.REST_OrderObject>();
        
        Order__c ppoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'),shouldCopy_RSA__c=false, Signed_RSA__c=true);
            
        Order__c ffoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', PreliminaryOrderRef_RSA__c= ppoo.id, shouldCopy_RSA__c=false, RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'), Signed_RSA__c=true);
       
        REST_SendLogicalEntityOrderEast.REST_OrderObject rord = new REST_SendLogicalEntityOrderEast.REST_OrderObject();
            rord.action='Insert';
            rord.preliminaryOrderIdDevice=0;
            rord.Order=ppoo;
            rord.signature = Signature;
            params.orders.add(rord);
            
        REST_SendLogicalEntityOrderEast.REST_OrderObject rford = new REST_SendLogicalEntityOrderEast.REST_OrderObject();
            rford.action='Insert';
            rford.preliminaryOrderIdDevice=0;
            rford.Order = ffoo;
            params.orders.add(rford);      
      
        params.campaignLineItems = new list<REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject>(); 
        
              CampaignLineItem__c clites = new CampaignLineItem__c( RecordTypeId=Util.recordType.get('CampaignLineItem__c:Trial'),
                                                              Forecast__c=100, Ownerid=Util.currentUser.ID, Agreed__c=200,
                                                              ProductCatalogEntryRef__c=Test_REST_DataFactoryEast.pceList.get(0).id,
                                                              PoG__c=300, FarmRef__c= Test_REST_DataFactoryEast.aList.get(0).id,
                                                              CampaignRef__c= Test_REST_DataFactoryEast.ca.id, Type__c= 'Charged',
                                                              PlantingDensity__c= '20000', ProductRef__c= Test_REST_DataFactoryEast.pList.get(0).id,
                                                              PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                                                              FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id);                        
             
        REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject rcli = new REST_SendLogicalEntityOrderEast.REST_CampaignLineItemObject(); 
            rcli.action='Insert';    
            rcli.preliminaryOrderIdDevice=0; 
            rcli.FinalOrderIdDevice=0;      
              rcli.CampaignLineItem= clites;
        params.campaignLineItems.add(rcli);                 
         
        REST_SendLogicalEntityOrderEast.REST_SendLogicalEntityOrder outOrder = REST_SendLogicalEntityOrderEast.sendOrders(params);               
    }
}