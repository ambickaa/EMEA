@isTest
public with sharing class Test_actionPlanCPController 
{
    public static List<Action_Plan_Line__c> actionPlanList;
    public static RecordType accountRecordType, productRecordType;
    public static String actualPeriod, priorperiod, nextPeriod, actualQuarter, priorQuarter, nextQuarter, fiscalYearPrior, fiscalYearActual, fiscalYearNext, PreviousFY;
    public static Country__c country;
    public static Account acc, acc2, acc3, vend;
    public static Division__c d;
    public static Product2 prod, prod2, prod3;
    public static Pricebook2 pb, pb2;
    public static PricebookEntry standardPrice, standardPrice2, standardPrice3, customPrice, customPrice2, customPrice3;
    
    static void init()
    {
        actionPlanList = new List<Action_Plan_Line__c>();
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
        PreviousFY = String.valueOf(System.Date.today().year() - 1);

        if(System.Date.today().month() == 1)
        {
            priorPeriod = String.valueOf(System.Date.today().year() - 1) + '-' + 12;
            actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
            nextPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() + 1);
        }
        else
        {
            if(System.Date.today().month() <= 9)
            {
                priorPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() - 1);
                actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
                
                if(System.Date.today().month() < 9)
                	nextPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() + 1);
                else if(System.Date.today().month() == 9)
                	nextPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month() + 1);
            }
            else 
            {
                if(System.Date.today().month() == 10)
                {
                	priorPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() - 1);
                    actualPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month());
                    nextPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month() + 1);
                }
                else if(System.Date.today().month() > 10)
                {
                	priorPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month() - 1);
                    actualPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month());
                    
                    if(System.Date.today().month() < 12)
                    	nextPeriod = String.valueOf(System.Date.today().year()) + '-' + String.valueOf(System.Date.today().month() + 1);
                    else if(System.Date.today().month() == 12)
                    	nextPeriod = String.valueOf(System.Date.today().year() + 1) + '-' + '01';
                }
            }        
        }
        
        
        if(Integer.valueof(System.Date.today().month()) == 12 || Integer.valueof(System.Date.today().month()) < 3)
        {
        	nextQuarter = 'Q3';
            actualQuarter = 'Q2';
            priorQuarter = 'Q1';
            if (Integer.valueof(System.Date.today().month()) == 12)
            {
                fiscalYearPrior = 'FY' + String.valueOf(System.Date.today().year()).substring(2,4);
                fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
                fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            }
            else
            {
                fiscalYearPrior = 'FY' + String.valueOf(System.Date.today().year()-1).substring(2,4);
                fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
                fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            }
        }
        else if(Integer.valueof(System.Date.today().month()) >= 3 && Integer.valueof(System.Date.today().month()) < 6)
        {
        	nextQuarter = 'Q4';
            actualQuarter = 'Q3';
            priorQuarter = 'Q2';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 6 && Integer.valueof(System.Date.today().month()) < 9)
        {
        	nextQuarter = 'Q1';
            actualQuarter = 'Q4';
            priorQuarter = 'Q3';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year() + 1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual + ' ' + nextQuarter;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 9 && Integer.valueof(System.Date.today().month()) < 12)
        {
        	nextQuarter = 'Q2';
            actualQuarter = 'Q1';
            priorQuarter = 'Q4';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            fiscalYearPrior = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
        }          
    }
    
    static void init2()
    {
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc;
        acc2 = new Account(Name = 'Account2', CountryRef__c = country.Id, Category__c = 'PoS', GC_Cust_Account_Grp_Descr__c = 'Ship-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc2;      
        acc3 = new Account(Name = 'Account3', CountryRef__c = country.Id, Category__c = '', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert acc3;
        
        vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
          
        d = new Division__c(Name = 'Roundup');
        insert d;        
        
        prod = new Product2(Name = 'product1', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        prod2 = new Product2(Name = 'product2', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode2', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod2;
        prod3 = new Product2(Name = 'product2', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode3', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod3;    
        
        pb = new Pricebook2(Name = 'test pb', PICK_Product_family__c = 'ROUNDUP', isActive = true, Integration_Key__c = 'TESTPB', CP_Account_Type__c = 'Distributor', CountryRef__c = country.Id);
        insert pb;
        pb2 = new Pricebook2(Name = 'test pb', PICK_Product_family__c = 'ROUNDUP', isActive = true, Integration_Key__c = 'TESTPB2', CP_Account_Type__c = 'PoS', CountryRef__c = country.Id);
        insert pb2;       
        
        standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert standardPrice2;
        standardPrice3 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod3.Id, UnitPrice = 30000, IsActive = true);
        insert standardPrice3;  
        
        customPrice = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert customPrice;
        customPrice2 = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert customPrice2;
        customPrice3 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod3.Id, UnitPrice = 30000, IsActive = true);
        insert customPrice3;
    }
    
    static testMethod void testCreatorDistributor() 
    {
        init();
        init2();                
        
        //DISTRIBUTOR
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = actualPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        apl.NUM_Ordered__c = 20;
        apl.NUM_Delivered__c = 10;
        //insert apl;
        
        Action_Plan_Line__c apl2 = new Action_Plan_Line__c();
        apl2.LKP_Account__c = acc.Id;
        apl2.LKP_SKU__c = prod2.Id;
        apl2.PICK_Period__c = actualPeriod;
        apl2.NUM_Initial_stock__c = 100;
        apl2.NUM_Final_stock__c = 50;
        apl2.NUM_Forecast__c = 50;
        apl2.NUM_Ordered__c = 20;
        apl2.NUM_Delivered__c = 10;
        //insert apl2;
        
        try {
        	insert new List<Action_Plan_Line__c>{apl,apl2};
        
	        Test.startTest();
	        
	        PageReference pageRef = Page.AccountViewCP;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('id', acc.Id);        
	        ApexPages.currentPage().getParameters().put('mode', 'view'); 
	        ApexPages.currentPage().getParameters().put('products', prod.Id);
	        actionPlanCPController controller = new actionPlanCPController();           
	        
	        controller.getPeriods();
	        
	        Test.stopTest();
	        
	        System.assertEquals(2,controller.mapProductFamilyAPL.size());  
        
        } catch (DmlException e) {
			for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug(e.getDmlMessage(i));
        }    
    }
    
    static testMethod void testCreatorPos() 
    {
        init();
        init2();                
        
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc2.Id;
        apl.LKP_SKU__c = prod2.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + 'Q1';
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        apl.NUM_Ordered__c = 20;
        apl.NUM_Delivered__c = 10;
        insert apl;
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        ApexPages.currentPage().getParameters().put('products', prod2.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.getQuarters();
        
        Test.stopTest();

        System.assertEquals(2,controller.mapProductFamilyAPL.size()); 
    }
    
    static testMethod void testCreatorNoCategory() 
    {
        init();
        init2();                
        
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc3.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + 'Q1';
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        apl.NUM_Ordered__c = 20;
        apl.NUM_Delivered__c = 10;
        insert apl;
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc3.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        ApexPages.currentPage().getParameters().put('products', prod.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.getQuarters();
        
        Test.stopTest();
        System.assertEquals(2,controller.mapProductFamilyAPL.size()); 
    }
    
    static testMethod void testNewAPL()
    {
        init();
        init2();
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view'); 
        actionPlanCPController controller = new actionPlanCPController();
        controller.periodSelected = actualPeriod;
        controller.newRow();
        
        Test.stopTest();
        
        System.assertNotEquals(controller.listaPintarAPL, null);       
    }
    
    static testMethod void testNewAPL2()
    {
        init();
        init2();
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view'); 
        actionPlanCPController controller = new actionPlanCPController();
        controller.quarterSelected = actualQuarter;
        controller.newRow();
        
        Test.stopTest();
        
        System.assertNotEquals(controller.listaPintarAPL, null);       
    }
    
    static testMethod void testCancelCustom()
    {
        init();
        init2();
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view'); 
        actionPlanCPController controller = new actionPlanCPController();
        controller.periodSelected = actualPeriod;
        controller.newRow();
        controller.cancelCustom();
        
        Test.stopTest();
        
        System.assertEquals(controller.mapProductFamilyAPL.get('zz'), null);
    }
    
    static testMethod void testSave()
    {
        init();
        init2();
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view'); 
        actionPlanCPController controller = new actionPlanCPController();
        controller.periodSelected = actualPeriod;
        controller.newRow();
        controller.save();
        
        Test.stopTest();
        
        //Action_Plan_Line__c apl = [SELECT ID, TXT_External_ID__c FROM Action_Plan_Line__c LIMIT 1];
        
        //System.assertNotEquals(apl.Id, null);
    }
    
    static testMethod void testSave2()
    {
        init();
        init2();
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = actualPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        apl.NUM_Ordered__c = 20;
        apl.NUM_Delivered__c = 10;
        
        try {
        	insert apl;
        } catch (DmlException e) {
			for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug(e.getDmlMessage(i));
        }
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        ApexPages.currentPage().getParameters().put('products', prod.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.periodSelected = actualPeriod;
        controller.newRow();
        controller.save();
        
        Test.stopTest();
    }
    
    static testMethod void testDelete()
    {
        init();
        init2();
        
        Test.startTest();
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        ApexPages.currentPage().getParameters().put('products', prod.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.periodSelected = actualPeriod;
        controller.editAll();
        controller.save();
        if(controller.getMapSize() != 0)
        {
            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).selected = true;
            controller.deleteActionPlanLines();
        }  
        
        Test.stopTest();
        
        System.assertEquals(controller.mapProductFamilyAPL.size(), 0);
    }
    
    static testMethod void testDelete2()
    {
        init();
        init2();
        
        Test.startTest();
        
        //DISTRIBUTOR
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = actualPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        apl.NUM_Ordered__c = 20;
        apl.NUM_Delivered__c = 10;
        
        try {
        	insert apl;
              
	        PageReference pageRef = Page.AccountViewCP;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put('id', acc.Id);        
	        ApexPages.currentPage().getParameters().put('mode', 'view');
	        actionPlanCPController controller = new actionPlanCPController();
	        controller.periodSelected = actualPeriod;
	
	        if(controller.getMapSize() != 0)
	        {
	            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).selected = true;
	            controller.deleteActionPlanLines();
	        }  
	        
	        System.assertEquals(controller.mapProductFamilyAPL.size(), 1);
        } catch (DmlException e) {
			for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug(e.getDmlMessage(i));
        }
        
        Test.stopTest();
    }
    
     static testMethod void testDelete3()
    {
        init();
        init2();
        
        Test.startTest();
        
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc2.Id;
        apl.LKP_SKU__c = prod2.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + actualQuarter;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        insert apl;
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        controller.quarterSelected = fiscalYearActual + ' ' + actualQuarter;
        controller.getData();
        if(controller.getMapSize() != 0)
        {
            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).selected = true;
            System.debug('El mapa a borrar es: '+controller.mapProductFamilyAPL.get('ROUNDUP').get(0));
            controller.deleteActionPlanLines();
        }  
        
        Test.stopTest();
        
        //List<Action_Plan_Line__c> listAux = [SELECT Id, TXT_External_ID__c FROM Action_Plan_Line__c];
        
        System.assertEquals(controller.mapProductFamilyAPL.size() , 1);
    }
    
    static testMethod void testDelete4()
    {
        init();
        init2();
        
        Test.startTest();
        
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc2.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + actualQuarter;
        insert apl;
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        controller.quarterSelected = fiscalYearActual + ' ' + actualQuarter;

        if(controller.getMapSize() != 0)
        {
            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).selected = true;
            System.debug('El mapa a borrar es: '+controller.mapProductFamilyAPL.get('ROUNDUP').get(0));
            controller.deleteActionPlanLines();
        }  
        
        Test.stopTest();
        
        //List<Action_Plan_Line__c> listAux = [SELECT Id, TXT_External_ID__c FROM Action_Plan_Line__c];
        
        System.assertEquals(controller.mapProductFamilyAPL.size(), 0);
    }
    
    /*static testMethod void testDelete5()
    {
        init();
        init2();
        
        Test.startTest();
        
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc2.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + 'Q1';
        insert apl;
              
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        controller.quarterSelected = fiscalYearActual + ' ' + 'Q1';
        id idaux = apl.id;
        
        if(controller.getMapSize() != 0)
        {
            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).selected = true;
            controller.mapProductFamilyAPL.get('ROUNDUP').get(0).actionPlanLine.Id = 'a1b25000000Gk2o';
            controller.deleteActionPlanLines();
        } 
        
        Test.stopTest();
        
        List<Action_Plan_Line__c> listAux = [SELECT Id, TXT_External_ID__c FROM Action_Plan_Line__c];

    }*/
    
    static testMethod void testDashboardPos() 
    {
        init();
        init2();
                
        //PoS
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc2.Id;
        apl.LKP_SKU__c = prod2.Id;
        apl.PICK_Quarter__c = fiscalYearActual + ' ' + actualQuarter;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        insert apl;
        
        Test.startTest();       
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        actionPlanCPController.surveyResults(acc2.Id, 'ROUNDUP');
        
        Test.stopTest();       
    }
    
    static testMethod void testDashboardDistributor() 
    {
        init();
        init2();
                
        //Distributor
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = actualPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        //insert apl;
        
        Action_Plan_Line__c apl2 = new Action_Plan_Line__c();
        apl2.LKP_Account__c = acc.Id;
        apl2.LKP_SKU__c = prod.Id;
        apl2.PICK_Period__c = PreviousFY + '-10';
        apl2.NUM_Initial_stock__c = 100;
        apl2.NUM_Final_stock__c = 50;
        apl2.NUM_Forecast__c = 50;
        //insert apl2;
        //insert new List<Action_Plan_Line__c>{apl,apl2};
        
        Test.startTest();       
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        actionPlanCPController.surveyResults(acc.Id, 'ROUNDUP');
        
        Test.stopTest();          
        
    }   
    
    static testMethod void testgetIsdevice()
    {
        init();
        init2();

        Test.startTest();       
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);        
        ApexPages.currentPage().getParameters().put('mode', 'view');
        actionPlanCPController controller = new actionPlanCPController();
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'iphone');
        controller.getIsDevice();
        
        Test.stopTest();
    }
    
    static testMethod void testBuilderController()
    {
        init();
        init2();
        
        Test.startTest(); 
        
        actionPlanCPController controller = new actionPlanCPController(acc);
        
        Test.stopTest();
    }
    
    static testMethod void testModeNull()
    {
        init();
        init2();
        
        Test.startTest(); 
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        actionPlanCPController controller = new actionPlanCPController(); 
        
        Test.stopTest();       
    }
    
    static testMethod void testDistributorFPoptions()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.getFPoptions();
        
        Test.stopTest();
    }
    
    static testMethod void testPoSFPoptions()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc2.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.getFPoptions();
        
        Test.stopTest(); 
    }
    
    static testMethod void testGeneralFPoptions()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc3.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.getFPoptions();
        
        Test.stopTest(); 
    }
    
    static testMethod void testMultiLines()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        ApexPages.currentPage().getParameters().put('mode', 'view');
        ApexPages.currentPage().getParameters().put('division', d.id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.multiLines();
        
        Test.stopTest(); 
    }
    
    static testMethod void testRefresh()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        actionPlanCPController controller = new actionPlanCPController();
        controller.Ok();
        controller.refresh();
        
        Test.stopTest(); 
    }
    
    static testMethod void testnulls()
    {
        init();
        init2();
        
        Test.startTest();
        
        PageReference pageRef = Page.AccountViewCP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', acc.Id);
        actionPlanCPController controller = new actionPlanCPController();
        //controller.listActionPlanLines = null;
        controller.getMapSize();
        controller.filterFamily();
        
        Test.stopTest(); 
    }
}