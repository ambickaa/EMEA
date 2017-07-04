@isTest
public class Test_VFC_Delivery {
    public static testMethod void testmethod1(){
        Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
           insert toCountry;
            
        //Account Creation
            Account acc1=new Account(Name='Test1',CountryRef__c=toCountry.ID);
            Database.insert (acc1);
            //Case Creation 
            Delivery__c dlv=new Delivery__c(Name='testtest',GC_Account_Integration_Key__c=acc1.Id,GC_Delivery_Number_Text__c='test1',GC_Integration_Key__c='12346',GC_Order_Number__c='143678');
            insert dlv;
            Case c1=new Case(AccountId=acc1.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium');
            insert c1;
        system.debug('+++caseID' + c1.id);
        
         //Invoice Creation
            Invoice__c inv=new Invoice__c(Name='testttttt',/*Divison_Code__c= '15',*/ GC_Integration_Key__c=c1.AccountId,GC_Account_Integration_Key__c=acc1.Id,GC_Order_Number__c='21345',GC_Invoice_Status_descr__c='testingapp',GC_Total_Inv_Amount_Nbr__c=120.012,GC_Invoice_Creation_Date__c=system.today());
            insert inv;
            //Invoice Lineitem Creation
            
            Invoice_Line_Item__c inlintem=new Invoice_Line_Item__c(Name='test',GC_Integration_Key__c='KEY0001',GC_Invoice_Integration_Key__c=inv.Id,GC_Quantity__c=2.0,GC_Net_Value_Amount__c=123.02,GC_UOM_Line_Item_Descr__c='tes');
            insert inlintem;
           
       
        PageReference pageRef = Page.vfpdelivery_new;
        pageRef.getParameters().put('id',c1.id);
        Test.setCurrentPageReference(pageRef);
        apexpages.StandardController apx = new apexPages.StandardController(c1);
        
        VFC_Delivery vfc=  new VFC_Delivery(apx);
        VFC.casId=c1.id;
         vfc.srchStrinv=inv.name;//bhaskar
        vfc.removepos=1;
        vfc.cs=c1;
        vfc.srchStrDel='test1';
        //vfc.srchStrInv='test2';
        vfc.casenum=c1.CaseNumber;
        vfc.srchStr='test4';
        vfc.conid='';
        vfc.casId=c1.id;
        vfc.accntnum=acc1.AccountNumber;
        
        
            //Delivery Lineitem Creation 
            Delivery_Line_Item__c dlitem=new Delivery_Line_Item__c();
            dlitem.name='TestDelivry';
            dlitem.GC_Plant_Desc__c='Test1';
            dlitem.GC_Dlvry_Integration_Key__c=dlv.Id;
            dlitem.GC_Integration_Key__c=dlv.Id;
            
            insert dlitem;
            vfc.deliveryWrapperListsearch= new List<wrapdelivery>();
            vfc.search();
             // vfc.srchStrDel=dlv.name;//bhaskar
             // vfc.getdelivery();
            //vfc.getdeliveryselection();
            VFC_Delivery.DelItemList = new List<DeliveryLineItemWrapper>();
        
            vfc.deliveryWrapperList=new List<wrapdelivery>(); 
            for(wrapDelivery w : vfc.deliveryWrapperList){
                w.isSelected = True; 
                if(!w.DelItemList.isEmpty()){
             
                    for(DeliveryLineItemWrapper t : w.DelItemList){
                        t.Flg = true;
                    }
                }
          
             }
             
            DeliveryLineItemWrapper dliw=new DeliveryLineItemWrapper(dlitem);
            dliw.flg=true;
            
            List<DeliveryLineItemWrapper> DelItemList=new List<DeliveryLineItemWrapper>();
            DelItemList.add(dliw);
            wrapDelivery wd=new wrapDelivery(dlv,DelItemList);
            wd.isSelected=true;
            vfc.deliveryWrapperListsearch=new  List<wrapDelivery>();
            vfc.deliveryWrapperListsearch.add(wd);
            vfc.selecteddeliverylineitem();
        
        
        wrapDelivery wd1=new wrapDelivery(dlv,DelItemList);
            wd1.isSelected=false;
            vfc.deliveryWrapperListsearch=new  List<wrapDelivery>();
            vfc.deliveryWrapperListsearch.add(wd1);
            vfc.selecteddeliverylineitem();
            
            
            //order product creation 
          
            
            Id pricebookId = Test.getStandardPricebookId();                         
            Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
            insert prd1;
            PricebookEntry pe=new PricebookEntry(UnitPrice = 1,Product2Id=prd1.id,Pricebook2Id=pricebookId,isActive=true);
            insert pe;
            //Order Creation 
            Order or1=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='1213232',EffectiveDate=system.today(),Status='Draft',PoNumber='516487',GC_Document_Type_Descr__c='testingthe',GC_Ship_To_Party_Text__c='tex',GC_Ship_To_Party_Descr__c='dscrt');
            insert or1;
            Order or2=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='14213232',EffectiveDate=system.today(),Status='Draft',PoNumber='516489',GC_Document_Type_Descr__c='testingapp',GC_Ship_To_Party_Text__c='te1',GC_Ship_To_Party_Descr__c='dsrt');
            insert or2;
            Order or3=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='14213212',EffectiveDate=system.today(),Status='Draft',PoNumber='511489',GC_Document_Type_Descr__c='testi1gapp',GC_Ship_To_Party_Text__c='te2',GC_Ship_To_Party_Descr__c='d1srt');
            insert or3;
            OrderItem oi = new OrderItem(OrderId=or1.id,Quantity=1,PricebookEntryId=pe.id, unitPrice=1,GC_Quantity__c=1);
            insert oi;

             
            //Order Selection Creation 
            OrderSelection__c ols=new OrderSelection__c();
            ols.Name='Testinnngordr';
            ols.CaseId_Text__c=c1.id;
            ols.Delivery_Id_Text__c=dlv.id;
            ols.DeliveryItem_Id_Text__c=dlitem.id;
            //ols.InvoiceId_Text__c='';
            ols.InvoiceLineItemId_Text__c='';
            OrderSelection__c ols1=new OrderSelection__c();
            ols1.Name='Testinnngordr';
            ols1.CaseId_Text__c=c1.id;
            ols1.Delivery_Id_Text__c=dlv.id;
            ols1.DeliveryItem_Id_Text__c=dlitem.id;
            //ols1.InvoiceId_Text__c=inv.id;
            ols1.InvoiceLineItemId_Text__c=inlintem.id;
            OrderSelection__c ols2=new OrderSelection__c();
            ols2.Name='Testinnngordr';
            ols2.CaseId_Text__c=c1.id;
            ols2.Delivery_Id_Text__c=dlv.id;
            ols2.DeliveryItem_Id_Text__c=dlitem.id;
            //ols2.InvoiceId_Text__c=inv.id;
            ols2.InvoiceLineItemId_Text__c=inlintem.id;
            OrderSelection__c ols3=new OrderSelection__c();
            List<OrderSelection__c> ocslistn=new List<OrderSelection__c>();
            ocslistn.add(ols);
            ocslistn.add(ols1);
            ocslistn.add(ols2);
            ocslistn.add(ols3);
            insert ocslistn;
            vfc.Ivid=inv.id;
            vfc.dlid=dlitem.id;
            vfc.removeposinv=0;
            vfc.removeposdel=0;
            //Methods 
            vfc.DelIdDelItmListMap = new Map<Id, List<DeliveryLineItemWrapper>>();
            vfc.getdelivery();
            vfc.getdeliveryselection();
            vfc.searchdel();
            
            vfc.selecteddeliverylineitem();
            vfc.deliveryWrapperListsearch=null;
            vfc.selecteddeliverylineitem();
            vfc.deliveryWrapperListsearch= new List<wrapdelivery>();
            vfc.searchdel(); 
            for(wrapDelivery w : vfc.deliveryWrapperListsearch){
                w.isSelected = True; 
             }
            vfc.deliveryWrapperList=new List<wrapdelivery>();
            vfc.selecteddeliverylineitem();
            vfc.invoiceWrapperListSearch = new List<wrapInvoice>();
            vfc.InvIdInvItmListMap= new map<Id, List<InvoiceLineItemWrapper>>();
        //bhaskar
       
           vfc.srchStrinv=inv.name;//bhaskar
           vfc.getInvoices();
           vfc.getinvoiceselection();
           vfc.searchinv();
           vfc.srchStrDel=dlv.name;//bhaskar
           vfc.getdelivery();  
           vfc.getdeliveryselection();
            /* for(wrapInvoice ow1: vfc.invoiceWrapperList){
            ow1.isSelected = true;
            if(!ow1.InvoiceItemList.isEmpty()){
                for(InvoiceLineItemWrapper ot: ow1.InvoiceItemList){
                    ot.flg=true;
            
                }
             
            }
            
           }*/
           vfc.invoiceWrapperListSearch=null;
           vfc.selectedInvoicelineitem();
           vfc.invoiceWrapperListSearch=new List<wrapInvoice>();
           vfc.searchinv();
           vfc.invoiceWrapperList=new List<wrapInvoice>();
           
           vfc.srchStr='1213232';
           InvoiceLineItemWrapper ivliw=new InvoiceLineItemWrapper(inlintem);
           ivliw.flg=true;
           List<InvoiceLineItemWrapper> InvoiceItemList=new List<InvoiceLineItemWrapper>();
           InvoiceItemList.add(ivliw);
           wrapInvoice wiv=new wrapInvoice(inv,InvoiceItemList);
           wiv.isSelected=true;
           wiv.InvoiceItemList.add(ivliw);
           vfc.invoiceWrapperListSearch=new List<wrapInvoice>();
           vfc.invoiceWrapperListSearch.add(wiv);
           
           
           OrderPrdtWrapper opw=new OrderPrdtWrapper(oi);
           opw.flg=true;
           List<OrderPrdtWrapper>opwl=new List<OrderPrdtWrapper>();
           opwl.add(opw);
           OrderWrapper ow=new OrderWrapper(or1,opwl);
           ow.flg1=true;
           ow.OrderItemList.add(opw);
           vfc.orderWrapperListsearch=new List<OrderWrapper>();
           vfc.orderWrapperListsearch.add(ow);
           vfc.selectedorderlineitem();
           vfc.getorders();
           vfc.getorderselection();
           
          // vfc.selectedInvoicelineitem();
           
        
          
           vfc.Attach();
          // system.assertEquals(false,vfc.hasNext_del);
          // system.assertEquals(false,vfc.hasPrevious_del);
            //system.assertEquals(,vfc.hasNext);
            //system.assertEquals(,vfc.hasNext);
           // vfc.next_del();
           //vfc.previous_del();
       // vfc.removecon();
       // vfc.removedel();
       // vfc.removeinv();
       // 
       // 
          vfc.OCSdeliverylist= New list<OrderSelection__c>();
          vfc.OCSdeliverylist.add(ols);
          vfc.dlid=ols.id;
          vfc.removedel();
       // vfc.deleteorderlistdel=new list<OrderSelection__c>();
        
          vfc.OCSInvoicelist=new list<OrderSelection__c>();
          vfc.OCSInvoicelist.add(ols1);
          vfc.removeinv();
          vfc.OCSlist= new list<OrderSelection__c>();
          vfc.conid=ols2.id;
          vfc.OCSlist.add(ols2);
          vfc.removecon();
        //bhaskar
          vfc.buttonvalue();
          //vfc.hasNext_inv=true;
          //vfc.hasPrevious_inv=true;
          vfc.selectedOption='test';
          vfc.deliveryWrapperList1=new List<wrapDelivery>();
          vfc.orderWrapperList1=new List<OrderWrapper>();
          vfc.invoiceWrapperList1=new List<wrapInvoice>();
          vfc.searchStr='test';
    }
    public static testMethod void testmethod2(){
        Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
            
        //Account Creation
         Account acc1=new Account(Name='Test1',CountryRef__c=toCountry.ID);
         Database.insert (acc1);
        
         //Case Creation 
         Case c1=new Case(AccountId=acc1.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',Origin='Email',Status='Open',Priority='Medium');
         insert c1;
         system.debug('+++caseID' + c1.id);
        
         Delivery__c dlv=new Delivery__c(Name='test',GC_Account_Integration_Key__c=acc1.Id,GC_Delivery_Number_Text__c='test1',GC_Integration_Key__c='12346',GC_Order_Number__c='143678');
         insert dlv;
            //Delivery Lineitem Creation 
         Delivery_Line_Item__c dlitem=new Delivery_Line_Item__c(name='TestDelivry',GC_Plant_Desc__c='Test1',GC_Dlvry_Integration_Key__c=dlv.Id,GC_Integration_Key__c='12346');
           insert dlitem;
       
           //Invoice Creation
            Invoice__c inv=new Invoice__c(Name='test',GC_Integration_Key__c='134145',GC_Account_Integration_Key__c=acc1.Id,GC_Order_Number__c='21345',GC_Invoice_Status_descr__c='testingapp',GC_Total_Inv_Amount_Nbr__c=120.012,GC_Invoice_Creation_Date__c=system.today());
            insert inv;
            //Invoice Lineitem Creation
            Invoice_Line_Item__c inlintem=new Invoice_Line_Item__c(Name='test',GC_Integration_Key__c='test123',GC_Invoice_Integration_Key__c=inv.Id,GC_Quantity__c=2.0,GC_Net_Value_Amount__c=123.02,GC_UOM_Line_Item_Descr__c='tes');
            insert inlintem;
          
            //order product creation 
          
            
           Id pricebookId = Test.getStandardPricebookId();                         
            Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1', isActive = true);
             insert prd1;

             PricebookEntry pe=new PricebookEntry(UnitPrice = 1,Product2Id=prd1.id,Pricebook2Id=pricebookId,isActive=true);
            insert pe;
             
            //Order Creation 
            Order or1=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='1213232',EffectiveDate=system.today(),Status='Draft',PoNumber='516487',GC_Document_Type_Descr__c='testingthe',GC_Ship_To_Party_Text__c='tex',GC_Ship_To_Party_Descr__c='dscrt');
            insert or1;
            Order or2=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='14213232',EffectiveDate=system.today(),Status='Draft',PoNumber='516489',GC_Document_Type_Descr__c='testingapp',GC_Ship_To_Party_Text__c='te1',GC_Ship_To_Party_Descr__c='dsrt');
            insert or2;
             Order or3=new Order(PriceBook2Id=pricebookId,AccountId=acc1.Id,GC_Integration_Key__c='14213212',EffectiveDate=system.today(),Status='Draft',PoNumber='511489',GC_Document_Type_Descr__c='testi1gapp',GC_Ship_To_Party_Text__c='te2',GC_Ship_To_Party_Descr__c='d1srt');
            insert or3;
                OrderItem oi = new OrderItem(OrderId=or1.id,Quantity=1,PricebookEntryId=pe.id, unitPrice=1,GC_Quantity__c=1);
            insert oi;
        
         OrderSelection__c ols=new OrderSelection__c();
            ols.Name='Testinnngordr';
            ols.CaseId_Text__c=c1.id;
            ols.Delivery_Id_Text__c=dlv.id;
            ols.DeliveryItem_Id_Text__c=dlitem.id;
            ols.InvoiceId_Text__c=inv.id;
            //ols.InvoiceLineItemId_Text__c=inlintem.id;
            //ols.OrderId_Text__c=null;
           OrderSelection__c ols1=new OrderSelection__c();
            ols1.Name='Testinnngordr';
            ols1.CaseId_Text__c=c1.id;
            ols1.Delivery_Id_Text__c=dlv.id;
            ols1.DeliveryItem_Id_Text__c=dlitem.id;
            ols1.InvoiceId_Text__c=inv.id;
            //ols1.InvoiceLineItemId_Text__c=inlintem.id;
            //ols1.OrderId_Text__c=null;
           OrderSelection__c ols2=new OrderSelection__c();
            ols2.Name='Testinnngordr';
            ols2.CaseId_Text__c=c1.id;
            ols2.Delivery_Id_Text__c=dlv.id;
            ols2.DeliveryItem_Id_Text__c=dlitem.id;
            ols2.InvoiceId_Text__c=inv.id;
            //ols2.InvoiceLineItemId_Text__c=inlintem.id;
            //ols2.OrderId_Text__c=null;
            List<OrderSelection__c> ocslistn=new List<OrderSelection__c>();
            ocslistn.add(ols);
            ocslistn.add(ols1);
            ocslistn.add(ols2);
            insert ocslistn;
          
          PageReference pageRef = Page.vfpdelivery_new;
        pageRef.getParameters().put('id',c1.id);
        apexpages.StandardController apx = new apexPages.StandardController(c1);
         Test.setCurrentPageReference(pageRef);
        VFC_Delivery vfc=  new VFC_Delivery(apx);
       
        

 
        vfc.deliveryWrapperList= new List<wrapdelivery>();
        vfc.deliveryWrapperListsearch= new List<wrapdelivery>();
       
        //vfc.hasNext=true;
        //vfc.hasPrevious=false; 
       
        
        vfc.orderWrapperListsearch = new List<OrderWrapper>();
        vfc.selecteddeliverylineitem();
        vfc.srchStrinv=inv.name;//bhaskar
        vfc.getInvoices();
        vfc.srchStrDel='ttttttttt';
        vfc.getdelivery();        
       }
    
    
    }