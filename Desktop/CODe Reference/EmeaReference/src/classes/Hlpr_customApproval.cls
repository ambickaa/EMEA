/***************************************
Organization: Accenture
Associated Trigger: CustomApprovalRule
****************************************/

public with sharing class Hlpr_customApproval
{
    
     Public static List<Case> beforeupdate(List<Case> cList,map<id,case>cMap)
    {    
           List<case> cNew = new List<case>();
           List<Case> cID=[select id, lastmodifieddate, Approval_Type__c,Case_Approval_Rule__c, GC_Max_CA_Amt_USD__c, Approval_Steps__c, reason, Parallel_Sequential__c, GC_Secondary_Reason_Descr__c,GC_Prdt_Group_Descr__c,GC_Sales_District_Descr__c,Approver1__c ,Approver2__c ,Approver3__c ,Approver4__c ,Approver5__c ,Approver6__c ,Approver7__c ,Approver8__c ,Approver9__c ,Approver10__c from case where  id in : cList];
           for(case c:cList)
           {     
               if(c.recordtypeid == System.Label.ServicecaseRTId)
               {
                    if(cMap.Keyset().contains(c.id) &&  c.Approval_Type__c==System.Label.ACS_Manual)//Manual
                    {
                        if(c.Approval_Type__c!= cMap.get(c.id).Approval_Type__c && c.Approval_Type__c==System.Label.ACS_Manual)//&& cMap.get(c.id).Approval_Type__c!=null)
                        {
                            if(c.Approver1__c!=null)
                            {
                                c.Case_Approval_Rule__c=null;
                                c.Approval_Steps__c=null;
                                c.Parallel_Sequential__c='';
                                c.Approver1__c=c.Approver2__c=c.Approver3__c=c.Approver4__c=c.Approver5__c=c.Approver6__c=c.Approver7__c=c.Approver8__c=c.Approver9__c=c.Approver10__c =null;
                                cNew.add(c);
                            }
                        }
                    }
               }
           }
    return Null;
    }
    
    Public static List<Case> beforeinsertupdate(List<Case> cList)
    {
        set<ID> caseIds = new set<Id>();
        List<case> cNew = new List<case>();
        List<case> cNew1 = new List<case>();
        List<Case> cID=new List<Case>();
        List<String> strCaseReason = new List<String>();
        List<String> strProduct_Group = new List<String>();
        List<String> strSales_District = new List<String>();
        List<Decimal> intGC_Max_CA_Amt_USD = new List<Decimal>();
        List<String> strSecondary_Reason =  new List<String>();
        
        for(Case c1:cList)
        {
           if(c1.recordtypeid == System.Label.ServicecaseRTId)// record type Label already made in emea
           {    
                // Validation rule for the request--1692 and AI: AI-1120 & AI-1121
                String sBreak ='\nThe following fields are mandatory to be filled out when submitting a case for approval';
               if(c1.Approval_Validation_1__c==True)
               { 
                   if(c1.Reason==System.Label.ACS_Programs_Compensation)
                   {         
                       if(c1.GC_Secondary_Reason_Descr__c==System.Label.ACS_Customer_Accommodation)
                       {
                            if(c1.AccountId==null){sBreak=sBreak+'\n'+System.Label.ACS_Account_Name;}
                            if(c1.Account_SAP_Number__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Account_SAP_Number;}
                            if(c1.OwnerId==null){sBreak=sBreak+'\n'+System.Label.ACS_Case_Owner;}
                            if(c1.GC_No_ofCust_for_CA__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Number_of_Customers_for_CA;}
                            if(c1.GC_Sales_Org_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Sales_Org;}
                            if(c1.GC_Sales_District_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Sales_District;}
                            if(c1.GC_Division_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Division;}
                            if(c1.GC_Prdt_Group_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Product_Group;}
                            if(c1.GC_CA_Frmt_descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_CA_Format;}
                            if(c1.GC_CA_Reason_descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_CA_Reason;}
                            if(c1.GC_Currency_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Local_Currency_LC;}
                            if(c1.GC_Amount_in_LC_Currncy__c==null){sBreak=sBreak+'\n'+System.Label.ACS_CA_Amount_in_LC;}
                            if(c1.GC_CA_Amount_in_USD__c==null){sBreak=sBreak+'\n'+System.Label.ACS_CA_Amount_in_USD;}
                            if(c1.GC_Max_CA_Amt_LC__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Max_CA_Amount_x_Customer_in_LC;}
                            if(c1.GC_Max_CA_Amt_USD__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Max_CA_Amount_x_Customer_in_USD;}
                        }
                       if(c1.GC_Secondary_Reason_Descr__c==System.Label.ACS_Rebate_Settlements)
                       {
                            if(c1.AccountId==null){sBreak=sBreak+'\n'+System.Label.ACS_Account_Name;}
                            if(c1.OwnerId==null){sBreak=sBreak+'\n'+System.Label.ACS_Case_Owner;}
                            //if(c1.GC_No_ofCust_for_CA__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Number_of_Customers_for_CA;}
                            if(c1.GC_Sales_Org_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Sales_Org;}
                            if(c1.GC_Sales_District_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Sales_District;}
                            if(c1.GC_Division_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Division;}
                            if(c1.GC_Prdt_Group_Descr__c==null){sBreak=sBreak+'\n'+System.Label.ACS_Product_Group;}
                       }
                    }   
                
                   
                  if(sBreak!='\nThe following fields are mandatory to be filled out when submitting a case for approval')
                   {  
                       c1.addError(sBreak);
                   }   
               }
                
                if(c1.Approval_Type__c == System.Label.ACS_Automated && c1.Approval_Validation_1__c==False)//Automatic
                {
                    cID.add(c1);
                    strCaseReason.add(c1.reason);
                    strSecondary_Reason.add(c1.GC_Secondary_Reason_Descr__c);
                    strProduct_Group.add(c1.GC_Prdt_Group_Descr__c);
                    strSales_District.add(c1.GC_Sales_District_Descr__c);
                    intGC_Max_CA_Amt_USD.add(c1.GC_Max_CA_Amt_USD__c);
                }
            }
            
        }
        List<Case_Approval_Rule__c> DOA_List = [select id ,Product_Group__c,Sales_District__c,Approval_Amount_Min__c,Approval_Amount_Max__c,Approval_Steps__c,Parallel_Sequential__c,Case_Reason__c,Secondary_Reason__c,Approver1__c,Approver2__c,Approver3__c,Approver4__c,Approver5__c,Approver6__c,Approver7__c,Approver8__c,Approver9__c,Approver10__c,lastmodifieddate  from Case_Approval_Rule__c where Case_Reason__c in :strCaseReason and Secondary_Reason__c in :strSecondary_Reason and Product_Group__c in :strProduct_Group and Sales_District__c in :strSales_District order by lastmodifieddate DESC];
        system.debug('Case Approval Rule Record Count ----------'+DOA_List.size() );
        
        for(Case c:cID)
        {              
             if(DOA_List.size()>0)
             { integer i=0;
                for(Case_Approval_Rule__c doa : DOA_List)
                { i++; 
                    if( c.GC_Max_CA_Amt_USD__c >= doa.Approval_Amount_Min__c &&  c.GC_Max_CA_Amt_USD__c<=doa.Approval_Amount_Max__c && c.reason == doa.Case_Reason__c &&  c.GC_Secondary_Reason_Descr__c== doa.Secondary_Reason__c && c.GC_Prdt_Group_Descr__c==doa.Product_Group__c && c.GC_Sales_District_Descr__c==doa.Sales_District__c )
                    {    
                        if(doa.Parallel_Sequential__c==System.Label.ACS_Sequential)//sequential
                        {
                              system.debug('inside IF sequential');
                              system.debug('c.Approver1__c0='+c.Approver1__c);
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
                              cNew1.add(c);
                              break;
                        }
                        else if(doa.Parallel_Sequential__c==System.Label.ACS_Parallel)//parallel
                       {
                            system.debug('inside IF Paralle all different steps');
                            system.debug('c.Approver1__c1='+c.Approver1__c);  
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
                        break;
                        }
                    } 
                   //testing still
                    else if(c.id!=null && (c.GC_Max_CA_Amt_USD__c <= doa.Approval_Amount_Min__c ||  c.GC_Max_CA_Amt_USD__c>=doa.Approval_Amount_Max__c))
                    {
                      system.debug('inside ELSE of ALL');
                      system.debug('c.Approver1__c2='+c.Approver1__c);  
                      c.Case_Approval_Rule__c=null;
                      c.Approval_Steps__c=null;
                      c.Parallel_Sequential__c='';
                      c.Approver1__c=c.Approver2__c=c.Approver3__c=c.Approver4__c=c.Approver5__c=c.Approver6__c=c.Approver7__c=c.Approver8__c=c.Approver9__c=c.Approver10__c =null;
                      cNew1.add(c);
                     
                    }
                }system.debug('i------------------'+i);
                     
            }
            else
            {
              system.debug('inside ELSE of ALL');
              system.debug('c.Approver1__c3='+c.Approver1__c);  
              c.Case_Approval_Rule__c=null;
              c.Approval_Steps__c=null;
              c.Parallel_Sequential__c='';
              c.Approver1__c=c.Approver2__c=c.Approver3__c=c.Approver4__c=c.Approver5__c=c.Approver6__c=c.Approver7__c=c.Approver8__c=c.Approver9__c=c.Approver10__c =null;
              cNew1.add(c);
              
            }
  
        }

        return cNew1; 
    }
}