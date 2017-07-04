/**
 * This class provides methods for inline vf page to show deliveries related to case account
 * and search based on certain criteria.
 * 
 * @author  Accenture
 * @version 1.0, 01/05/2017
 * 
 */ 
public class DeliveriesController1 extends ODICommons1{
    public List<Delivery__c> lstDeliveries;
    //public String salesDistrictCode{get;set;}
    public String distributionChannel{get;set;}
    public String dlvryDateByMnth{get;set;}
    public String dlvryStatusDescr{get;set;}
    public Report oReport{get;set;}
    
    public DeliveriesController1(Apexpages.StandardController con){
        oReport = getReport(Label.Account_with_Delivery);
        system.debug(logginglevel.info,'constr:'+oReport);
    }
    
    public Set<String> setDistributionChannel{
        get{
            if(null == setDistributionChannel){
                setDistributionChannel = new Set<String>();
                system.debug(logginglevel.info,'getLstDeliveries:'+getLstDeliveries());
                for(Delivery__c d : getLstDeliveries()){
                    if(null != d.Distribution_Channel_Code__c)
                        setDistributionChannel.add(d.Distribution_Channel_Code__c);
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
    
    public Set<String> setDlvryStatusDesc{
        get{
            if(null == setDlvryStatusDesc){
                setDlvryStatusDesc = new Set<String>();
                for(Delivery__c d : getLstDeliveries()){
                    if(null != d.GC_Ovrall_Delvy_Stat_Descr__c)
                        setDlvryStatusDesc.add(d.GC_Ovrall_Delvy_Stat_Descr__c);
                } 
            }
            return setDlvryStatusDesc;
        }
        set;
    }
    
    // property to create drop down for Delivery Status Description
    public List<SelectOption> lstDlvryStatusDesc{
        get{
            if(lstDlvryStatusDesc == null){
                lstDlvryStatusDesc = new List<SelectOption>();
                lstDlvryStatusDesc.add(new SelectOption('',ALL_OPTION));
                for(String dsd : setDlvryStatusDesc){
                    lstDlvryStatusDesc.add(new SelectOption(dsd,dsd));
                }
                lstDlvryStatusDesc.sort();
            }
            return lstDlvryStatusDesc;
        }
        set;
    }
    
    /**
     * This method constructs query for fetching delivery records based on the filter criteria
     * 
     * @param   Nothing
     * @returns Query as string
     * @throws  Nothing
     * @since   1.0
     * 
     */
    public override String getQuery(){
        String query = 'SELECT Id,fGC_Ship_To_ID__c,LastModifiedDate,ShipTo_Acc_Integration_Key__c'
                        +',ShipTo_Acc_Integration_Key__r.Name,GC_Account_Integration_Key__c'
                        +',GC_Account_Integration_Key__r.Name,Name,GC_Delivery_Creation_Date__c,GC_Delivery_Date__c'
                        +',GC_Proposed_GI_Date__c,GC_Actual_GI_Date__c,GC_Order_Number__c,Distribution_Channel_Code__c'
                        +',GC_Ovrall_Delvy_Stat_Descr__c'
                        +',(SELECT Name,GC_SKULine_Item_Nbr__c,GC_Item_Code__c,GC_Item_Descr__c'
                                     +',GC_Batch_Number_Text__c,GC_Plant_Desc__c,GC_SKULineItem_Quantity__c'
                                     +',GC_Shipping_Point_Descr__c'
                                     +' FROM Delivery_Line_Items2__r'
                                     +' ORDER BY GC_Item_Code__c ASC'
                                     +',Name ASC)'
                        +' FROM Delivery__c' 
                        +' WHERE (GC_Account_Integration_Key__c = :accountId OR ShipTo_Acc_Integration_Key__c= :accountId)';
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
        if(dlvryDateByMnth != null){
            //if selected month is later than current monthm consider previous year, current year otherwise
            if(Integer.valueOf(dlvryDateByMnth) > Date.today().month())
                query += ' AND CALENDAR_YEAR(GC_Delivery_Date__c) = '+ (Date.today().year()-1);
            else
                query += ' AND CALENDAR_YEAR(GC_Delivery_Date__c) = '+ Date.today().year();
            query += ' AND CALENDAR_MONTH(GC_Delivery_Date__c) = '+Integer.valueOf(dlvryDateByMnth);
        }
        if(dlvryStatusDescr != null){
            query += ' AND GC_Ovrall_Delvy_Stat_Descr__c = \'' + dlvryStatusDescr + '\'';
        }
        query+=' ORDER BY LastModifiedDate DESC' 
                 +' LIMIT :REC_LIMIT';
        return query;
    }
    
    /**
     * This method returns the next set of records based on pagination
     * 
     * @param   Nothing
     * @returns List of delivery records
     * @throws  Nothing
     * @since   1.0
     * 
     */
    public List<Delivery__c> getLstDeliveries(){
        if(con != null)
            return (List<Delivery__c>)con.getRecords();
        return new List<Delivery__c>();
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
        getLstDeliveries();// get fresh list of deliveries
    }
}