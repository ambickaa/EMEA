/**
 * This class provides methods for inline vf page to show invoices related to case account
 * and search based on certain criteria.
 * 
 * @author  Accenture
 * @version 1.0, 01/05/2017
 * 
 */ 
public class InvoicesController1 extends ODICommons1{
    public List<Order> lstInvoices;
    //public String salesDistrictCode{get;set;}
    public String distributionChannel{get;set;}
    public String billingDateByMnth{get;set;}
    public String invTypeDescr{get;set;}
    public Report oReport{get;set;}
    
    public InvoicesController1(Apexpages.StandardController con){
        oReport = getReport(Label.Account_with_Invoice);
    }
    
    public Set<String> setDistributionChannel{
        get{
            if(null == setDistributionChannel){
                setDistributionChannel = new Set<String>();
                for(Invoice__c i : getLstInvoices()){
                    if(null != i.Distribution_Channel_Code__c)
                        setDistributionChannel.add(i.Distribution_Channel_Code__c);
                }
            }
            return setDistributionChannel;
        }
        set;
    }
    
    // property to create drop down for Distribution Channel
    public List<SelectOption> lstDistributionChannel{
        get{
            if(lstDistributionChannel == null){
                lstDistributionChannel = new List<SelectOption>();
                lstDistributionChannel.add(new SelectOption('',ALL_OPTION));
                for(String dc : setDistributionChannel){
                    lstDistributionChannel.add(new SelectOption(dc,dc));
                }
                lstDistributionChannel.sort();
            }
            return lstDistributionChannel;
        }
        set;
    }
    
    public Set<String> setInvTypeDesc{
        get{
            if(null == setInvTypeDesc){
                setInvTypeDesc = new Set<String>();
                for(Invoice__c i : getLstInvoices()){
                    if(null != i.GC_Invoice_Type_Descr__c)
                        setInvTypeDesc.add(i.GC_Invoice_Type_Descr__c);
                }
            }
            return setInvTypeDesc;
        }
        set;
    }
    
    // property to create drop down for Invoice Type Description
    public List<SelectOption> lstInvTypeDesc{
        get{
            if(lstInvTypeDesc == null){
                lstInvTypeDesc = new List<SelectOption>();
                lstInvTypeDesc.add(new SelectOption('',ALL_OPTION));
                for(String itd : setInvTypeDesc){
                    lstInvTypeDesc.add(new SelectOption(itd,itd));
                }
                lstInvTypeDesc.sort();
            }
            return lstInvTypeDesc;
        }
        set;
    }
    
    /**
     * This method constructs query for fetching invoice records based on the filter criteria
     * 
     * @param   Nothing
     * @returns Query as string
     * @throws  Nothing
     * @since   1.0
     * 
     */
    public override String getQuery(){
        system.debug('chk:'+accountId);
        if(accountId != null){
            String query = 'SELECT Id,fGC_Ship_To_ID__c,LastModifiedDate,GC_Payer_Text__c,GC_Payer_Descr__c'
                            +',GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.Name,Name'
                            +',GC_Invoice_Type_Descr__c,GC_Invoice_Due_Date__c,GC_Invoice_Creation_Date__c'
                            +',GC_Cash_Application_Date__c,GC_Order_Number__c,GC_Total_Inv_Amount_Nbr__c'
                            +',View_Invoice_PDF__c,Distribution_Channel_Code__c'
                            +',(SELECT Id,Name,GC_Item_Code__c,GC_Item_Descr__c'
                                           +',GC_Net_Value_Amount__c,GC_Quantity__c,GC_UOM_Line_Item_Descr__c'
                                           +' FROM Invoice_Line_Items2__r)'
                            +' FROM Invoice__c'
                            +' WHERE (GC_Account_Integration_Key__c = :accountId OR ShipTo_Acc_Integration_Key__c = :accountId) ';
            /*if(intFYear != null){
                query += ' AND FISCAL_YEAR(GC_Doc_Creation_Date__c) = :intFYear';
            }*/
            if(division != null){
                query += ' AND Divison_Code__c = :division';
            }
            if(salesOrg != null){
                query += ' AND Sales_Org_Code__c = :salesOrg';
            }
            if(distributionChannel != null){
                query += ' AND Distribution_Channel_Code__c = \'' + distributionChannel + '\'';
            }
            if(billingDateByMnth != null){
                if(Integer.valueOf(billingDateByMnth) > Date.today().month()){
                    query += ' AND CALENDAR_YEAR(GC_Invoice_Creation_Date__c) = '+(Date.today().year()-1);
                }else{
                    query += ' AND CALENDAR_YEAR(GC_Invoice_Creation_Date__c) = '+Date.today().year();
                }
                query += ' AND CALENDAR_MONTH(GC_Invoice_Creation_Date__c) = '+Integer.valueOf(billingDateByMnth);
            }
           // if(invTypeDescr != null){
         //       query += ' AND GC_Document_Type_Descr__c = \'' + invTypeDescr +'\'';
         //   }
            query+=' ORDER BY LastModifiedDate DESC' 
                     +' LIMIT :REC_LIMIT';

            return query;
        }
        return null;
    }
    
    /**
     * This method returns the next set of records based on pagination
     * 
     * @param   Nothing
     * @returns List of invoice records
     * @throws  Nothing
     * @since   1.0
     * 
     */
    public List<Invoice__c> getLstInvoices(){
        if(con != null)
            return (List<Invoice__c>)con.getRecords();
        return new List<Invoice__c>();
    }
    
    /**
     * This method call the search based on the criteiria chosen by user
     * 
     * @param   Nothing
     * @returns Nothing
     * @throws  Nothing
     * @since   1.0
     * 
     */
    public void search(){
        con = null;//set con to null so that query should be fired again
        getLstInvoices();// get fresh list of invoices
    }
}