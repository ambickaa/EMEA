@isTest

public class test_NPSDashboard
{
    /*
        Class to test all the functionality from NPS Dashboard chart controller. 
        One function for case based charts and another one for task ones.
    */
    NPSDashboardChartsController dcc = new NPSDashboardChartsController();
    
    private static testmethod void NPScaseCharts1()
    {
        NPSDashboardChartsController dcc = new NPSDashboardChartsController();
        

        Test.startTest();
        // pageReference methods //
        dcc.filterYear();
        dcc.filterCountry();
        dcc.filterDiv();
        dcc.filterMonth();
        dcc.filterTouch();
        // end pageReference methods //
        String a = dcc.xlsHeader;
        a = dcc.selSegment;
        a = dcc.selStartDate;
        Date b = dcc.selEndDate;
        Event c = dcc.act;
 		List<Case> listCaseExport = dcc.listaCasosExport;       
        List<Task> listTaskExport = dcc.listaTasksExport; 
        NPSDashboardChartsController.campainFilters('2015', 'Corn', 'Spain', '2', '2015-01-09', '2015-12-25');
        NPSDashboardChartsController.caseFilters('2015', 'Corn', 'Spain', '2', '2015-01-09', '2015-12-25');
        NPSDashboardChartsController.taskFilters('2015', 'Corn', 'Spain', '2', '2015-01-09', '2015-12-25');
        listCaseExport = NPSDashboardChartsController.surveyResultsExport('2015', 'Corn', 'Spain', '2', '2015-01-09', '2015-12-25');
        listTaskExport = NPSDashboardChartsController.callsStatusExport('2015', 'Corn', 'Spain', '2', '2015-01-09', '2015-12-25');
        Test.stopTest();
        
    } 
   
    //---------------------------------------------------------------------------------------------    
    private static testmethod void NPSpageMethods()
    {
        NPSDashboardChartsController dcc = new NPSDashboardChartsController();
        
        List<SelectOption> year = new List<SelectOption>();
       	List<SelectOption> div = new List<SelectOption>();
        List<SelectOption> tc = new List<SelectOption>();
        List<SelectOption> ctr = new List<SelectOption>();
        List<SelectOption> mth = new List<SelectOption>();
        
        List<NPSDashboardChartsController.dataContainer > scoreFarmTest = new List<NPSDashboardChartsController.dataContainer>();
        
        // SelectOption methods //
        year = dcc.getYRoptions();
        div = dcc.getDVoptions(); 
        tc = dcc.getTCoptions();
        ctr = dcc.getCTRoptions();
        mth = dcc.getMTHoptions();
        // end selectOption methods //

        scoreFarmTest = NPSDashboardChartsController.scoreFarm('2015', 'Corn', 'testCountry', '2', '', '');
        scoreFarmTest = NPSDashboardChartsController.surveyResultsSecCauseTable('2015', 'Corn', 'testCountry', '2', '', '');
        scoreFarmTest = NPSDashboardChartsController.scorePerYear('2015', 'Corn', 'testCountry', '2', '', '');
    }
    
    
    private static testmethod void NPSexports()
    {
        
        RecordType rtCampaign = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'NPS' LIMIT 1];
        RecordType rtCase = [SELECT Id, Name, SobjectType FROM RecordType WHERE Name = 'Survey Result' LIMIT 1];
        Country__c country = new Country__c(name='testCountry');
        insert country;
        Division__c div = new Division__c(name='Corn');
        insert div;
        Year__c year = new Year__c(name='2015');
        insert year;
        Account ac = new Account();
        ac.Name = 'TestAccount';
        ac.Category__c = 'Farm';
        ac.GC_Status_Descr__c = 'Active';
        ac.CountryRef__c = country.Id;
        insert ac;
        Contact contact1 = new Contact(lastName='testContact', Account=ac, email='testemailContact@asdfasdfasdf.com', countryref__c=country.Id);
        insert contact1;
        Campaign campaign = new Campaign(RecordTypeId = rtCampaign.Id, Name='testCamp', TXT_Farm_Size__c = 'Medium', DivisionRef__c=div.Id, CountryRef__c=country.id, YearV2__c=year.id, TXT_Wave__c='2', TXT_Local_segment__c='-',StartDate=date.newInstance(2015, 1, 7), EndDate=date.newInstance(2015, 12, 25));
        insert campaign;   
        Case cas1 = new Case(RecordTypeId = rtCase.Id, NPS_CAMPAIGN__c=campaign.id, ContactId = contact1.Id, NPS_RESULT_Q1__c=9, NPS_Country__c=country.name, AccountId = ac.Id, Status = 'New', NPS_RESULT_Q4__c='YES', NPS_INTERVIEW_START__c=datetime.newInstance(2015, 7, 20), NPS_INTERVIEW_END__c=datetime.newInstance(2015, 8, 4));
        insert cas1;
        Case cas2 = new Case(RecordTypeId = rtCase.Id, NPS_CAMPAIGN__c=campaign.id, ContactId = contact1.Id, NPS_RESULT_Q1__c=4, NPS_Country__c=country.name, AccountId = ac.Id, Status = 'New', NPS_RESULT_Q4__c='YES', NPS_INTERVIEW_START__c=datetime.newInstance(2015, 7, 20), NPS_INTERVIEW_END__c=datetime.newInstance(2015, 8, 4));
        insert cas2;
        task t1=[SELECT status, DAT_COMPLETED_DATE__c, FRML_DAYS_TO_CLOSE__c, LKP_NPS_Case__r.NPS_Country__c FROM task WHERE (LKP_NPS_Case__c =: cas1.Id)];
        task t2=[SELECT status, DAT_COMPLETED_DATE__c, FRML_DAYS_TO_CLOSE__c, LKP_NPS_Case__r.NPS_Country__c FROM task WHERE (LKP_NPS_Case__c =: cas2.Id)];
        
        Test.setCurrentPageReference(new PageReference('Page.NPS_Dashboard_Export')); 
        System.currentPageReference().getParameters().put('paramDash', '1'); 
        System.currentPageReference().getParameters().put('paramExcel', '1'); 
        System.currentPageReference().getParameters().put('paramYear', '-'); 
        System.currentPageReference().getParameters().put('paramDivision', '-'); 
        System.currentPageReference().getParameters().put('paramCountry', '-'); 
        System.currentPageReference().getParameters().put('paramTouch', '-'); 
        System.currentPageReference().getParameters().put('paramstartDate', ''); 
        System.currentPageReference().getParameters().put('paramendDate', '');
            
        NPSDashboardChartsController dcc = new NPSDashboardChartsController();
        
        Test.setCurrentPageReference(new PageReference('Page.NPS_Dashboard_Export')); 
        System.currentPageReference().getParameters().put('paramDash', '2'); 
        System.currentPageReference().getParameters().put('paramExcel', '1'); 
        System.currentPageReference().getParameters().put('paramYear', '-'); 
        System.currentPageReference().getParameters().put('paramDivision', '-'); 
        System.currentPageReference().getParameters().put('paramCountry', '-'); 
        System.currentPageReference().getParameters().put('paramTouch', '-'); 
        System.currentPageReference().getParameters().put('paramstartDate', ''); 
        System.currentPageReference().getParameters().put('paramendDate', '');
            
        NPSDashboardChartsController dcc2 = new NPSDashboardChartsController();
    }  
}