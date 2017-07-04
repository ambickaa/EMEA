@isTest
private class Test_TriggerActionPlanStockControl {
    
    public static List<Action_Plan_Line__c> actionPlanList;
    public static RecordType accountRecordType, productRecordType;
    public static String actualPeriod, priorperiod, nextPeriod, actualQuarter, priorQuarter, nextQuarter, fiscalYearPrior, fiscalYearActual, fiscalYearNext, finalActualQuarter, finalPriorQuarter, finalNextQuarter;
    
    static void init()
    {
        actionPlanList = new List<Action_Plan_Line__c>();
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        
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
            finalActualQuarter = fiscalYearActual + ' ' + actualQuarter;
            finalPriorQuarter = fiscalYearPrior + ' ' + priorQuarter;
            finalNextQuarter = fiscalYearNext + ' ' + nextQuarter;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 3 && Integer.valueof(System.Date.today().month()) < 6)
        {
        	nextQuarter = 'Q4';
            actualQuarter = 'Q3';
            priorQuarter = 'Q2';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual;
            finalNextQuarter = fiscalYearNext + ' ' + nextQuarter;
            finalActualQuarter = fiscalYearActual + ' ' + actualQuarter;
            finalPriorQuarter = fiscalYearPrior + ' ' + priorQuarter;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 6 && Integer.valueof(System.Date.today().month()) < 9)
        {
        	nextQuarter = 'Q1';
            actualQuarter = 'Q4';
            priorQuarter = 'Q3';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year() + 1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            fiscalYearPrior = fiscalYearActual + ' ' + nextQuarter;
            finalActualQuarter = fiscalYearActual + ' ' + actualQuarter;
            finalPriorQuarter = fiscalYearPrior + ' ' + priorQuarter;
        }
        else if(Integer.valueof(System.Date.today().month()) >= 9 && Integer.valueof(System.Date.today().month()) < 12)
        {
        	nextQuarter = 'Q2';
            actualQuarter = 'Q1';
            priorQuarter = 'Q4';
            fiscalYearNext = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            fiscalYearActual = 'FY' +  String.valueOf(System.Date.today().year()+1).substring(2,4);
            fiscalYearPrior = 'FY' +  String.valueOf(System.Date.today().year()).substring(2,4);
            finalNextQuarter = fiscalYearNext + ' ' + nextQuarter;
            finalActualQuarter = fiscalYearActual + ' ' + actualQuarter;
            finalPriorQuarter = fiscalYearPrior + ' ' + priorQuarter;
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
        apl.PICK_Period__c = actualPeriod;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        try {
        	insert apl;

	        apl.NUM_Final_stock__c = 30;
	        update apl;
	        
	        Action_Plan_Line__c q1 = [SELECT Id, NUM_Final_stock__c FROM Action_plan_Line__c WHERE Id =: apl.Id LIMIT 1];
	        Action_Plan_Line__c q2 = [SELECT Id, NUM_Initial_stock__c FROM Action_plan_Line__c WHERE PICK_Period__c = :nextPeriod AND LKP_Account__c =: acc.Id LIMIT 1];
	        
	        //Verification
	        System.assertEquals(q1.NUM_Final_stock__c, q2.NUM_Initial_stock__c);
        } catch (DmlException e) {
			for(Integer i = 0; i < e.getNumDml(); i++)
    			system.debug(e.getDmlMessage(i));
        }
        
        Test.stopTest();       
    }

    static testMethod void myUnitTest2() 
    {
        init();
        test.startTest();
        
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
        apl.PICK_Quarter__c = finalActualQuarter ;
        apl.NUM_Initial_stock__c = 100;
        apl.NUM_Final_stock__c = 50;
        apl.NUM_Forecast__c = 50;
        actualQuarter = 'Q4';
        insert apl;

        apl.NUM_Final_stock__c = 30;
        update apl;
        
        Action_Plan_Line__c q1 = [SELECT Id, NUM_Final_stock__c FROM Action_plan_Line__c WHERE Id =: apl.Id LIMIT 1];
        Action_Plan_Line__c q2 = [SELECT Id, NUM_Initial_stock__c FROM Action_plan_Line__c WHERE PICK_Quarter__c =: finalNextQuarter  AND LKP_Account__c =: acc.Id LIMIT 1];
        
        //Verification
        System.assertEquals(q1.NUM_Final_stock__c, q2.NUM_Initial_stock__c);     
        
        test.stopTest();
    }
}