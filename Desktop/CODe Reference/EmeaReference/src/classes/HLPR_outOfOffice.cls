/*
Class name - HLPR_outOfOffice
Description- Utility class for trigger 
Created By - Accenture IDC
*/
public class HLPR_outOfOffice {
/*
Method name - processInsert
Description - This method is for out of office
*/
    public static void processInsert(List < Case > lstcase) {
        Set<id> caseid= new Set<Id>(); 
        set<String> CaseOrigin = new Set<String>();
        set<id> Conid = new Set<id>();
        List<Out_Of_Office__c> lst1 = new List<Out_Of_Office__c>();
        set<String> EmailAdd = new Set<String>();
        
        for (Case c: lstcase) {
            if(c.id!=null || c.Origin != null || c.contactId!=null)
            {
                caseid.add(c.id);
                CaseOrigin.add(c.Origin);
                Conid.add(c.contactId);
            }
        }
        
        List<Out_Of_Office__c> oooLst = [Select id,Case_Origin__c,IS_Active__c,Start_Date__c,End_Date__c,Template_ID__c,Queue_Email_Address__c,Email_Templates__c from Out_Of_Office__c where Case_Origin__c in :CaseOrigin];
        
        List<Contact> conLst =[Select Id ,email from Contact where id in :Conid];
      
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        
        for(Out_Of_Office__c o:oooLst)
        {
            if(o.Queue_Email_Address__c!=null)
                EmailAdd.add(o.Queue_Email_Address__c);
        }
        
        List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address in :EmailAdd];
                
        for(Integer i= 0; i <oooLst.size(); i++)
        {
            // Out of office mail is sent when it falls within the duration and active flag is set to true and date in between start and end date  
            if(oooLst[i].IS_Active__c == true){
                if( Date.today() >= oooLst[i].Start_Date__c && Date.today() <= oooLst[i].End_Date__c)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    if(conLst.size() == 1)
                    {
                        for(Integer k=0;k<owea.size();k++)
                        {
                            if(owea[k].id!=null)
                            {                       
                                mail.setOrgWideEmailAddressId(owea[k].Id);
                            }
                         }                               
                            mail.setTemplateId(oooLst[i].Template_ID__c);
                            if(conLst[0].Email!=null)
                            {
                                mail.setTargetObjectId(conLst[0].id);
                            }
                            mail.setWhatId(oooLst[i].id);
                            mail.saveAsActivity = false;
                            lstMsgsToSend.add(mail);     
                    }   
                }
            }
        }
        update lst1;
        Messaging.sendEmail(lstMsgsToSend); 
    }
}