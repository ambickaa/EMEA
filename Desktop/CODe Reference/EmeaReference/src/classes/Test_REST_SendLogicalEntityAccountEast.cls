@isTest
public class Test_REST_SendLogicalEntityAccountEast{

   public static testMethod void TestSendAccounts() {
    
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();        
        Systemsettings__c s;
        try{
            List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
        }
        catch(Exception e)
        {
            s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
            insert s;
        }

        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        Test.StopTest();
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();

            paramsAcc.statusCode=null;
            paramsAcc.statusDescription='';
        
        
        //*** ACCOUNTS DATA ***
            paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        
                REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                    rAcc.action='Insert';
                    rAcc.PrimaryDistributorIdDevice=0;
                    rAcc.PrimaryPosIdDevice=0;
                    rAcc.BankAccountHolderIdDevice=0;
                    rAcc.BuyerIdDevice=0;
                    rAcc.ParentIdIdDevice=0; 
                    rAcc.account = new Account(CountryRef__c = Test_REST_DataFactoryEast.c.id,Name='AccountNeww', Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), 
                                               idDevice__c=550,City__c='123',StateProvince__c='123',DE_Landkreis__c='123',Micro_Region__c='123',County__c='123',DE_ZIP_PLZ__c='12345'); 
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
       
            
       //*** ACCOUNTS DATA: PARENT & PRIMARY ***
       
       REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc2 = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
                    rAcc2.action='Insert';
                    rAcc2.PrimaryDistributorIdDevice=550;
                    rAcc2.PrimaryPosIdDevice=550;
                    rAcc2.BankAccountHolderIdDevice=0;
                    rAcc2.BuyerIdDevice=900;
                    rAcc2.ParentIdIdDevice=550; 
                    rAcc2.account = new Account(CountryRef__c = Test_REST_DataFactoryEast.c.id,Name='AccountNeww', Category__c='Farm', RecordTypeId=Util.recordType.get('Account:DistRetPoS'), 
                                               idDevice__c=551,City__c='123',StateProvince__c='123',DE_Landkreis__c='123',Micro_Region__c='123',County__c='123',DE_ZIP_PLZ__c='12345'); 
            paramsAcc.accounts.add(rAcc2);
       
       
       //*** CONTACTS DATA ***
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>();   
           
              REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
              rCon.action='Insert';
              rCon.AccountIdIdDevice=550;    
              rCon.contact=new Contact(LastName='Jamess',CountryRef__c=Test_REST_DataFactoryEast.c.id,idDevice__c='900',Street__c='123',StateProvince__c='123',Micro_Region__c='123',County__c='123',City__c='123',DE_Landkreis__c='123',
                                       AccountID=null, DE_Territory_Key__c=Test_REST_DataFactoryEast.TM.id); 
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

        //*** TOUCHPOINTS DATA ***
        paramsAcc.touchpoints = new list<REST_SendLogicalEntityAccountEast.REST_TPPObject>();   
           
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPP.action='Insert';
              rTPP.AccountIdIdDevice=0;    
              rTPP.touchpoint=new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',idDevice__c=111,LKP_ACCOUNT__c=Test_REST_DataFactoryEast.aList.get(6).id); 
        paramsAcc.touchpoints.add(rTPP); 
        
        /*REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP2 = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPP2.action='Insert';
              rTPP2.AccountIdIdDevice=550;    
              rTPP2.touchpoint=new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',idDevice__c=111,LKP_ACCOUNT__c=null); 
        paramsAcc.touchpoints.add(rTPP2); */
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPu = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPu.action='Update';
              rTPPu.AccountIdIdDevice=0;    
              rTPPu.touchpoint=[SELECT Name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(3).id];
        paramsAcc.touchpoints.add(rTPPu); 
        
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPd = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPd.action='Delete';
              rTPPd.AccountIdIdDevice=0;    
              rTPPd.touchpoint=[SELECT Name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(4).id];     
        paramsAcc.touchpoints.add(rTPPd);
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);        
        
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject CoObj : outAccount.contacts){
              System.assertEquals(100,CoObj.statusCode);}
        //System.AssertEquals(outAccount.statuscode,100);
    }
    
    public static testMethod void PrevDel() {
        
       User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
            List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
        }
        catch(Exception e)
        {
            s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
            insert s;
        }

        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        Test.stoptest();
    
        Account FarmTest = new Account(CountryRef__c= Test_REST_DataFactoryEast.c.ID, Name='FarmTestii', Category__c='Farm',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'));
        insert FarmTest;
        Contact ConTest= new Contact(CountryRef__c= Test_REST_DataFactoryEast.c.ID, LastName='Johnson');
        insert ConTest;
        Touchpoint_Program__c TPPTest= new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',LKP_ACCOUNT__c=FarmTest.id);
        insert TPPTest;
    
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
        paramsAcc.statusCode=null;
        paramsAcc.statusDescription='';
        paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>(); 
        paramsAcc.touchpoints= new list<REST_SendLogicalEntityAccountEast.REST_TPPObject>();
        
        REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
        rAcc.action='Delete';
        rAcc.account=Farmtest;    
        paramsAcc.accounts.add(rAcc);

        REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
        rCon.action='Update';
        rCon.AccountIdIdDevice=920;    
        rCon.contact=Contest; 
        rCon.LastModifiedDate=Datetime.valueOf('2017-02-01 17:45:41');
        paramsAcc.contacts.add(rCon); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
        rTPP.action='Update';
        rTPP.AccountIdIdDevice=0;    
        rTPP.touchpoint=TPPtest;
        rTPP.LastModifiedDate=Datetime.valueOf('2017-02-01 17:45:41');
        paramsAcc.touchpoints.add(rTPP);

        
        delete Farmtest;
        delete ConTest;
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);
        System.assertEquals(201,outAccount.statusCode);
        for(REST_SendLogicalEntityAccountEast.REST_AccountObject clio : outAccount.accounts){
              System.assertEquals(201,clio.statusCode);}                       
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject clio : outAccount.contacts){
              System.assertEquals(201,clio.statusCode);} 
    }
    public static testMethod void Mismatch() {
        
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
            List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
        }
        catch(Exception e)
        {
            s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
            insert s;
        }
        
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        
        test.stoptest() ;

        Account FarmTest = new Account(CountryRef__c= Test_REST_DataFactoryEast.c.ID, Name='FarmTestii', Category__c='Farm',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'));
        insert FarmTest;
        Contact ConTest= new Contact(CountryRef__c= Test_REST_DataFactoryEast.c.ID, LastName='Johnson');
        insert ConTest;
        Touchpoint_Program__c TPPTest= new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',LKP_ACCOUNT__c=FarmTest.id);
        insert TPPTest;
    
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount paramsAcc = new REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount();
        paramsAcc.statusCode=null;
        paramsAcc.statusDescription='';
        paramsAcc.accounts = new list<REST_SendLogicalEntityAccountEast.REST_AccountObject>(); 
        paramsAcc.contacts = new list<REST_SendLogicalEntityAccountEast.REST_ContactObject>(); 
        paramsAcc.touchpoints= new list<REST_SendLogicalEntityAccountEast.REST_TPPObject>();
        
        REST_SendLogicalEntityAccountEast.REST_AccountObject rAcc = new REST_SendLogicalEntityAccountEast.REST_AccountObject();     
        rAcc.action='Delete';
        rAcc.account=Farmtest;    
        paramsAcc.accounts.add(rAcc);

        REST_SendLogicalEntityAccountEast.REST_ContactObject rCon = new REST_SendLogicalEntityAccountEast.REST_ContactObject();
        rCon.action='Update';
        rCon.AccountIdIdDevice=920;    
        rCon.contact=Contest; 
        paramsAcc.contacts.add(rCon); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
        rTPP.action='Update';
        rTPP.AccountIdIdDevice=921;    
        rTPP.touchpoint=TPPtest;
        paramsAcc.touchpoints.add(rTPP);
        
        Farmtest.City__c='BCN';
        Contest.City__c='BCN';
        TPPtest.CHK_AGREED__c=true;
        update Farmtest;
        update ConTest;
        update TPPtest;
        
        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);
        System.assertEquals(200,outAccount.statusCode);
        for(REST_SendLogicalEntityAccountEast.REST_AccountObject clio : outAccount.accounts){
              System.assertEquals(200,clio.statusCode);}                       
        for(REST_SendLogicalEntityAccountEast.REST_ContactObject clio : outAccount.contacts){
              System.assertEquals(200,clio.statusCode);}  
    }
    public static testMethod void DMLException() {
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        //system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
            List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
        }
        catch(Exception e)
        {
            s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
            insert s;
        }
        
        
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        
        Test.stopTest();
        
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


        /*paramsAcc.touchpoints = new list<REST_SendLogicalEntityAccountEast.REST_TPPObject>();   
           
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPP.action='Insert';
              rTPP.AccountIdIdDevice=0;    
              rTPP.touchpoint=new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',idDevice__c=111,LKP_ACCOUNT__c=Test_REST_DataFactoryEast.aList.get(6).id); 
        paramsAcc.touchpoints.add(rTPP); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPu = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPu.action='Update';
              rTPPu.AccountIdIdDevice=0;    
              rTPPu.touchpoint=[SELECT name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(3).id];
        paramsAcc.touchpoints.add(rTPPu); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPd = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPd.action='Delete';
              rTPPd.AccountIdIdDevice=0;    
              rTPPd.touchpoint=[SELECT name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(4).id];     
        paramsAcc.touchpoints.add(rTPPd);*/


        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);

        System.AssertEquals(outAccount.statuscode,999);  
                                   
    }
    public static testMethod void DMLException2() {
        User u = new User(Id=Userinfo.getUserId(), CountryISOCode__c='BU');
        update u;
        system.debug('va a buscar: '+Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
        Test.startTest();
        Test_REST_DataFactoryEast.TestData();
        Systemsettings__c s;
        try{
            List<Systemsettings__c> mcs = Systemsettings__c.getall().values();
            mcs[0].value__c = 'all';
            update mcs;
        }
        catch(Exception e)
        {
            s = new Systemsettings__c(name='EAST_REST_SVC_JSON_SAVE', value__c ='all');
            insert s;
        }
        
        
        Systemsettings__c s2 = new Systemsettings__c(name='BU_REST_LOG_FOLDER', value__c ='BulgariaLogs');
        insert s2;
        
        Test.stopTest();
        
        System.debug(Limits.getQueries());
        system.debug('enter log');
        
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


        paramsAcc.touchpoints = new list<REST_SendLogicalEntityAccountEast.REST_TPPObject>();   

        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPP = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPP.action='Insert';
              rTPP.AccountIdIdDevice=0;    
              rTPP.touchpoint=new Touchpoint_Program__c(LKP_YEAR__c = Test_REST_DataFactoryEast.Year.id,PICK_TOUCHPOINT_PROG__c='DEMO',idDevice__c=111,LKP_ACCOUNT__c=Test_REST_DataFactoryEast.aList.get(6).id); 
        paramsAcc.touchpoints.add(rTPP); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPu = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPu.action='Update';
              rTPPu.AccountIdIdDevice=0;    
              rTPPu.touchpoint=[SELECT name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(3).id];
        paramsAcc.touchpoints.add(rTPPu); 
        
        REST_SendLogicalEntityAccountEast.REST_TPPObject rTPPd = new REST_SendLogicalEntityAccountEast.REST_TPPObject();
              rTPPd.action='Delete';
              rTPPd.AccountIdIdDevice=0;    
              rTPPd.touchpoint=[SELECT name, PICK_TOUCHPOINT_PROG__c, LastModifiedDate, LKP_ACCOUNT__c, idDevice__c 
                                FROM Touchpoint_Program__c
                                WHERE ID=:Test_REST_DataFactoryEast.tppList.get(4).id];     
        paramsAcc.touchpoints.add(rTPPd); 


        REST_SendLogicalEntityAccountEast.REST_SendLogicalEntityAccount outAccount= REST_SendLogicalEntityAccountEast.sendAccounts(paramsAcc);
        //outAccount.ErrorDescription('ERROR_STATUS_CHANGE_NOT_ALLOWED');
        
        System.AssertEquals(outAccount.statuscode,999);                          
    }
    }