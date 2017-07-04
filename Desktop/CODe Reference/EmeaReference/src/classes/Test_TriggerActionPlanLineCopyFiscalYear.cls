@isTest
private class Test_TriggerActionPlanLineCopyFiscalYear 
{
    public static RecordType accountRecordType, productRecordType;
    public static String actualPeriod, priorperiod, actualQuarter, priorQuarter, fiscalYearPrior, fiscalYearActual;
    
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
        if(System.Date.today().month() == 1)
        {
            actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
        }
        else
        {
            if(System.Date.today().month() < 10)
            {
                actualPeriod = String.valueOf(System.Date.today().year()) + '-' + '0' + String.valueOf(System.Date.today().month());
            }
            else 
            {
                if(System.Date.today().month() == 10)
                {
                    actualPeriod = String.valueOf(System.Date.today().year() + '-'+ String.valueOf(System.Date.today().month()));
                }
                else
                    if(System.Date.today().month() > 10)
                {
                    actualPeriod = String.valueOf(System.Date.today().year() + '-' + String.valueOf(System.Date.today().month()));
                }
            }        
        }
        
        if(Integer.valueof(System.Date.today().month()) == 12 ||Integer.valueof(System.Date.today().month()) < 3)
        {
            actualQuarter = 'Q2';
            if (Integer.valueof(System.Date.today().month()) == 12)
            {
                fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            }
            else
            {
                fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            }
        }
        else if(Integer.valueof(System.Date.today().month()) >= 3 && Integer.valueof(System.Date.today().month()) < 6)
        {
            actualQuarter = 'Q3';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
        }
        else if(Integer.valueof(System.Date.today().month()) >= 6 && Integer.valueof(System.Date.today().month()) < 9)
        {
            actualQuarter = 'Q4';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
        }
        else if(Integer.valueof(System.Date.today().month()) >= 9 && Integer.valueof(System.Date.today().month()) < 12)
        {
            actualQuarter = 'Q1';
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
        }
    }
    
    static testMethod void myUnitTest() 
    {
      init();
      Test.startTest();
      
      //DISTRIBUTOR Action Plan Line
      User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
      Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
      insert country;
      
      Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert acc;
      
      Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert vend;
      
      Division__c d = new Division__c(Name = 'Roundup');
      insert d;        
        
      Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
      insert prod;
      Id pricebookId = Test.getStandardPricebookId();
       
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
      insert standardPrice;
      
      Action_Plan_Line__c apl = new Action_Plan_Line__c();
      apl.LKP_Account__c = acc.Id;
      apl.LKP_SKU__c = prod.Id;
      apl.PICK_Period__c = actualPeriod ;
      apl.NUM_Initial_stock__c = 100;
      apl.NUM_Final_stock__c = 50;
      apl.NUM_Forecast__c = 50;
      
      try {
      	  insert apl;

	      Test.stopTest();
	      
	      List<Action_Plan_Line__c> listAPL = new List<Action_Plan_Line__c>([SELECT Id, TXT_External_ID__c, LKP_Account__c, LKP_SKU__c, PICK_Period__c, OwnerId FROM Action_Plan_Line__c]);
	      for(Action_Plan_Line__c a : listAPL)
	      {          
	          System.assertEquals(a.TXT_External_ID__c.substring(0,31), String.valueOf(a.LKP_Account__c).substring(0,15) + '-' + String.valueOf(a.LKP_SKU__c).substring(0,15));
	      }
      } catch (DmlException e) {
			for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug(e.getDmlMessage(i));
        }
      
    }
    
    static testMethod void myUnitTest2() 
    {
      init();
      Test.startTest();
      
      //DISTRIBUTOR Action Plan Line
      User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
      Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
      insert country;
      
      Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'PoS', GC_Cust_Account_Grp_Descr__c = 'Ship-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert acc;
      
      Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert vend;
      
      Division__c d = new Division__c(Name = 'Roundup');
      insert d;        
        
      Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
      insert prod;
      Id pricebookId = Test.getStandardPricebookId();
       
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
      insert standardPrice;
      
      Action_Plan_Line__c apl = new Action_Plan_Line__c();
      apl.LKP_Account__c = acc.Id;
      apl.LKP_SKU__c = prod.Id;
      apl.PICK_Quarter__c = fiscalYearActual + ' ' +actualQuarter;
      apl.NUM_Initial_stock__c = 100;
      apl.NUM_Final_stock__c = 50;
      apl.NUM_Forecast__c = 50;
      insert apl; 
      
      Test.stopTest();
      
      List<Action_Plan_Line__c> listAPL = new List<Action_Plan_Line__c>([SELECT Id, TXT_External_ID__c, LKP_Account__c, LKP_SKU__c, PICK_Quarter__c, OwnerId FROM Action_Plan_Line__c]);
      for(Action_Plan_Line__c a : listAPL)
      {          
          System.assertEquals(a.TXT_External_ID__c.substring(0,31), String.valueOf(a.LKP_Account__c).substring(0,15) + '-' + String.valueOf(a.LKP_SKU__c).substring(0,15));
      }      
      
    }
    
    static testMethod void myUnitTest3() 
    {
      init();
      Test.startTest();
      
      //DISTRIBUTOR Action Plan Line
      User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
      Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
      insert country;
      
      Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert acc;
      
      Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert vend;
      
      Division__c d = new Division__c(Name = 'Roundup');
      insert d;        
        
      Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
      insert prod;
      Id pricebookId = Test.getStandardPricebookId();
       
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
      insert standardPrice;
      
      Action_Plan_Line__c apl = new Action_Plan_Line__c();
      apl.LKP_Account__c = acc.Id;
      apl.LKP_SKU__c = prod.Id;
      apl.PICK_Period__c = actualPeriod.substring(0,6) + '07' ;
      apl.NUM_Initial_stock__c = 100;
      apl.NUM_Final_stock__c = 50;
      apl.NUM_Forecast__c = 50;
      insert apl; 
      
      Test.stopTest();
      
      List<Action_Plan_Line__c> listAPL = new List<Action_Plan_Line__c>([SELECT Id FROM Action_Plan_Line__c]);
      System.assertEquals(listAPL.size(),2);    
      
    }
    
    static testMethod void myUnitTest4() 
    {
      init();
      Test.startTest();
      
      //PoS Action Plan Line
      User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
      Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
      insert country;
      
      Account acc = new Account(Name = 'Account1', CountryRef__c = country.Id, Category__c = 'PoS', GC_Cust_Account_Grp_Descr__c = 'Ship-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert acc;
      
      Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
      insert vend;
      
      Division__c d = new Division__c(Name = 'Roundup');
      insert d;        
        
      Product2 prod = new Product2(Name = 'product1', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
      insert prod;
      Id pricebookId = Test.getStandardPricebookId();
       
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
      insert standardPrice;
      
      Action_Plan_Line__c apl = new Action_Plan_Line__c();
      apl.LKP_Account__c = acc.Id;
      apl.LKP_SKU__c = prod.Id;
      apl.PICK_Period__c = fiscalYearActual + ' ' + 'Q4' ;
      apl.NUM_Initial_stock__c = 100;
      apl.NUM_Final_stock__c = 50;
      apl.NUM_Forecast__c = 50;
      insert apl; 
      
      Test.stopTest();
      
      List<Action_Plan_Line__c> listAPL = new List<Action_Plan_Line__c>([SELECT Id FROM Action_Plan_Line__c]);
      System.assertEquals(listAPL.size(),1);    
      
    }
}