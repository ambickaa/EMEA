/*
Class name - Hlpr_GlobalFirstResponseDate
Description- Utility class for trigger Trg_TaskafterInsertUpdate 
Created By - Accenture IDC
*/
public class Hlpr_GlobalFirstResponseDate{
    /*
Method name - processTasks
Description - This method will update the first response date on Case
*/
    public static void processTasks(List < task> lsttasks) {
        set<id> setwhatId= new set<id>();
        for(Task t:lsttasks){ 
            String whatId = t.whatId;   
            if(t.WhatId!=null && whatId.substring(0, 3)== '500' ){  
                setwhatId.add(t.WhatId);
            }
        }
        map<id,case> CaseMap= new map<id,case>([select id,RecordTypeId, GC_First_Resp_To_Cust_Date__c, (select id, type,createddate,status from tasks) from case where id in :setwhatId]);
        list<case> caselist=[select id, RecordTypeId,GC_First_Resp_To_Cust_Date__c, (select id,  type,createddate,status from tasks where (type='Call' OR type='Email')  order by CreatedDate Desc ) from case where id in :setwhatId];
        Map<Id, List<Task>> map1 = new  Map<Id, List<Task>>();
        Set<Case> cslsit = new Set<case>();
        List<Case> cslsit1 = new List<case>();
        for(Case c:caselist){
            if(c.recordtypeid == System.Label.ServicecaseRTId)
            {
                map1.put(c.Id, c.tasks);
            }
        }
        
        case C;
        
        if(map1.size()>0)
        {
            for(task t: lsttasks){
                if(t.whatId!=null && CaseMap.containsKey(t.WhatId)){
                    C= CaseMap.get(t.WhatId);
                    if(C.GC_First_Resp_To_Cust_Date__c== null){
                        List<task> tlist = map1.get(C.id);
                        if(tlist.isEmpty()){   
                            if((t.type=='Call' || t.type=='Email') && (!System.Label.Task_For_Automatic_Reply.contains(t.Subject))){                                
                                    C.GC_First_Resp_To_Cust_Date__c= t.createddate;
                            }
                            else{
                                C.GC_First_Resp_To_Cust_Date__c=null;  
                            }
                        }
                        else{   
                             if(!System.Label.Task_For_Automatic_Reply.contains(t.Subject))						
                              {
                                 C.GC_First_Resp_To_Cust_Date__c= tlist[0].createddate;
                              }                          
                        }
                        
                    }
                    c.Is_ByPass__c = true;
                    cslsit.add(C);
                }
            }
            cslsit1.addall(cslsit);
            update cslsit1;
        }
    }    
}