public with sharing class AccountActionPlanGermanyCPController extends AccountListVirtualController{

    public AccountActionPlanGermanyCPController ()
    {
        objectFactory = new TacticalPlanGermanyFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
    }
    
    public List<CampaignLineItem> tacticalPlans
    {
        get
        {
             return ( List<CampaignLineItem> ) wrapperObjects;
        }
        set;
    }
    
    public virtual boolean getIsDisplayExcel()
    {
       if (Util.currentAccount.RecordTypeId != Util.recordType.get('Account:DistRetPoS')) {
            return false;
        }else{
            return true;
        }
    }
    
    public virtual boolean getIsDisplayButtons(){
        
          infoUser =[
                    SELECT Is_Regional_Manager__c, Is_Country_Manager__c, Is_Promoter__c, Profile.Name, Is_Sales_Rep__c
                    FROM User 
                    WHERE ID = :userInfo.getUserID()];
        //Begin germany dev
        //Admin full access
        if (infoUser.Profile.Name == 'System Administrator'){
            return true;
        }
        //Farm full access
        else if (Util.currentAccount.RecordTypeId == Util.recordType.get('Account:GroupFarmSite')){
            return true;
        }
        //CP/Distributor/Sales Representative or Regional Manager
        else if (Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS')
                    && (infoUser.Is_Sales_Rep__c
                        || infoUser.Is_Regional_Manager__c) // it should be giving access to RM already.
                    ){
            return true;
                
        }
        //CP/Others/Sales Representative
        else if (Util.currentAccount.RecordTypeId == Util.recordType.get('Account:Others')
                    && infoUser.Is_Sales_Rep__c 
                    ){
            return true;
        }  else if(util.isAccountOwner && util.isCpStandard)
            {
            return true;
        
             }
        
            else {
            return false;
            }
        
        //End germany dev
        //Current condition to display buttons, grants access to everyone except CM with Account Types Distributors, Competitors and Others.
//        if (infoUser.Is_Country_Manager__c== true && Util.currentAccount.RecordTypeId != Util.recordType.get('Account:Group/Farm/Site')) 
//        {
//            return false;
//        }else{
//            return true;
//        }
    }
    
    public Map<String, Double>sumOfNumberFields
    {
        get
        {
            if(sumOfNumberFields == null)
            {
                sumOfNumberFields = new Map<String, Double>();

                sumOfNumberFields.put('C_PY_FORECAST', 0);
                sumOfNumberFields.put('C_CY_FORECAST', 0);
                sumOfNumberFields.put('C_PY_AGREED', 0);
                sumOfNumberFields.put('C_CY_AGREED', 0);
                sumOfNumberFields.put('C_PY_POG', 0);
                sumOfNumberFields.put('C_CY_POG', 0);

                for(CampaignLineItem c : tacticalPlans)
                {
                   if(c.record.Forecast__c<> null)
                    {
                        sumOfNumberFields.put('C_PY_FORECAST', (sumOfNumberFields.get('C_PY_FORECAST')+c.record.Forecast__c));
                    }
                    if(c.nextPeriodeElement.record.Forecast__c<> null)
                    {
                        sumOfNumberFields.put('C_CY_FORECAST', (sumOfNumberFields.get('C_CY_FORECAST')+c.nextPeriodeElement.record.Forecast__c));
                    }
                    
                    if(c.record.Agreed__c<> null)
                    {
                        sumOfNumberFields.put('C_PY_AGREED', (sumOfNumberFields.get('C_PY_AGREED')+c.record.Agreed__c));
                    }
                    if(c.nextPeriodeElement.record.Agreed__c<> null)
                   {
                        sumOfNumberFields.put('C_CY_AGREED', (sumOfNumberFields.get('C_CY_AGREED')+c.nextPeriodeElement.record.Agreed__c));
                    }
                    
                    if(c.record.POG__c<> null)
                    {
                        sumOfNumberFields.put('C_PY_POG', (sumOfNumberFields.get('C_PY_POG')+c.record.POG__c));
                    }
                    if(c.nextPeriodeElement.record.POG__c<> null)
                    {
                        sumOfNumberFields.put('C_CY_POG', (sumOfNumberFields.get('C_CY_POG')+c.nextPeriodeElement.record.POG__c));
                    }
                }
                
            }
            return sumOfNumberFields;
        }
        set;
    }
    public String texto {get;set;}
  
    public Map<String, Decimal>summaryFields
    {
        get
        {
            if(summaryFields == null)
            {
                summaryFields = new Map<String, Decimal>();
                          
                summaryFields.put('LY_FORECAST_OWN',0);
                summaryFields.put('LY_FORECAST_COMPETITOR',0);
                summaryFields.put('LY_AGREED_OWN',0);
                summaryFields.put('LY_AGREED_COMPETITOR',0);
                summaryFields.put('LY_POG_OWN',0);
                summaryFields.put('LY_POG_COMPETITOR',0);
                           
                summaryFields.put('CY_FORECAST_OWN',0);
                summaryFields.put('CY_FORECAST_COMPETITOR',0);
                summaryFields.put('CY_AGREED_OWN',0);
                summaryFields.put('CY_AGREED_COMPETITOR',0);
                summaryFields.put('CY_POG_OWN',0);
                summaryFields.put('CY_POG_COMPETITOR',0);
                          
                summaryFields.put('LY_FORECAST_RATIO',0);
                summaryFields.put('CY_FORECAST_RATIO',0);
                summaryFields.put('LY_AGREED_RATIO',0);
                summaryFields.put('CY_AGREED_RATIO',0);
                summaryFields.put('LY_POG_RATIO',0);
                summaryFields.put('CY_POG_RATIO',0);
                          
                if(Util.currentYear != null && Util.currentCampaign != null && Util.currentUser != null){
                    List<CampaignLineItem__c> clisThisYear = [
                        SELECT
                            Forecast__c,
                            Agreed__c,
                            PoG__c,
                            ProductRef__c,
                            ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID,
                            ProductRef__r.ProductVendor__r.Name
                        FROM CampaignLineItem__c
                        WHERE
                            (
                               // ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID = :Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog') OR
                                ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID = :Util.recordType.get('ProductCatalog__c:SalesProductCatalog')
                            ) AND
                            CampaignRef__r.isActive = true AND
                            CampaignRef__r.YearV2__c = :Util.currentYear.id AND
                            CampaignRef__r.DE_Season__c = :Util.currentCampaign.DE_Season__c AND
                            CampaignRef__r.OwnerID = :Util.currentUser.ID AND
                            CampaignRef__r.DivisionRef__r.Id = :Util.currentDivision.ID
                        ];
                    Set<ID> productsUsed = new Set<ID>();
                    for(CampaignLineItem__c cli : clisThisYear){
                        productsUsed.add(cli.ProductRef__c);
                    }
                    Map<ID,Product2> productsMap = new Map<ID,Product2>([SELECT DE_BasicUnits__c, DE_RelFactor__c FROM Product2 WHERE ID IN :productsUsed]);
                    texto='';
                    for(CampaignLineItem__c cli : clisThisYear){
                        if(cli.ProductRef__c != null){
                            Decimal multiplier = 0;
                            if(Util.DIVISION_ROUNDUP.equalsIgnoreCase(Util.currentDivision.Name)){
                                multiplier = productsMap.get(cli.ProductRef__c).DE_RelFactor__c * productsMap.get(cli.ProductRef__c).DE_BasicUnits__c;
                            }else{
                                multiplier = productsMap.get(cli.ProductRef__c).DE_BasicUnits__c;
                            }

                           /* if(cli.ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID == Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog')){
                                if(cli.Forecast__c != null) summaryFields.put('CY_FORECAST_COMPETITOR',summaryFields.get('CY_FORECAST_COMPETITOR')+(cli.Forecast__c * multiplier));
                                if(cli.Agreed__c != null) summaryFields.put('CY_AGREED_COMPETITOR',summaryFields.get('CY_AGREED_COMPETITOR') + (cli.Agreed__c * multiplier));
                                if(cli.PoG__c != null) summaryFields.put('CY_POG_COMPETITOR',summaryFields.get('CY_POG_COMPETITOR') + (cli.PoG__c * multiplier));
                            }else if (cli.ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID == Util.recordType.get('ProductCatalog__c:SalesProductCatalog')){
                                if(cli.Forecast__c != null) summaryFields.put('CY_FORECAST_OWN',summaryFields.get('CY_FORECAST_OWN')+(cli.Forecast__c * multiplier));
                                if(cli.Agreed__c != null) summaryFields.put('CY_AGREED_OWN',summaryFields.get('CY_AGREED_OWN') + (cli.Agreed__c * multiplier));
                                if(cli.PoG__c != null) summaryFields.put('CY_POG_OWN',summaryFields.get('CY_POG_OWN') + (cli.PoG__c * multiplier));
                            }*/
                            if (cli.ProductRef__r.ProductVendor__r.Name.contains('Monsanto'))
                            {
                                if(cli.Forecast__c != null) summaryFields.put('CY_FORECAST_OWN',summaryFields.get('CY_FORECAST_OWN').setScale(2)+(cli.Forecast__c * multiplier).setScale(2));
                                if(cli.Agreed__c != null) summaryFields.put('CY_AGREED_OWN',summaryFields.get('CY_AGREED_OWN').setScale(2) + (cli.Agreed__c * multiplier).setScale(2));
                                if(cli.PoG__c != null) summaryFields.put('CY_POG_OWN',summaryFields.get('CY_POG_OWN').setScale(2) + (cli.PoG__c * multiplier).setScale(2));
                            }else if (!cli.ProductRef__r.ProductVendor__r.Name.contains('Monsanto'))
                            {
                                if(cli.Forecast__c != null) summaryFields.put('CY_FORECAST_COMPETITOR',summaryFields.get('CY_FORECAST_COMPETITOR').setScale(2)+(cli.Forecast__c * multiplier).setScale(2));
                                if(cli.Agreed__c != null) summaryFields.put('CY_AGREED_COMPETITOR',summaryFields.get('CY_AGREED_COMPETITOR').setScale(2) + (cli.Agreed__c * multiplier).setScale(2));
                                if(cli.PoG__c != null) summaryFields.put('CY_POG_COMPETITOR',summaryFields.get('CY_POG_COMPETITOR').setScale(2) + (cli.PoG__c * multiplier).setScale(2));
                        
                            }
                        }
                        //texto+= '<br/>' + cli.Agreed__c + ':' + summaryFields.get('CY_AGREED_OWN');                                 
                    }      
                    if(summaryFields.get('CY_FORECAST_COMPETITOR') + summaryFields.get('CY_FORECAST_OWN') != 0){
                        summaryFields.put('CY_FORECAST_RATIO',summaryFields.get('CY_FORECAST_OWN') * 100 / (summaryFields.get('CY_FORECAST_COMPETITOR') + summaryFields.get('CY_FORECAST_OWN')));
                    }
                    if(summaryFields.get('CY_AGREED_COMPETITOR') + summaryFields.get('CY_AGREED_OWN') != 0){
                        summaryFields.put('CY_AGREED_RATIO',summaryFields.get('CY_AGREED_OWN') * 100 / (summaryFields.get('CY_AGREED_COMPETITOR') + summaryFields.get('CY_AGREED_OWN')));
                    }
                    if(summaryFields.get('CY_POG_COMPETITOR') + summaryFields.get('CY_POG_OWN') != 0){
                        summaryFields.put('CY_POG_RATIO',summaryFields.get('CY_POG_OWN') * 100 / (summaryFields.get('CY_POG_COMPETITOR') + summaryFields.get('CY_POG_OWN')));
                    }
                }
                           
                if(Util.previewsCampaign != null && Util.currentCampaign != null){                            
                    List<CampaignLineItem__c> clisLastYear = [
                     SELECT 
                         Forecast__c, 
                         Agreed__c, 
                         PoG__c,
                         ProductRef__c,
                         ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID,
                         ProductRef__r.ProductVendor__r.Name
                     FROM CampaignLineItem__c
                     WHERE 
                     //  FarmRef__c = :Util.currentAccount.id AND 
                         (
                             //ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID = :Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog') OR 
                             ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID = :Util.recordType.get('ProductCatalog__c:SalesProductCatalog')
                         ) AND 
                       //CampaignRef__c = :Util.previewsCampaign.id AND
                         CampaignRef__r.YearV2__c = :Util.lastYear.id AND
                         CampaignRef__r.DE_Season__c = :Util.currentCampaign.DE_Season__c AND
    //                      CampaignRef__r.OwnerID = :Util.currentUser.ID AND
                         CampaignRef__r.DivisionRef__r.Id = :Util.currentDivision.ID AND
                         CampaignRef__r.OwnerID = :Util.currentUser.ID];
             
                    Set<ID> productsUsed = new Set<ID>();
                    for(CampaignLineItem__c cli : clisLastYear){
                        productsUsed.add(cli.ProductRef__c);
                    }
                    Map<ID,Product2> productsMap = new Map<ID,Product2>([SELECT DE_BasicUnits__c, DE_RelFactor__c FROM Product2 WHERE ID IN :productsUsed]);
                    for(CampaignLineItem__c cli : clisLastYear){
                        if(cli.ProductRef__c != null){
                            Decimal multiplier = 0;
                            if(Util.DIVISION_ROUNDUP.equalsIgnoreCase(Util.currentDivision.Name)){
                                multiplier = productsMap.get(cli.ProductRef__c).DE_RelFactor__c * productsMap.get(cli.ProductRef__c).DE_BasicUnits__c;
                            }else{
                                multiplier = productsMap.get(cli.ProductRef__c).DE_BasicUnits__c;
                            }

                            /*if(cli.ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID == Util.recordType.get('ProductCatalog__c:CompetitorProductCatalog')){
                                if(cli.Forecast__c != null) summaryFields.put('LY_FORECAST_COMPETITOR',summaryFields.get('LY_FORECAST_COMPETITOR')+(cli.Forecast__c * multiplier));
                                if(cli.Agreed__c != null) summaryFields.put('LY_AGREED_COMPETITOR',summaryFields.get('LY_AGREED_COMPETITOR') + (cli.Agreed__c * multiplier));
                                if(cli.PoG__c != null) summaryFields.put('LY_POG_COMPETITOR',summaryFields.get('LY_POG_COMPETITOR') + (cli.PoG__c * multiplier));
                            }else if (cli.ProductCatalogEntryRef__r.ProductCatalogRef__r.recordTypeID == Util.recordType.get('ProductCatalog__c:SalesProductCatalog')){
                                if(cli.Forecast__c != null) summaryFields.put('LY_FORECAST_OWN',summaryFields.get('LY_FORECAST_OWN')+(cli.Forecast__c * multiplier));
                                if(cli.Agreed__c != null) summaryFields.put('LY_AGREED_OWN',summaryFields.get('LY_AGREED_OWN') + (cli.Agreed__c * multiplier));
                                if(cli.PoG__c != null) summaryFields.put('LY_POG_OWN',summaryFields.get('LY_POG_OWN') + (cli.PoG__c * multiplier));
                            }*/
                             if (cli.ProductRef__r.ProductVendor__r.Name.contains('Monsanto'))
                            {
                                if(cli.Forecast__c != null) summaryFields.put('LY_FORECAST_OWN',summaryFields.get('LY_FORECAST_OWN').setScale(2)+(cli.Forecast__c * multiplier).setScale(2));
                                if(cli.Agreed__c != null) summaryFields.put('LY_AGREED_OWN',summaryFields.get('LY_AGREED_OWN').setScale(2) + (cli.Agreed__c * multiplier).setScale(2));
                                if(cli.PoG__c != null) summaryFields.put('LY_POG_OWN',summaryFields.get('LY_POG_OWN').setScale(2) + (cli.PoG__c * multiplier).setScale(2));
                            }else if (!cli.ProductRef__r.ProductVendor__r.Name.contains('Monsanto'))
                            {
                                if(cli.Forecast__c != null) summaryFields.put('LY_FORECAST_COMPETITOR',summaryFields.get('LY_FORECAST_COMPETITOR').setScale(2)+(cli.Forecast__c * multiplier).setScale(2));
                                if(cli.Agreed__c != null) summaryFields.put('LY_AGREED_COMPETITOR',summaryFields.get('LY_AGREED_COMPETITOR').setScale(2) + (cli.Agreed__c * multiplier).setScale(2));
                                if(cli.PoG__c != null) summaryFields.put('LY_POG_COMPETITOR',summaryFields.get('LY_POG_COMPETITOR').setScale(2) + (cli.PoG__c * multiplier).setScale(2));
                        
                            }
                        }
                    }

                    if(summaryFields.get('LY_FORECAST_COMPETITOR') + summaryFields.get('LY_FORECAST_OWN') != 0){
                        summaryFields.put('LY_FORECAST_RATIO',summaryFields.get('LY_FORECAST_OWN') * 100 / (summaryFields.get('LY_FORECAST_COMPETITOR') + summaryFields.get('LY_FORECAST_OWN')));
                    }
                    if(summaryFields.get('LY_AGREED_COMPETITOR') + summaryFields.get('LY_AGREED_OWN') != 0){
                        summaryFields.put('LY_AGREED_RATIO',summaryFields.get('LY_AGREED_OWN') * 100 / (summaryFields.get('LY_AGREED_COMPETITOR') + summaryFields.get('LY_AGREED_OWN')));
                    }
                    if(summaryFields.get('LY_POG_COMPETITOR') + summaryFields.get('LY_POG_OWN') != 0){
                        summaryFields.put('LY_POG_RATIO',summaryFields.get('LY_POG_OWN') * 100 / (summaryFields.get('LY_POG_COMPETITOR') + summaryFields.get('LY_POG_OWN')));
                    }
                }
            }
            return summaryFields;
        }
        set;
    }
  
  
  
  public Map<String, String>getsummaryFields2() 
  {
    
    Integer Dec = 2;
    
    Division__c currentDivision=Util.currentDivision;
    if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONITOR)){
      Dec = 3;
    }
    
    Map<String, String>returned=new Map<String, String>(); 
    
    for (String clave: summaryFields.keyset())
    {
      if(clave.contains('RATIO'))   returned.put(clave, String.valueof(summaryFields.get(clave).setScale(2)));//IF is % only two decimals.
      else  returned.put(clave, String.valueof(summaryFields.get(clave).setScale(Dec)));
    }
    
  
    returned.put('CY_FORECAST',  String.valueof((summaryFields.get('CY_FORECAST_COMPETITOR')+summaryFields.get('CY_FORECAST_OWN')).setScale(Dec)));
    returned.put('CY_AGREED',  String.valueof((summaryFields.get('CY_AGREED_COMPETITOR')+summaryFields.get('CY_AGREED_OWN')).setScale(Dec)));
    returned.put('CY_POG',  String.valueof((summaryFields.get('CY_POG_COMPETITOR')+summaryFields.get('CY_POG_OWN')).setScale(Dec)));
    returned.put('LY_FORECAST',  String.valueof((summaryFields.get('LY_FORECAST_COMPETITOR')+summaryFields.get('LY_FORECAST_OWN')).setScale(Dec)));
    returned.put('LY_AGREED',  String.valueof((summaryFields.get('LY_AGREED_COMPETITOR')+summaryFields.get('LY_AGREED_OWN')).setScale(Dec)));
    returned.put('LY_POG',  String.valueof((summaryFields.get('LY_POG_COMPETITOR')+summaryFields.get('LY_POG_OWN')).setScale(Dec)));

    return returned;
  }
//to send excel via mail  
public void excelToMail(){
        
        Division__c currentDivision=Util.currentDivision;
        system.debug('TMP_DEBUG_DIVISION: ' + currentDivision);
        PageReference excel;
        String excelName;     
        if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_CORN)){
             excel = new PageReference('/apex/ExcelExportCornReport'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
             //excel = Page.ExcelExportCornReport;  
             excelName='S&T ZVD Mais '+retoure.TXT_year__c;       
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_OSR)){
             excel = new PageReference('/apex/ExcelExportOSRReportNew'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
             //excel = Page.ExcelExportOSRReportNew;
             excelName='S&T ZVD Raps '+retoure.TXT_year__c;       
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_LATITUDE)){
             excel = new PageReference('/apex/ExcelExportLatitudeReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
            // excel = Page.ExcelExportLatitudeReport; 
             excelName='CP ZielVereinbarung Latitude ';                   
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONITOR)){
             excel = new PageReference('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
            // excel = Page.ExcelExportMonitorReport;  
             excelName='CP ZielVereinbarung Monitor ';                                                  
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_ROUNDUP)){
            if(IsWStufeOrGHNL){
                excel = new PageReference('/apex/ExcelExportRUPBonus2017?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
                    if(IsWStufe)
                        excelName = 'Roundup Bonus-Programm 2017_W-Stufe';
                    else
                        excelName = 'Roundup Bonus-Programm 2016_GHNL';
            } else {
             excel = new PageReference('/apex/ExcelExportRUPWVK_GHNLReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
           //excel = Page.ExcelExportRUPWVK_GHNLReport;
             excelName='CP ZielVereinbarung RUPWVK_GHNL';
            }                               
        }else{
        excel.getParameters().put('id',Util.currentAccount.Id);
        excel.getParameters().put('division',Util.currentDivision.Id);
        excel.getParameters().put('retoure',retoure.Id);
      
        }
        excel.setRedirect(true);

        Attachment attach;
        attach = new Attachment(Name=excelName+' ['+ Util.currentAccount.Name+']'+'.xls',  isPrivate = false);
        String userMail=Util.currentUser.Email;
        Blob body;
        try{
           body = excel.getContent();
        }
        catch (VisualforceException e) {
           body = Blob.valueOf('Error while generating excel' + e);
           attach.name = 'Error.txt';
           userMail='everis.salesforce@gmail.com';
           
       }
        attach.body = body;
              
        integer counter=0;    
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[1];
        
        emails[counter++]=sendToMail(attach,userMail,userMail,Util.currentAccount.Name);
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emails,false);
            for(Messaging.SendEmailResult mser: (List<Messaging.SendEmailResult>)r){
                if(mser.Success)
                    Util.addConfirmMessage('ZVD an die Email ['+Util.currentUser.eMail+ '] versendet');
            }
        }
        catch(Exception e) {}
    }
    
    public static Messaging.SingleEmailMessage sendToMail( Attachment paramAttach, String paramReplyTo, String paramTo, String AccountName){

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        
        efa.setFileName(paramAttach.name);
        efa.setBody(paramAttach.body);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa}); 
        email.setTargetObjectId(Util.currentUser.Id);
            
        if(String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Header').Value__c)==null)
            email.setSubject( 'A new Excel file for ['+AccountName+']');
        else
            email.setSubject( String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Header').Value__c)+ ' ['+Util.currentDivision.Name+']'+ '['+AccountName+']');                
        email.setToAddresses ( ((paramTo != null && paramTo != '')?paramTo:'').split(':'));
        if(String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Body').Value__c)==null)
            email.setPlainTextBody( 'Please find attached the Excel file that has just been created' );
        else 
            email.setPlainTextBody( String.valueOf(SystemSettings__c.getValues('DE_ExcelMail_Body').Value__c) );          
        //email.setOrgWideEmailAddressId(SystemSettings__c.getValues('DE_ORG_MAILER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        email.setSaveAsActivity(false);

        return email;
    }

    public boolean IsWStufeOrGHNL{
        get{
            if(Util.currentAccount.DE_ID_Status__c == 'Wiederverkäufer Ost' || Util.currentAccount.DE_ID_Status__c == 'Wiederverkäufer West' || Util.currentAccount.DE_ID_Status__c == 'Großhandels-Niederlassung')
                return true;
            else
                return false;
        } set;
    }
    
    public boolean IsWStufe{
        get{
            if(Util.currentAccount.DE_ID_Status__c == 'Wiederverkäufer Ost' || Util.currentAccount.DE_ID_Status__c == 'Wiederverkäufer West')
                return true;
            else
                return false;
        } set;
    }

}