public with sharing class AccountTacticalPlanElementController
{
    public AccountTacticalPlanComponentController prevCampController {get; set;}
    public AccountTacticalPlanComponentController currentCampController {get; set;}
    public AccountTacticalPlanItalyController italyController {get; set;}
    public AccountTacticalPlanUKController ukController {get; set;}
    public AccountTacticalPlanRSAController rsaController {get; set;}

    public AccountActionPlanGermanySTController germanySTController {get;set;}
    public AccountActionPlanGermanyCPController germanyCPController {get;set;}

    public Campaign currentCampain {get { return Util.currentCampaign; } set;}
    public Division__c currentDivision {get{ return Util.currentDivision; } set;}
    public Map<String,Division__c> divisions {get{ return Util.divisions; } set;}

    public PageReference downloadUrl {get;set;}
    
    public String premiumProductsCurrent 
    {
        get
        {
            premiumProductsCurrent='';
            for (ProductCatalogEntry__c pce : [SELECT id, ProductRef__r.Name, DE_isPremium__c FROM ProductCatalogEntry__c Where ProductCatalogRef__c=:currentCampain.SalesPCMRef__c AND DE_isPremium__c=true])
            {
                premiumProductsCurrent=premiumProductsCurrent+pce.ProductRef__r.Name;
            }

            if(premiumProductsCurrent!='')
            return premiumProductsCurrent;
            else return 'NO PRODUCTS';
        }
        
        set;}
        
        
    public Account account
    {
        get
        {
            return Util.currentAccount;
        }
        set;
    }
    
    public boolean getIsBlockFields()
    {
        return Util.countryView.isBlockFields;
    }
    public boolean getIsItalianView()
    {
        return Util.countryView.isItalianTacticalPlan;
    }
    
    public boolean getIsUKView()
    {
        return Util.countryView.isUKTacticalPlan;
    }
    
    public boolean getIsRSAView()
    {
        return Util.countryView.isRSATacticalPlan;
    }
    
    public boolean getIsGermanView()
    {
        return Util.countryView.isGermanActionPlan;
    }
    
    public boolean getIsGermanCPView()
    {
        return Util.countryView.isGermanCPActionPlan;
    }
    
    public String getCountry()
    {
        return Util.countryView.countryCode.name();
    }
    
    public boolean getIsCpStandard()
    {
        return Util.isCpStandard;
    }
    
    
    public AccountTacticalPlanElementController()
    {
        system.debug('***** AccountTacticalPlanElementController START');
        if(getIsItalianView())
        {
            system.debug('***** getIsItalian START');
            italyController = new AccountTacticalPlanItalyController();

        }
        else if(getIsUKView())
        {
            system.debug('***** getIsUK START');
            ukController = new AccountTacticalPlanUKController();
        }
        else if(getIsRSAView())
        {
            system.debug('***** getIsRSA START');
            rsaController = new AccountTacticalPlanRSAController();
        }
        else if(getIsGermanView())
        {    system.debug('***** getIsGerman START');
            // make an if that checks division
           // if(Util.DIVISION_ROUNDUP.equalsIgnoreCase(Util.currentDivision.Name) ||
           //    Util.DIVISION_LATITUDE.equalsIgnoreCase(Util.currentDivision.Name) ||
          //     Util.DIVISION_MONITOR.equalsIgnoreCase(Util.currentDivision.Name) ||
          //     Util.DIVISION_MONFAST.equalsIgnoreCase(Util.currentDivision.Name)){
          //      germanyCPController = new AccountActionPlanGermanyCPController();
         //   }else{
                germanySTController = new AccountActionPlanGermanySTController();
                germanyCPController = new AccountActionPlanGermanyCPController();
                prevCampController = new AccountTacticalPlanComponentController(Util.previewsCampaign);
                prevCampController.mode = 'No Mode';
               currentCampController = new AccountTacticalPlanComponentController(Util.currentCampaign);
               // italyController = new AccountTacticalPlanItalyController();
           // }
        }
        else if(getIsGermanCPView())
        {    
            system.debug('CONTROLADOR TEST');
            germanyCPController = new AccountActionPlanGermanyCPController();
            prevCampController = new AccountTacticalPlanComponentController(Util.previewsCampaign);
            prevCampController.mode = 'No Mode';
            currentCampController = new AccountTacticalPlanComponentController(Util.currentCampaign);
        }
        else
        {
            system.debug('CONTROLADOR TEST');
            prevCampController = new AccountTacticalPlanComponentController(Util.previewsCampaign);
            prevCampController.mode = 'No Mode';
            currentCampController = new AccountTacticalPlanComponentController(Util.currentCampaign);
        }
        
        system.debug('***** AccountTacticalPlanElementController END');
    }

    public PageReference doCreateAcreages()
    {
        AcreagesManager.createAcreagesByTacticalPlans(Util.currentAccount.Id);
        return URLx.setURL('/apex/'+Util.countryView.country.AccountViewPage__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId 
                  + '#' + AccountAcreagesProductListController.JUMPER_ACREAGES);
    }
    
    public PageReference goToVoucherGeneratorPage()
    {
        return URLx.setURL('/apex/VoucherGenerator?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId);
    }
    
    public PageReference generatePDF() {
        OrderCancellation.generatePDF();
        PageReference returned = new PageReference('/apex/' + Util.countryView.country.AccountViewPage__c);
        returned.setRedirect(true);
        returned.getParameters().put('id',Util.currentAccount.Id);
        return returned; 
    }
    /*public PageReference doCreateExcel(){
    
        if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_CORN)){
            return URLx.setURL('/apex/ExcelExportCornReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_OSR)){
            return URLx.setURL('/apex/ExcelExportOSRReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_LATITUDE)){
            return URLx.setURL('/apex/ExcelExportLatitudeReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONITOR)){
            return URLx.setURL('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_ROUNDUP)){
            return URLx.setURL('/apex/ExcelExportRUPGHNLSockelReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else{
            Util.addWarningMessage('Unexpected Error');
            return ApexPages.currentPage();
        }
    }
    public PageReference doCreateExcel2(){
                    return URLx.setURL('/apex/ExcelExportRUPWVK_GHNLReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
    }*/
    
    public static Retoure__c retoure
    {
        get
        {
        String year;
        if(Util.currentCampaign!=null) year = Util.CurrentCampaign.YearV2__r.Name;
        else if(Util.currentCampaign==null) year = Util.currentYear.Name;
            
           List<Retoure__c> retoures = [SELECT Id, TXT_year__c 
                         FROM Retoure__c
                         WHERE Account__c =: Util.currentAccount.Id AND Division__c =: Util.currentDivision.Id AND TXT_year__c =:year];
                         
            if (retoures.size() > 0){
               retoure = retoures.get(0);
            }
            else{
                retoure = new Retoure__c (Account__c = Util.currentAccount.ID , Division__c = Util.currentDivision.id, TXT_year__c = year);
             }

            return retoure;
        } set;
    }

    public String getCreateExcelURL(){
        String returned;
        if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_CORN)){

            returned = ('/apex/ExcelExportCornReport'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_OSR)){
            returned = ('/apex/ExcelExportOSRReportNew'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID + '&retoureId=' + retoure.Id);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_LATITUDE)){
            returned = ('/apex/ExcelExportLatitudeReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONITOR)){
            returned = ('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONFAST)){
            returned = ('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_ROUNDUP)){
            returned = ('/apex/ExcelExportRUPGHNLSockelReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }
        return returned;
    }
    
    public String getCreateExcelURL2(){
        if(germanyCPController.IsWStufeOrGHNL)
            return ('/apex/ExcelExportRUPBonus2017?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        else
            return ('/apex/ExcelExportRUPWVK_GHNLReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
    }
    
    public void doCreateExcel(){
        
        if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_CORN)){
            downloadURL = new PageReference('/apex/ExcelExportCornReport'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId  + '&retoureId=' + retoure.Id);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_OSR)){
            downloadURL = new PageReference('/apex/ExcelExportOSRReportNew'+retoure.TXT_year__c+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID + '&retoureId=' + retoure.Id);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_LATITUDE)){
            downloadURL = new PageReference('/apex/ExcelExportLatitudeReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONITOR)){
            downloadURL = new PageReference('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_MONFAST)){
             downloadURL = new PageReference('/apex/ExcelExportMonitorReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }else if(currentDivision.Name.equalsIgnoreCase(Util.DIVISION_ROUNDUP)){
            downloadURL = new PageReference('/apex/ExcelExportRUPGHNLSockelReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        }
    }
    
    public void doCreateExcel2(){
        if(germanyCPController.IsWStufeOrGHNL)
        // only to 'Dist./Ret./PoS' having id_Status = 'Großhandels-Niederlassung', 'Großhandels-Niederlassung', 'Wiederverkäufer Stufe', 'Wiederverkäufer Ost', 'Wiederverkäufer West'
            downloadURL = new PageReference('/apex/ExcelExportRUPBonus?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
        else
            downloadURL = new PageReference('/apex/ExcelExportRUPWVK_GHNLReport?id=' + Util.currentAccount.Id + '&division=' + Util.divisionID);
    }
}