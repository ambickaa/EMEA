public with sharing class AccountActionPlanGermanySTController  extends AccountListVirtualController
{
    
  public Set<Id> currentPCEs { get; set;}
   
  public AccountActionPlanGermanySTController()
    {
        currentPCEs=new Set<id>();
        if (Util.CurrentCampaign != null && Util.currentCampaign.SalesPCMREf__c!=null){
            for (ProductCatalogEntry__c pce:[SELECT ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c=:Util.currentCampaign.SalesPCMRef__c]){
                currentPCEs.add(pce.ProductRef__c);
            }
        }       
        objectFactory = new ActionPlanGermanyFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
    }
  
  public List<CampaignLineItem> tacticalPlans
  {
    get
    {
        for(CampaignLineItem c : ( List<CampaignLineItem> ) wrapperObjects){
            if(c.nextPeriodeElement.record.ProductRef__c != null && !currentPCEs.contains(c.nextPeriodeElement.record.ProductRef__c))
                c.frozen=true;
        }
       return ( List<CampaignLineItem> ) wrapperObjects;
    }
    set;
  }
  
    public virtual boolean getIsDisplayExcel(){
        infoUser =[
            SELECT Is_Regional_Manager__c
            FROM User 
            WHERE ID = :userInfo.getUserID()];
        
        Integer distributor = 0;
        Boolean agreed = false;
        if (tacticalPlans.size() == 0){
            distributor = 1;
        }
        for(CampaignLineItem c : tacticalPlans){
            if (c.nextPeriodeElement.record.Agreed__c != null && c.nextPeriodeElement.record.Agreed__c > 0){
                agreed = true;
                break;
            }    
        }
        if(agreed == false) distributor = 1;
        if (infoUser.Is_Regional_Manager__c== true ) return false;
        else if (Util.currentAccount.RecordType.name != 'Dist./Ret./PoS') return false;
        else if (Util.currentDivision.Name != 'Corn' && Util.currentDivision.Name != 'OSR') return false;
        else if (distributor == 1) return false;
        else return true;        
    }
    
    public virtual boolean getIsDisplayButtons(){

        infoUser =[
            SELECT Is_Regional_Manager__c, Is_Country_Manager__c, Is_Promoter__c, Is_Sales_Rep__c, Profile.Name
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
        //S&T/Distributor/Sales Representative or Regional Manager
        else if (Util.currentAccount.RecordTypeId == Util.recordType.get('Account:DistRetPoS')
                    && (infoUser.Is_Sales_Rep__c
                        || infoUser.Is_Regional_Manager__c) // it should be giving access to RM already.
                    ){
            return true;
                
        }
        //S&T/Others/Sales Representative or Promoter
        else if (Util.currentAccount.RecordTypeId == Util.recordType.get('Account:Others')
                    && (infoUser.Is_Promoter__c 
                        || infoUser.Is_Sales_Rep__c )
                    ){
            return true;
                
        }
       // else if(util.currentUserTerrMan.contains(util.currentAccountCountry.DE_Territory_Key__c ))
       else if(util.isAccountOwner && util.isCpStandard)
        {
          return true;
        
        }
        
         else {
            return false;
        }
        
        //End germany dev
        //Current condition to display buttons, grants access to everyone except CM with Account Types Distributors, Competitors and Others.
//        if (infoUser.Is_Country_Manager__c== true  && Util.currentAccount.RecordTypeId != Util.recordType.get('Account:Group/Farm/Site')) 
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
        sumOfNumberFields.put('FOC_PY_POG', 0);
        sumOfNumberFields.put('C_PY_POG', 0);
        sumOfNumberFields.put('FOC_CY_FORECAST', 0);
        sumOfNumberFields.put('C_CY_FORECAST', 0);
        sumOfNumberFields.put('FOC_CY_AGREED', 0);
        sumOfNumberFields.put('C_CY_AGREED', 0);
        sumOfNumberFields.put('C_CY_POG', 0);
        sumOfNumberFields.put('FOC_CY_POG', 0);
        sumOfNumberFields.put('CY_Inventory', 0);
        for(CampaignLineItem c : tacticalPlans)
        {
          if(c.freeOfChargeElement.record.POG__c<> null)
          {
            sumOfNumberFields.put('FOC_PY_POG', (sumOfNumberFields.get('FOC_PY_POG')+c.freeOfChargeElement.record.POG__c));
          }

           if(c.record.POG__c<> null)
           {

               sumOfNumberFields.put('C_PY_POG', (sumOfNumberFields.get('C_PY_POG')+c.record.POG__c));
           }
          
          
          //System.assert(false, c.nextPeriodeElement);
          if(c.nextPeriodeElement.freeOfChargeElement.record.Forecast__c<> null)
          {
            sumOfNumberFields.put('FOC_CY_FORECAST', (sumOfNumberFields.get('FOC_CY_FORECAST')+c.nextPeriodeElement.freeOfChargeElement.record.Forecast__c));
          }
          if(c.nextPeriodeElement.record.Forecast__c<> null)
          {
            sumOfNumberFields.put('C_CY_FORECAST', (sumOfNumberFields.get('C_CY_FORECAST')+c.nextPeriodeElement.record.Forecast__c));
          }
          
          if(c.nextPeriodeElement.freeOfChargeElement.record.Agreed__c<> null)
          {
            sumOfNumberFields.put('FOC_CY_AGREED', (sumOfNumberFields.get('FOC_CY_AGREED')+c.nextPeriodeElement.freeOfChargeElement.record.Agreed__c));
          }
          if(c.nextPeriodeElement.record.Agreed__c<> null)
          {
            sumOfNumberFields.put('C_CY_AGREED', (sumOfNumberFields.get('C_CY_AGREED')+c.nextPeriodeElement.record.Agreed__c));
          }
          
          if(c.nextPeriodeElement.freeOfChargeElement.record.POG__c<> null)
          {
            sumOfNumberFields.put('FOC_CY_POG', (sumOfNumberFields.get('FOC_CY_POG')+c.nextPeriodeElement.freeOfChargeElement.record.POG__c));
          }
          if(c.nextPeriodeElement.record.POG__c<> null)
          {
            sumOfNumberFields.put('C_CY_POG', (sumOfNumberFields.get('C_CY_POG')+c.nextPeriodeElement.record.POG__c));
          }
          
          if(c.nextPeriodeElement.getInventory() <> null)
          {
            sumOfNumberFields.put('CY_Inventory', (sumOfNumberFields.get('CY_Inventory')+c.nextPeriodeElement.getInventory()));
          }
          
          
        }
        
      }
      return sumOfNumberFields;
    }
    set;
  }


//to send excel via mail  
public void excelToMail(){
        
        Division__c currentDivision=Util.currentDivision;
        
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
             excel = new PageReference('/apex/ExcelExportRUPWVK_GHNLReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
           //excel = Page.ExcelExportRUPWVK_GHNLReport;
             excelName='CP ZielVereinbarung RUPWVK_GHNL';                                      
        }   
                      
      //  excel.getParameters().put('id',Util.currentAccount.Id);
      //  excel.getParameters().put('division',Util.currentDivision.Id);
      //  excel.getParameters().put('retoure',retoure.Id);
        
        excel.setRedirect(true);

        Attachment attach;
        attach = new Attachment(Name=excelName+' ['+ Util.currentAccount.Name+']'+'.xls',  isPrivate = false);
        
        String userMail=Util.currentUser.Email;
        
        Blob body;
        try {
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
                for(Messaging.SendEmailResult mser: (List<Messaging.SendEmailResult>)r)
                {   if(mser.Success)
                        Util.addConfirmMessage('ZVD an die Email ['+Util.currentUser.eMail+ '] versendet');
                    
                    System.debug('Email result ' + mser.IsSuccess());
                    System.debug('mail='+r.get(0).getErrors()[0].getMessage());
                }
           }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            }
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
        email.setOrgWideEmailAddressId(SystemSettings__c.getValues('DE_ORG_MAILER_ID').Value__c);
        email.setReplyTo(paramReplyTo);
        email.setSaveAsActivity(false);

        return email;
    }
    
    public override PageReference save(){
        
        for(CampaignLineItem c : tacticalPlans){
            if (c.nextPeriodeElement.record.PoG__c != null && c.nextPeriodeElement.record.PoG__c > 0 && c.nextPeriodeElement.record.LKP_DistributorRefST__c == null){
                Util.AddErrorMessage(label.DE_POG_WITHOUT_POS);
                return null;
            } 
        }
        try{
           objectModifier.save( wrapperObjects );
        } catch (DMLException theException){
            if((theException.getMessage()).contains(label.DE_RETOURE_POGVSMENGE)) return null;
            else{
                Util.addErrorMessage(theException.getMessage());
                return null;
            }   
        }

        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+Util.countryView.country.AccountViewPage__c+'?id='+accountId+'&division='+Util.divisionId+'#'+jumperTag );
        }
        return URLx.setURL( '/apex/'+Util.countryView.country.AccountViewPage__c+'?id='+accountId+'&division='+Util.divisionId );
    }
  
}