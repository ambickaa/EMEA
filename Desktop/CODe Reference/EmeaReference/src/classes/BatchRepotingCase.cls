/*
Class name - BatchRepotingCase 
Description- Batch Class for ACS Global Reports fields
Created By - Accenture IDC
*/

global class BatchRepotingCase implements Database.Batchable<sObject>
{
    Private String query='' ;
      
    Global BatchRepotingCase(){
    query = 'select id,BusinessHoursId, status,LastModifiedDate,GC_First_Resp_To_Cust_Date__c, closeddate,CreatedDate from case where recordtypeid = \''+System.Label.ServicecaseRTId+'\'';
    
    //system.debug('query ** '+query);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Case> cScope)
    {
        list<case> caselistupdate= new list<case>();
        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        Set<ID> caseIds = new Set<ID>();       
        for(Case updatedCase:cScope){
        Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
        
                if(updatedCase.status!='Closed'){
                    //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                    Double CaseAgeBusinessHours= BusinessHours.diff(hoursToUse, updatedCase.CreatedDate,updatedCase.LastModifiedDate)/3600000.0; 
                    updatedCase.GC_Case_Age_in_Business_Hours_nbr__c   =   CaseAgeBusinessHours;         
                }
                else{
                    Double CaseAgeBusinessHours= BusinessHours.diff(hoursToUse, updatedCase.CreatedDate,updatedCase.ClosedDate)/3600000.0;
                    updatedCase .GC_Case_Age_in_Business_Hours_nbr__c   =   CaseAgeBusinessHours;
                }  
                if(updatedCase.GC_First_Resp_To_Cust_Date__c!=null){
                    Double ResponsetimeBusinessHours= BusinessHours.diff(hoursToUse, updatedCase.CreatedDate,updatedCase.GC_First_Resp_To_Cust_Date__c)/3600000.0; 
                    updatedCase.GC_Response_Time_in_Business_Hours_nbr__c = ResponsetimeBusinessHours;
                }
                
                if(updatedCase.GC_First_Resp_To_Cust_Date__c!=null && updatedCase.status=='Closed'){
                    Double HandletimeBusinessHours= BusinessHours.diff(hoursToUse, updatedCase.GC_First_Resp_To_Cust_Date__c,updatedCase.ClosedDate)/3600000.0;    
                    updatedCase.GC_Handle_Time_in_Business_Hours_nbr__c = HandletimeBusinessHours;
                }
              caselistupdate.add(updatedCase );     
        }
        database.update(caselistupdate,false);    
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
}