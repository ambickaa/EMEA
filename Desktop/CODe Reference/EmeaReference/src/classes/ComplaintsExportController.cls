global with sharing class ComplaintsExportController
{
    public String fileName{get;set;}
    
    public List<Case>ListCustomerComplaint1{get;set;}
    public List<Case>ListCustomerComplaint2{get;set;}
    public List<Case>ListCustomerComplaint3{get;set;}
    public List<Case>ListCustomerComplaint4{get;set;}
    public List<Case>ListCustomerComplaint5{get;set;}
        
    public List<Complaint_Products__c>ListComplaintProducts1{get;set;}
    public List<Complaint_Products__c>ListComplaintProducts2{get;set;}
    public List<Complaint_Products__c>ListComplaintProducts3{get;set;}
    public List<Complaint_Products__c>ListComplaintProducts4{get;set;}
    public List<Complaint_Products__c>ListComplaintProducts5{get;set;}
    
    public Map<String, GIMS__c>GIMS_PCK_CODES = GIMS__c.getall();
    
    public ID ComplaintQuality{get;set;}
    public ID ComplaintService{get;set;}

    public Map<String,Id>Map_CaseRecordtype{get;set;}
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    public ComplaintsExportController(){
        
        String numDash= ApexPages.currentPage().getParameters().get('params');
        
        Map_CaseRecordtype = new Map<String,Id>();
        for (recordtype r : [SELECT DeveloperName, Id FROM Recordtype WHERE SObjectType = 'Case' AND isActive = true]) Map_CaseRecordtype.put(r.DeveloperName, r.Id);   
        ComplaintQuality=Map_CaseRecordtype.get('Complaint_Quality');
        ComplaintService=Map_CaseRecordtype.get('Complaint_Service');
            
        if(numDash=='1'){
            fileName='Monsanto Customer Complaint';

            
            ListCustomerComplaint1 = new List<Case>();
            ListCustomerComplaint2 = new List<Case>();
            ListCustomerComplaint3 = new List<Case>();
            ListCustomerComplaint4 = new List<Case>();
            ListCustomerComplaint5 = new List<Case>();
            
            for(Case CustomerComplaint : [SELECT CaseNumber, CreatedBy.name, DAT_Date_Notified_of_Complaint__c, GC_Division_Descr__c, PCK_Sub_division__c,  LKP_Country__r.TXT_Country_ISO_Code__c, LKP_Country__r.Area__r.TXT_Country_ISO_Code__c , Status, TXT_Reporting_Group__c, GC_Region_Name__c, PCK_Sub_Region__c, PCK_Brand__c, PICK_Complaint_Category__c, PCK_Complaint_sub_category_1__c, PCK_Complaint_sub_category_2__c, LKP_Sales_Year__r.Name, PCK_Severity_Ranking__c, GC_Complaint_Reason_descr__c, Description, NUM_Estimated_Settlement_amount_dolars__c, FRML_Actual_Settlement_Value__c, ClosedDate, CreatedDate, NPS_EXT_RESPONSEID__c, LKP_Direct_Customer_Name__r.GC_Integration_Key__c,  LKP_Indirect_Customer_Name__r.GC_Integration_Key__c, LKP_Direct_Customer_Name__r.name, LKP_Indirect_Customer_Name__r.name, TXTA_Delivery_Info__c, TXT_Transportation_Carrier__c, GC_Invoice_Number_Text__c, Approval_Validation_1__c, GC_Territory_Name__c, PCK_Crop__c, PCK_Complaints_Export_Status__c, DAT_Date_Settlement_Agreement__c, Owner.Name, TXT_Indirect_Customer_Name__c, NUM_FOC_Seed_Value__c, NUM_FOC_COGs_Value__c, NUM_Value__c, LKP_Complaint_Coordinator__r.Name FROM Case WHERE (Recordtypeid =: Map_CaseRecordtype.get('Complaint_Quality') OR Recordtypeid =: Map_CaseRecordtype.get('Complaint_Service')) AND PCK_Complaints_Export_Status__c='In Progress']){
                
                if(CustomerComplaint.NUM_Estimated_Settlement_amount_dolars__c==null) CustomerComplaint.NUM_Estimated_Settlement_amount_dolars__c=0;
                
                CustomerComplaint.PCK_Brand__c = GIMS_PCK_CODES.containsKey(CustomerComplaint.PCK_Brand__c) ? GIMS_PCK_CODES.get(CustomerComplaint.PCK_Brand__c).Brand_Code_del__c : null;
                
                CustomerComplaint.PICK_Complaint_Category__c = GIMS_PCK_CODES.containsKey(CustomerComplaint.PICK_Complaint_Category__c) ? GIMS_PCK_CODES.get(CustomerComplaint.PICK_Complaint_Category__c).Category_Code__c : null;
                
                CustomerComplaint.PCK_Complaint_sub_category_1__c = GIMS_PCK_CODES.containsKey(CustomerComplaint.PCK_Complaint_sub_category_1__c) ? GIMS_PCK_CODES.get(CustomerComplaint.PCK_Complaint_sub_category_1__c).Sub_category_1_Code__c : null;
                
                CustomerComplaint.PCK_Complaint_sub_category_2__c = GIMS_PCK_CODES.containsKey(CustomerComplaint.PCK_Complaint_sub_category_2__c) ? GIMS_PCK_CODES.get(CustomerComplaint.PCK_Complaint_sub_category_2__c).Sub_category_2_Code__c : null;
                
                CustomerComplaint.LKP_Country__r.TXT_Country_ISO_Code__c = CustomerComplaint.LKP_Country__r.TXT_Country_ISO_Code__c != null ? CustomerComplaint.LKP_Country__r.TXT_Country_ISO_Code__c : CustomerComplaint.LKP_Country__r.Area__r.TXT_Country_ISO_Code__c;
                
                if (ListCustomerComplaint1.size()<1000) ListCustomerComplaint1.add(CustomerComplaint);
                else if (ListCustomerComplaint2.size()<1000) ListCustomerComplaint2.add(CustomerComplaint);
                else if (ListCustomerComplaint3.size()<1000) ListCustomerComplaint3.add(CustomerComplaint);
                else if (ListCustomerComplaint4.size()<1000) ListCustomerComplaint4.add(CustomerComplaint);
                else if (ListCustomerComplaint5.size()<1000) ListCustomerComplaint5.add(CustomerComplaint);
            }
        }
        else if (numDash=='2'){
            fileName='Monsanto Complaint Product';
             ListComplaintProducts1 = new List<Complaint_Products__c>();
             ListComplaintProducts2 = new List<Complaint_Products__c>();
             ListComplaintProducts3 = new List<Complaint_Products__c>();
             ListComplaintProducts4 = new List<Complaint_Products__c>();
             ListComplaintProducts5 = new List<Complaint_Products__c>();
            for(Complaint_Products__c ComplaintProduct : [SELECT LKP_CASE__r.CaseNumber, name, LKP_CASE__r.recordtypeid,    LKP_CASE__r.PCK_Complaints_Export_Status__c, ID, FRML_BATCH_NUMBER__c, TXT_Batch_Name__c, LKP_Product__r.name, NUM_Complaint_quantity__c, PICK_Complained_Qty_UOM__c, NUM_Affected_Acres_ha__c FROM Complaint_Products__c WHERE  (LKP_CASE__r.recordtypeid =: Map_CaseRecordtype.get('Complaint_Quality') OR LKP_CASE__r.recordtypeid =: Map_CaseRecordtype.get('Complaint_Service')) AND LKP_CASE__r.PCK_Complaints_Export_Status__c='In Progress']){
                system.debug('***Complaint Products: ' + ComplaintProduct);
                if(ListComplaintProducts1.size()<1000)  ListComplaintProducts1.add(ComplaintProduct);
                else if (ListComplaintProducts2.size()<1000) ListComplaintProducts2.add(ComplaintProduct);
                else if (ListComplaintProducts3.size()<1000) ListComplaintProducts3.add(ComplaintProduct);
                else if (ListComplaintProducts4.size()<1000) ListComplaintProducts4.add(ComplaintProduct);
                else if (ListComplaintProducts5.size()<1000) ListComplaintProducts5.add(ComplaintProduct);
            }
        }
    }
}