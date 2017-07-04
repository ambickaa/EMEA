global with sharing class NPSDashboardChartsController
{

public String selYear {get; set;}
public String selMonth {get; set;}
public String selDiv {get; set;}
public String selTouch {get; set;}
public String selCountry {get; set;}
public String selSegment {get; set;}
public String selStartDate{get; set;}
public Date selEndDate{get; set;}
public Event act{get;set;}
public String fileName{get;set;}

public static final String recordTypeId = '012D00000003Bof';
public static final String recordTypeCampaign = '012D00000003Bnh';

  // Listas de Casos
public transient List<Case> listaCasosExport{get;set;} 
public transient List<dataContainer> listaSurveyResults{get;set;}
public transient List<dataContainer> listaType{get;set;}
public transient List<dataContainer> listaCallsTasks{get;set;}
public transient List<dataContainer> listaScore{get;set;}
public transient List<dataContainer> listaScoreSegment{get;set;}
public transient List<dataContainer> listaScoreFarm{get;set;}
public transient List<dataContainer> listaCauseTable{get;set;}

  // Listas de Tasks
public transient List<Task> listaTasksExport{get;set;}
public transient List<dataContainer> listaCallsStatus{get;set;}
public transient List<dataContainer> listaDaysClose{get;set;}
public transient List<dataContainer> listaDaysClosePerc{get;set;}
public transient List<dataContainer> listaAvgDaysOpen{get;set;}

public ApexPages.StandardSetController cont{get; set;}    

public String xlsHeader {
        get {
String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    } 

 public NPSDashboardChartsController(){
        selYear = '-';
        selMonth = '-';
        selDiv = '-';
        selTouch = '-';
        selCountry = '-';
        
        String excel= ApexPages.currentPage().getParameters().get('paramExcel');
        String numDash= ApexPages.currentPage().getParameters().get('paramDash');
        String year = ApexPages.currentPage().getParameters().get('paramYear') == null ? '-' : ApexPages.currentPage().getParameters().get('paramYear');
        String div = ApexPages.currentPage().getParameters().get('paramDiv') == null ? '-' : ApexPages.currentPage().getParameters().get('paramDiv');
        String country = ApexPages.currentPage().getParameters().get('paramCountry') == null ? '-' : ApexPages.currentPage().getParameters().get('paramCountry');
        String touch = ApexPages.currentPage().getParameters().get('paramTouch') == null ? '-' : ApexPages.currentPage().getParameters().get('paramTouch');
        String startDate = ApexPages.currentPage().getParameters().get('paramStartDate') == null ? '' : ApexPages.currentPage().getParameters().get('paramStartDate');
        String endDate = ApexPages.currentPage().getParameters().get('paramEndDate') == null ? '' : ApexPages.currentPage().getParameters().get('paramEndDate');
        
        
        if(excel=='1')
        {
            if(numDash=='1')
            {
                fileName='NPSExportSurveyResults'+(country=='-'?'':('_'+country))+(year=='-'?'':('_'+year))+(div=='-'?'':('_'+div))+(touch=='-'?'':('_'+touch))+(startDate==''?'':('_'+startDate))+(endDate==''?'':('_'+endDate));
                listaSurveyResults = surveyResults(year, div , country, touch , startDate, endDate);
                listaType = type(year, div , country, touch , startDate, endDate);
                listaCallsTasks = CallsTasks(year, div , country, touch , startDate, endDate);
                listaScore = score(year, div , country, touch , startDate, endDate);
                listaScoreSegment = scoreSegment(year, div , country, touch , startDate, endDate);
                listaScoreFarm = scoreFarm(year, div , country, touch , startDate, endDate);
                listaCauseTable = surveyResultsCauseTable(year, div , country, touch , startDate, endDate);
                
            }
            
            else if(numDash=='2')
            {
                fileName='NPSExportFollowUpCalls'+(country=='-'?'':('_'+country))+(year=='-'?'':('_'+year))+(div=='-'?'':('_'+div))+(touch=='-'?'':('_'+touch))+(startDate==''?'':('_'+startDate))+(endDate==''?'':('_'+endDate));
                listaCallsStatus = callsStatus(year, div , country, touch , startDate, endDate);
                listaDaysClose = daysClose(year, div , country, touch , startDate, endDate);
                listaDaysClosePerc = daysClosePerc(year, div , country, touch , startDate, endDate);
                listaAvgDaysOpen = avgDaysOpen(year, div , country, touch , startDate, endDate);
                
            }
        }                        
    }
    
    
 public List<SelectOption> getYRoptions() {
        List<SelectOption> options = new List<SelectOption>();
     options.add(new SelectOption('-', '-'));
     options.add(new SelectOption(string.valueof(2014), string.valueof(2014)));
     options.add(new SelectOption(string.valueof(2015), string.valueof(2015)));
     options.add(new SelectOption(string.valueof(2016), string.valueof(2016)));
    return options;
    }
    
  public PageReference filterYear() {
                
        return null;
    }

 public List<SelectOption> getDVoptions() {
        List<SelectOption> options = new List<SelectOption>();
     options.add(new SelectOption('-', '-'));
     options.add(new SelectOption('Corn', 'Corn'));
     options.add(new SelectOption('OSR', 'OSR'));
    return options;
    }
    
    public PageReference filterDiv() {
                
        return null;
    }
    
    public List<SelectOption> getTCoptions() {
        List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('-', '-'));
    options.add(new SelectOption(string.valueof(1), string.valueof(1)));
    options.add(new SelectOption(string.valueof(2), string.valueof(2)));
    options.add(new SelectOption(string.valueof(3), string.valueof(3)));
    return options;
    }
    
    public PageReference filterTouch() {
                
        return null;   
    }
    
    public List<SelectOption> getCTRoptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-', '-'));
        String queryDefinition = 'SELECT NPS_Country__c name FROM Case WHERE  recordtypeid=\''+recordTypeId +'\'';
        queryDefinition += ' GROUP BY NPS_Country__c';
        
        AggregateResult[] ARs = Database.query(queryDefinition);
        
        for(AggregateResult surveyResultItem : ARs){
            options.add(new SelectOption((String)surveyResultItem.get('name'), (String)surveyResultItem.get('name')));
        }
        
        return options;    
    }    
    
    public PageReference filterCountry() {
                
        return null;   
    }
    
    public List<SelectOption> getMTHoptions() {
        List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('-', '-'));
            options.add(new SelectOption('1', 'January'));
            options.add(new SelectOption('2', 'February'));
            options.add(new SelectOption('3', 'March'));
            options.add(new SelectOption('4', 'April'));
            options.add(new SelectOption('5', 'May'));
            options.add(new SelectOption('6', 'June'));
            options.add(new SelectOption('7', 'July'));
            options.add(new SelectOption('8', 'August'));
            options.add(new SelectOption('9', 'September'));
            options.add(new SelectOption('10', 'October'));
            options.add(new SelectOption('11', 'November'));
            options.add(new SelectOption('12', 'December'));
     
    return options;    
    }
    public PageReference filterMonth() {
                
        return null;
    }

public static String caseFilters(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String filter = '';
    if(year != '-')
        filter += ' AND FRML_Year_Campaign__c = \''+year+'\'';
    if(division != '-')
        filter += ' AND NPS_CAMPAIGN__r.DivisionRef__r.name =\''+division+'\'';
    if(country != '-')
        filter += ' AND NPS_country__c =\''+country+'\'';
    if(touchpoint !='-')
        filter += ' AND NPS_CAMPAIGN__r.TXT_Wave__c =\''+touchpoint+'\'';
    if(startDate != '')
    {
        filter += ' AND NPS_INTERVIEW_START__c >='+startDate+'T00:00:00Z';
    }
    if(endDate != '')
        filter += ' AND NPS_INTERVIEW_START__c <='+endDate+'T00:00:00Z';
    return filter;
}  

public static String campainFilters(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String filter = '';
    if(year != '-')
        filter += ' AND YearV2__r.name = \''+year+'\'';
    if(division != '-')
        filter += ' AND DivisionRef__r.name =\''+division+'\'';
    if(country != '-')
        filter += ' AND CountryRef__r.name =\''+country+'\'';
    if(touchpoint !='-')
        filter += ' AND TXT_Wave__c =\''+touchpoint+'\'';
    if(startDate != '')
    {
        filter += ' AND StartDate >='+startDate+'';
    }
    if(endDate != '')
        filter += ' AND EndDate <='+endDate+'';
    return filter;
} 



public static String taskFilters(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String filter = '';
    if(year != '-')
        filter += ' AND LKP_NPS_Case__r.FRML_Year_Campaign__c = \''+year+'\'';
    if(division != '-')
        filter += ' AND LKP_NPS_Case__r.NPS_CAMPAIGN__r.DivisionRef__r.name =\''+division+'\'';
    if(country != '-')
        filter += ' AND LKP_NPS_Case__r.NPS_country__c =\''+country+'\'';
    if(touchpoint !='-')
        filter += ' AND LKP_NPS_Case__r.NPS_CAMPAIGN__r.TXT_Wave__c =\''+touchpoint+'\'';
    if(startDate != '')
    {
        filter += ' AND LKP_NPS_Case__r.NPS_INTERVIEW_START__c >='+startDate+'T00:00:00Z';
    }
    if(endDate != '')
    {
        filter += ' AND LKP_NPS_Case__r.NPS_INTERVIEW_START__c <='+endDate+'T00:00:00Z';
    }
    return filter;
}  
    
@RemoteAction
global static dataContainer[] surveyResults(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> surveyResultsList = new List<dataContainer>();
    String test2 = null;
    String myString = 'SELECT count(id) id, NPS_Country__c country FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10';    
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);    
    myString += ' GROUP BY NPS_Country__c';
    AggregateResult[] ARs =  Database.query(myString);    
    for(AggregateResult surveyResultItem : ARs)
    {
        surveyResultsList.add(new dataContainer(Integer.ValueOf(surveyResultItem.get('id')), (String)surveyResultItem.get('country')));
    }
      return surveyResultsList ;
}

public static List<Case> surveyResultsExport(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    String myString = 'SELECT id, NPS_RESULT_Q4__c, account.owner.name,NPS_EXT_RESPONSEID__c, NPS_Country__c, account.name, contact.name, NPS_INTERVIEW_START__c, NPS_INTERVIEW_END__c, NPS_RESULT_Q1__c, FRML_Is_Detractor__c, FRML_Is_Passive__c, FRML_Is_Promoter__c, FRML_Tasks_generated_counter__c ,NPS_Campaign__r.TXT_Local_segment__c, NPS_Campaign__r.TXT_Farm_Size__c, NPS_RESULT_Q21__c FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10';    
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);    
    List<Case> listaCasosExport = new List<Case>();
    listaCasosExport = Database.query(myString);     
    return listaCasosExport;
}


@RemoteAction
global static dataContainer[] type(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> typeList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_Is_Detractor__c) Detractors , SUM(FRML_Is_Passive__c) Passives, SUM(FRML_Is_Promoter__c) Promoters, NPS_Country__c country FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10';    
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    myString += ' GROUP BY NPS_Country__c';
    system.debug('query: '+myString);
    AggregateResult[] AR =  Database.query(myString);
    
    for(AggregateResult scoretItem : AR)
    {                                                                                     /*detractors promoters passives*/
        typeList.add(new dataContainer((String)scoretItem.get('country'), Integer.ValueOf(scoretItem.get('Detractors')), Integer.ValueOf(scoretItem.get('Promoters')), Integer.ValueOf(scoretItem.get('Passives'))));
    }
      return typeList;
}

@RemoteAction
global static dataContainer[] callsTasks(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> callsTasksList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_Tasks_generated_counter__c) Tasks, SUM(FRML_Calls_done_counter__c) Calls, NPS_Country__c country FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10 ';
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    myString += ' GROUP BY NPS_Country__c';
    
    AggregateResult[] ARr =  Database.query(myString);
    
    for(AggregateResult callsTasksItem : ARr)
    {
        callsTasksList.add(new dataContainer((String)callsTasksItem.get('country'), Integer.ValueOf(callsTasksItem.get('Calls')), Integer.ValueOf(callsTasksItem.get('Tasks'))));
    }
      return callsTasksList;
}

@RemoteAction
global static dataContainer[] score(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> scoreList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_Is_Promoter__c) promoters, sum(FRML_Is_Detractor__c) detractors, sum(FRML_Is_Passive__c) passives, NPS_Country__c country FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' ';    
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    myString += ' GROUP BY NPS_Country__c';
        
    AggregateResult[] ARb = Database.query(myString);
    
    
    for(AggregateResult scoreItem : ARb)
    {
        Double promoters = Integer.ValueOf(scoreItem.get('promoters'));
        Double passives = Integer.ValueOf(scoreItem.get('passives'));
        Double detractors = Integer.ValueOf(scoreItem.get('detractors'));    
        Double score = (passives + promoters + detractors) == 0 ? 0 :(((promoters - detractors)/(passives + promoters + detractors)) *100);
        scoreList.add(new dataContainer ((String)scoreItem.get('country'), Integer.valueOf(score)));
    }
      return scoreList;
}

@RemoteAction
global static dataContainer[] scoreSegment(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> scoreSegmentList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_Is_Promoter__c) promoters, sum(FRML_Is_Detractor__c) detractors, sum(FRML_Is_Passive__c) passives, NPS_Country__c country, NPS_Campaign__r.TXT_Local_segment__c segment FROM Case WHERE RecordTypeId =\''+recordTypeId+'\'';
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);               
    myString += '  GROUP BY NPS_Country__c, NPS_Campaign__r.TXT_Local_segment__c';
        
    AggregateResult[] ARb = Database.query(myString);
        
    for(AggregateResult scoreSegmentItem : ARb)
    {
        Double promoters = Integer.ValueOf(scoreSegmentItem.get('promoters'));
        Double passives = Integer.ValueOf(scoreSegmentItem.get('passives'));
        Double detractors = Integer.ValueOf(scoreSegmentItem.get('detractors'));        
        Double score = (passives + promoters + detractors) == 0 ? 0 :(((promoters - detractors)/(passives + promoters + detractors)) *100);
        scoreSegmentList.add(new dataContainer ((String)scoreSegmentItem .get('Country'), Integer.valueOf(score), (String)scoreSegmentItem .get('Segment')));
    }
      return scoreSegmentList;
}

@RemoteAction
global static dataContainer[] scoreFarm(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    List<dataContainer> scoreFarmList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_Is_Promoter__c) promoters, sum(FRML_Is_Detractor__c) detractors, sum(FRML_Is_Passive__c) passives, NPS_Country__c country, NPS_Campaign__r.TXT_Farm_Size__c size FROM Case WHERE RecordTypeId =\''+recordTypeId+'\'';    
    myString += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    myString += ' GROUP BY NPS_campaign__r.TXT_Farm_Size__c, NPS_Country__c';
    AggregateResult[] ARf = Database.query(myString);    
    
    for(AggregateResult scoreFarmItem : ARf)
    {
        Double promoters = Integer.ValueOf(scoreFarmItem .get('promoters'));
        Double passives = Integer.ValueOf(scoreFarmItem .get('passives'));
        Double detractors = Integer.ValueOf(scoreFarmItem .get('detractors'));        
        Double score = (passives + promoters + detractors) == 0 ? 0 :(((promoters - detractors)/(passives + promoters + detractors)) *100);
        scoreFarmList.add(new dataContainer ((String)scoreFarmItem .get('Country'),  Integer.valueOf(score), (String)scoreFarmItem .get('Size')));
    }
      return scoreFarmList;
}


@RemoteAction
global static dataContainer[] callsStatus(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String queryDefinition = 'SELECT count(id) Calls, LKP_NPS_Case__r.NPS_Country__c country, status ';
    queryDefinition +=' FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND  (status =\'Not started\') AND (LKP_NPS_Case__r.NPS_Country__c != null)';
    String queryFilter = taskFilters(year, division, country, touchpoint, startDate, endDate);        
    queryFilter += ' GROUP BY LKP_NPS_Case__r.NPS_Country__c, status';
    // Aprovecharemos el 3r dataContainer creado porq tiene 1 strinG y 2 integers para representar los dos posibles status.
    // calls -> Not Started    ,    tasks -> Completed  (dataContainer->status)
    Map<String, dataContainer> mapaResults = new Map<String, dataContainer>();
    for(AggregateResult item : Database.query(queryDefinition + queryFilter))
    {
            dataContainer itemCountry = new dataContainer((String)item.get('country'), (Integer)item.get('Calls'), 0);
            mapaResults.put(itemCountry.country, itemCountry);
    }
    queryDefinition = 'SELECT count(id) Calls, LKP_NPS_Case__r.NPS_Country__c country, status';
    queryDefinition +=' FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND status =\'Completed\' AND (LKP_NPS_Case__r.NPS_Country__c != null)';                                     
    for(AggregateResult item : Database.query(queryDefinition + queryFilter))
    {
        if(mapaResults.get((String)item.get('country'))!=null)        
        {
            dataContainer itemCountry = mapaResults.get((String)item.get('country'));
            itemCountry.tasks = (Integer)item.get('Calls');
            mapaResults.put(itemCountry.country, itemCountry);
        }
        else
        {
            dataContainer itemCountry = new dataContainer((String)item.get('country'), 0 , (Integer)item.get('Calls'));
            mapaResults.put(itemCountry.country, itemCountry);
        }
    }    
    return mapaResults.values();    
}

public static List<Task> callsStatusExport(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String myString = 'SELECT id,LKP_NPS_Case__r.NPS_Country__c,status,FRML_DAYS_TO_CLOSE__c, ActivityDate,LKP_NPS_Case__r.NPS_EXT_RESPONSEID__c   FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND (LKP_NPS_Case__r.NPS_Country__c != null)';    
    myString += taskFilters(year, division, country, touchpoint, startDate, endDate);    
    List<Task> listaTasksExport = new List<Task>();
    listaTasksExport = Database.query( myString);     
    return listaTasksExport;
}


@RemoteAction
global static dataContainer[] daysClose(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String queryDefinition = 'SELECT LKP_NPS_Case__r.NPS_Country__c, FRML_DAYS_TO_CLOSE__c';
    queryDefinition +=' FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND Status = \'Completed\' AND (LKP_NPS_Case__r.NPS_Country__c != null) ';
    String queryFilter= taskFilters(year, division, country, touchpoint, startDate, endDate);  

    Map<String, dataContainer> mapaResults = new Map<String, dataContainer>();
    // Aprovechamos 1r dataContainer definido con 1 string y 3 integers
    // passives -> slow  ,  promoters -> mid  ,  detractors _> fast
     
    for(Task item : Database.query(queryDefinition + queryFilter))
    {
       if(mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c) != null)        
        {
            dataContainer itemCountry = mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c);
            if(item.FRML_DAYS_TO_CLOSE__c <= 5){
                itemCountry.detractors += 1;
            } else if(item.FRML_DAYS_TO_CLOSE__c <= 10){
                itemCountry.promoters += 1;                        
            } else{
                itemCountry.passives += 1;
            }
           mapaResults.put(itemCountry.country, itemCountry);
        }
        else
        {
            dataContainer itemCountry = new dataContainer(item.LKP_NPS_Case__r.NPS_Country__c, 0, 0, 0);
            if(item.FRML_DAYS_TO_CLOSE__c <= 5){
                itemCountry.detractors += 1;
            } else if(item.FRML_DAYS_TO_CLOSE__c <= 10){
                itemCountry.promoters += 1;                        
            } else{
                itemCountry.passives += 1;
            }
           mapaResults.put(itemCountry.country, itemCountry);            
        }
        
    }    
    return mapaResults.values();
    
}
    
@RemoteAction
global static dataContainer[] daysClosePerc(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String queryDefinition = 'SELECT LKP_NPS_Case__r.NPS_Country__c, FRML_DAYS_TO_CLOSE__c';
    queryDefinition +=' FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND Status = \'Completed\' AND (LKP_NPS_Case__r.NPS_Country__c != null) ';
    String queryFilter= taskFilters(year, division, country, touchpoint, startDate, endDate);        
        
    Map<String, dataContainer> mapaResults = new Map<String, dataContainer>();
 
    // dataContainer aprovechado con mismos tipos de parámetro :  passives -> slow  ,  promoters -> mid  ,  detractors _> fast
     
    for(Task item : Database.query(queryDefinition + queryFilter))
    {
       if(mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c) != null)        
        {
            dataContainer itemCountry = mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c);
            if(item.FRML_DAYS_TO_CLOSE__c <= 5){
                itemCountry.detractors += 1;
            } else if(item.FRML_DAYS_TO_CLOSE__c <= 10){
                itemCountry.promoters += 1;                        
            } else{
                itemCountry.passives += 1;
            }
           mapaResults.put(itemCountry.country, itemCountry);
        }
        else
        {
            dataContainer itemCountry = new dataContainer(item.LKP_NPS_Case__r.NPS_Country__c, 0, 0, 0);
            if(item.FRML_DAYS_TO_CLOSE__c <= 5){
                itemCountry.detractors += 1;
            } else if(item.FRML_DAYS_TO_CLOSE__c <= 10){
                itemCountry.promoters += 1;                        
            } else{
                itemCountry.passives += 1;
            }
           mapaResults.put(itemCountry.country, itemCountry);            
        }
        
    }
    
    Map<String, dataContainer> resultsPerc = new Map<String, dataContainer>();
    // List resultsList = new List();
    // resultsList = mapaResults.values();
    
    for(dataContainer pais: mapaResults.values()){
        Double tot= pais.detractors + pais.promoters + pais.passives;        
        Double percentDetractors = ((Double.valueOf(pais.detractors))/tot);
        pais.detractors = Integer.valueOf(percentDetractors *100);        
        Double percentPromoters = ((Double.valueOf(pais.promoters))/tot);
        pais.promoters= Integer.valueOf(percentPromoters *100);
        Double percentPassives = ((Double.valueOf(pais.passives))/tot);
        pais.passives= Integer.valueOf(percentPassives *100);        
        resultsPerc.put(pais.country, pais);
    }
    
    
    return resultsPerc.values();
    
}
    
@RemoteAction
global static dataContainer[] avgDaysOpen(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    String queryDefinition = 'SELECT LKP_NPS_Case__r.NPS_Country__c, FRML_DAYS_TO_CLOSE__c';
    queryDefinition +=' FROM task WHERE subject=\'NPS: Customer Call\' AND LKP_NPS_Case__c !=null AND Status = \'Completed\' AND (LKP_NPS_Case__r.NPS_Country__c != null) ';
    String queryFilter= taskFilters(year, division, country, touchpoint, startDate, endDate);
  
    Map<String, dataContainer> mapaResults = new Map<String, dataContainer>();
    // Aprovechamos 3r dataContainer definido con 1 string y 2 integers
    // calls -> dies totals   ,  tasks -> nº casos  l'average serà diesTot/Casos 
    
    for(Task item : Database.query(queryDefinition + queryFilter))
    {
       if(mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c) != null)        
        {
            dataContainer itemCountry = mapaResults.get(item.LKP_NPS_Case__r.NPS_Country__c);
            itemCountry.calls += (Integer)item.FRML_DAYS_TO_CLOSE__c;
            itemCountry.tasks += 1;
            mapaResults.put(itemCountry.country, itemCountry);
        }
        else
        {
            dataContainer itemCountry = new dataContainer(item.LKP_NPS_Case__r.NPS_Country__c, 0, 0);
            itemCountry.calls = (Integer)item.FRML_DAYS_TO_CLOSE__c;
            itemCountry.tasks = 1;
            mapaResults.put(itemCountry.country, itemCountry);            
        }
        
    }
    
    // Creem un nou mapa amb 1 string i un integer que serà el avg a partir de les dades en el map anterior. A partir del 4t dataContainer
    Map<String, dataContainer> avgDays = new Map<String, dataContainer>();
    
    for(dataContainer pais: mapaResults.values()){
        dataContainer thisCountry = new dataContainer(pais.country, (pais.calls/pais.tasks));
        avgDays.put(thisCountry.country, thisCountry);
    }
    
    return avgDays.values();
    
}


@RemoteAction
global static dataContainer[] surveyResultsCauseTable(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    String queryDefinition = 'SELECT NPS_RESULT_Q21_EN__c FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10';    
    queryDefinition += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    // Necessitem un datacontainer amb 1 string(survey result) i un integer(comptador).  --> 4o dataContainer
    Map<String, dataContainer> surveyResultsMap = new Map<String, dataContainer>();
    
    for(Case item : Database.query(queryDefinition))
    {
       if(surveyResultsMap.get(item.NPS_RESULT_Q21_EN__c) != null)        
        {
            dataContainer itemCase = surveyResultsMap.get(item.NPS_RESULT_Q21_EN__c);
            itemCase.country = item.NPS_RESULT_Q21_EN__c;
            itemCase.score += 1;
            surveyResultsMap.put(itemCase.country, itemCase);
        }
        else
        {
            dataContainer itemCase = new dataContainer(item.NPS_RESULT_Q21_EN__c, 1);
            surveyResultsMap.put(itemCase.country, itemCase);            
        }
        
    }
      return surveyResultsMap.values() ;
}

/*** SECONDARY CAUSE ***/

// Oriol Raméntol 05/04/2016 START

@RemoteAction
global static dataContainer[] surveyResultsSecCauseTable(String year, String division, String country, String touchpoint, String startDate, String endDate) 
{
    String queryDefinition = 'SELECT NPS_RESULT_Q31__c FROM Case WHERE RecordTypeId =\''+recordTypeId+'\' AND NPS_RESULT_Q1__c <= 10';    
    queryDefinition += caseFilters(year, division, country, touchpoint, startDate, endDate);        
    // Necessitem un datacontainer amb 1 string(survey result) i un integer(comptador).  --> 4o dataContainer
    Map<String, dataContainer> surveyResultsMap = new Map<String, dataContainer>();
    
    for(Case item : Database.query(queryDefinition))
    {
       if(surveyResultsMap.get(item.NPS_RESULT_Q31__c) != null)        
        {
            dataContainer itemCase = surveyResultsMap.get(item.NPS_RESULT_Q31__c);
            itemCase.country = item.NPS_RESULT_Q31__c;
            itemCase.score += 1;
            surveyResultsMap.put(itemCase.country, itemCase);
        }
        else
        {
            dataContainer itemCase = new dataContainer(item.NPS_RESULT_Q31__c, 1);
            surveyResultsMap.put(itemCase.country, itemCase);            
        }
        
    }
      return surveyResultsMap.values() ;
}


@RemoteAction
global static dataContainer[] ScorePerYear(String year, String division, String country, String touchpoint, String startDate, String endDate)
{
    List<dataContainer> scoreyearList = new List<dataContainer>();
    String myString = 'SELECT SUM(FRML_NPS_Score_Formula__c) score, YearV2__r.name year, CountryRef__r.name country  FROM Campaign WHERE RecordtypeId =\''+recordTypeCampaign+'\' ';
    myString += campainFilters(year, division, country, touchpoint, startDate, endDate);
    myString += ' GROUP BY YearV2__r.name, countryref__r.name  ORDER BY YearV2__r.name ASC, countryref__r.name ASC';
    
    AggregateResult[] ARb = Database.query(myString);
    
    Set<String> Set_Country = new Set<String>();
    Set<String> Set_Year = new Set<String>();
    Map<String,list<Decimal>> Map_Score = new Map<String,list<Decimal>>();
    Map<String,list<String>> Map_CY = new Map<String,list<String>>();   
    system.debug('*** aggregate result' + ARb);
    for(AggregateResult scoreyearItem : ARb)
    {
        Set_Country.add((String)scoreyearItem.get('country'));
        Set_Year.add((String)scoreyearItem.get('year'));
        
        List<String> List_year = !Map_CY.containskey((String)scoreyearItem.get('country')) ? new List<String>() : Map_CY.get((String)scoreyearItem.get('country'));
        
        List_year.add((String)scoreyearItem.get('year'));
        Map_CY.put((String)scoreyearItem.get('country'), List_year);   
    } 
    
    system.debug(Set_country);
    system.debug(Map_Score);
    
    boolean exists=false;
    for (String countries : Set_Country){
        for (String years : Set_Year){
            for (integer i=0 ; i <Map_CY.get(countries).size(); i++)
            {
                if(Map_CY.get(countries)[i] == years){
                    exists=true;
                }
            }
            if (exists==true){
                for (AggregateResult scoreyearcountry : ARb){
                    if(((String)scoreyearcountry.get('year') == years) && ((String)scoreyearcountry.get('country') == countries)){
                        List<Decimal> List_score = !Map_Score.containskey((String)scoreyearcountry.get('year')) ? new List<Decimal>() : Map_Score.get((String)scoreyearcountry.get('year'));
                        List_score.add((Decimal)scoreyearcountry.get('score'));
                        Map_Score.put(years, List_score);
                    }
                }
            } else if (exists==false){
                List<Decimal> List_score = !Map_Score.containskey(years) ? new List<Decimal>() : Map_Score.get(years);
                List_score.add(0);
                Map_Score.put(years, List_score);
            }
            exists=false;           
        }       
    }
    
    scoreyearList.add(new dataContainer (Set_Country, Set_Year, Map_Score));
    return scoreyearList;
}
// Oriol 05/04/2016 END

global class dataContainer    
{
    public String country{get;set;}
    public Integer numRecords{get;set;}
    public Integer passives{get;set;}
    public Integer promoters{get;set;}
    public Integer detractors{get;set;}
    public Integer calls{get;set;}
    public Integer tasks{get;set;}
    public Integer score{get;set;}
    public Integer record{get;set;}
    public String result{get;set;}
    public String segment{get;set;}
    public String farm_size{get;set;}
    public String Year{get;set;}
    public Set<String> Set_Country {get;set;}
    public Set<String> Set_year {get;set;}
    public Map<String,list<Decimal>> Map_Score {get;set;}
    
    dataContainer(set<String> p_country, set<String> p_year, Map<String,list<Decimal>> p_score)
    {
        Set_Country = p_country;
        Set_Year = p_year;
        Map_Score = p_score;
    }
    
    dataContainer(String p_country, Integer p_detractors, Integer p_promoters, Integer p_passives)
    {
        country = p_country;
        detractors = p_detractors;
        promoters = p_promoters;
        passives = p_passives;
    }
    
     dataContainer(Integer p_numRecords, String p_country)
    {
        numRecords=p_numRecords;
        country = p_country;       
        
    }
    
     dataContainer(String p_country, Integer p_calls, Integer p_tasks)
    {
        country = p_country;
        calls = p_calls;
        tasks = p_tasks;       
        
    }
    
     dataContainer(String p_country, Integer p_score)
    {
        country = p_country;
        score = p_score;
    }
        
    dataContainer(String p_country, Integer p_score, String p_segment)
    {
        country = p_country;
        score = p_score;
        segment = p_segment;
    }


}
    /*
global class dataContainer2    
{
    String country;
    Integer numRecords;
    Integer passives;
    Integer promoters;
    Integer detractors;
    Integer calls;
    Integer tasks;
    Integer score;
    Integer record;
    String result;
    
    dataContainer2(String p_result, Integer p_record)
    {
        result = p_result;
        record = p_record;
    }
} */
}