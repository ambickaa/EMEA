@IsTest
public class AccountTacticalPlanRSAControllerTest{

    public static testmethod void getPopUp(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);       
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        Id CAccID=Controller.getpopupAccount();
        System.AssertEquals(CAccID,Test_REST_DataFactoryEast.Farm.id);   
    }
    
    public static testmethod void NewAP(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);    
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan NewAP = Controller.getActionPlan();
        System.Assert(NewAP!=null);
    }
    
    public static testmethod void PageRef(){
    Test_REST_DataFactoryEast.TestData();
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        PageReference PPT = Controller.doLoadProductPickerTax();
        PageReference PPR = Controller.doLoadProductPickerRegular();
        PageReference PPFR = Controller.doLoadProductPickerFebReceipt();
        PageReference PPC= Controller.doLoadProductPickerConsigned();
        String PPTCat= PPT.getParameters().get('Catalog');
        String PPRCat= PPR.getParameters().get('Catalog');
        String PPFRCat= PPFR.getParameters().get('Catalog');
        String PPCCat= PPC.getParameters().get('Catalog');
        System.AssertEquals(PPTCat,'Tax');
        System.AssertEquals(PPRCat,'Regular');
        System.AssertEquals(PPFRCat,'Feb Receipt');
        System.AssertEquals(PPCCat, 'Regular');
    }
    public static testmethod void AP(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        
        Test_REST_DataFactoryEast.pr1.Description='MP1';
		Test.StartTest();
        
        CampaignLineItem__c TesCliR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', 
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id);
       
        
        CampaignLineItem__c TesCliFR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Feb Receipt', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged',
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(1).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(1).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );        
      
        insert new List<CampaignLineItem__c>{TesCliR, TesCliFR};

        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP = new AccountTacticalPlanRSAController.ActionPlan();
        AP.addNewRegular();
        AP.editRegular();
        AP.cancelRegular();
        try{AP.checkRegularStock();}
        catch(Exception er){System.Debug(er);}
		AP.saveRegular();
		AP.deleteselectedRegular();
        Test.StopTest();
    }
    
    public static testmethod void APb(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        
        Test_REST_DataFactoryEast.pr1.Description='MP1';
		Test.StartTest();
        
        CampaignLineItem__c TesCliR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', 
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id);
       
        
        CampaignLineItem__c TesCliFR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Feb Receipt', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged',
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(1).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(1).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );        
      
        insert new List<CampaignLineItem__c>{TesCliR, TesCliFR};

        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan APb = new AccountTacticalPlanRSAController.ActionPlan();
        APb.addNewFebReceipt();
        APb.editFebReceipt();
        APb.cancelFebReceipt();
        try{APb.checkFebReceiptStock();}
        catch(Exception efr){System.Debug(efr);}            
        APb.saveFebReceipt();             
        APb.deleteselectedFebReceipt();

        Test.StopTest();
    }
    
    
    public static testmethod void AP7(){
    	Test_REST_DataFactoryEast.TestData();
    	ID DFId = Test_REST_DataFactoryEast.Farm.id;
    	Util.SetCurrentAccount(DFId);
    	Test.StartTest();
    	
    	 CampaignLineItem__c TesCliT=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Tax',
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id, 
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged',
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(2).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(2).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliT;
        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();
        
    	
        AP.addNewTax(); 
        AP.editTax();
        AP.cancelTax(); 
        try{AP.checkTaxStock();}
        catch(Exception et){System.Debug(et);} 
        AP.saveTax();
        AP.deleteselectedTax(); 
        Test.StopTest();
    
    }
    
    
    public static testmethod void AP6(){
    	Test_REST_DataFactoryEast.TestData();
    	ID DFId = Test_REST_DataFactoryEast.Farm.id;
    	Util.SetCurrentAccount(DFId);
    	Test.StartTest();
    	
    	CampaignLineItem__c TesCliC=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', 
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(3).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(3).id, consigned__c=true,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliC;
        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();
        
    	
        AP.addNewConsigned(); 
        AP.editConsigned();
        AP.cancelConsigned(); 
        try{AP.checkConsignedStock();}
        catch(Exception ec){System.Debug(ec);} 
        AP.saveConsigned();
        AP.deleteselectedConsigned(); 
        Test.StopTest();
    
    }
    
    
    
    public static testmethod void AP2(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        Test.StartTest();

        
        CampaignLineItem__c TesCliR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', 
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(0).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(0).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliR;
        

        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();        
       // PageReference PoR = AP.createRegularPreliminaryOrder();
    //    PageReference FFoR = AP.createRegularFinalOrder();
        Boolean RDP= Ap.getDisplayCreatePreliminarButton();      
        Boolean RDPf= Ap.getDisplayCreateFinalButton();

        Test.StopTest();
    } 
    
    public static testmethod void AP3(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        Test.StartTest();
        
        CampaignLineItem__c TesCliFR=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Feb Receipt', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged',
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(1).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(1).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliFR;
        
        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();        

        Boolean FRDP= Ap.getDisplayCreateFebReceiptPreliminarButton();        
        Boolean FRDPf= Ap.getDisplayCreateFebReceiptFinalButton();
        
        PageReference GS = AP.getSelected();
        System.Assert(GS==null);
        Test.StopTest();
    }  
    
    public static testmethod void AP4(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        Test.StartTest();

        CampaignLineItem__c TesCliT=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Tax',
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id, 
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged',
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(2).id,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(2).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliT;
        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();        
        //PageReference PoT = AP.createTaxPreliminaryOrder();
        //PageReference PPFR = AP.createTaxFinalOrder();
        Boolean TDP= Ap.getDisplayCreateTaxPreliminarButton();
        Boolean TDPf= Ap.getDisplayCreateTaxFinalButton();

        Test.StopTest();
    }
    
    
        public static testmethod void AP5(){
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        Test.StartTest();

          CampaignLineItem__c TesCliC=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    GlobalStock_RSA__c =Test_REST_DataFactoryEast.Sto.id,
                    Forecast__c=500, Agreed__c=600,PoG__c=700,
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged', 
                    FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(3).id, consigned__c=true,
                    PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(3).id,
                    ProductRef__c=Test_REST_DataFactoryEast.pr1.id );
        insert TesCliC;
        
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();        
        //PageReference PoT = AP.createTaxPreliminaryOrder();
        //PageReference PPFR = AP.createTaxFinalOrder();
        Boolean CDP= Ap.getdisplayCreateConsignedPreliminarButton();
        Boolean CDPf= Ap.getDisplayCreateConsignedFinalButton();

        Test.StopTest();
    } 
    
                 
    public static testmethod void OrderItemTest(){
      
        Test_REST_DataFactoryEast.TestData();
        Id DFId = Test_REST_DataFactoryEast.Farm.id;
        Util.SetCurrentAccount(DFId);
        Test.StartTest();
              
        CampaignLineItem__c TesCli=new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'), 
                    FarmRef__c = Util.currentAccount.id, CatalogType_RSA__c = 'Regular', 
                    CampaignRef__c = Util.currentCampaign.ID, Type__c = 'Charged');
                    
        AccountTacticalPlanRSAController Controller = new AccountTacticalPlanRSAController();
        AccountTacticalPlanRSAController.OrderItem OI= new AccountTacticalPlanRSAController.OrderItem(TesCli, true, 250, 20);  
        AccountTacticalPlanRSAController.ActionPlan AP= new AccountTacticalPlanRSAController.ActionPlan();
        
        AccountTacticalPlanRSAController.ActionPlan tAP= Controller.getActionPlan();
        AP.addNewTax();
        AP.addNewFebReceipt();
        AP.addNewRegular();
        AP.addNewConsigned();
                
        OI.setFinalOrderNames('Draft');
        Map<String,Double> Tmapii=Controller.getSumOfNumberFields();
        List<CampaignLineItem> tCLI= controller.tacticalPlans;
        Map<String, map<String,Double>> TMApa = controller.extraInformation;
        Test.StopTest();
    }   
}