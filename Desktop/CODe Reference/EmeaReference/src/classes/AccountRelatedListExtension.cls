/***************************************
Created By: Abhinav Sharma
Organization: Accenture
Email Id: abhinav.l.sharma@accenture.com
Associated Visualforce Page: VFP_SalesAreaRelatedList
****************************************/

public class AccountRelatedListExtension{
    
    public String lstSalesOrg{get; set;}
    public String lstDivisonCode{get; set;}
    public String lstChannelCode{get; set;}
    public String lstFYear{get; set;}
    
    public list<Order> Records{get;set;}
    public list<Delivery__c> DRecords{get;set;}
    public list<Invoice__c> IRecords{get;set;}
    public list<Contract> CRecords{get;set;}
    
    public list<Order> All_O_Records{get;set;}
    public list<Delivery__c> All_D_Records{get;set;}
    public list<Invoice__c> All_I_Records{get;set;}
    public list<Contract> All_C_Records{get;set;}
    
    public String ReportID{get;set;}
    public String DReportID{get;set;}
    public String IReportID{get;set;}
    public String CReportID{get;set;}
    
    public String ReportName{get;set;}
    public String DReportName{get;set;}
    public String IReportName{get;set;}
    public String CReportName{get;set;}
    
    public String OrderShipToID{get;set;}
    public String DeliveryShipToID{get;set;}
    public String InvoiceShipToID{get;set;}
    public String ContractShipToID{get;set;}
    
    public String FiscalYear='';
    
    public integer Ocounter=0;
    public integer OrecNum=5;
    public integer Olimits=5;
    
    public integer Dcounter=0;
    public integer DrecNum=5;
    public integer Dlimits=5;
    
    public integer Icounter=0;
    public integer IrecNum=5;
    public integer Ilimits=5;
    
    public integer Ccounter=0;
    public integer CrecNum=5;
    public integer Climits=5;
    
    public Integer intFYear;   
    
    public String RecID='';
    public String RecID_trim{get;set;}
    
    public String ReportLabel='';   
    Public Boolean bolRender{get;set;}
    Public Boolean AllbolRender{get;set;}
    
    List<Sales_Area__c> lstSalesArea;
    List<Report> lstReport;
    List<String> splitFYear;
    Set<String> setSalesOrg = new Set<String>();
    Set<String> setDivionCode = new Set<String>();
    Set<String> setDistrictCode = new Set<String>();
    
    List<String> SalesOrglst = new List<String>();
    List<String> DivionCodelst = new List<String>();
    List<String> DistrictCodelst = new List<String>();
    
    private final Account Record;
    
    //-----------
    // Change by everis at 01 march 2016  
    // New code fragment              
    //------------
    public account RecordAux{get;set;}
    public user currentUser{get;set;}
    //-----------
    // END Change by everis               
    //------------
    
    public AccountRelatedListExtension(ApexPages.StandardController controller){
        AllbolRender=true;
        bolRender=false;
        this.Record = (Account) controller.getRecord();
        RecID = Record.Id;
        RecID_trim=RecID.substring(0, 15);
        
        
        FiscalYear=Label.Fiscal_Year;
        splitFYear = FiscalYear.split(',');
        
        lstReport=new List<Report>();
        lstReport=[Select id,DeveloperName,Name from Report where DeveloperName like 'Account%'];
        for(Report oReport:lstReport){
            if(oReport.DeveloperName==Label.Account_with_Standard_Order){
                ReportID=oReport.Id;
                ReportName=oReport.Name;
            }
            if(oReport.DeveloperName==Label.Account_with_Delivery){
                DReportID=oReport.Id;
                DReportName=oReport.Name;
            }
            if(oReport.DeveloperName==Label.Account_with_Invoice){
                IReportID=oReport.Id;
                IReportName=oReport.Name;
            }
            if(oReport.DeveloperName==Label.Account_with_Standard_Contract){
                CReportID=oReport.Id;
                CReportName=oReport.Name;
            }
        }
        
        //-----------
        // Change by everis at 01 march 2016  
        // New code fragment              
        //------------
        id userId=userInfo.getUserId();        
        currentUser=[select name,division,alias from user where id=:userId];
          RecordAux=[Select id,GC_Country_Name__c from account where id=:RecID];
        //-----------  
        // End fragment              
        //------------
        
        lstSalesArea = new List<Sales_Area__c>();
        
        for(Sales_Area__c oSalesArea:[select id,GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.GC_country_Name__c, Sales_Org_Code__c,Distribution_Channel_Code__c,Divison_Code__c,Sales_District_Code__c,Name
                                      from Sales_Area__c where GC_Account_Integration_Key__c =:RecID and is_Marked_For_Del__c=false]){                  
                                          lstSalesArea.add(oSalesArea);
                                          
                                          if(oSalesArea.Sales_Org_Code__c !=null){
                                              setSalesOrg.add(oSalesArea.Sales_Org_Code__c);
                                          }
                                          
                                          if(oSalesArea.Divison_Code__c !=null){
                                              
                                              
                                              //-----------
                                              // Change by everis at 01 march 2016 
                                              // 
                                              // This change is made for CP restriction. 
                                              // If the restriction is settled then the visualforce will only shows �15� as division filter.
                                              // If there is no restriction the behavior is the same before modification.                               
                                              //------------
                                              
                                              RelList_visib__c visibility=RelList_visib__c.getInstance(oSalesArea.GC_Account_Integration_Key__r.GC_country_Name__c);
                                              
                                              //-----------
                                              // Change by everis at 07 april 2016 
                                              // 
                                              // This change is made for S&T restriction. 
                                              // If the restriction is settled then the visualforce will only shows �17� as division filter.
                                              // If there is no restriction the behavior is the same before modification.                               
                                              //------------
                                              
                                              RelListST_visib__c visibilityST=RelListST_visib__c.getInstance(oSalesArea.GC_Account_Integration_Key__r.GC_country_Name__c);
                                              
                                              //-----------
                                              //End Change by everis at 07 april 2016
                                              //                                
                                              //------------
                                              
                                              if(visibility!=null && currentUser.Division=='CP')
                                              {
                                                  
                                                  setDivionCode.add('15');
                                              }
                                              
                                              //-----------
                                              // Change by everis at 07 april 2016 
                                              // 
                                              // This change is made for S&T restriction. 
                                              // If the restriction is settled then the visualforce will only shows �17� as division filter.
                                              // If there is no restriction the behavior is the same before modification.                               
                                              //------------

                                              else if(visibilityST!=null && currentUser.Division=='S&T')
                                              {
                                                  
                                                  setDivionCode.add('17');
                                              }
                                              
                                              //-----------
                                              //End Change by everis at 07 april 2016
                                              //                                
                                              //------------
                                              
                                              else setDivionCode.add(oSalesArea.Divison_Code__c);
                                              //-----------
                                              //End Change by everis at 01 march 2016
                                              //
                                              // OLD code section replaced :  setDivionCode.add(oSalesArea.Divison_Code__c);
                                              //                                
                                              //------------
                                          }
                                          
                                          if(oSalesArea.Sales_District_Code__c !=null){
                                              setDistrictCode.add(oSalesArea.Sales_District_Code__c);
                                          }                        
                                      }
        
        for(String ostr:setSalesOrg){
            SalesOrglst.add(ostr);
            SalesOrglst.sort();            
        }
        
        for(String ostr:setDivionCode){
            DivionCodelst.add(ostr);
            DivionCodelst.sort();            
        }
        
        for(String ostr:setDistrictCode){
            DistrictCodelst.add(ostr);
            DistrictCodelst.sort();            
        }
        
        AllDatalist();
    }
    
    public List<SelectOption> getSalesOrg() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        
        for(String s:SalesOrglst){
            options.add(new SelectOption(s,s));    
        }     
        return options;
    }
    
    public List<SelectOption> getDivisonCode() {
        List<SelectOption> options = new List<SelectOption>();
        
        
        //-----------
        // Change by everis at 01 march 2016                
        //------------
        if(DivionCodelst.size()>1)options.add(new SelectOption('All','All'));
        //-----------
        // End Change 
        // 
        // Old code replaced: options.add(new SelectOption('All','All'));
        //------------ 
        
        for(String s:DivionCodelst){
            options.add(new SelectOption(s,s));    
        }      
        
        return options;
    }
    
    public List<SelectOption> getChannelCode() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        
        for(String s:DistrictCodelst){
            options.add(new SelectOption(s,s));    
        }      
        
        return options;
    }
    
    public List<SelectOption> getFYear() {
        List<SelectOption> options = new List<SelectOption>();
        for(String s:splitFYear){
            options.add(new SelectOption(s,s));    
        } 
        return options;
    }
    public void Datalist(){
        AllbolRender=false;
        bolRender=true;
        Ocounter=0;
        OrecNum=5;
        Olimits=5;
        
        Dcounter=0;
        DrecNum=5;
        Dlimits=5;
        
        Icounter=0;
        IrecNum=5;
        Ilimits=5;
        
        Ccounter=0;
        CrecNum=5;
        Climits=5;
        
        intFYear=Integer.ValueOf(lstFYear);
        lists();      
        Dlists();
        Ilists();
        Clists();                   
    }
    public void AllDatalist(){
        All_O_lists();      
        All_D_lists();
        All_I_lists();
        All_C_lists();                   
    }
    
    public void All_O_lists(){    
        string All_O_Dyn='select id,fGC_Ship_To_ID__c,ShipTo_Acc_Integration_Key__c,AccountID,Account.Name,ShipTo_Acc_Integration_Key__r.Name,GC_Ship_To_Party_Descr__c,Name,PoNumber,GC_Document_Type_Descr__c,GC_Doc_Creation_Date__c,GC_Requested_Delivery_Date__c,LastModifiedDate,GC_Open_Order_Qty__c from Order where (AccountID = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) Order By LastModifiedDate DESC LIMIT :Olimits OFFSET: Ocounter';
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        
        All_O_Dyn=whiteLabelQuery(All_O_Dyn);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        All_O_Records=Database.query(All_O_Dyn);
        
        for(Order o_Rec:All_O_Records){
            if(o_Rec.fGC_Ship_To_ID__c != null || o_Rec.fGC_Ship_To_ID__c != ''){
                OrderShipToID = o_Rec.fGC_Ship_To_ID__c;
            }
        } 
    }
    
    public void All_D_lists(){                        
        String All_D_Dyn='select id,fGC_Ship_To_ID__c,LastModifiedDate,ShipTo_Acc_Integration_Key__c,ShipTo_Acc_Integration_Key__r.Name,GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.Name, Name, GC_Delivery_Creation_Date__c, GC_Delivery_Date__c, GC_Proposed_GI_Date__c, GC_Actual_GI_Date__c, GC_Order_Number__c from Delivery__c where (GC_Account_Integration_Key__c = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) '; 
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        All_D_Dyn=whiteLabelQuery(All_D_Dyn);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------             
        
        All_D_Dyn += 'Order By LastModifiedDate DESC LIMIT :Dlimits OFFSET: Dcounter';
        
        All_D_Records = Database.query(All_D_Dyn);
        
        for(Delivery__c o_Rec:All_D_Records){
            if(o_Rec.fGC_Ship_To_ID__c != null || o_Rec.fGC_Ship_To_ID__c != ''){
                DeliveryShipToID = o_Rec.fGC_Ship_To_ID__c;
            }
        } 
        
    }
    
    public void All_I_lists(){ 
        //Add View_Invoice_PDF__c to the query string
        String All_I_Dyn='select id,fGC_Ship_To_ID__c,LastModifiedDate,GC_Payer_Text__c,GC_Payer_Descr__c,GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.Name,Name, GC_Invoice_Type_Descr__c, GC_Invoice_Due_Date__c, GC_Invoice_Creation_Date__c,GC_Cash_Application_Date__c, GC_Order_Number__c, GC_Total_Inv_Amount_Nbr__c, View_Invoice_PDF__c from Invoice__c where (GC_Account_Integration_Key__c = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) ';   
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        
        All_I_Dyn=whiteLabelQuery(All_I_Dyn);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------        
        
        All_I_Dyn +='Order By LastModifiedDate DESC LIMIT :Ilimits OFFSET: Icounter';
        
        All_I_Records = Database.query(All_I_Dyn);
        
        for(Invoice__c o_Rec:All_I_Records){
            if(o_Rec.fGC_Ship_To_ID__c != null || o_Rec.fGC_Ship_To_ID__c != ''){
                InvoiceShipToID = o_Rec.fGC_Ship_To_ID__c;
            }
        } 
    }
    
    
    public void All_C_lists(){                           
        String All_C_Dyn='select id,fGC_Ship_To_ID__c,LastModifiedDate,ContractNumber, AccountId, Account.Name,PO_Number_Text__c, Document_Date__c, Total_Contract_Qty__c, CalledOff_Contract_Qty__c, OutStanding_Contract_Qty__c,GC_Integration_Key__c,ShipToParty_Name_Text__c from Contract where (AccountId = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) ';
        
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        
        All_C_Dyn=whiteLabelQuery(All_C_Dyn);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        
        All_C_Dyn +='Order By LastModifiedDate DESC LIMIT :Climits OFFSET: Ccounter';
        
        All_C_Records = Database.query(All_C_Dyn);
        
        for(Contract o_Rec:All_C_Records){
            if(o_Rec.fGC_Ship_To_ID__c != null || o_Rec.fGC_Ship_To_ID__c != ''){
                ContractShipToID = o_Rec.fGC_Ship_To_ID__c;
            }
        } 
    }
    
    public void lists(){       
        String strDynOrder = 'select id,ShipTo_Acc_Integration_Key__c,LastModifiedDate,AccountID,Account.Name,ShipTo_Acc_Integration_Key__r.Name,GC_Ship_To_Party_Descr__c, Name, PoNumber, GC_Document_Type_Descr__c, GC_Doc_Creation_Date__c, GC_Requested_Delivery_Date__c, GC_Open_Order_Qty__c from Order where (AccountID = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) and FISCAL_YEAR(GC_Doc_Creation_Date__c) =:intFYear ';      
        
        if(lstSalesOrg != 'All'){
            strDynOrder += 'and Sales_Org_Code__c =: lstSalesOrg ';
        }
        
        if(lstDivisonCode != 'All'){
            strDynOrder += 'and Divison_Code__c =: lstDivisonCode ';
        }
        
        /*
if(lstChannelCode != 'All'){
strDynOrder += 'and Sales_District_Code__c =: lstChannelCode ';
}
*/
        
        strDynOrder += 'Order By LastModifiedDate DESC LIMIT :Olimits OFFSET: Ocounter ';
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        
        strDynOrder= whiteLabelQuery(strDynOrder);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        
        Records = Database.query(strDynOrder);                  
    }  
    
    public void Dlists(){
        String strDynDelivery='select id,ShipTo_Acc_Integration_Key__c,LastModifiedDate,ShipTo_Acc_Integration_Key__r.Name,GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.Name,Name, GC_Delivery_Creation_Date__c, GC_Delivery_Date__c, GC_Proposed_GI_Date__c, GC_Actual_GI_Date__c, GC_Order_Number__c from Delivery__c  where (GC_Account_Integration_Key__c = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) and FISCAL_YEAR(GC_Delivery_Creation_Date__c) =:intFYear ';      
        
        if(lstSalesOrg != 'All'){
            strDynDelivery += 'and Sales_Org_Code__c =: lstSalesOrg ';
        }
        
        if(lstDivisonCode != 'All'){
            strDynDelivery += 'and Divison_Code__c =: lstDivisonCode ';
        }
        
        strDynDelivery += 'Order By LastModifiedDate DESC LIMIT :Dlimits OFFSET: Dcounter ';
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        
        strDynDelivery=whiteLabelQuery(strDynDelivery);
        
        //----------- 
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        
        DRecords = Database.query(strDynDelivery);                             
    }
    
    public void Ilists(){
        //Add View_Invoice_PDF__c to the query string
        String strDynInvoice = 'select id,GC_Payer_Text__c,GC_Payer_Descr__c,LastModifiedDate,GC_Account_Integration_Key__c,GC_Account_Integration_Key__r.Name,Name, GC_Invoice_Type_Descr__c, GC_Invoice_Due_Date__c, GC_Cash_Application_Date__c,GC_Invoice_Creation_Date__c, GC_Order_Number__c, GC_Total_Inv_Amount_Nbr__c, View_Invoice_PDF__c from Invoice__c where (GC_Account_Integration_Key__c = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) and FISCAL_YEAR(GC_Invoice_Creation_Date__c) =:intFYear ';      
        
        if(lstSalesOrg != 'All'){
            strDynInvoice += 'and Sales_Org_Code__c =: lstSalesOrg ';
        }
        
        if(lstDivisonCode != 'All'){
            strDynInvoice += 'and Divison_Code__c =: lstDivisonCode ';
        }
        
        /*
if(lstChannelCode != 'All'){
strDynInvoice += 'and Sales_District_Code__c =: lstChannelCode ';
}
*/
        
        strDynInvoice += 'Order By LastModifiedDate DESC LIMIT :Ilimits OFFSET: Icounter';
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        strDynInvoice=whiteLabelQuery(strDynInvoice);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        
        IRecords = Database.query(strDynInvoice); 
    }
    
    public void Clists(){
        String strDynContract = 'select id,ContractNumber, AccountId,Account.Name,PO_Number_Text__c, Document_Date__c, Total_Contract_Qty__c, CalledOff_Contract_Qty__c, OutStanding_Contract_Qty__c,GC_Integration_Key__c,ShipToParty_Name_Text__c,LastModifiedDate from Contract where (AccountId  = :RecID OR ShipTo_Acc_Integration_Key__c= :RecID) and FISCAL_YEAR(Document_Date__c) =:intFYear ';      
        
        if(lstSalesOrg != 'All'){
            strDynContract += 'and Sales_Org_Code__c =: lstSalesOrg ';
        }
        
        if(lstDivisonCode != 'All'){
            strDynContract += 'and Divison_Code__c =: lstDivisonCode ';
        }
        
        /*
if(lstChannelCode != 'All'){
strDynContract += 'and Sales_District_Code__c =: lstChannelCode ';
}
*/
        
        strDynContract += 'Order By LastModifiedDate DESC LIMIT :Climits OFFSET: Ccounter';
        
        
        //-----------
        // Change by everis at 01 march 2016
        // New code fragment
        //------------
        strDynContract= whiteLabelQuery(strDynContract);
        
        //-----------
        // END Change by everis at 01 march 2016
        // END code fragment
        //------------
        
        
        CRecords = Database.query(strDynContract);                             
    }     
    
    public PageReference nextbtn(){
        Ocounter += Olimits ;
        lists();
        return null;
    }
    
    public PageReference prvbtn(){
        Ocounter -= Olimits ;
        lists();
        return null;
    }
    
    public PageReference AllOnextbtn(){
        Ocounter += Olimits ;
        All_O_lists();
        return null;
    }
    
    public PageReference AllOprvbtn(){
        Ocounter -= Olimits ;
        All_O_lists();
        return null;
    }
    
    public PageReference nextbtnD(){
        Dcounter += Dlimits ;
        Dlists();
        return null;
    }
    
    public PageReference prvbtnD(){
        Dcounter -= Dlimits ;
        Dlists();
        return null;
    }
    
    public PageReference AllDnextbtn(){
        Dcounter += Dlimits ;
        All_D_lists();
        return null;
    }
    
    public PageReference AllDprvbtn(){
        Dcounter -= Dlimits ;
        All_D_lists();
        return null;
    }
    
    public PageReference nextbtnI(){
        Icounter += Ilimits ;
        Ilists();
        return null;
    }
    
    public PageReference prvbtnI(){
        Icounter -= Ilimits ;
        Ilists();
        return null;
    }
    
    public PageReference AllInextbtn(){
        Icounter += Ilimits ;
        All_I_lists();
        return null;
    }
    
    public PageReference AllIprvbtn(){
        Icounter -= Ilimits ;
        All_I_lists();
        return null;
    }
    
    public PageReference nextbtnC(){
        Ccounter += Climits ;
        Clists();
        return null;
    }
    
    public PageReference prvbtnC(){
        Ccounter -= Climits ;
        Clists();
        return null;
    }
    
    public PageReference AllCnextbtn(){
        Ccounter += Climits ;
        All_C_lists();
        return null;
    }
    
    public PageReference AllCprvbtn(){
        Ccounter -= Climits ;
        All_C_lists();
        return null;
    }
    
    public boolean getOnxt(){
        if((Ocounter + Olimits) > OrecNum)
            return true;
        else
            return false;
    }
    
    public boolean getDnxt(){
        if((Dcounter + Dlimits) > DrecNum)
            return true;
        else
            return false;
    }
    
    public boolean getInxt(){
        if((Icounter + Ilimits) > IrecNum)
            return true;
        else
            return false;
    }
    
    public boolean getCnxt(){
        if((Ccounter + Climits) > CrecNum)
            return true;
        else
            return false;
    }
    //-----------
    // Change by everis at 01 march 2016
    // New code fragment
    // 
    // Every time the controller make a query for a related list the method 
    // changes the query in order to apply the restrictions in the visibility.
    // If there is not any restriction the query returned by the method is the same as received. 
    //------------
    public String whiteLabelQuery(String Query)
    {
        string newQuery=Query;
        boolean notWhiteLabP=False;
        boolean showOnlyCP=False;
		//-----------
        // Change by everis at 07 april 2016 
        // 
        // This change is made for S&T restriction.                             
        //------------
        boolean showOnlyST=False;
        //-----------
        // End Change by everis at 07 april 2016 
        //
        //------------

        if(lstDivisonCode!=null || DivionCodelst.size()==1)
        {
            RelList_visib__c visibility=RelList_visib__c.getInstance(RecordAux.GC_country_Name__c);
            
            //-----------
            // Change by everis at 07 april 2016 
            // 
            // This change is made for S&T restriction.                             
            //------------
            RelListST_visib__c visibilityST=RelListST_visib__c.getInstance(RecordAux.GC_country_Name__c);
            //-----------
            // End Change by everis at 07 april 2016 
            //
            //------------

            if(visibility!=null && currentUser.Division=='CP')showOnlyCP=True;
            
            //-----------
            // Change by everis at 07 april 2016 
            // 
            // This change is made for S&T restriction.                             
            //------------
            else if(visibilityST!=null && currentUser.Division=='S&T')showOnlyST=True;
            //-----------
            // End Change by everis at 07 april 2016 
            //
            //------------
            
        }
        string infoDivCount;
        If(currentUser.Division=='CP') infoDivCount=RecordAux.GC_country_Name__c + '_15';
        else If(currentUser.Division=='S&T') infoDivCount=RecordAux.GC_country_Name__c + '_17';
        else infoDivCount='Not contempled';
        
        WhiteLabProd_Vis__c visiB=WhiteLabProd_Vis__c.getInstance(infoDivCount);
        if(visiB!=null)
        {   
            if(visiB.value__C==True && lstDivisonCode==null && visiB.name.contains(DivionCodelst[0]) )
            {
                if (visiB.Visibility__c!=null && visiB.Visibility__c.contains(currentUser.Alias))notWhiteLabP=False;
                else notWhiteLabP=True;
                    
            }
                
            else if( visiB.value__C==True && visiB.name.contains(lstDivisonCode) && !visiB.Visibility__c.contains(currentUser.Alias) )
            {
                
               if (visiB.Visibility__c!=null && visiB.Visibility__c.contains(currentUser.Alias))notWhiteLabP=False;
                else notWhiteLabP=True;
            }
                
        }
        
        
        if(showOnlyCP)
        {
            string[] QueryParts=newQuery.split('where');
            string div=' \''+String.escapeSingleQuotes('15')+'\'';
            newQuery=QueryParts[0] + ' where Divison_Code__c='+div+' and ' + QueryParts[1];
            
        }
        //-----------
        // Change by everis at 07 april 2016 
        // 
        // This change is made for S&T restriction.                             
        //------------
        if(showOnlyST)
        {
        	string[] QueryParts=newQuery.split('where');
            string div=' \''+String.escapeSingleQuotes('17')+'\'';
            newQuery=QueryParts[0] + ' where Divison_Code__c='+div+' and ' + QueryParts[1];
        }
        //-----------
        // End Change by everis at 07 april 2016 
        //
        //------------
        if(notWhiteLabP)
        {
            string[] QueryParts=newQuery.split('where');
            newQuery=QueryParts[0] + ' where CHK_White_label_prods__c=False and ' + QueryParts[1];
            
        }
        
        return newQuery;   
    }
    //-----------
    // END Change by everis at 01 march 2016
    // END code fragment
    //------------
    
    
}