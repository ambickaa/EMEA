/*
Class name - HLPR_GlobalCaseRollup 
Description- Utility class for trigger Trg_AfterinsertupdateCase
Created By - Accenture IDC
*/
public class HLPR_GlobalCaseRollup {
    
    public static Map<Id,case> mapOldCases = New Map<Id,case>();
    
    /*
    Method name - CountChildCases
    Description - This method is used for count the child cases
    */
    public static void CountChildCases(Set<Id> ParentIds, map<id, case>  mapCases)
    {
        //Extract parent cases for the cases being changed 
        List<Case> lstParentCases = [Select Id,CaseNumber, (Select Id,isclosed,status from Cases),isclosed,status From CASE where Id IN :ParentIds];  
        integer intClosedCases;
        integer intOpenCases;                      
        for (Case cs: lstParentCases)
        {
            //Set the total of child for a parent ---
            if (cs.cases.size() !=0)
               cs.GC_No_of_Child_cases__c =  cs.cases.size();
            else
                cs.GC_No_of_Child_cases__c = null;
            //------------------
            
            //Reset the counters ---
            intClosedCases = 0;
            intOpenCases = 0;    
            //-------------
            
            //
            //Calcuate Open and Closed Cases---
            for(case chldCase: cs.cases)
            {
                if(chldCase.isclosed==true || chldCase.status=='Closed')
                   intClosedCases += 1;
                else
                   intOpenCases += 1; 
            }
            //---------------
            
            //Update closed child cases ---
            if(intClosedCases >0)
                cs.GC_No_of_Closed_Child_Cases__c =  intClosedCases;
            else
                cs.GC_No_of_Closed_Child_Cases__c =  null;
            //----------------
            
            //other field updates
            cs.Is_ByPass__c = true;
        }
        
        System.debug('Update Paerebts- ' + lstParentCases);
        //Update the Parent Cases
        database.saveresult[] results = database.update(lstParentCases, false);
        
        Case updCase;            
        System.debug('Update results- ' + results);
        // In case any errors happen log against child being updated 
        for(integer icnt = 0; icnt < results.size(); icnt++)
        {
            System.debug('Update results[icnt].isSuccess()- ' + results[icnt].isSuccess());
            if(!results[icnt].isSuccess()) //Check if Error Occurred add to the main child being inserted/updated 
            {
                updCase = mapCases.get(lstParentCases[icnt].id);
                system.debug('Error Happended - Parent Case ' + lstParentCases[icnt]);
                system.debug('Error Happended - updCase' + updCase);
                system.debug('Error Happended - Actual Error' + 'Error occurred for Case#' + lstParentCases[icnt].CaseNumber + ' \nError Details: ' +  results[icnt].getErrors()[0].getStatusCode() +  '\n' + results[icnt].getErrors()[0].getMessage() + '\n' + results[icnt].getErrors()[0].getFields());
                updCase.addError ('Error occurred for Case#' + lstParentCases[icnt].CaseNumber + ' \nError Details: ' + results[icnt].getErrors()[0].getStatusCode()+  '\n' + results[icnt].getErrors()[0].getMessage() + '\n' + results[icnt].getErrors()[0].getFields() );
            }  
        }
   

    }
        
    /*
    Method name - Reset fields
    Description - This method is used reset roll-up fields for handling clone functionality    
    */
    public static void Resetfields(List<Case> lstCases)
    {
        for (Case cs:lstCases)
        {
            cs.GC_No_of_Closed_Child_Cases__c = null;
            cs.GC_No_of_Child_cases__c = null;
            cs.Is_ByPass__c = false;
        }
    }

    /*
    Method name - Check Old Values
    Description - This method is used store the old map to be used later on since due to some trigger/managed package old map is lost   
    */
    public static void storeoldvalues(Map<Id,Case> mapCases)
    {
        mapOldCases = mapCases;
    }

}