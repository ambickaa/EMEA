@isTest
public class Test_REST_LogicalEntityActivity{
 
    public static testmethod void DeleteTest(){
        /* Insert of database background */ 
        Datetime timestamp=System.now();
		User usr = [Select id, name, CountryISOCode__c  from User where id=:UserInfo.getUserId() Limit 1];        
        Country__c country = new Country__c(Name ='HQ', TacticalPlanSetting__c = 'Standard');      
        insert country;
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1)); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1),
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        SystemSettings__c systemsetting = new SystemSettings__c(Name=usr.CountryISOCode__c+'_TPP_TRIGGER',Value__C='1#1#1');
        insert systemsetting;
        Account account = new Account (CountryRef__c=country.Id, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), Category__c='Farm');
        insert account;
        Contact contact= new Contact(FirstName='Pablo', LastName='Mora', CountryRef__c=country.Id, AccountId=account.id);
        insert contact;
        Touchpoint_Program__c touchpoint = new Touchpoint_Program__c(LKP_ACCOUNT__c= account.id, LKP_YEAR__c=year.Id,LKP_CROP__c=divi.id,CHK_AGREED__c=false,CHK_PLAN__c=false,CHK_COMPLETED__c=false,DAT_PLAN__c=system.today());
        insert touchpoint;
        SystemSettings__c s1 = new SystemSettings__c( Name='NUM_MONTHS_EVENTS_IPAD',Value__C='6');
        insert s1;
        Task task =new Task(WhatId = account.id, WhoId=contact.Id, Subject='Call', Status='New', Priority='Normal',ActivityDate=Date.today(), LKP_TOUCHPOINT_PROG__c=touchpoint.Id);
        insert task;
        Event event =new Event(WhatId = account.id, DurationInMinutes=5, WhoId=contact.Id, Subject='Vacation', ActivityDateTime=System.now(),ActivityDate=Date.today(),LKP_TOUCHPOINT_PROG__c=touchpoint.Id, Agreed__c=false,Completed__c=false,Plan__c=false);
        insert event;
        Case casex = new Case (AccountId=account.Id, ContactId=contact.Id, Subject='testSubject', Description='description', GC_Resolution_Text__c='Valid Support',GC_Functional_Area_Descr__c='Cases', Type='Bug',Status='Closed' );
        insert casex;
        
        test.startTest();
       
        Task task2 =new Task(WhatId = account.id, WhoId=contact.Id, Subject='Call', Status='New', Priority='Normal', ActivityDate=Date.today(),LKP_TOUCHPOINT_PROG__c=touchpoint.Id,Agreed__c=false,Completed__c=false,Plan__c=false);
        insert task2;
        
        delete task;
        delete event;
        
        List<Task> taskToCheck= new List<Task>{task,task2};
        List<Event> eventToCheck= new List<Event>{event};
        List<Case> caseToCheck= new List<Case>();
        REST_DelLogicalEntityActivity.REST_DelLogicalEntity_Activity paramInfo = new REST_DelLogicalEntityActivity.REST_DelLogicalEntity_Activity();
        paramInfo.tasks=taskToCheck;
        paramInfo.events=eventToCheck;
        paramInfo.cases=caseToCheck;
        
        REST_DelLogicalEntityActivity.REST_DelLogicalEntity_Activity returned= REST_DelLogicalEntityActivity.getDeletedActivities(paramInfo);
        
        Set<Task> taskReturned=new set<Task>();
        taskReturned.addAll(returned.tasks);
        Set<Event> eventReturned =new set<Event>();
        eventReturned.addAll(returned.events);
        
        test.stopTest();
        System.assert(taskReturned.contains(task));
        System.assert(!taskReturned.contains(task2));
        System.assert(eventReturned.contains(event));
        }
    
    public static testmethod void Test_LogicalEntityActivity(){
        /* Insert of database background */ 
        Datetime timestamp=System.now();
		User usr = [Select id, name, CountryISOCode__c  from User where id=:UserInfo.getUserId() Limit 1];
        Country__c country = new Country__c(Name ='HQ', TacticalPlanSetting__c = 'Standard');      
        insert country;
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1)); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1),
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        SystemSettings__c systemsetting = new SystemSettings__c(Name=usr.CountryISOCode__c+'_TPP_TRIGGER',Value__C='1#1#1');
        insert systemsetting;
        Account account = new Account (CountryRef__c=country.Id, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), Category__c='Farm');
        insert account;
        Contact contact= new Contact(FirstName='Pablo', LastName='Mora', CountryRef__c=country.Id, AccountId=account.id);
        insert contact;
        Touchpoint_Program__c touchpoint = new Touchpoint_Program__c(LKP_ACCOUNT__c= account.id, LKP_YEAR__c=year.Id,LKP_CROP__c=divi.id,CHK_AGREED__c=false,CHK_PLAN__c=false,CHK_COMPLETED__c=false,DAT_PLAN__c=system.today());
        insert touchpoint;
        SystemSettings__c s1 = new SystemSettings__c( Name='NUM_MONTHS_EVENTS_IPAD',Value__C='6');
        insert s1;
        Task task =new Task(WhatId = account.id, WhoId=contact.Id, Subject='Call', Status='New', Priority='Normal',ActivityDate=Date.today(),LKP_TOUCHPOINT_PROG__c=touchpoint.Id);
        insert task;
        Event event =new Event(WhatId = account.id, DurationInMinutes=5, WhoId=contact.Id, Subject='Vacation', ActivityDateTime=System.now(),ActivityDate=Date.today(),LKP_TOUCHPOINT_PROG__c=touchpoint.Id,Agreed__c=false,Completed__c=false,Plan__c=false);
        insert event;
        Case casex = new Case (AccountId=account.Id, ContactId=contact.Id, Subject='testSubject', Description='description', GC_Resolution_Text__c='Valid Support',GC_Functional_Area_Descr__c='Cases', Type='Bug',Status='Closed' );
        insert casex;
        
        test.startTest();
       
        Task task2 =new Task(WhatId = account.id, WhoId=contact.Id, Subject='Call', Status='New', Priority='Normal', ActivityDate=Date.today(),LKP_TOUCHPOINT_PROG__c=touchpoint.Id,Agreed__c=false,Completed__c=false,Plan__c=false);
        insert task2;
        
        delete task;
        delete event;
        
        List<Task> taskToCheck= new List<Task>{task,task2};
        List<Event> eventToCheck= new List<Event>{event};
        List<Case> caseToCheck= new List<Case>();
        DateTime b = System.now();
        REST_LogicalEntityActivity.REST_LogicalEntity_Activity paramInfo = new REST_LogicalEntityActivity.REST_LogicalEntity_Activity(b);
		REST_Request paramInfo2 = new REST_Request();
        REST_LogicalEntityActivity.getActivities(paramInfo2);
        paramInfo.tasks=taskToCheck;
        paramInfo.events=eventToCheck;
        paramInfo.cases=caseToCheck;

        
        test.stopTest();
        }
}