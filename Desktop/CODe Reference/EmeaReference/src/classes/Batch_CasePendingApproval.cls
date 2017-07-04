global class Batch_CasePendingApproval implements Database.Batchable<sObject>{
    
    public string query; 
    public decimal ApprovalJobTimeMIn;
    public decimal ApprovalJobTimeMax;
    public decimal ApprovalJobTimeMIn_Rem;
    public decimal ApprovalJobTimeMax_Rem;
    public decimal ApprovalJobTimeMIn_ACS;
    public decimal ApprovalInterval;
    public Map<String,List<ProcessInstanceWorkitem>>  wi =new Map<String,List<ProcessInstanceWorkitem>>();
    public Map<String,List<ProcessInstanceWorkitem>>  wi1 =new Map<String,List<ProcessInstanceWorkitem>>();
    public Map<id,User> umap =new  Map<id,User>();  
    
    Global Batch_CasePendingApproval(){
        List<ProcessInstanceWorkItem> wiList = new List<ProcessInstanceWorkItem>();
        List<ProcessInstanceWorkItem> wi1List = new List<ProcessInstanceWorkItem>();
        Map<id,string> cid=new Map<id,string>();
        
        /***Commented by ACS as a part of request 25080 associated with release
        EME - ACS Support Services - Release #7 - 2016 - July- 19*********/
        /*for(case c:[select id,CaseNumber from case]){
            cid.put(c.id,c.CaseNumber);
        }*/
        
        // To know if the case is in approval process and is locked
        //system.debug('Inside-----------');
        if(!Test.IsRunningTest()){
            ApprovalJobTimeMIn=integer.valueOf(System.Label.ApproverElapsedTimeInHoursMax)-1;
            ApprovalJobTimeMax=integer.valueOf(System.Label.ApproverElapsedTimeInHoursMax);
            ApprovalInterval = 24;
            ApprovalJobTimeMIn_ACS = 48;
        }
        else{
            ApprovalJobTimeMIn=0;
            ApprovalJobTimeMax=0.00058;
            ApprovalJobTimeMIn_ACS = 0.00058;
            ApprovalInterval = 0.1;
        }
        
        /***Edited by ACS as a part of request 25080 associated with release
        EME - ACS Support Services - Release #7 - 2016 - July- 19*********/
        for(ProcessInstance pi:[SELECT Id, Status,TargetObjectId,TargetObject.Name ,(SELECT Id, ActorId,ElapsedTimeInHours, ProcessInstanceId FROM Workitems)  FROM ProcessInstance where  status=:System.Label.ProcessInstanceStatus1 and ProcessDefinition.TableEnumOrId =: 'Case'])//Pending
        {
            //string idvall=cid.get(pi.TargetObjectId);
            string idvall=pi.TargetObject.Name;
            if(pi.Workitems.size()>0){
                for(ProcessInstanceWorkItem pwi: pi.workitems){
                    //system.debug(pwi.ElapsedTimeInHours);
                    if(pwi.ElapsedTimeInHours >= ApprovalJobTimeMIn && pwi.ElapsedTimeInHours < = ApprovalJobTimeMax){// between 47- 48 hrs
                        wiList.add(pwi);
                    }else if(pwi.ElapsedTimeInHours > ApprovalJobTimeMIn_ACS){// greater than 48 hrs
                        wi1List.add(pwi);
                    } 
                }
                if(!wiList.isEmpty())
                    wi.put(pi.TargetObjectId+''+idvall,wiList);
                if(!wi1List.isEmpty())
                    wi1.put(pi.TargetObjectId+''+idvall,wi1List);
            }
            //empty the lists
            wiList = new List<ProcessInstanceWorkItem>();
            wi1List = new List<ProcessInstanceWorkItem>();
        }
        
        for(User u:[SELECT Id, LastName, FirstName, Name, CompanyName, Title, Street, City, Email, IsActive, UserType FROM User where IsActive=true ])
        {
            umap.put(u.id,u);
        }
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC){
       query='select flagNo__c, id, lastmodifieddate,CaseNumber, Case_Approval_Rule__c, GC_Max_CA_Amt_USD__c, Approval_Steps__c, reason, Parallel_Sequential__c, GC_Secondary_Reason_Descr__c,GC_Prdt_Group_Descr__c,GC_Sales_District_Descr__c,Approver1__c ,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c ,Approver10__c,recordtypeid,Approval_Validation_1__c from case where Approval_Validation_1__c=true and   recordtypeid = \''+System.Label.ServicecaseRTId+'\'';// approval type =Automatic and record type =service
        return Database.getQueryLocator(query); 
    }
         
    global void execute(Database.BatchableContext BC, List<Case> cScope){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Case> listCaseToUpdate = new List<Case>();
        for(Case c:cScope)
        {   
            if(wi.keySet().contains(c.id+''+c.CaseNumber ) && (c.flagNo__c == 0 || c.flagNo__c == null)){// 1st reminder mail if elapsed time between 47 to 48 hrs
                List<ProcessInstanceWorkitem>PIW=new  List<ProcessInstanceWorkitem>();
                PIW.addAll(wi.get(c.id+''+c.CaseNumber));
                for(ProcessInstanceWorkitem  w:PIW)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(w.ActorId);
                    mail.setTemplateId(System.Label.ACS_EmailTemplateId);
                    mail.setWhatId(c.id);    
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setSaveAsActivity(false);
                    mailList.add(mail);       
                }
                /***Added by ACS as a part of request 25080 associated with release
                 EME - ACS Support Services - Release #7 - 2016 - July- 19*********/
                if(c.flagNo__c == null || c.flagNo__c == 0){
                    c.flagNo__c = 1;
                    listCaseToUpdate.add(c);
                }
            }else if (wi1.keySet().contains(c.id+''+c.CaseNumber)){// send reminder mail every 24 hrs if elapsed time is greater than 48 hrs
                if(c.flagNo__c != null && c.flagNo__c != 0){
                    //ApprovalJobTimeMIn_Rem = (2+(c.flagNo__c*1))-1;
                    //ApprovalJobTimeMax_Rem = 2+(c.flagNo__c*1);
                    ApprovalJobTimeMIn_Rem = (ApprovalJobTimeMIn_ACS+(c.flagNo__c*ApprovalInterval))-1;
                    ApprovalJobTimeMax_Rem = ApprovalJobTimeMIn_ACS+(c.flagNo__c*ApprovalInterval);
                    if(wi1.get(c.id+''+c.CaseNumber)[0].ElapsedTimeInHours > ApprovalJobTimeMIn_Rem && wi1.get(c.id+''+c.CaseNumber)[0].ElapsedTimeInHours < ApprovalJobTimeMax_Rem){
                        List<ProcessInstanceWorkitem> PIW = new  List<ProcessInstanceWorkitem>();
                        PIW.addAll(wi1.get(c.id+''+c.CaseNumber));
                        for(ProcessInstanceWorkitem  w:PIW)
                        {  
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(w.ActorId);
                            mail.setTemplateId(System.Label.ACS_EmailTemplateId);
                            mail.setWhatId(c.id);    
                            mail.setBccSender(false);
                            mail.setUseSignature(false);
                            mail.setSaveAsActivity(false);
                            mailList.add(mail);       
                        }   
                        c.flagNo__c = c.flagNo__c + 1;
                        listCaseToUpdate.add(c);
                    }
                }
            }
        }               
        try
        {
          Messaging.sendEmail(mailList);
          Database.update(listCaseToUpdate);
        }
        Catch (Exception e){}
    }
        
    global void finish(Database.BatchableContext BC)
    { 
    }
}