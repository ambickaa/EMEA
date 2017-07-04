@isTest
public class Test_REST_SendLogicalEntityFieldCheckUp
{
     private static SM_Campaign__c smc;
     private static Account acc;
     private static Contact co;
     private static Division__c d;
     private static Field__c f;
     private static SM_stage__c st;
     private static RecordType rt;
     private static FieldCheckUp__c fcu;
     private static FCU_External_Conditions__c ec;
     private static FCU_Symptoms_Causes__c sc;
     private static VisualRatingProduct__c vrp;
     private static FCU_Visual_Rating__c vr;
     private static FCU_Observations__c oo;
     
     /* BEGIN - INSERT REST_FieldCheckUpObject */
     static testmethod void InsertTest()
     {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
               
        //External Conditions
        SM_External_Conditions__c sec = new SM_External_Conditions__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert sec;
        ec = new FCU_External_Conditions__c(LKP_ExternalConditions__c=sec.Id, LKP_FCU__c=fcu.Id, TXT_Value__c='ext1', idDevice__c='1');                        
        eco.action = 'Insert';
        eco.statusCode = 0;
        eco.fcuexternalcondition = ec;
        
        //Symptom causes
        SM_Symptoms_Causes__c ssc = new SM_Symptoms_Causes__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaigns__c=smc.Id);
        insert ssc;
        sc = new FCU_Symptoms_Causes__c(LKP_SymptomsCauses__c=ssc.Id, LKP_FCU__c=fcu.Id, TXTA_Remark__c='symp1', idDevice__c=1);             
        sco.action = 'Insert';
        sco.statusCode = 0;
        sco.fcusymptomcause = sc;
        
        //Visual Rating Product        
        vrp = new VisualRatingProduct__c(Name='testVisualProduct', FieldCheckUp__c=fcu.Id, idDevice__c=1);               
        vrpo.action = 'Insert';
        vrpo.statusCode = 0;
        vrpo.visualratingproduct = vrp;        
        
        //Visual ratings
        SM_Visual_Rating__c svr = new SM_Visual_Rating__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert svr;        
        vr = new FCU_Visual_Rating__c(LKP_VisualRating__c=svr.Id, LKP_VisualRatingProduct__c=vrp.Id, TXT_Value__c='value1', idDeviceParent__c=1, idDevice__c=0);                
        vro.action = 'Insert';
        vro.statusCode = 0;
        vro.fcuvisualrating = vr;
        
        //Observations
        SM_Observations__c so = new SM_Observations__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert so;
        oo = new FCU_Observations__c(LKP_Observations__c=so.Id, TXTA_Value__c='value1', idDevice__c=1);        
        o.action = 'Insert';
        o.statusCode = 0;
        o.fcuobservation = oo;
        
        //INSERT
        request.action = 'Insert';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);      
        System.assert(resp.statusCode == 100);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() > 0);
        System.assert(resp.fcuvisualratings.size() > 0);
        System.assert(resp.fcuobservations.size() > 0);               
        
     }
     /* END - INSERT REST_FieldCheckUpObject */
     
     /* BEGIN - UPDATE REST_FieldCheckUpObject */
     static testmethod void UpdateTest()
     {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        InsertTest();
        
        //FieldCheckUp
        FieldCheckUp__c fcuAux = [SELECT Id, Name, LastModifiedDate FROM FieldCheckUp__c WHERE Id =: fcu.Id LIMIT 1];
        
        //External Conditions
        FCU_External_Conditions__c ecAux = [SELECT Id, Name, LastModifiedDate, TXT_Value__c FROM FCU_External_Conditions__c WHERE Id =: ec.Id LIMIT 1];
        ecAux.TXT_Value__c = 'extUpdate'; 
        eco.action = 'Update';
        eco.statusCode = 0;
        eco.LastModifiedDate = ecAux.LastModifiedDate;
        eco.fcuexternalcondition = ecAux;
        
        //Symptom causes
        FCU_Symptoms_Causes__c scAux = [SELECT Id, Name, LastModifiedDate, TXTA_Remark__c FROM FCU_Symptoms_Causes__c WHERE Id =: sc.Id LIMIT 1];     
        scAux.TXTA_Remark__c = 'sympUpdate';
        sco.action = 'Update';
        sco.statusCode = 0;
        sco.LastModifiedDate = scAux.LastModifiedDate;
        sco.fcusymptomcause = scAux;
        
        //Visual Rating Product        
        VisualRatingProduct__c vrpAux = [SELECT Id, Name, LastModifiedDate FROM VisualRatingProduct__c WHERE Id =: vrp.Id LIMIT 1];
        vrpAux.Name = 'productUpdate';
        vrpo.action = 'Update';
        vrpo.statusCode = 0;
        vrpo.LastModifiedDate = vrpAux.LastModifiedDate;
        vrpo.visualratingproduct = vrpAux;
        
        //Visual ratings
        FCU_Visual_Rating__c svrAux = [SELECT Id, Name, TXT_Value__c, LastModifiedDate FROM FCU_Visual_Rating__c WHERE Id =: vr.Id];
        svrAux.TXT_Value__c = 'valUp';        
        vro.action = 'Update';
        vro.statusCode = 0;
        vro.LastModifiedDate = svrAux.LastModifiedDate;
        vro.fcuvisualrating = svrAux;
        
        //Observations       
        FCU_Observations__c ooAux =[SELECT Id, Name, LastModifiedDate, TXTA_Value__c FROM FCU_Observations__c WHERE Id =: oo.Id];
        ooAux.TXTA_Value__c = 'obsUp';
        o.action = 'Update';
        o.statusCode = 0;
        o.LastModifiedDate = ooAux.LastModifiedDate;
        o.fcuobservation = ooAux;
        
        //UPDATE
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.LastModifiedDate = fcuAux.LastModifiedDate;        
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);      
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);      
        System.assert(resp.statusCode == 100);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() > 0);
        System.assert(resp.fcuvisualratings.size() > 0);
        System.assert(resp.fcuobservations.size() > 0);

     }
     /* END - UPDATE REST_FieldCheckUpObject */
     
     /* BEGIN - DELETE REST_FieldCheckUpObject */
     static testmethod void DeleteTest()
     {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        InsertTest();
        
        //DELETES
        FieldCheckUp__c fcuAux = [SELECT Id, Name, LastModifiedDate FROM FieldCheckUp__c WHERE Id =: fcu.Id LIMIT 1];
        
        //External Conditions
        FCU_External_Conditions__c ecAux = [SELECT Id, Name, LastModifiedDate, LKP_ExternalConditions__c FROM FCU_External_Conditions__c WHERE Id =: ec.Id LIMIT 1];
        eco.action = 'Delete';
        eco.statusCode = 0;
        eco.LastModifiedDate = ecAux.LastModifiedDate;
        eco.fcuexternalcondition = ecAux;
        
        //Symptom causes
        FCU_Symptoms_Causes__c scAux = [SELECT Id, Name, LastModifiedDate, TXTA_Remark__c FROM FCU_Symptoms_Causes__c WHERE Id =: sc.Id LIMIT 1];     
        sco.action = 'Delete';
        sco.statusCode = 0;
        sco.LastModifiedDate = scAux.LastModifiedDate;
        sco.fcusymptomcause = scAux;
        
        //Visual Rating Product        
        VisualRatingProduct__c vrpAux = [SELECT Id, Name, LastModifiedDate FROM VisualRatingProduct__c WHERE Id =: vrp.Id LIMIT 1];
        vrpo.action = 'Delete';
        vrpo.statusCode = 0;
        vrpo.LastModifiedDate = vrpAux.LastModifiedDate;
        vrpo.visualratingproduct = vrpAux;
        
        //Visual ratings
        FCU_Visual_Rating__c svrAux = [SELECT Id, Name, TXT_Value__c, LastModifiedDate FROM FCU_Visual_Rating__c WHERE Id =: vr.Id];     
        vro.action = 'Delete';
        vro.statusCode = 0;
        vro.LastModifiedDate = svrAux.LastModifiedDate;
        vro.fcuvisualrating = svrAux;
        
        //Observations       
        FCU_Observations__c ooAux =[SELECT Id, Name, LastModifiedDate FROM FCU_Observations__c WHERE Id =: oo.Id];
        o.action = 'Delete';
        o.statusCode = 0;
        o.LastModifiedDate = ooAux.LastModifiedDate;
        o.fcuobservation = ooAux;
        
        //DELETE
        request.action = 'Delete';
        request.statuscode = 0;
        request.statusDescription = null;
        request.LastModifiedDate = fcuAux.LastModifiedDate;        
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);      
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);      
        System.assert(resp.statusCode == 100);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() > 0);
        System.assert(resp.fcuvisualratings.size() > 0);
        System.assert(resp.fcuobservations.size() > 0);
        
       /*  END - DELETE REST_FieldCheckUpObject */
     }
     static testmethod void UpdateErrorTest()
     {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        InsertTest();
        
        //FieldCheckUp
        FieldCheckUp__c fcuAux = [SELECT Id, Name, LastModifiedDate FROM FieldCheckUp__c WHERE Id =: fcu.Id LIMIT 1];
        
        //External Conditions
        FCU_External_Conditions__c ecAux = [SELECT Id, TXT_Value__c, LastModifiedDate, LKP_ExternalConditions__c FROM FCU_External_Conditions__c WHERE Id =: ec.Id LIMIT 1];
        eco.action = 'Update';
        eco.statusCode = 0;
        eco.LastModifiedDate = Date.today();
        eco.fcuexternalcondition = ecAux;
        
        //Symptom causes
        FCU_Symptoms_Causes__c scAux = [SELECT Id, Name, LastModifiedDate, TXTA_Remark__c FROM FCU_Symptoms_Causes__c WHERE Id =: sc.Id LIMIT 1];
        sco.action = 'Update';
        sco.statusCode = 0;
        sco.LastModifiedDate = Date.today();
        sco.fcusymptomcause = scAux;
        
        //Visual Rating Product        
        VisualRatingProduct__c vrpAux = [SELECT Id, Name, LastModifiedDate FROM VisualRatingProduct__c WHERE Id =: vrp.Id LIMIT 1];
        vrpo.action = 'Update';
        vrpo.statusCode = 0;
        vrpo.LastModifiedDate = Date.today();
        vrpo.visualratingproduct = vrpAux;
        
        //Visual ratings
        FCU_Visual_Rating__c svrAux = [SELECT Id, Name, TXT_Value__c, LastModifiedDate FROM FCU_Visual_Rating__c WHERE Id =: vr.Id];    
        vro.action = 'Update';
        vro.statusCode = 0;
        vro.LastModifiedDate = Date.today();
        vro.fcuvisualrating = svrAux;
        
        //Observations       
        FCU_Observations__c ooAux =[SELECT Id, Name, LastModifiedDate, TXTA_Value__c FROM FCU_Observations__c WHERE Id =: oo.Id];
        o.action = 'Update';
        o.statusCode = 0;
        o.LastModifiedDate = Date.today();
        o.fcuobservation = ooAux;       
        
        //UPDATE ERROR
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.LastModifiedDate = Date.today();        
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);      
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);      
        System.assert(resp.statusCode == 200);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() > 0);
        System.assert(resp.fcuvisualratings.size() > 0);
        System.assert(resp.fcuobservations.size() > 0);
        
     }
     
      static testmethod void DeleteErrorTest()
      {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        InsertTest();
     
        //External Conditions
        FCU_External_Conditions__c ecAux = [SELECT Id, TXT_Value__c, LastModifiedDate, LKP_ExternalConditions__c FROM FCU_External_Conditions__c WHERE Id =: ec.Id LIMIT 1];
        eco.action = 'Delete';
        eco.statusCode = 0;
        eco.LastModifiedDate = ecAux.LastModifiedDate;
        eco.fcuexternalcondition = ecAux;
        delete ecAux;
        
        //Symptom causes
        FCU_Symptoms_Causes__c scAux = [SELECT Id, Name, LastModifiedDate, TXTA_Remark__c FROM FCU_Symptoms_Causes__c WHERE Id =: sc.Id LIMIT 1];
        sco.action = 'Deleted';
        sco.statusCode = 0;
        sco.LastModifiedDate = scAux.LastModifiedDate;
        sco.fcusymptomcause = scAux;
        delete scAux;
        
        //Visual ratings
        FCU_Visual_Rating__c svrAux = [SELECT Id, Name, TXT_Value__c, LastModifiedDate FROM FCU_Visual_Rating__c WHERE Id =: vr.Id];    
        vro.action = 'Deleted';
        vro.statusCode = 0;
        vro.LastModifiedDate = svrAux.LastModifiedDate;
        vro.fcuvisualrating = svrAux;
        delete svrAux;
        
        //Visual Rating Product        
        VisualRatingProduct__c vrpAux = [SELECT Id, Name, LastModifiedDate FROM VisualRatingProduct__c WHERE Id =: vrp.Id LIMIT 1];
        vrpo.action = 'Deleted';
        vrpo.statusCode = 0;
        vrpo.LastModifiedDate = vrpAux.LastModifiedDate;
        vrpo.visualratingproduct = vrpAux;
        delete vrpAux;
        
        //Observations       
        FCU_Observations__c ooAux =[SELECT Id, Name, LastModifiedDate, TXTA_Value__c FROM FCU_Observations__c WHERE Id =: oo.Id];
        o.action = 'Deleted';
        o.statusCode = 0;
        o.LastModifiedDate = ooAux.LastModifiedDate;
        o.fcuobservation = ooAux;
        delete ooAux;
        
        //FieldCheckUp
        FieldCheckUp__c fcuAux = [SELECT Id, Name, LastModifiedDate, lkp_field__c FROM FieldCheckUp__c WHERE Id =: fcu.Id LIMIT 1];
        String idAux = fcuAux.Id;
        delete fcuAux;
        
        //DELETE ERROR
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.LastModifiedDate = fcuAux.LastModifiedDate;        
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);      
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);      
        System.assert(resp.statusCode == 201);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() > 0);
        System.assert(resp.fcuvisualratings.size() > 0);
        System.assert(resp.fcuobservations.size() > 0);
        
      }
           
      static testmethod void ExceptionDMLTest1()
      {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();       
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject();
      
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];
        
        fcu = new FieldCheckUp__c();
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //External Conditions
        SM_External_Conditions__c sec = new SM_External_Conditions__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert sec;
        ec = new FCU_External_Conditions__c(LKP_ExternalConditions__c=sec.Id, LKP_FCU__c = fcu.Id, TXT_Value__c='ext1', idDevice__c='1');
        insert ec;                      
        eco.action = 'Insert';
        eco.statusCode = 0;
        eco.fcuexternalcondition = ec;
        
        //Symptom causes
        SM_Symptoms_Causes__c ssc = new SM_Symptoms_Causes__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaigns__c=smc.Id);
        insert ssc;
        sc = new FCU_Symptoms_Causes__c(LKP_SymptomsCauses__c=ssc.Id, LKP_FCU__c = fcu.Id, TXTA_Remark__c='symp1', idDevice__c=1);             
        sco.action = 'Insert';
        sco.statusCode = 0;
        sco.fcusymptomcause = sc;
        
        //Visual Rating Product        
        vrp = new VisualRatingProduct__c(Name='testVisualProduct', idDevice__c=1);               
        vrpo.action = 'Insert';
        vrpo.statusCode = 0;
        vrpo.visualratingproduct = vrp;
        
        //Visual ratings
        SM_Visual_Rating__c svr = new SM_Visual_Rating__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert svr;        
        vr = new FCU_Visual_Rating__c(LKP_VisualRating__c=svr.Id, LKP_FCU__c = fcu.Id, LKP_VisualRatingProduct__c=vrp.Id, TXT_Value__c='value1', idDeviceParent__c=1, idDevice__c=0);                
        vro.action = 'Insert';
        vro.statusCode = 0;
        vro.fcuvisualrating = vr;
        
        //Observations
        SM_Observations__c so = new SM_Observations__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert so;
        oo = new FCU_Observations__c(LKP_Observations__c=so.Id, LKP_FCU__c = fcu.Id, TXTA_Value__c='value1', idDevice__c=1);        
        o.action = 'Insert';
        o.statusCode = 0;
        o.fcuobservation = oo;
        
        //INSERT
        request.action = 'Insert';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);   
        System.assert(resp.statusCode == 999);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);
        System.assert(resp.fcuexternalconditions.size() > 0);
        System.assert(resp.fcusymptomscauses.size() > 0);
        System.assert(resp.visualratingsproduct.size() >0);
        System.assert(resp.fcuvisualratings.size() >0);
        System.assert(resp.fcuobservations.size() > 0);
     }
     
     static testmethod void ExceptionDMLTest2()
     {
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();       
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject();
      
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;
        
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];
        
        fcu = new FieldCheckUp__c();
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //FieldCheckUp
        FieldCheckUp__c fcuAux = [SELECT Id, Name, LastModifiedDate FROM FieldCheckUp__c WHERE Id =: fcu.Id LIMIT 1];
        
        //External Conditions
        SM_External_Conditions__c sec = new SM_External_Conditions__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert sec;
        ec = new FCU_External_Conditions__c(LKP_ExternalConditions__c=sec.Id, LKP_FCU__c = fcu.Id, TXT_Value__c='ext1', idDevice__c='1');
        insert ec;                      
        eco.action = 'Insert';
        eco.statusCode = 0;
        eco.fcuexternalcondition = ec;
        
        //UPDATE
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.LastModifiedDate = fcuAux.LastModifiedDate;        
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();        
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
        resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
        System.debug(resp.statusCode);   
        System.assertEquals(998, resp.statusCode);
        System.assert(resp.statusDescription != null);
        System.assert(resp.fieldcheckup != null);        
     }
     
            
     static testmethod void NoRights()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }

        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;

        //INSERT
        request.action = 'Delete';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
            //System.assert(resp.statusCode == 202);
            //System.assert(resp.statusDescription != null);
            //System.assert(resp.fieldcheckup != null);
        } 
               
     }
     
     static testmethod void NoRights2()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }

        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //External Conditions
        SM_External_Conditions__c sec = new SM_External_Conditions__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert sec;
        ec = new FCU_External_Conditions__c(LKP_ExternalConditions__c=sec.Id, LKP_FCU__c = fcu.Id, TXT_Value__c='ext1', idDevice__c='1');
        insert ec;                      
        eco.action = 'Delete';
        eco.statusCode = 0;
        eco.fcuexternalcondition = ec;

        //INSERT
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcuexternalconditions.add(eco);
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();        
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();        
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();    
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
           // System.assert(resp.statusCode == 202);
            System.assert(resp.statusDescription != null);
            System.assert(resp.fieldcheckup != null);
        } 
               
     }
     
     static testmethod void NoRights3()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }

        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //Symptom causes
        SM_Symptoms_Causes__c ssc = new SM_Symptoms_Causes__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaigns__c=smc.Id);
        insert ssc;
        sc = new FCU_Symptoms_Causes__c(LKP_SymptomsCauses__c=ssc.Id, LKP_FCU__c=fcu.Id, TXTA_Remark__c='symp1', idDevice__c=1);
        insert sc;             
        sco.action = 'Delete';
        sco.statusCode = 0;
        sco.fcusymptomcause = sc;

        //INSERT
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();
        request.fcusymptomscauses.add(sco);        
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();        
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();    
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
           // System.assert(resp.statusCode == 202);
            System.assert(resp.statusDescription != null);
            System.assert(resp.fieldcheckup != null);
        }               
     }
     
     static testmethod void NoRights4()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }
        
        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //Visual Rating Product        
        vrp = new VisualRatingProduct__c(Name='testVisualProduct', FieldCheckUp__c=fcu.Id, idDevice__c=1); 
        insert vrp;              
        vrpo.action = 'Delete';
        vrpo.statusCode = 0;
        vrpo.visualratingproduct = vrp; 

        //INSERT
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();       
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.visualratingsproduct.add(vrpo);  
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();    
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
            //System.assert(resp.statusCode == 202);
            System.assert(resp.statusDescription != null);
            System.assert(resp.fieldcheckup != null);
        } 
               
     }
     
     static testmethod void NoRights5()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }
        
        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //Visual Rating Product        
        vrp = new VisualRatingProduct__c(Name='testVisualProduct', FieldCheckUp__c=fcu.Id, idDevice__c=1);               
        insert vrp;
                
        //Visual ratings
        SM_Visual_Rating__c svr = new SM_Visual_Rating__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert svr;        
        vr = new FCU_Visual_Rating__c(LKP_VisualRating__c=svr.Id, LKP_FCU__c=fcu.Id, LKP_VisualRatingProduct__c=vrp.Id, TXT_Value__c='value1', idDeviceParent__c=1, idDevice__c=0);
        insert vr;                
        vro.action = 'Delete';
        vro.statusCode = 0;
        vro.fcuvisualrating = vr;

        //INSERT
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();       
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuvisualratings.add(vro);
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();    
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
          //  System.assert(resp.statusCode == 202);
            System.assert(resp.statusDescription != null);
            System.assert(resp.fieldcheckup != null);
        } 
               
     }
     
     static testmethod void NoRights6()
     {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Service'];
        
        for(Profile p : ps)         
        {
            profiles.put(p.name, p.id);         
        }
        
        User user = [SELECT Id FROM user WHERE isActive = true AND profileid =: profiles.get('Customer Service') LIMIT 1];
        REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject request = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();        
        fcu = new FieldCheckUp__c();
        REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject eco = new REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject sco = new REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject vrpo = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject();
        REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject vro = new REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject();
        REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject o = new REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject ();
        
        SystemSettings__c ss = new SystemSettings__c(Name='EAST_REST_SVC_JSON_SAVE', Value__c='all');
        insert ss;
        SystemSettings__c ss2 = new SystemSettings__c(Name=Util.currentUser.CountryISOCode__c+'_REST_LOG_FOLDER', Value__c='SpainLogs');
        insert ss2;        
        
        smc = new SM_Campaign__c(name = 'testCampaign');
        insert smc;
        Country__c c = new Country__c(Name='testCountry', TacticalPlanSetting__c = 'Standard');
        insert c;        
        acc = new Account(Name='testAccount', Category__c='Group', GC_Status_Descr__c ='Active', CountryRef__c=c.Id);
        insert acc;
        co = new Contact(FirstName='testContact', LastName='testContact', AccountId=acc.Id);
        insert co;
        d = new Division__c(Name='testDivision');
        insert d;
        Year__c last = new Year__c (Name='2012', Current_Year__c=false, YearEndDate__c=date.newinstance(2012, 12, 31), 
        YearStartDate__c=date.newinstance(2012, 1, 1)); 
        insert last;    
        Year__c  year = new Year__c (Name='2013', Current_Year__c=true, YearEndDate__c=date.newinstance(2014, 12, 31), 
        YearStartDate__c=date.newinstance(2013, 1, 1), YearPreviousYear__c=Last.id,CurrentYear_RSA__c=true); 
        insert year;    
                 
        Acreage__c ac = new Acreage__c(AcrFarmRef__c = acc.id,  AcrYearRef__c = year.Id, AcrTotalAcreages__c = 200);
        insert ac;   
        
        f = new Field__c(Name='testField', LKP_Acreage__c = ac.Id);
        insert f;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;                
        rt = [SELECT Id, Name, SobjectType FROM RecordType WHERE SObjectType='FieldCheckUp__c' LIMIT 1];         
        
        fcu.idDevice__c = 1;
        fcu.LKP_SeedsmanCampaign__c = smc.Id;
        fcu.LKP_Account__c = acc.Id;
        fcu.LKP_Contact__c = co.Id;
        fcu.LKP_Division__c = d.Id;
        fcu.LKP_Field__c = f.Id;
        fcu.LKP_SM_Stage__c = st.Id;    
        fcu.RecordTypeId = rt.Id;
        fcu.TXT_Note_title_ExternalConditions__c = 'note title external condition';
        fcu.TXTA_Note_body_ExternalConditions__c = 'note body external condition';
        fcu.TXT_Note_title_SymptomsCauses__c = 'note title symptoms';
        fcu.TXTA_Note_body_SymptomsCauses__c = 'note body symptoms';
        fcu.TXT_Note_title_VisualRating__c = 'note title visual rating';
        fcu.TXTA_Note_body_VisualRating__c = 'note body visual rating';
        fcu.PICK_Language__c = 'EN';
        insert fcu;
        
        //Observations
        SM_Observations__c so = new SM_Observations__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert so;
        oo = new FCU_Observations__c(LKP_Observations__c=so.Id, TXTA_Value__c='value1', idDevice__c=1);        
        o.action = 'Delete';
        o.statusCode = 0;
        o.fcuobservation = oo;
        
        //INSERT
        request.action = 'Update';
        request.statuscode = 0;
        request.statusDescription = null;
        request.fieldcheckup = fcu;
        request.fcuexternalconditions = new List<REST_SendLogicalEntityFieldCheckUp.REST_ExternalConditionsObject>();
        request.fcusymptomscauses = new List<REST_SendLogicalEntityFieldCheckUp.REST_SymptomsCausesObject>();       
        request.visualratingsproduct = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsProductObject>();
        request.fcuvisualratings = new List<REST_SendLogicalEntityFieldCheckUp.REST_VisualRatingsObject>();
        request.fcuobservations = new List<REST_SendLogicalEntityFieldCheckUp.REST_ObservationsObject>();
        request.fcuobservations.add(o);
        
        String JsonMsg = JSON.serialize(request);       
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sendLogicalEntity/FieldCheckUp';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        system.runAs(user)
        {
            REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject resp = new REST_SendLogicalEntityFieldCheckUp.REST_FieldCheckUpObject();
            resp = REST_SendLogicalEntityFieldCheckUp.sendFieldCheckUp(request);
           // System.assert(resp.statusCode == 202);
            System.assert(resp.statusDescription != null);
            System.assert(resp.fieldcheckup != null);
        } 
               
     }
}