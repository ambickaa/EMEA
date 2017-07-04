@isTest
public class Test_REST_DataFactoryEvent {
    
    public static REST_SendLogicalEntityEvent.REST_EventObject eventForTest { get; set; }
    public static REST_SendLogicalEntityEvent.REST_LeadObject leadForTest { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_AccountObject accountForTest { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_AccountObject accountForTest2 { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_AccountObject accountForTest3 { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_AccountObject accountForTest4 { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_AccountObject accountForTest5 { get; set; } 
    public static REST_SendLogicalEntityEvent.REST_ContactObject contactForTest { get; set; }
    public static REST_SendLogicalEntityEvent.REST_ContactObject contactForTest2 { get; set; }
    public static REST_SendLogicalEntityEvent.REST_SurveyAnswerObject surveyAnswerForTest { get; set; }
    public static REST_SendLogicalEntityEvent.REST_SurveyAnswerObject surveyAnswerForTest2 { get; set; }
    public static REST_SendLogicalEntityEvent.REST_FeedbackObject feedbackForTest { get; set; }
    public static Campaign event {get; set;}
    
    public static void createOneRESTLead()
    {
        Lead testLead1=new lead(lastname='testLead1', company = 'companyLeadTest',status='Open', CHK_Consent_Accept_Terms__c = true);
        insert testLead1;
        leadForTest = new REST_SendLogicalEntityEvent.REST_LeadObject();
        leadForTest.lead=new lead(lastname='testLead2', company = 'companyLeadTest',status='Open', CHK_Consent_Accept_Terms__c = true);
        
        
       
    }
    
    public static void createOneRESTAccount()
    {
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
        country__c countTest=new country__c(name='TestCount');
        Account testAccount1=new Account(RecordType=rt,Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56);
        insert testAccount1;
        accountForTest = new REST_SendLogicalEntityEvent.REST_AccountObject();
        accountForTest.account=testAccount1;
        
        Account testAccount2=new Account(RecordType=rt,Name='Account2',Category__c='asdfg',GC_Status_Descr__c='asdx',CountryRef__c=countTest.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56,TotalOtherAcreagesManualCY__c=100);
        insert testAccount2;
        testAccount2.CornTotalAcreagesCY__c=50;
        accountForTest2 = new REST_SendLogicalEntityEvent.REST_AccountObject();
        accountForTest2.account=testAccount2;
        
        Account testAccount3=new Account(RecordType=rt,Name='Account3',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56,TotalOtherAcreagesManualCY__c=100);
        insert testAccount3;
        testAccount3.CornTotalAcreagesCY__c=50;
        testAccount3.OSRTotalAcreagesCY__c=20;
        accountForTest3 = new REST_SendLogicalEntityEvent.REST_AccountObject();
        accountForTest3.account=testAccount3;
        
        Account testAccount4=new Account(RecordType=rt,Name='Account4',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56,TotalOtherAcreagesManualCY__c=100);
        insert testAccount4;
        testAccount4.CornTotalAcreagesCY__c=50;
        testAccount4.OSRTotalAcreagesCY__c=20;
        testAccount4.CornDekalbMarketShareCY__c=150;
        accountForTest4 = new REST_SendLogicalEntityEvent.REST_AccountObject();
        accountForTest4.account=testAccount4;

        Account testAccount5=new Account(RecordType=rt,Name='Account5',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id,CornTotalAcreagesCY__c=40,OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50,OSRDekalbMarketshareCY__c=56,TotalOtherAcreagesManualCY__c=100);
        insert testAccount5;
        testAccount5.CornTotalAcreagesCY__c=50;
        testAccount5.OSRTotalAcreagesCY__c=20;
        testAccount5.CornDekalbMarketShareCY__c=150;
        testAccount5.totalAcreagesCY__c=52;
        
        accountForTest5 = new REST_SendLogicalEntityEvent.REST_AccountObject();
        accountForTest5.account=testAccount5;        
    }
    
    public static void createOneRESTContact()
    {
        RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
         country__c countTest=new country__c(name='TestCount');
        Account testAcc2=new Account(RecordType=rt,Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id); 
        insert testAcc2;
        
        Contact testContact1=new Contact(lastName='testContact1',Account=testAcc2);
        contactForTest = new REST_SendLogicalEntityEvent.REST_ContactObject();
        contactForTest.contact=testContact1;
        
        Contact testContact2=new Contact(lastName='testContact2',Account=testAcc2);
        insert testContact2;
        testContact2.Address_Door__c='43';
        contactForTest2 = new REST_SendLogicalEntityEvent.REST_ContactObject();
        contactForTest2.contact=testContact2;
    }
    
    public static void createOneRESTSurveyAnswer()
    {
         RecordType rt=[Select id,Name from RecordType where SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];
         country__c countTest=new country__c(name='TestCount');
        RecordType rt2=[Select id,Name from RecordType where SobjectType='Campaign' and Name='Sales Campaign' limit 1];            
        campaign campTest=new campaign(RecordType=rt2,name='CampTest',CountryRef__c=countTest.id);
        insert campTest;         
        event = campTest;
        
        Event_Question__c question = new Event_question__c(txt_question__c='question1', LKP_event__c =event.Id);
        insert question;
        Event_Answer__c answer = new Event_Answer__c (txt_answer__c='question1', LKP_question__c = question.Id);
        insert answer;
        
        Lead tLead1=new lead(lastname='tLead1', company = 'companyLeadTest',status='Open', CHK_Consent_Accept_Terms__c = true);  
        insert tLead1;
        Account testAcc3=new Account(RecordType=rt,Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=countTest.id); 
        insert testAcc3;
        Contact testContact3=new Contact(lastName='testContact2',Account=testAcc3);
        insert testContact3;
        Event_Survey_Answer__c testSurvey1=new Event_Survey_Answer__c(LKP_Event__c=CampTest.Id,TXT_Text_Answer__c='Answer for test',LKP_Lead__c=tLead1.Id);
        surveyAnswerForTest = new REST_SendLogicalEntityEvent.REST_SurveyAnswerObject();    
        surveyAnswerForTest.surveyAnswer=testSurvey1;
        Event_Survey_Answer__c testSurvey2=new Event_Survey_Answer__c(LKP_Event__c=CampTest.Id,TXT_Text_Answer__c='Answer for test',LKP_Lead__c=tLead1.Id,LKP_Contact__c=testContact3.id);
        surveyAnswerForTest2 = new REST_SendLogicalEntityEvent.REST_SurveyAnswerObject();    
        surveyAnswerForTest2.surveyAnswer=testSurvey2;
    }
    public static void createOneRESTFeedback()
    {
        RecordType rt3=[Select id,Name from RecordType where SobjectType='Campaign' and Name='Sales Campaign' limit 1];
        campaign tCampaign=new campaign(name='tCampaign',RecordType=rt3,CountryRef__c='a0CL000000C6gYy');
        
        
        Event_Feedback__c testFeedback1=new Event_Feedback__c(PICK_Rate__c='Yellow',LKP_Event__c=tCampaign.Id);
        feedbackForTest = new REST_SendLogicalEntityEvent.REST_FeedbackObject();    
        feedbackForTest.feedback=testFeedback1;
    }
    
    public static void createOneRESTEvent()
    {   

        eventForTest = new REST_SendLogicalEntityEvent.REST_EventObject();
        eventForTest.statusCode=0;
        eventForTest.statusDescription='Unprocessed';
        eventForTest.eventId=event.Id;
        
        
        List<REST_SendLogicalEntityEvent.REST_LeadObject> leadsT=new list<REST_SendLogicalEntityEvent.REST_LeadObject>();
        List<REST_SendLogicalEntityEvent.REST_AccountObject> accsT=new list<REST_SendLogicalEntityEvent.REST_AccountObject>();
        List<REST_SendLogicalEntityEvent.REST_ContactObject> contactsT=new list<REST_SendLogicalEntityEvent.REST_ContactObject>();
        List<REST_SendLogicalEntityEvent.REST_SurveyAnswerObject> surveysT=new list<REST_SendLogicalEntityEvent.REST_SurveyAnswerObject>();
        List<REST_SendLogicalEntityEvent.REST_FeedbackObject> feedbacksT=new list<REST_SendLogicalEntityEvent.REST_FeedbackObject>();
        
        leadsT.add(leadForTest);
        accsT.add(accountFortest);
        accsT.add(accountFortest2);
        accsT.add(accountFortest3);
        accsT.add(accountFortest4);
        accsT.add(accountFortest5);
        contactsT.add(contactFortest);
        contactsT.add(contactFortest2);
        surveysT.add(surveyAnswerFortest);
        surveysT.add(surveyAnswerFortest2);
        feedbacksT.add(feedbackFortest);
        
        eventForTest.leads=leadsT;
        eventForTest.accounts=accsT;
        eventForTest.contacts=contactsT;
        eventForTest.surveys=surveysT;
        eventForTest.feedbacks=feedbacksT;
      
    }
    public static void SetSystemSettings(string value)
    {
        User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs( thisUser )
        {
            
            systemSettings__c settings = systemSettings__c.getInstance('EAST_REST_SVC_JSON_SAVE');
            systemSettings__c settings2 = systemSettings__c.getInstance(Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER');
            if(settings2 == null) 
            {
                settings2 = new systemSettings__c();
                settings2.Name = Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER';
                settings2.Value__c='SpainLogs';
                
                insert settings2;
            }
            if(settings == null) 
            {
                settings = new systemSettings__c();
                settings.Name = 'EAST_REST_SVC_JSON_SAVE';
                settings.Value__c='all';       
                insert settings;
            } else if(value=='Exception')
            {
                settings.Value__c=value;
                update settings;                
            }         
        }
    }
}