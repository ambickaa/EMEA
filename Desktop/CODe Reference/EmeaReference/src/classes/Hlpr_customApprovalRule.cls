/***************************************
Organization: Accenture
Associated Trigger: CustomApprovalRule
****************************************/

public class Hlpr_customApprovalRule 
{

    Public static void AfterUpdate(List<Case_Approval_Rule__c> carListNew )
    {   
        
       
        List<Case> clist = new List<Case>();
        List<Case> cNew = new List<Case>();
        List<Case_Approval_Rule__c> listCarIn = new List <Case_Approval_Rule__c>();        
        List<String> strCaseReason = new List<String>();
        List<String> strProduct_Group = new List<String>();
        List<String> strSales_District = new List<String>();
        List<Decimal> intGC_Max_CA_Amt_USD = new List<Decimal>();
        List<String> strSecondary_Reason =  new List<String>();
        List<String> strParallel_Sequential = new List<String>();
        
       
        Map<Id,Case_Approval_Rule__c> carListNewMap = new Map<Id,Case_Approval_Rule__c>(carListNew);
        // To know if the case is in approval process and is locked
        Set<id>casesetlockstatus = new Set<id>();
        
        for(ProcessInstance pi:[SELECT Id, Status,TargetObjectId FROM ProcessInstance where  status=:System.Label.ProcessInstanceStatus1])//Pending
        {
           casesetlockstatus.Add(pi.TargetObjectId);
        }
        for(Case_Approval_Rule__c car : carListNew)
            {

            strCaseReason.add(car.Case_Reason__c);
            strSecondary_Reason.add(car.Secondary_Reason__c);
            strSales_District.add(car.Sales_District__c);
            strProduct_Group.add(car.Product_Group__c);
            }
            
            Map<Id,Case_Approval_Rule__c> mappCar = new Map<Id,Case_Approval_Rule__c>([select id ,Product_Group__c,Sales_District__c,Approval_Amount_Min__c,Approval_Amount_Max__c,Approval_Steps__c,Parallel_Sequential__c,Case_Reason__c,Secondary_Reason__c,Approver1__c,Approver2__c,Approver3__c,Approver4__c,Approver5__c,Approver6__c,Approver7__c,Approver8__c,Approver9__c,Approver10__c,lastmodifieddate  from Case_Approval_Rule__c where Case_Reason__c in :strCaseReason and Secondary_Reason__c in :strSecondary_Reason and Product_Group__c in :strProduct_Group and Sales_District__c in :strSales_District order by lastmodifieddate ASC]);            
            system.debug('map size of car is ' + mappcar.values().size());
            clist = [select id, lastmodifieddate, Case_Approval_Rule__c, GC_Max_CA_Amt_USD__c, Approval_Steps__c, reason, Parallel_Sequential__c, GC_Secondary_Reason_Descr__c,GC_Prdt_Group_Descr__c,GC_Sales_District_Descr__c,Approver1__c ,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c ,Approver10__c from case where Approval_Type__c='Automated' and (Case_Approval_Rule__c = null or Case_Approval_Rule__c In : mappCar.keySet() ) and recordtypeid=:System.Label.ServicecaseRTId order by lastmodifieddate Asc ] ; 
            //clist = [select id, lastmodifieddate, Case_Approval_Rule__c, GC_Max_CA_Amt_USD__c, Approval_Steps__c, reason, Parallel_Sequential__c, GC_Secondary_Reason_Descr__c,GC_Prdt_Group_Descr__c,GC_Sales_District_Descr__c,Approver1__c ,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c ,Approver10__c,recordtypeid from case where Approval_Type__c=:System.Label.ACS_Automated and  recordtypeid=:System.Label.ServicecaseRTId  order by lastmodifieddate Asc ] ; //approval type =automatic and record type is service
            system.debug('cList size check for case without paralle or seq defined ' + cLIst.size());
            
            
        integer i=0;  
        for(case c: cList) 
        { 
            
            i++;
            system.debug('------------'+c);
            if(!casesetlockstatus.contains(c.id))
              {              
                for(Case_Approval_Rule__c DOA: carListNew )
                {
                    if(DOA.Parallel_Sequential__c == null && c.Case_Approval_Rule__c == DOA.id && c.GC_Max_CA_Amt_USD__c >= doa.Approval_Amount_Min__c &&  c.GC_Max_CA_Amt_USD__c<=doa.Approval_Amount_Max__c && c.reason == doa.Case_Reason__c &&  c.GC_Secondary_Reason_Descr__c== doa.Secondary_Reason__c && c.GC_Prdt_Group_Descr__c==doa.Product_Group__c && c.GC_Sales_District_Descr__c==doa.Sales_District__c)
                    {
                        system.debug(' inside ELSE of ALL 1');
                        c.Case_Approval_Rule__c=null;
                        c.Approval_Steps__c=null;
                        c.Parallel_Sequential__c='';
                      
                        c.Approver1__c =null;
                        c.Approver2__c =null;
                        c.Approver3__c =null;
                        c.Approver4__c =null;
                        c.Approver5__c =null;
                        c.Approver6__c =null;
                        c.Approver7__c =null;
                        c.Approver8__c =null;
                        c.Approver9__c =null;
                        c.Approver10__c=null;
                        cNew.add(c);
                        break;
                    }
                    else if(c.Case_Approval_Rule__c == DOA.id && c.GC_Max_CA_Amt_USD__c >= doa.Approval_Amount_Min__c &&  c.GC_Max_CA_Amt_USD__c<=doa.Approval_Amount_Max__c && c.reason == doa.Case_Reason__c &&  c.GC_Secondary_Reason_Descr__c== doa.Secondary_Reason__c && c.GC_Prdt_Group_Descr__c==doa.Product_Group__c && c.GC_Sales_District_Descr__c==doa.Sales_District__c)
                    {
                        if(doa.Parallel_Sequential__c==System.Label.ACS_Sequential)//sequential
                        {
                          system.debug('inside IF sequential');
                          c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                          c.Case_Approval_Rule__c=doa.id;
                          c.Approval_Steps__c = doa.Approval_Steps__c;
                          c.Approver1__c = doa.Approver1__c;
                          c.Approver2__c = doa.Approver2__c;
                          c.Approver3__c = doa.Approver3__c;
                          c.Approver4__c = doa.Approver4__c;
                          c.Approver5__c = doa.Approver5__c;
                          c.Approver6__c = doa.Approver6__c;
                          c.Approver7__c = doa.Approver7__c;
                          c.Approver8__c = doa.Approver8__c;
                          c.Approver9__c = doa.Approver9__c;
                          c.Approver10__c = doa.Approver10__c;
                          cNew.add(c);
                          
                        }
                  
                        else if(doa.Parallel_Sequential__c==System.Label.ACS_Parallel)//parallel
                        {
                            system.debug('inside IF Paralle all different steps');
                            if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c!=null )
                            {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver9__c;c.Approver10__c = doa.Approver10__c;
                              cNew.add(c);
                            }//All Values are there
                            else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c==null )
                            {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver9__c;c.Approver10__c = doa.Approver9__c;
                              cNew.add(c);
                            }// except 9 all are Null
                            else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c==null && doa.Approver10__c==null )
                            {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver8__c;c.Approver10__c = doa.Approver8__c;
                                 cNew.add(c);
                            }//except 8 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver7__c;c.Approver7__c = doa.Approver7__c;c.Approver10__c = doa.Approver8__c;
                                  cNew.add(c);
                              }//except 7 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver6__c;c.Approver8__c = doa.Approver6__c;c.Approver9__c = doa.Approver6__c;c.Approver10__c = doa.Approver6__c;
                                 cNew.add(c);
                              }//except 6 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver5__c;c.Approver7__c = doa.Approver5__c;c.Approver8__c = doa.Approver5__c;c.Approver9__c = doa.Approver5__c;c.Approver10__c = doa.Approver5__c;
                                 cNew.add(c);
                              }//except 5 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {   
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver4__c;c.Approver6__c = doa.Approver4__c;c.Approver7__c = doa.Approver4__c;c.Approver8__c = doa.Approver4__c;c.Approver9__c = doa.Approver4__c;c.Approver10__c = doa.Approver4__c;
                                  cNew.add(c);
                              }//except 4 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver3__c;c.Approver5__c = doa.Approver3__c;c.Approver6__c = doa.Approver3__c;c.Approver7__c = doa.Approver3__c;c.Approver8__c = doa.Approver3__c;c.Approver9__c = doa.Approver3__c;c.Approver10__c = doa.Approver3__c;
                                  cNew.add(c);
                              }//except 3 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver2__c;c.Approver4__c = doa.Approver2__c;c.Approver5__c = doa.Approver2__c;c.Approver6__c = doa.Approver2__c;c.Approver7__c = doa.Approver2__c;c.Approver8__c = doa.Approver2__c;c.Approver9__c = doa.Approver2__c;c.Approver10__c = doa.Approver2__c;
                                  cNew.add(c);
                              }//except 2 all are Null
                              else if(doa.Approver1__c!=null && doa.Approver2__c==null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                              {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver1__c;c.Approver3__c = doa.Approver1__c;c.Approver4__c = doa.Approver1__c;c.Approver5__c = doa.Approver1__c;c.Approver6__c = doa.Approver1__c;c.Approver7__c = doa.Approver1__c;c.Approver8__c = doa.Approver1__c;c.Approver9__c = doa.Approver1__c;c.Approver10__c = doa.Approver1__c;
                                 cNew.add(c);
                              }//except 1 all are Null
                             
                        }
                         break;
                    }
                    else if(c.GC_Max_CA_Amt_USD__c >= doa.Approval_Amount_Min__c &&  c.GC_Max_CA_Amt_USD__c<=doa.Approval_Amount_Max__c && c.reason == doa.Case_Reason__c &&  c.GC_Secondary_Reason_Descr__c== doa.Secondary_Reason__c && c.GC_Prdt_Group_Descr__c==doa.Product_Group__c && c.GC_Sales_District_Descr__c==doa.Sales_District__c)
                    {
                        if(doa.Parallel_Sequential__c==System.Label.ACS_Sequential)//sequential
                        {
                              system.debug('inside IF sequential');
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver8__c = doa.Approver8__c;
                              c.Approver9__c = doa.Approver9__c;
                              c.Approver10__c = doa.Approver10__c;
                              cNew.add(c);
                              
                        }
                  
                        else if(doa.Parallel_Sequential__c==System.Label.ACS_Parallel)//Parallel
                        {
                          system.debug('inside IF Paralle all different steps');
                          if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c!=null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver8__c = doa.Approver8__c;
                              c.Approver9__c = doa.Approver9__c;
                              c.Approver10__c = doa.Approver10__c;
                             cNew.add(c);
                          }//All Values are there
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver8__c = doa.Approver8__c;
                              c.Approver9__c = doa.Approver9__c;
                              c.Approver10__c = doa.Approver9__c;
                              cNew.add(c);
                          }// except 9 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver8__c = doa.Approver8__c;
                              c.Approver9__c = doa.Approver8__c;
                              c.Approver10__c = doa.Approver8__c;
                              cNew.add(c);
                          }//except 8 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver8__c = doa.Approver7__c;
                              c.Approver7__c = doa.Approver7__c;
                              c.Approver10__c = doa.Approver8__c;
                              cNew.add(c);
                          }//except 7 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver6__c;
                              c.Approver7__c = doa.Approver6__c;
                              c.Approver8__c = doa.Approver6__c;
                              c.Approver9__c = doa.Approver6__c;
                              c.Approver10__c = doa.Approver6__c;
                              cNew.add(c);
                          }//except 6 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver5__c;
                              c.Approver6__c = doa.Approver5__c;
                              c.Approver7__c = doa.Approver5__c;
                              c.Approver8__c = doa.Approver5__c;
                              c.Approver9__c = doa.Approver5__c;
                              c.Approver10__c = doa.Approver5__c;
                              cNew.add(c);
                          }//except 5 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {   
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver4__c;
                              c.Approver5__c = doa.Approver4__c;
                              c.Approver6__c = doa.Approver4__c;
                              c.Approver7__c = doa.Approver4__c;
                              c.Approver8__c = doa.Approver4__c;
                              c.Approver9__c = doa.Approver4__c;
                              c.Approver10__c = doa.Approver4__c;
                              cNew.add(c);
                          }//except 4 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver3__c;
                              c.Approver4__c = doa.Approver3__c;
                              c.Approver5__c = doa.Approver3__c;
                              c.Approver6__c = doa.Approver3__c;
                              c.Approver7__c = doa.Approver3__c;
                              c.Approver8__c = doa.Approver3__c;
                              c.Approver9__c = doa.Approver3__c;
                              c.Approver10__c = doa.Approver3__c;
                             cNew.add(c);
                          }//except 3 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver2__c;
                              c.Approver3__c = doa.Approver2__c;
                              c.Approver4__c = doa.Approver2__c;
                              c.Approver5__c = doa.Approver2__c;
                              c.Approver6__c = doa.Approver2__c;
                              c.Approver7__c = doa.Approver2__c;
                              c.Approver8__c = doa.Approver2__c;
                              c.Approver9__c = doa.Approver2__c;
                              c.Approver10__c = doa.Approver2__c;
                              cNew.add(c);
                          }//except 2 all are Null
                          else if(doa.Approver1__c!=null && doa.Approver2__c==null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                          {
                              c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                              c.Case_Approval_Rule__c=doa.id;
                              c.Approval_Steps__c = doa.Approval_Steps__c;
                              c.Approver1__c = doa.Approver1__c;
                              c.Approver2__c = doa.Approver1__c;
                              c.Approver3__c = doa.Approver1__c;
                              c.Approver4__c = doa.Approver1__c;
                              c.Approver5__c = doa.Approver1__c;
                              c.Approver6__c = doa.Approver1__c;
                              c.Approver7__c = doa.Approver1__c;
                              c.Approver8__c = doa.Approver1__c;
                              c.Approver9__c = doa.Approver1__c;
                              c.Approver10__c = doa.Approver1__c;
                             cNew.add(c);
                          }//except 1 all are Null
                        
                        }
                        break;
                    }
                   /* else
                    {
                       system.debug('inside ELSE of ALL');
                          c.Case_Approval_Rule__c=null;
                          c.Approval_Steps__c=null;
                          c.Parallel_Sequential__c='';
                          
                          c.Approver1__c =null;
                          c.Approver2__c =null;
                          c.Approver3__c =null;
                          c.Approver4__c =null;
                          c.Approver5__c =null;
                          c.Approver6__c =null;
                          c.Approver7__c =null;
                          c.Approver8__c =null;
                          c.Approver9__c =null;
                          c.Approver10__c =null;
                         
                    }*/
                    
                    else if(c.Case_Approval_Rule__c == DOA.id )
                    {
                        boolean Flag=false;
                        if(c.GC_Max_CA_Amt_USD__c <= doa.Approval_Amount_Min__c ||  c.GC_Max_CA_Amt_USD__c >=doa.Approval_Amount_Max__c){Flag=true;}
                        if(c.reason != doa.Case_Reason__c){Flag=true;}
                        if(c.GC_Secondary_Reason_Descr__c != doa.Secondary_Reason__c){Flag=true;}
                        if(c.GC_Prdt_Group_Descr__c != doa.Product_Group__c){Flag=true;}
                        if(c.GC_Sales_District_Descr__c != doa.Sales_District__c){Flag=true;}
                        if(Flag==true){system.debug('inside ELSE of ALL');c.Case_Approval_Rule__c=null;c.Approval_Steps__c=null;c.Parallel_Sequential__c='';c.Approver1__c =c.Approver2__c =c.Approver3__c =c.Approver4__c = c.Approver5__c =c.Approver6__c =c.Approver7__c =c.Approver8__c =c.Approver9__c =null;c.Approver10__c =null;cNew.add(c);}
                    
                    }
                }
               
            }
        
        }
        checkRecursive.run5 = False; 
        database.update(cNew);
        system.debug('cNew---------'+cNew.size());
    }
     Public static void beforeDelete(List<Case_Approval_Rule__c> carList)
    {
    
        set<id> cid=new set<id>();
        List<String> strCaseReason = new List<String>();
        List<String> strProduct_Group = new List<String>();
        List<String> strSales_District = new List<String>();
        List<Decimal> intGC_Max_CA_Amt_USD = new List<Decimal>();
        List<String> strSecondary_Reason =  new List<String>();
        List<String> strParallel_Sequential = new List<String>();
        List<Case> cNew1 =  new List<Case>();
        List<Case_Approval_Rule__c> carListNew = new List<Case_Approval_Rule__c>(); 
        
        for(Case_Approval_Rule__c car : carList)
        {
            cid.add(car.id);
            strCaseReason.add(car.Case_Reason__c);
            strSecondary_Reason.add(car.Secondary_Reason__c);
            strSales_District.add(car.Sales_District__c);
            strProduct_Group.add(car.Product_Group__c);
        }
        system.debug('++++ carid is ' + cid);
        carListNew = [select id ,Product_Group__c,Sales_District__c,Approval_Amount_Min__c,Approval_Amount_Max__c,Approval_Steps__c,Parallel_Sequential__c,Case_Reason__c,Secondary_Reason__c,Approver1__c,Approver2__c,Approver3__c,Approver4__c,Approver5__c,Approver6__c,Approver7__c,Approver8__c,Approver9__c,Approver10__c,lastmodifieddate  from Case_Approval_Rule__c where ID not in :cid and Case_Reason__c in :strCaseReason and Secondary_Reason__c in :strSecondary_Reason and Product_Group__c in :strProduct_Group and Sales_District__c in :strSales_District order by lastmodifieddate DESC limit 1];
        //system.debug('++++ fetched CAR id fater deletion of OLD ' + carListNew[0].id);
        Map<Id,Case> mapCase = new Map<Id,Case>([select id,Case_Approval_Rule__c,Approval_Type__c,GC_Max_CA_Amt_USD__c,Approval_Steps__c,reason ,Parallel_Sequential__c,GC_Secondary_Reason_Descr__c,GC_Prdt_Group_Descr__c,GC_Sales_District_Descr__c,Approver1__c ,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c ,Approver10__c,recordtypeid from case where Case_Approval_Rule__c in :cid and recordtypeid=:System.Label.ServicecaseRTId  ]);
        system.debug('++++ again fetched case id is ' + mapCase.values());
        
        // To know if the case is in approval process and is locked
        Set<id>casesetlockstatus=new Set<id>();
        
        for(ProcessInstance pi:[SELECT Id, Status,TargetObjectId FROM ProcessInstance where  status=:System.Label.ProcessInstanceStatus1])//Pending
        {
           casesetlockstatus.Add(pi.TargetObjectId);
        }
        
        if(mapCase.values()!= null)
        {
            for(Case c : mapCase.values())
            {
                 if(!casesetlockstatus.contains(c.id))
                 {
                    if(carListNew.size()>0)
                    {
                        for(Case_Approval_Rule__c doa : carListNew  )
                        {
                            if(c.GC_Max_CA_Amt_USD__c >= doa.Approval_Amount_Min__c &&  c.GC_Max_CA_Amt_USD__c<=doa.Approval_Amount_Max__c && c.reason == doa.Case_Reason__c &&  c.GC_Secondary_Reason_Descr__c== doa.Secondary_Reason__c && c.GC_Prdt_Group_Descr__c==doa.Product_Group__c && c.GC_Sales_District_Descr__c==doa.Sales_District__c )
                            {     
                              system.debug('++++11 inside IF' + c);
                              if(doa.Parallel_Sequential__c == System.Label.ACS_Sequential)//sequential
                              {
                                  system.debug('inside IF sequential');
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver9__c;c.Approver10__c = doa.Approver10__c;
                                  cNew1.add(c);
                                  
                              }
                            else if(doa.Parallel_Sequential__c==System.Label.ACS_Parallel)//parallel
                            {
                                system.debug('inside IF Paralle all different steps');
                                if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c!=null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver9__c;c.Approver10__c = doa.Approver10__c;
                                  cNew1.add(c);
                                }//All Values are there
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c!=null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver9__c;c.Approver10__c = doa.Approver9__c;
                                  cNew1.add(c);
                                }// except 9 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c!=null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver8__c;c.Approver9__c = doa.Approver8__c;c.Approver10__c = doa.Approver8__c;
                                  cNew1.add(c);
                                }//except 8 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c!=null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver7__c;c.Approver8__c = doa.Approver7__c;c.Approver7__c = doa.Approver7__c;c.Approver10__c = doa.Approver8__c;
                                  cNew1.add(c);
                                }//except 7 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c!=null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver6__c;c.Approver7__c = doa.Approver6__c;c.Approver8__c = doa.Approver6__c;c.Approver9__c = doa.Approver6__c;c.Approver10__c = doa.Approver6__c;
                                  cNew1.add(c);
                                }//except 6 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c!=null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver5__c;c.Approver6__c = doa.Approver5__c;c.Approver7__c = doa.Approver5__c;c.Approver8__c = doa.Approver5__c;c.Approver9__c = doa.Approver5__c;c.Approver10__c = doa.Approver5__c;
                                  cNew1.add(c);
                                }//except 5 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c!=null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {   
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver4__c;c.Approver5__c = doa.Approver4__c;c.Approver6__c = doa.Approver4__c;c.Approver7__c = doa.Approver4__c;c.Approver8__c = doa.Approver4__c;c.Approver9__c = doa.Approver4__c;c.Approver10__c = doa.Approver4__c;
                                  cNew1.add(c);
                                }//except 4 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c!=null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver3__c;c.Approver4__c = doa.Approver3__c;c.Approver5__c = doa.Approver3__c;c.Approver6__c = doa.Approver3__c;c.Approver7__c = doa.Approver3__c;c.Approver8__c = doa.Approver3__c;c.Approver9__c = doa.Approver3__c;c.Approver10__c = doa.Approver3__c;
                                  cNew1.add(c);
                                }//except 3 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c!=null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver2__c;c.Approver3__c = doa.Approver2__c;c.Approver4__c = doa.Approver2__c;c.Approver5__c = doa.Approver2__c;c.Approver6__c = doa.Approver2__c;c.Approver7__c = doa.Approver2__c;c.Approver8__c = doa.Approver2__c;c.Approver9__c = doa.Approver2__c;c.Approver10__c = doa.Approver2__c;
                                  cNew1.add(c);
                                }//except 2 all are Null
                                else if(doa.Approver1__c!=null && doa.Approver2__c==null && doa.Approver3__c==null && doa.Approver4__c==null && doa.Approver5__c==null && doa.Approver6__c==null && doa.Approver7__c==null && doa.Approver8__c==null && doa.Approver9__c==null && doa.Approver10__c==null )
                                {
                                  c.Parallel_Sequential__c = doa.Parallel_Sequential__c;
                                  c.Case_Approval_Rule__c=doa.id;
                                  c.Approval_Steps__c = doa.Approval_Steps__c;
                                  c.Approver1__c = doa.Approver1__c;c.Approver2__c = doa.Approver1__c;c.Approver3__c = doa.Approver1__c;c.Approver4__c = doa.Approver1__c;c.Approver5__c = doa.Approver1__c;c.Approver6__c = doa.Approver1__c;c.Approver7__c = doa.Approver1__c;c.Approver8__c = doa.Approver1__c;c.Approver9__c = doa.Approver1__c;c.Approver10__c = doa.Approver1__c;
                                  cNew1.add(c);
                                }//except 1 all are Null
                                
                            }
                            break;
                          }
                          else
                          {
                            system.debug('inside ELSE of ALL');
                            c.Case_Approval_Rule__c=null;
                            c.Approval_Steps__c=null;
                            c.Parallel_Sequential__c='';
                            c.Approver1__c =c.Approver2__c=c.Approver3__c=c.Approver4__c=c.Approver5__c=c.Approver6__c=c.Approver7__c=c.Approver8__c=c.Approver9__c=c.Approver10__c=NULL; 
                            cNew1.add(c);
                           
                          }
                        }
                    }
                    else
                    {
                      system.debug('inside ELSE of ALL');
                      c.Case_Approval_Rule__c=null;
                      c.Approval_Steps__c=null;
                      c.Parallel_Sequential__c='';
                      c.Approver1__c=c.Approver2__c=c.Approver3__c=c.Approver4__c=c.Approver5__c=c.Approver6__c=c.Approver7__c=c.Approver8__c=c.Approver9__c=c.Approver10__c =null;
                      cNew1.add(c);
                   }
                }
            }
        }
                checkRecursive.run4 = False;
                database.update(cNew1);           
    }    
    
    
    
   }