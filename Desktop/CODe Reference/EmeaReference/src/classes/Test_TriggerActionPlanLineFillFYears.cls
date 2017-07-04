@isTest
public class Test_TriggerActionPlanLineFillFYears {
    
    @isTest public static void  createOneActionPlanLine()
    { 
        Country__c testCoun= new Country__c(name='testCount',Units_of_Measurement__c='Basic Units');
        insert testCoun;
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        currentUser.Country=testCoun.Name;
        update currentUser;
        RecordType rt3=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
        Account testAcc=new Account(RecordType=rt3,Name='Account',Category__c='Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party',GC_Status_Descr__c='Active',CountryRef__c=testCoun.Id);
        insert testAcc;
        RecordType rt=[Select id,Name from RecordType where name='CP Sales Product' limit 1];
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', GC_Cust_Account_Grp_Descr__c = 'Sold-to party', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType.Id);
        insert vend;
        
        RecordType productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2' LIMIT 1];
        Division__c d = new Division__c(Name = 'CP');
        Product2 prod = new Product2(ProductCartonPerPallet__c= 8,Name = 'product1', Family='CP', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType.Id);
        insert prod;
        RecordType rt2=[Select id,Name from RecordType where Name='Action Plan Line' limit 1];
        Action_Plan_Line__c apl1=new Action_Plan_Line__c(RecordType=rt2,
                                                            LKP_SKU__c=PROD.Id,PICK_Period__c='2015-09',LKP_Account__c=testAcc.Id);

        
        Action_Plan_Line__c apl2=new Action_Plan_Line__c(RecordType=rt2,
                                                            LKP_SKU__c=PROD.Id,PICK_Period__c='2015-08',LKP_Account__c=testAcc.Id);
        system.debug('primeraAPL:'+apl1 + '\n SegundaApl:'+ apl2 );
     
        
        Test.startTest();
        insert apl1;
        insert apl2;

        //system.assert(auxAcc.Forecasted_Year__c.contains(string.valueOf(apl1.PICK_Period__c).left(4)));
        
    }
}