/***************************************
Created By: Abhinav Sharma
Organization: Accenture
Email Id: abhinav.l.sharma@accenture.com
Associated Visualforce Page: VFP_PartnerFunctionRelatedList
****************************************/
public class PartnerFunctionRelatedListExtension {

    public String RecID='';
    public String RecID_trim{get;set;}
        
    public integer counter=0;
    public integer recNum=5;
    public integer limits=5; 
    
    public String lstPartnerFunctionName{get; set;}
    public String lstSalesArea{get; set;}
    public String lstMarkDelete{get; set;}
    
    public Boolean AllBolRender{get; set;}
    public Boolean BolRender{get; set;}
    
    public list<Partner_Function__c> PRecords{get;set;}
    public list<Partner_Function__c> AllPRecords{get;set;}
    public String ReportID{get;set;}
    public String ReportName{get;set;}
    
    Set<String> setPartnerFunctionName = new Set<String>();
    Set<String> setSalesArea = new Set<String>();
    List<String> PartnerFunctionNamelst = new List<String>();
    List<String> SalesArealst = new List<String>();
    
    List<Partner_Function__c> lstPartnerFunction;
    List<Report> lstReport;    
    
    public PartnerFunctionRelatedListExtension(ApexPages.StandardController controller) {
    
        AllbolRender=true;
        bolRender=false;
    
        Account Record = (Account) controller.getRecord();
        RecID = Record.Id;
        RecID_trim=RecID.substring(0, 15);
        
        lstReport=new List<Report>();
        lstReport=[Select id,DeveloperName,Name from Report where DeveloperName like 'Account%'];
        for(Report oReport:lstReport){
            if(oReport.DeveloperName==Label.Account_with_Partner_Function){
                ReportID=oReport.Id;
                ReportName=oReport.Name;
            }
        }
        
        lstPartnerFunction = new List<Partner_Function__c>();
        
        for(Partner_Function__c oPartnerFunction:[select id,Name,is_Marked_For_Del__c,Sales_Area_Integration_Key__r.Name,Partner_Function_Descr__c,Partner_SAP_ID__c
                                        from Partner_Function__c where Primry_Acct_Integration_Key__c =:RecID]){                  
            lstPartnerFunction.add(oPartnerFunction);
            if(oPartnerFunction.Partner_Function_Descr__c!=null){
                setPartnerFunctionName.add(oPartnerFunction.Partner_Function_Descr__c);
            }
            
            if(oPartnerFunction.Sales_Area_Integration_Key__r.Name !=null){
                setSalesArea.add(oPartnerFunction.Sales_Area_Integration_Key__r.Name);
            }                       
        }
        
        for(String ostr:setPartnerFunctionName){
            PartnerFunctionNamelst.add(ostr);
            PartnerFunctionNamelst.sort();            
        }
        
        for(String ostr:setSalesArea){
            SalesArealst.add(ostr);
            SalesArealst.sort();            
        }
        fnPartnerFucntionAll();

    }
    
    public List<SelectOption> getMarkDelete() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('False','No'));
        options.add(new SelectOption('True','Yes'));                            
        return options;
    }
      
    public List<SelectOption> getPartnerFunctionName() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        
        if(PartnerFunctionNamelst !=null){       
            for(String s:PartnerFunctionNamelst){
                options.add(new SelectOption(s,s));    
            }
        }      

        return options;
    }
    
    public List<SelectOption> getSalesArea() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));

        for(String s:SalesArealst){
            options.add(new SelectOption(s,s));    
        }      
        return options;
    }
    
     public void Datalist(){
        AllbolRender=false;
        bolRender=true;
        counter=0;
        recNum=5;
        limits=5; 
        fnPartnerFucntion();                  
    }
    
    public void fnPartnerFucntion(){
                
        String strDynPartner ='select id,Name,is_Marked_For_Del__c,Sales_Area_Integration_Key__r.Name,Partner_Function_Descr__c,Partner_SAP_ID__c from Partner_Function__c where Primry_Acct_Integration_Key__c =:RecID ';
        
        if(lstMarkDelete!='All'){
            Boolean BolMarkDelete=Boolean.ValueOf(lstMarkDelete);
            strDynPartner +='and is_Marked_For_Del__c =: BolMarkDelete ';
        }
                                
        if(lstSalesArea !='All'){
            strDynPartner +='and Sales_Area_Integration_Key__r.Name =: lstSalesArea ';
        }
        
        if(lstPartnerFunctionName !='All'){
            strDynPartner +='and Partner_Function_Descr__c =:  lstPartnerFunctionName ';
        }
        
        strDynPartner +='LIMIT :limits OFFSET: counter';
                                                    
        PRecords = Database.query(strDynPartner);                 
    } 
    
    public void fnPartnerFucntionAll(){     
        AllPRecords = [select id,Name,is_Marked_For_Del__c,Sales_Area_Integration_Key__r.Name,Partner_Function_Descr__c,Partner_SAP_ID__c
                                from Partner_Function__c where Primry_Acct_Integration_Key__c =:RecID LIMIT :limits OFFSET: counter];                  
    }
    
    public PageReference nextbtn(){
        counter += limits ;
        fnPartnerFucntion();
        return null;
    }
    
    public PageReference Allnextbtn(){
        counter += limits ;
        fnPartnerFucntionAll();
        return null;
    }
    
    public PageReference prvbtn(){
        counter -= limits ;
        fnPartnerFucntion();
        return null;
    }
    
    public PageReference Allprvbtn(){
        counter -= limits ;
        fnPartnerFucntionAll();
        return null;
    }
    
    public boolean getnxt(){
        if((counter + limits) > recNum)
            return true;
        else
            return false;
    }
    

}