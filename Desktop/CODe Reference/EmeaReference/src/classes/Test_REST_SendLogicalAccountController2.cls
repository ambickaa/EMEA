@isTest
public class Test_REST_SendLogicalAccountController2{

    public static testMethod void TestSendAccounts() {
    
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
        	s = [SELECT id, value__c from Systemsettings__c where name='RSA_REST_SVC_JSON_SAVE'];
        	s.value__c='all';
        	update s;
        }
        catch(Exception e)
        {
        	s = new Systemsettings__c(name='RSA_REST_SVC_JSON_SAVE', value__c ='all');
        	insert s;
        }
        Test.startTest();
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
            
            paramsAcc.statusCode=null;
            paramsAcc.statusDescription='';
        
            paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        
                REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                    rAcc.action='Insert';
                    rAcc.PrimaryDistributorIdDevice=0;
                    rAcc.PrimaryPosIdDevice=0;
                    rAcc.BankAccountHolderIdDevice=0;
                    rAcc.BuyerIdDevice=0;
                    rAcc.ParentIdIdDevice=0; 
                    rAcc.account = new Account(CountryRef__c = Test_REST_DataFactoryEast.c.id,Name='AccountNeww', 
                                               Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), 
                                               idDevice__c=550); 
            paramsAcc.accounts.add(rAcc);
                      
            REST_SendLogicalEntityAccountEast.REST_AccountObject rAccu = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccu.PrimaryDistributorIdDevice=0;
                rAccu.PrimaryPosIdDevice=0;
                rAccu.BankAccountHolderIdDevice=0;
                rAccu.BuyerIdDevice=0;
                rAccu.ParentIdIdDevice=0;
                rAccu.action='Update';
                rAccu.Account=[SELECT Name, CountryRef__c, Category__c, LastModifiedDate, City__c, StateProvince__c,
                               DE_Landkreis__c, Micro_Region__c, County__c,DE_ZIP_PLZ__c  
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farm.id];
            paramsAcc.accounts.add(rAccu);       
        
           REST_SendLogicalEntityAccountEast.REST_AccountObject rAccd = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccd.PrimaryDistributorIdDevice=0;
                rAccd.PrimaryPosIdDevice=0;
                rAccd.BankAccountHolderIdDevice=0;
                rAccd.BuyerIdDevice=0;
                rAccd.ParentIdIdDevice=0;
                rAccd.action='Delete';
                rAccd.Account=[SELECT Name, CountryRef__c, Category__c, LastModifiedDate, City__c, StateProvince__c,
                               DE_Landkreis__c, Micro_Region__c, County__c,DE_ZIP_PLZ__c 
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farmii.id];
            paramsAcc.accounts.add(rAccd);      
       
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>();   
           
              REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCon.action='Insert';
              rCon.AccountIdIdDevice=0;    
              rCon.contact=new Contact(LastName='Jamess',CountryRef__c=Test_REST_DataFactoryEast.c.id,idDevice__c='900',
                                       AccountID=Test_REST_DataFactoryEast.aList.get(6).id);      
        paramsAcc.contacts.add(rCon); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rConu = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rConu.action='Update';
              rConu.AccountIdIdDevice=0;    
              rConu.contact=[SELECT LastName, LastModifiedDate, AccountID, CountryRef__c, idDevice__c, 
                             DE_Territory_Key__c,Street__c,StateProvince__c,Micro_Region__c,County__c,
                             City__c,DE_Landkreis__c,DE_ZIP_PLZ__c 
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(3).id];
        paramsAcc.contacts.add(rConu); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rCond = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCond.action='Delete';
              rCond.AccountIdIdDevice=0;    
              rCond.contact=[SELECT LastName, LastModifiedDate, AccountID, CountryRef__c, idDevice__c, 
                             DE_Territory_Key__c,Street__c,StateProvince__c,Micro_Region__c,County__c,
                             City__c,DE_Landkreis__c,DE_ZIP_PLZ__c 
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(4).id];     
        paramsAcc.contacts.add(rCond); 

        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);

        for(REST_SendLogicalEntityAccountEast.REST_AccountObject AcObj : outAccount.accounts){
              System.assertEquals(100,AcObj.statusCode);}                       
       
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject CoObj : outAccount.contacts){
              System.assertEquals(100,CoObj.statusCode);}
        System.AssertEquals(outAccount.statuscode,100);        
                
        Test.StopTest();
    }
    
    public static testMethod void PrevDel() {
        
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
    
        Account FarmTest = new Account(CountryRef__c= Test_REST_DataFactoryEast.c.ID, Name='FarmTestii', Category__c='Farm',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'));
        insert FarmTest;
        Contact ConTest= new Contact(CountryRef__c= Test_REST_DataFactoryEast.c.ID, LastName='Johnson');
        insert ConTest;
    
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
        paramsAcc.statusCode=null;
        paramsAcc.statusDescription='';
        paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>(); 
        
        REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
        rAcc.action='Delete';
        rAcc.account=Farmtest;    
        paramsAcc.accounts.add(rAcc);
        

        REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
        rCon.action='Update';
        rCon.AccountIdIdDevice=920;    
        rCon.contact=Contest; 
        paramsAcc.contacts.add(rCon); 
        
        delete Farmtest;
        delete ConTest;
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);
        System.assertEquals(201,outAccount.statusCode);
        for(REST_SendLogicalEntityAccountEast.REST_AccountObject clio : outAccount.accounts){
              System.assertEquals(201,clio.statusCode);}                       
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject clio : outAccount.contacts){
              System.assertEquals(201,clio.statusCode);} 
        Test.stoptest();                 
    }
    public static testMethod void Mismatch() {
        
        Test_REST_DataFactoryEast.TestData();
        
        test.starttest();
    
        Account FarmTest = new Account(CountryRef__c= Test_REST_DataFactoryEast.c.ID, Name='FarmTestii', Category__c='Farm',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'));
        insert FarmTest;
        Contact ConTest= new Contact(CountryRef__c= Test_REST_DataFactoryEast.c.ID, LastName='Johnson');
        insert ConTest;
    
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
        paramsAcc.statusCode=null;
        paramsAcc.statusDescription='';
        paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>(); 
        
        REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
        rAcc.action='Delete';
        rAcc.account=Farmtest;    
        paramsAcc.accounts.add(rAcc);
        

        REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
        rCon.action='Update';
        rCon.AccountIdIdDevice=920;    
        rCon.contact=Contest; 
        paramsAcc.contacts.add(rCon); 
        
        Farmtest.City__c='BCN';
        Contest.City__c='BCN';
        update Farmtest;
        update ConTest;
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);
        System.assertEquals(200,outAccount.statusCode);
        for(REST_SendLogicalEntityAccountEast.REST_AccountObject clio : outAccount.accounts){
              System.assertEquals(200,clio.statusCode);}                       
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject clio : outAccount.contacts){
              System.assertEquals(200,clio.statusCode);}  
              
        test.stoptest() ;                                
    }
    public static testMethod void DMLException() {
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
            
            paramsAcc.statusCode=null;
            paramsAcc.statusDescription='';
        
            paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        
                REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                    rAcc.action='Insert';
                    rAcc.PrimaryDistributorIdDevice=0;
                    rAcc.PrimaryPosIdDevice=0;
                    rAcc.BankAccountHolderIdDevice=0;
                    rAcc.BuyerIdDevice=0;
                    rAcc.ParentIdIdDevice=0; 
                    rAcc.account = new Account(CountryRef__c = Test_REST_DataFactoryEast.c.Id,Name='AccountNeww', 
                                               Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), 
                                               idDevice__c=550); 
            paramsAcc.accounts.add(rAcc);
                      
            REST_SendLogicalEntityAccountEast.REST_AccountObject rAccu = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccu.PrimaryDistributorIdDevice=0;
                rAccu.PrimaryPosIdDevice=0;
                rAccu.BankAccountHolderIdDevice=0;
                rAccu.BuyerIdDevice=0;
                rAccu.ParentIdIdDevice=0;
                rAccu.action='Update';
                rAccu.Account=[SELECT Name, Id, Category__c, LastModifiedDate 
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farm.id];
            paramsAcc.accounts.add(rAccu);       
        
           REST_SendLogicalEntityAccountEast.REST_AccountObject rAccd = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccd.PrimaryDistributorIdDevice=0;
                rAccd.PrimaryPosIdDevice=0;
                rAccd.BankAccountHolderIdDevice=0;
                rAccd.BuyerIdDevice=0;
                rAccd.ParentIdIdDevice=0;
                rAccd.action='Delete';
                rAccd.Account=[SELECT Name, Id, CountryRef__c, Category__c, LastModifiedDate
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farmii.id];
            paramsAcc.accounts.add(rAccd);      
       
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>();   
           
              REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCon.action='Insert';
              rCon.AccountIdIdDevice=0;    
              rCon.contact=new Contact(LastName='Jamess',CountryRef__c=Test_REST_DataFactoryEast.c.id,idDevice__c='900',
                                       AccountID=Test_REST_DataFactoryEast.aList.get(6).id);      
        paramsAcc.contacts.add(rCon); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rConu = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rConu.action='Update';
              rConu.AccountIdIdDevice=0;    
              rConu.contact=[SELECT LastName, LastModifiedDate, AccountID, idDevice__c, Id
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(3).id];
        paramsAcc.contacts.add(rConu); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rCond = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCond.action='Delete';
              rCond.AccountIdIdDevice=0;    
              rCond.contact=[SELECT LastName, LastModifiedDate, AccountID, CountryRef__c, idDevice__c, Id
 
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(4).id];     
        paramsAcc.contacts.add(rCond); 

        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);

        //System.AssertEquals(outAccount.statuscode,100);  
        Test.stopTest();                             
    }
     public static testMethod void DMLException2() {
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
            
            paramsAcc.statusCode=null;
            paramsAcc.statusDescription='';
        
            paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        
                REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                    rAcc.action='Insert';
                    rAcc.PrimaryDistributorIdDevice=0;
                    rAcc.PrimaryPosIdDevice=0;
                    rAcc.BankAccountHolderIdDevice=0;
                    rAcc.BuyerIdDevice=0;
                    rAcc.ParentIdIdDevice=0; 
                    rAcc.account = new Account(CountryRef__c = null,Name='AccountNeww', 
                                               Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), 
                                               idDevice__c=550); 
            paramsAcc.accounts.add(rAcc);
                      
            REST_SendLogicalEntityAccountEast.REST_AccountObject rAccu = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccu.PrimaryDistributorIdDevice=0;
                rAccu.PrimaryPosIdDevice=0;
                rAccu.BankAccountHolderIdDevice=0;
                rAccu.BuyerIdDevice=0;
                rAccu.ParentIdIdDevice=0;
                rAccu.action='Update';
                rAccu.Account=[SELECT Name, Id, Category__c, LastModifiedDate 
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farm.id];
            paramsAcc.accounts.add(rAccu);       
        
           REST_SendLogicalEntityAccountEast.REST_AccountObject rAccd = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                rAccd.PrimaryDistributorIdDevice=0;
                rAccd.PrimaryPosIdDevice=0;
                rAccd.BankAccountHolderIdDevice=0;
                rAccd.BuyerIdDevice=0;
                rAccd.ParentIdIdDevice=0;
                rAccd.action='Delete';
                rAccd.Account=[SELECT Name, Id, CountryRef__c, Category__c, LastModifiedDate
                               FROM Account WHERE ID=:Test_REST_DataFactoryEast.Farmii.id];
            paramsAcc.accounts.add(rAccd);      
       
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>();   
           
              REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCon.action='Insert';
              rCon.AccountIdIdDevice=0;    
              rCon.contact=new Contact(LastName='Jamess',CountryRef__c=null,idDevice__c='900',
                                       AccountID='001000000000000');      
        paramsAcc.contacts.add(rCon); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rConu = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rConu.action='Update';
              rConu.AccountIdIdDevice=0;    
              rConu.contact=[SELECT LastName, LastModifiedDate, AccountID, idDevice__c, Id
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(3).id];
        paramsAcc.contacts.add(rConu); 
        
        REST_SendLogicalEntityAccountEast.REST_ContactObject rCond = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCond.action='Delete';
              rCond.AccountIdIdDevice=0;    
              rCond.contact=[SELECT LastName, LastModifiedDate, AccountID, CountryRef__c, idDevice__c, Id
 
                             FROM Contact 
                             WHERE ID=:Test_REST_DataFactoryEast.conList.get(4).id];     
        paramsAcc.contacts.add(rCond); 

        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);

        //System.AssertEquals(outAccount.statuscode,100);  
        Test.stopTest();                             
    }
    }