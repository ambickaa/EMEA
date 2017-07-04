@isTest
private class Test_Everis_ACS_Deploy_1
{
    public static RecordType accountRecordType;
    
    static void init()
    {
        accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
        
        SystemSettings__c setting = new SystemSettings__c();
        setting.Name = 'EAST_REST_SVC_JSON_SAVE';
        setting.Value__c = 'all';
        insert setting;
        
        SystemSettings__c setting2 = new SystemSettings__c();
        setting2.Name = 'SP_REST_LOG_FOLDER';
        setting2.Value__c = 'SpainLogs';
        insert setting2;
             
    }     

    static testMethod void UnitTest_TriggerAccountDuplicateBlocker() 
    {
        init();
        
        Country__c c = new Country__c(Name = 'france');
        insert c;
        
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, Country = 'france');
        update u;        

        Account acc1 = new Account(Name = 'testAccount1', CountryRef__c = c.Id, Category__c = 'Distributor', recordTypeId = accountRecordType.Id);
        insert acc1;

        Account acc2 = new Account(Name = 'testAccount1', CountryRef__c = c.Id, Category__c = 'Distributor', recordTypeId = accountRecordType.Id);
        insert acc2;
    
    }
    
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_Insert()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u; 
        
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        Country__c c = new Country__c(Name = 'france');
        insert c;
        
        //Account
        account acc = new Account(CountryRef__c = c.id, Name='AccountNeww', Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), idDevice__c=550); 
        insert acc;
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';
        e.WhatId = acc.Id;
        
        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'insert';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;
        
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Insert';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct);
    }
    
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_Update()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u; 
        
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';
        insert e;
        
        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'Update';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;
        
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        insert t;
        
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Update';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct);
    }
    
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_Update2()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u; 
        
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';
        
        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'Update';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;
        
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Update';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct);
    }
    
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_Delete()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u; 
        
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';
        
        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'Delete';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;
        
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Delete';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct);
    }
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_previousDeleted()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u;
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name='ES_Sales Representative CP'];
        User u2 = new User(Alias = 'testuser', CountryISOCode__c = 'SP', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testfullbox.com');     */   
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        //Country
        Country__c c = new Country__c(Name = 'france');
        insert c;
        
        //Account
        account acc = new Account(CountryRef__c = c.id, Name='AccountNeww', Category__c='Farm', RecordTypeId=Util.recordType.get('Account:GroupFarmSite'), idDevice__c=550); 
        insert acc;
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';
        e.WhatId = acc.Id;
        insert e;
        delete e;
            
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        t.whatId = acc.Id;
        insert t;
        delete t;

        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'Delete';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;   
    
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Delete';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct); 
    }
    
    static testMethod void UnitTest_REST_SendLogicalEntityActivity_DMLException()
    {
        Id uID = UserInfo.getUserId();
        User u = new User(Id = uID, CountryISOCode__c = 'SP');
        update u;
       
        init();       
        
        List<REST_SendLogicalEntityActivity.REST_TaskObject> listTasks = new List<REST_SendLogicalEntityActivity.REST_TaskObject>();
        List<REST_SendLogicalEntityActivity.REST_eventObject> listEvents = new List<REST_SendLogicalEntityActivity.REST_eventObject>();
        
        //Events
        Event e = new Event();
        e.OwnerId = UserInfo.getUserId();
        //e.Subject = 'Llamada Telefónica';
        e.IsAllDayEvent = true;
        e.ActivityDate = Date.today();
        e.TXT_Comments_Copy__c = '';        
            
        //Tasks
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Call';
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.idDevice__c = 1;
        insert t;
                
        REST_SendLogicalEntityActivity.REST_eventObject paramEvt = new REST_SendLogicalEntityActivity.REST_eventObject();
        paramEvt.action = 'Insert';
        paramEvt.statusCode = null;
        paramEvt.statusDescription = '';
        paramEvt.LastModifiedDate = null;
        paramEvt.event = e;   
    
        REST_SendLogicalEntityActivity.REST_TaskObject paramTsk = new REST_SendLogicalEntityActivity.REST_TaskObject();
        paramTsk.action = 'Insert';
        paramTsk.statusCode = null;
        paramTsk.statusDescription = '';
        paramTsk.LastModifiedDate = null;
        paramTsk.task = t;
        
        listTasks.add(paramTsk);
        listEvents.add(paramEvt);        
        
        REST_SendLogicalEntityActivity.REST_ActivityObject paramAct = new REST_SendLogicalEntityActivity.REST_ActivityObject();
        paramAct.statusCode = null;
        paramAct.statusDescription = '';
        paramAct.tasks = listTasks;
        paramAct.events = listEvents;
        
        REST_SendLogicalEntityActivity.REST_ActivityObject returned = REST_SendLogicalEntityActivity.sendActivities(paramAct);  
    }
}