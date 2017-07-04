/***************************************
Organization: Accenture
Associated Trigger: VFP_ManualApproval
****************************************/
public class VFC_ManualApproval {
public String ParallelSequential{get;set;}
public case casedetail{get;set;}
public case colddata{get;set;}
public case cNew{get;set;}
public case cEdit{get;set;}
public boolean inputblock{get;set;}
public boolean outputblock{get;set;}
public boolean hide{get;set;}
public boolean EditButton{get;set;}
    public VFC_ManualApproval(ApexPages.StandardController controller) 
    {
        hide=false;
        casedetail=(case)controller.getRecord();
        cNew=[select id,Approval_Validation_1__c,Approval_Type__c,Approval_Steps__c,Parallel_Sequential__c,Approver1__c,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c,Approver10__c   from case where id=:casedetail.id];
        cEdit=[select id,Approval_Validation_1__c,Approval_Type__c,Approval_Steps__c,Parallel_Sequential__c,Approver1__c,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c,Approver10__c   from case where id=:casedetail.id];
        
        if(cEdit.Approval_Type__c==System.Label.ACS_Manual ) //&& (cEdit.Parallel_Sequential__c=='Parallel' || cEdit.Parallel_Sequential__c=='Sequential')
        {
            hide=true;
            
            outputblock=true;
            inputblock=false;
            EditButton=true;
            if(cEdit.Approval_Validation_1__c==true)
            {
               EditButton=false;
            }
            
            if(cEdit.Parallel_Sequential__c==System.Label.ACS_Parallel && cEdit.Approval_Steps__c!=null)
            {
                if(cEdit.Approval_Steps__c==1)
                {
                    cEdit.Approver2__c=cEdit.Approver3__c=cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==2)
                {
                    cEdit.Approver3__c=cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==3)
                {
                    cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==4)
                {
                    cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==5)
                {
                    cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==6)
                {
                    cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==7)
                {
                    cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==8)
                {
                    cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==9)
                {
                    cEdit.Approver10__c=null;       
                }
            }
            
        }      
       
    }
    
    
    public void saveFinal()
    {   
       //cNew=new case();
        //PageReference pageRef = ApexPages.currentPage();
        //pageRef.setRedirect(true);
        system.debug('test-----------inside');
        string urll=URL.getSalesforceBaseUrl().toExternalForm()+'/'+cEdit.id;
        
        if(cEdit.Parallel_Sequential__c!=null)
        {
             cNew.Parallel_Sequential__c=cEdit.Parallel_Sequential__c;
             integer i=0;
             if(cEdit.Approver1__c!=null )
             {
                 cNew.Approval_Steps__c=1;
                 cNew.Approver1__c=cEdit.Approver1__c;
                 
             }
             else if(cEdit.Approver1__c==null && cEdit.Approver2__c==null && cEdit.Approver3__c==null && cEdit.Approver4__c==null && cEdit.Approver5__c==null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 cNew.Approver1__c=null;
                 cNew.Approval_Steps__c=0;
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Atlease one Approver Value is required to save this record'));
                 outputblock=false;
                 inputblock=true;
                 EditButton=false;
             }
             
             if(cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 system.debug('inside 2----'+cEdit.Approver2__c);
                 cNew.Approval_Steps__c=2;
                 cNew.Approver2__c=cEdit.Approver2__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c==null && cEdit.Approver3__c==null && cEdit.Approver4__c==null && cEdit.Approver5__c==null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver2__c=cNew.Approver3__c=cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver1__c;       
                 }
                 else
                 {
                     cNew.Approver2__c=cNew.Approver3__c=cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             { system.debug('--inside 3rd---'+cNew.Approver3__c);
                 cNew.Approval_Steps__c=3;
                 cNew.Approver3__c=cEdit.Approver3__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c==null && cEdit.Approver4__c==null && cEdit.Approver5__c==null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {   system.debug('--inside null 3rd---'+cNew.Approver3__c);
                     cNew.Approver3__c=cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver2__c;       
                 }
                 else
                 {
                     cNew.Approver3__c=cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {  system.debug('--inside 4rd---'+cNew.Approver4__c);
                 cNew.Approval_Steps__c=4;
                 cNew.Approver4__c=cEdit.Approver4__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c==null && cEdit.Approver5__c==null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {  system.debug('--inside null 4th---'+cNew.Approver4__c);
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver3__c;       
                 }
                 else
                 {
                     cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 cNew.Approval_Steps__c=5;
                 cNew.Approver5__c=cEdit.Approver5__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c==null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver4__c;       
                 }
                 else
                 {
                     cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver6__c!=null && cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 cNew.Approval_Steps__c=6;
                 cNew.Approver6__c=cEdit.Approver6__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c!=null && cEdit.Approver6__c==null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver5__c;       
                 }
                 else
                 {
                     cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             
             if(cEdit.Approver7__c!=null && cEdit.Approver6__c!=null && cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null) 
             {
                 cNew.Approval_Steps__c=7;
                 cNew.Approver7__c=cEdit.Approver7__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c!=null && cEdit.Approver6__c!=null && cEdit.Approver7__c==null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver6__c;       
                 }
                 else
                 {
                     cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver8__c!=null && cEdit.Approver7__c!=null && cEdit.Approver6__c!=null && cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 cNew.Approval_Steps__c=8;
                 cNew.Approver8__c=cEdit.Approver8__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c!=null && cEdit.Approver6__c!=null && cEdit.Approver7__c!=null && cEdit.Approver8__c==null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver7__c;       
                 }
                 else
                 {
                     cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
             if(cEdit.Approver9__c!=null && cEdit.Approver8__c!=null && cEdit.Approver7__c!=null && cEdit.Approver6__c!=null && cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 cNew.Approval_Steps__c=9;
                 cNew.Approver9__c=cEdit.Approver9__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c!=null && cEdit.Approver6__c!=null && cEdit.Approver7__c!=null && cEdit.Approver8__c!=null && cEdit.Approver9__c==null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver9__c=cNew.Approver10__c=cEdit.Approver8__c;       
                 }
                 else
                 {
                     cNew.Approver9__c=cNew.Approver10__c=null;       
                 }
             }
    
             if(cEdit.Approver10__c!=null && cEdit.Approver9__c!=null && cEdit.Approver8__c!=null && cEdit.Approver7__c!=null && cEdit.Approver6__c!=null && cEdit.Approver5__c!=null && cEdit.Approver4__c!=null && cEdit.Approver3__c!=null && cEdit.Approver2__c!=null && cEdit.Approver1__c!=null)
             {
                 cNew.Approval_Steps__c=10;
                 cNew.Approver10__c=cEdit.Approver10__c;
             }
             else if(cEdit.Approver1__c!=null &cEdit.Approver2__c!=null && cEdit.Approver3__c!=null && cEdit.Approver4__c!=null && cEdit.Approver5__c!=null && cEdit.Approver6__c!=null && cEdit.Approver7__c!=null && cEdit.Approver8__c!=null && cEdit.Approver9__c!=null && cEdit.Approver10__c==null)
             {
                 if(cNew.Parallel_Sequential__c==System.Label.ACS_Parallel)
                 {
                     cNew.Approver10__c=cEdit.Approver9__c;       
                 }
                 else
                 {
                     cNew.Approver10__c=null;       
                 }
             }
             if(cNew.Approver1__c!=null)
             {
                 //cNew.id=cEdit.id;
                 update cNew;
                 outputblock=true;
                 inputblock=false;
                 EditButton=true;
             }   
             system.debug('cNew---------------------'+cNew);
             //PageReference pageRef = new PageReference(urll);
            // pageRef.setRedirect(true);
             //return pageRef;
        } 
        else
        {
            cNew.Parallel_Sequential__c=null;
            cNew.Approval_Steps__c=0;
            cNew.Approver1__c=cNew.Approver2__c=cNew.Approver3__c=cNew.Approver4__c=cNew.Approver5__c=cNew.Approver6__c=cNew.Approver7__c=cNew.Approver8__c=cNew.Approver9__c=cNew.Approver10__c=null;
            cEdit.Approver1__c=cEdit.Approver2__c=cEdit.Approver3__c=cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;
            update cNew;
            outputblock=true;
            inputblock=false;
            EditButton=true;
            
            //PageReference pageRef = new PageReference(urll);
            //pageRef.setRedirect(true);
            //return pageRef;
        } 
        //PageReference pageRef = new PageReference(ApexPages.currentPage());
       
             system.debug('cEdit.Parallel_Sequential__c---------------------'+cEdit.Parallel_Sequential__c);
             
         
      // return null;
        
        
    }
    public void Edit()
    {
        cEdit=new case();
        cEdit=[select id,Approval_Validation_1__c,Approval_Steps__c,Parallel_Sequential__c,Approver1__c,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c,Approver10__c   from case where id=:casedetail.id];
        
        if(cEdit.Parallel_Sequential__c==System.Label.ACS_Parallel && (cEdit.Approval_Steps__c!=0 || cEdit.Approval_Steps__c!=null ))
            {
                if(cEdit.Approval_Steps__c==1)
                {
                    cEdit.Approver2__c=cEdit.Approver3__c=cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==2)
                {
                    cEdit.Approver3__c=cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==3)
                {
                    cEdit.Approver4__c=cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==4)
                {
                    cEdit.Approver5__c=cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==5)
                {
                    cEdit.Approver6__c=cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==6)
                {
                    cEdit.Approver7__c=cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==7)
                {
                    cEdit.Approver8__c=cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==8)
                {
                    cEdit.Approver9__c=cEdit.Approver10__c=null;       
                }
                else if(cEdit.Approval_Steps__c==9)
                {
                    cEdit.Approver10__c=null;       
                }
            }
           
         if(cEdit.Approval_Validation_1__c==true)
            {
                 EditButton=false;
                 outputblock=true;
                 inputblock=false;
            }
         else
         {
             EditButton=false;
             outputblock=false;
             inputblock=true; 
         }   
    }
    
       public void Cancel(){
        //cEdit=[select id,Approval_Validation_1__c,Approval_Type__c,Approval_Steps__c,Parallel_Sequential__c,Approver1__c,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c,Approver10__c   from case where id=:casedetail.id];
         EditButton=true;
         outputblock=true;
         inputblock=false;
       }
}