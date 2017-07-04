@isTest
public without sharing class Test_CPUkraineForecastController 
{
    public static List<Action_Plan_Line__c> actionPlanList;
    public static RecordType accountRecordType, productRecordType,APL_Rt;
    public static String actualPeriod, priorperiod, actualQuarter, priorQuarter, fiscalYearPrior, fiscalYearActual;
    
       static testMethod void testCreatorUkraineForecastSKU() 
    {
       
        actionPlanList = new List<Action_Plan_Line__c>();
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        APL_Rt = [SELECT Id FROM RecordType WHERE Name = 'Action Plan Line' AND SobjectType = 'Action_Plan_Line__c' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
        //DISTRIBUTOR
        if(System.Date.today().month() == 1)
        {
            priorPeriod = String.valueOf(System.Date.today().year() - 1) + '-' + 12;
            actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
        }
        else
        {
            if(System.Date.today().month() - 1 < 10)
            {
                priorPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month() - 1);
                actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
            }
            else if(System.Date.today().month() - 1 >= 10)
            {
                actualPeriod = String.valueOf(System.Date.today().year() + '-' + String.valueOf(System.Date.today().month()));
                priorPeriod = String.valueOf(System.Date.today().year() + '-' + String.valueOf(System.Date.today().month() - 1));
            }       
        }
        
        //PoS
        if(Integer.valueof(System.Date.today().month()) <= 3)
        {
            actualQuarter = 'Q1';
            priorQuarter = 'Q4';
            fiscalYearPrior = 'FY' + String.valueOf(System.Date.today().year() - 1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
        }
        else if(Integer.valueof(System.Date.today().month()) > 3 && Integer.valueof(System.Date.today().month()) < 7)
        {
            actualQuarter = 'Q2';
            priorQuarter = 'Q1';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 7 && Integer.valueof(System.Date.today().month()) < 10)
        {
            actualQuarter = 'Q3';
            priorQuarter = 'Q2';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 10 && Integer.valueof(System.Date.today().month()) < 13)
        {
            actualQuarter = 'Q4';
            priorQuarter = 'Q3';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
        }   
         
   
    
 
       
        
        
        //DISTRIBUTOR Action Plan Line
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        user userToManageBy=[SELECT Id, Name, Country FROM User where Id!=:userinfo.getuserId() and IsActive=True limit 1];
        userToManageBy.ManagerId=currentUser.id;
        
        update userToManageBy;
       
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        list<account> accToIns=new list<account>();
        Account acc = new Account(OwnerId =userinfo.getuserid(),Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
         accToIns.add(acc); 
        
         Account acc2 = new Account(OwnerId =userToManageBy.id,Name = 'Account2', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
         accToIns.add(acc2); 
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor',GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
         accToIns.add(vend); 
         insert accToIns; 
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;        
        
        Product2 prod = new Product2(Name = 'product1', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode1', TXT_commercial_name__c='product1',DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        Product2 prod2 = new Product2(Name = 'product2', Family='ROUNDUP', ProductSAPCode__c = 'SAPCode2', TXT_commercial_name__c='product2',DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod2;     
        
        Pricebook2 pb = new Pricebook2(Name = 'test pb', PICK_Product_family__c = 'Roundup', isActive = true, Integration_Key__c = 'TESTPB', CP_Account_Type__c = 'Distributor');
        insert pb;        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert standardPrice2;      
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert customPrice;
        PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod2.Id, UnitPrice = 20000, IsActive = true);
        insert customPrice2;
        
        list<SelectOption> auxSetProds=new list<SelectOption>();
        list<SelectOption> auxListProds=new list<SelectOption>();
        
        // Options selected to make a filter by product and distributor
        for(Pricebookentry p : [SELECT Product2Id, product2.name, product2.TXT_commercial_name__c FROM PriceBookEntry where pricebook2id =:pb.id order by name asc])
        {
            if(p.product2.TXT_commercial_name__c != null)
            {
                SelectOption opt = new SelectOption(p.product2.id, p.product2.TXT_commercial_name__c);
                auxSetProds.add(opt);
            }
        }
        auxListProds.addAll(auxSetProds);
        List<SelectOption> auxDist=new list<SelectOption>();
        SelectOption opt = new SelectOption(acc.id, acc.name);
        SelectOption opt2 = new SelectOption(acc2.id, acc2.name);
        auxDist.add(opt);
        auxDist.add(opt2);

      
        list<Action_Plan_Line__c> aplToIns=new list<Action_Plan_Line__c>();
        //DISTRIBUTOR
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.RecordTypeId=APL_Rt.Id;
        apl.LKP_Account__c = acc.Id;
        apl.LKP_SKU__c = prod.Id;
        apl.PICK_Period__c = priorPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        aplToIns.add(apl);
        
        Action_Plan_Line__c apl2 = new Action_Plan_Line__c();
        apl2.RecordTypeId=APL_Rt.Id;
        apl2.LKP_Account__c = acc.Id;
        apl2.LKP_SKU__c = prod2.Id;
        apl2.PICK_Period__c = priorPeriod;
        apl2.NUM_Initial_stock__c = 150;
        apl2.NUM_Final_stock__c = 75;
        apl2.NUM_Forecast__c = 50;
        aplToIns.add(apl2);                
        
        insert aplToIns;
         test.startTest();
        PageReference pageRef = Page.AccountViewES;
        Test.setCurrentPage(pageRef);
       
        CP_UKRAINEforecastController controller = new CP_UKRAINEforecastController();
        controller.selectedProducts=auxListProds;
        controller.selectedDistributors=auxDist;
        controller.getProducts();
        controller.saveForecastSKU();
        controller.getIsDevice();
        
        country.Units_of_Measurement__c = 'Rels';
        update country;
        controller.saveForecastSKU();
       test.stoptest();
    }
}