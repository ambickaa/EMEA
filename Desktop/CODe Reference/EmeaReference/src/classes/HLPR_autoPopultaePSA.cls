/*
Class name - HLPR_autoPopultaePSA
Description- Utility class for trigger 
Created By - Accenture IDC
*/
public class HLPR_autoPopultaePSA {
/*
Method name - processInsert
Description - This method insert YW partner as PSA
*/
    public static void processInsert(List < Case > lstcase) {
        Set<id> caseid= new Set<Id>(); 
        set<id> accid = new Set<id>();
        set<String> sapCode = new set<String>();
        String YWPartner = System.Label.YW_Partner;
        
        for (Case c: lstcase) {
            if((c.id!=null || c.AccountId != null ) && c.recordtypeid == System.Label.ServicecaseRTId)
            {
                caseid.add(c.id);
                accid.add(c.AccountId); 
            }
        }
        
        List<Partner_Function__c> pLst = [Select id,Partner_Function_Code__c,Partner_SAP_ID__c from Partner_Function__c where 
                    Primry_Acct_Integration_Key__c in :accid and Partner_Function_Code__c = :YWPartner and isdeleted=false];
                    //system.debug('aaa' + pLst);
                    
        for(Partner_Function__c pLst1 : pLst)
        {
            if(pLst1.Partner_SAP_ID__c != null)
            {
                sapCode.add(pLst1.Partner_SAP_ID__c);
            }
        }
        system.debug('sapCode.size***' + sapCode.size());
        List<User> userLst = [Select id,SAP_Partner_Code__c from user where SAP_Partner_Code__c in :sapCode];
        
        for(Case c: lstcase)
        {
            if( pLst !=null)
            {
                if(sapCode.size()==1 && c.GC_Primary_Srvc_Agent_SFID__c==null)
                {
                     for(User u :userLst)
                     {
                          c.GC_Primary_Srvc_Agent_SFID__c=u.id;
                     }
                }  
            }
        }
    }
}