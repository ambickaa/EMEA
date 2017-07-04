/*
Class name - HlprlocaltoUSDCurren
Description- Utility class for trigger Trg_BeforeinsertupdateCase 
Created By - Accenture IDC
*/
public class HlprlocaltoUSDCurren
{
    public void currencyUpdate(List<Case> cn)
    {
        For(Case c:cn)
        {
            Map<String, Exchange_Rates_Of_Currency__c> mcs = Exchange_Rates_Of_Currency__c.getall();
            List<Exchange_Rates_Of_Currency__c> mcs1 = Exchange_Rates_Of_Currency__c.getall().values();
            
            For(integer i=0;i<mcs1.size();i++)                                               
            {
                if((c.GC_Amount_in_LC_Currncy__c!=null ||c.GC_CA_Cst_LC_Currncy__c!=null||c.GC_Max_CA_Amt_LC__c!=null) && c.GC_Currency_Descr__c==null)
                {
                    c.GC_Currency_Descr__c.adderror('Please Select Currency');
                }
               /* if((c.GC_Rebate_settlement_amount_in_LC__c!=null) && c.GC_Local_currency__c==null)
                {
                    c.GC_Local_currency__c.adderror('Please Select Currency');
                }*/
                
                if(c.GC_Currency_Descr__c == mcs1[i].code__c)
                {
                    If(c.GC_Max_CA_Amt_LC__c!=null||c.GC_Amount_in_LC_Currncy__c!=null ||c.GC_CA_Cst_LC_Currncy__c!=null)
                    {
                        if(c.GC_Max_CA_Amt_LC__c==null)
                        {
                            c.GC_Max_CA_Amt_LC__c=0;
                        }
                         if(c.GC_Amount_in_LC_Currncy__c==null)
                        {
                            c.GC_Amount_in_LC_Currncy__c=0;
                        }
                        if(c.GC_CA_Cst_LC_Currncy__c==null)
                        {
                            c.GC_CA_Cst_LC_Currncy__c=0;
                        }
                        try
                        {                                                                           
                            c.GC_Max_CA_Amt_USD__c= c.GC_Max_CA_Amt_LC__c*mcs1[i].Exchange_Rates__c;
                            c.GC_CA_amount_in_USD__c=c.GC_Amount_in_LC_Currncy__c*mcs1[i].Exchange_Rates__c;
                            c.GC_CA_Additional_Cost__c =c.GC_CA_Cst_LC_Currncy__c*mcs1[i].Exchange_Rates__c;

                        }  
                        catch(Exception e)
                        {
                            c.adderror(' Use Valid Number in LC Field :');
                        }  
                    }
                }   
                else
                {
                    IF(c.GC_Max_CA_Amt_LC__c==null)
                    {
                        c.GC_Max_CA_Amt_USD__c=0;
                    }
                    IF(c.GC_CA_Cst_LC_Currncy__c==null)
                    {
                        c.GC_CA_amount_in_USD__c=0;
                    }
                    IF(c.GC_Amount_in_LC_Currncy__c==null)
                    {
                        c.GC_CA_Additional_Cost__c=0;
                    }
                }
                
                if(c.GC_Local_currency__c==mcs1[i].code__c)
                {
                    try
                    {
                        if(c.GC_Rebate_settlement_amount_in_LC__c!=null)
                        {
                            c.GC_Rebate_settlement_amount_in_USD__c = c.GC_Rebate_settlement_amount_in_LC__c*mcs1[i].Exchange_Rates__c;
                        }
                    }
                    catch(Exception e)
                    {
                        c.adderror(' Use Valid Number in LC Field :');
                    }   
                }
                else
                {
                    if(c.GC_Rebate_settlement_amount_in_LC__c==null)
                    {
                        c.GC_Rebate_settlement_amount_in_USD__c = 0;
                    }
                }
            }
        }
    }
}