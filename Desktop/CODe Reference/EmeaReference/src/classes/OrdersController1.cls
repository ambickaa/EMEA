/**
 * This class provides methods for inline vf page to show orders related to case account
 * and search based on certain critieria.
 * 
 * @author  Accenture
 * @version 1.0, 12/27/2016
 * 
 */ 
public class OrdersController1 extends ODICommons1{
    public List<Order> lstOrders;
    public String requestedDlvrDateByMnth{get;set;}
    public String documentTypeDescr{get;set;}
    public String distributionChannel{get;set;}
    public Report oReport{get;set;}
    
    public OrdersController1(Apexpages.StandardController con){
        system.debug('chk:'+con.getRecord());
        if(ApexPages.currentPage().getParameters().get('id') != null){
            oReport = getReport(Label.Account_with_Standard_Order);
        }
    }
    
    public Set<String> setDocTypeDesc{
        get{
            if(null == setDocTypeDesc){
                setDocTypeDesc = new Set<String>();
                for(Order o : getLstOrders()){
                    if(null != o.GC_Document_Type_Descr__c)
                        setDocTypeDesc.add(o.GC_Document_Type_Descr__c);
                }
            }
            return setDocTypeDesc;
        }
        set;
    }
    
    // property to create drop down for Document Type Descrpition
    public List<SelectOption> lstDocTypeDesc{
        get{
            if(lstDocTypeDesc == null){
                lstDocTypeDesc = new List<SelectOption>();
                lstDocTypeDesc.add(new SelectOption('','All'));
                for(String dtd : setDocTypeDesc){
                    lstDocTypeDesc.add(new SelectOption(dtd,dtd));
                }
                lstDocTypeDesc.sort();
            }
            return lstDocTypeDesc;
        }
        set;
    }
    
    public Set<String> setDistributionChannel{
        get{
            if(null == setDistributionChannel){
                setDistributionChannel = new Set<String>();
                for(Order o : getLstOrders()){
                    if(null != o.Distribution_Channel_Code__c)
                        setDistributionChannel.add(o.Distribution_Channel_Code__c);
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
    
    /**
     * This method constructs query for fetching order records based on the filter criteria
     * 
     * @param   Nothing
     * @returns Query as string
     * @throws  Nothing
     * @since   1.0
     * 
     */ 
    public override String getQuery(){
        if(accountId != null){
            String query = 'SELECT Id,fGC_Ship_To_ID__c,ShipTo_Acc_Integration_Key__c,AccountID,Account.Name'
                             +',ShipTo_Acc_Integration_Key__r.Name,GC_Ship_To_Party_Descr__c,Name,PoNumber'
                             +',GC_Document_Type_Descr__c,GC_Doc_Creation_Date__c,GC_Requested_Delivery_Date__c'
                             +',LastModifiedDate,GC_Open_Order_Qty__c,GC_Integration_Key__c,Distribution_Channel_Code__c'
                             +',(SELECT Id,GC_SalesOrder_Item_Nbr__c,PricebookEntry.ProductCode'
                                         +',Description,GC_Quantity__c,GC_Sales_UoM_Text__c,fGC_Unit_Price__c'
                                         +' FROM OrderItems)' 
                             +' FROM Order' 
                             +' WHERE (AccountID = :accountId OR ShipTo_Acc_Integration_Key__c= :accountId)';
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
            if(requestedDlvrDateByMnth != null){
                //if month is later than current month, consider the previous year, otherwise consider current year
                if(Integer.valueOf(requestedDlvrDateByMnth) > Date.today().month()){
                    query += ' AND CALENDAR_YEAR(GC_Requested_Delivery_Date__c) = '+ (Date.today().year()-1);
                }else{
                    query += ' AND CALENDAR_YEAR(GC_Requested_Delivery_Date__c) = '+ Date.today().year();
                }
                query += ' AND CALENDAR_MONTH(GC_Requested_Delivery_Date__c) = '+Integer.valueOf(requestedDlvrDateByMnth);
            }
            if(documentTypeDescr != null){
                query += ' AND GC_Document_Type_Descr__c = \'' + documentTypeDescr + '\'';
            }
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
     * @returns List of order records
     * @throws  Nothing
     * @since   1.0
     * 
     */ 
    public List<Order> getLstOrders(){
        if(con != null)
            return (List<Order>)con.getRecords();
        return new List<Order>();
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
    public Pagereference search(){
        con = null; //set con to null so that query should be fired again
        getLstOrders(); // get fresh list of orders
        return null;
    }
}