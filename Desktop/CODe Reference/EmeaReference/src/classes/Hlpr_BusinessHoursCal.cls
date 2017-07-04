/*
Class name  - Hlpr_BusinessHoursCal
Description-  Helper for calculating Respose age
Created By - Accenture IDC
*/
public class Hlpr_BusinessHoursCal{
/*
Method name - processcases
Description - Helper for calculating Respose age
*/
    public static void processcases(list<case>caselist, map<id,case>caseoldmap) {
   
        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        RecordType recType = [SELECT DeveloperName,Id,IsActive,Name FROM RecordType WHERE  DeveloperName = 'Service_Case' limit 1];
        set<id> caseset = new set<id>();
        for(Case c :caselist ){
            if(c.recordtypeid == recType.id){
                caseset.add(c.id);
            }   
        }
    list<case> caselistupdate= new list<case>();
        for (Case updatedCase :[select id,BusinessHoursId, status,LastModifiedDate,GC_First_Resp_To_Cust_Date__c, closeddate,CreatedDate from case where id in:caseset]) {
               
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
                //System.debug('ResponsetimeBusinessHours::'+HandletimeBusinessHours);
                updatedCase.GC_Handle_Time_in_Business_Hours_nbr__c = HandletimeBusinessHours;
                }
                                         
               updatedCase.Is_ByPass__c = true;//For bypass validation Unread_Email_Validation
              caselistupdate.add(updatedCase );     
        }

 update caselistupdate;
    }
    
}