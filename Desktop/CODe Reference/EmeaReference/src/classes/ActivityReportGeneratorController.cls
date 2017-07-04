public with sharing class ActivityReportGeneratorController
{  
 public String imageURL{get;set;}
  
  public List<FieldCheckUp__c> FCUList {get;set;}
  public List<FCU_External_Conditions__c> ExtCondList {get;set;}
  public List<FCU_Observations__c> ObsList {get;set;}
  public List<FCU_Symptoms_Causes__c> SymptCausList {get;set;}
  public List<FCU_Visual_Rating__c> VisRatList {get;set;}
  public List<FieldCheckUp__c> AccountDataList  {get;set;}  
  public List<VisualRatingProduct__c> VRProductList {get;set;}
  public List<Note> NotesList  {get;set;}  
  public FCU_Report_Generator__c generator {get;set;}
  public List<ExternalConditionsMaster__c> ExtCondMasterList {get;set;}
  public Map<String, String> languagesMap {get;set;}
  public Account acc {get; set;}
  public Contact cont {get; set;}
  public Field__c fie {get; set;}
  public Acreage__c acr {get; set;}  
  public  List<Schema.FieldSetMember> fieldSetAccount {get;set;}
  public  List<Schema.FieldSetMember> fieldSetContact {get;set;}
  public  List<Schema.FieldSetMember> fieldSetField {get;set;}
  public  List<Schema.FieldSetMember> fieldSetAcreage {get;set;}  
  public List<FieldCheckUp__c> ContactDataList  {get;set;}
  public List<FieldCheckUp__c> FieldDataList  {get;set;}
  public List<FieldCheckUp__c> AcreageDataList  {get;set;}
  public List<FieldCheckUp__c> StageDataList  {get;set;}
  public List<User> UserList {get;set;}
  public  ActivityReportGeneratorController() 
  {
       
    imageURL='/servlet/servlet.FileDownload?file=';
    
    Generator=[SELECT
                    Name, id, TXT_Notes__c, createddate, TXT_Observations__c, TXT_Symptoms_Causes__c, TXT_Visual_rating__c, LKP_Field_Check_Up__c, TXT_Language__c, TXT_External_Conditions__c                                                            
                    FROM
                    FCU_Report_Generator__c
                    WHERE id=:ApexPages.currentPage().getParameters().get('idReport')
                    ]; 
    
    system.debug('id del report: ' + ApexPages.currentPage().getParameters().get('idReport'));  
                    
   List<Id> listaIDsObjetos = new List<Id>();
       listaIDsObjetos.add(generator.LKP_Field_Check_Up__c);
        if(generator.TXT_Notes__c!=null)
        {
            String[] idNotes=generator.TXT_Notes__c.replaceAll(' ','').split(',');
            for(String itemNotes : idNotes)
            {
                listaIDsObjetos.add(itemNotes);
            }
        }
        if(generator.TXT_Observations__c!=null)
        {
            String[] idObservations=generator.TXT_Observations__c.replaceAll(' ','').split(',');
            for(String itemObservations : idObservations)
            {
                listaIDsObjetos.add(itemObservations);
            }
        }
        if(generator.TXT_Symptoms_Causes__c!=null)
        { 
            String[] idSymptoms=generator.TXT_Symptoms_Causes__c.replaceAll(' ','').split(',');
            for(String itemSymptoms : idSymptoms)
            {
                listaIDsObjetos.add(itemSymptoms);
            }
        }
        if(generator.TXT_Visual_rating__c!=null)
        {
            String[] idVisual=generator.TXT_Visual_rating__c.replaceAll(' ','').split(',');
            for(String itemVisual : idVisual)
            {
                listaIDsObjetos.add(itemVisual);
            }
        }
         if(generator.TXT_External_Conditions__c!=null)
        {
            String[] idExternal=generator.TXT_External_Conditions__c.replaceAll(' ','').split(',');
            for(String itemExternal : idExternal)
            {
                listaIDsObjetos.add(itemExternal);
            }
        }     
    
    FCUList=[SELECT                           
               Name, id, PICK_Language__c   
               FROM 
               FieldCheckUp__c
               WHERE id IN : listaIDsObjetos               
               ];
    for(FieldCheckUp__c fcuplang : FCUList)
    {
        String languageReport = fcuplang.PICK_Language__c;
    }
 
       
    ExtCondList=[SELECT
                    Name, id, TXT_value__c, LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.Id, idDevice__c, 
                    LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.Name, LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.TXT_Units_of_measure__c,LKP_FCU__r.PICK_Language__c
                    FROM
                    FCU_External_Conditions__c
                    WHERE id IN : listaIDsObjetos ORDER BY Createddate
                    ];
    
    ObsList=[SELECT
                Name, id, TXTA_value__c, LKP_Observations__r.name
                , LKP_FCU__r.PICK_Language__c
                , LKP_Observations__r.LKP_ObservationsMaster__r.name, (select id, name from attachments)
                FROM
                FCU_Observations__c
                WHERE id IN : listaIDsObjetos ORDER BY Createddate
                ];
                
                for(FCU_Observations__c item : ObsList)
                {
                    item.TXTA_Value__c = formatParagraph(item.TXTA_Value__c);                   
                }
    
    SymptCausList=[SELECT
                    Name, id, LKP_SymptomsCauses__r.LKP_CausesMaster__r.Name, TXTA_Remark__c, LKP_SymptomsCauses__r.LKP_SymptomsMaster__r.Name
                    , LKP_FCU__r.PICK_Language__c
                    , 
                    (select name, id, description from attachments)
                    FROM
                    FCU_Symptoms_Causes__c
                    WHERE id IN : listaIDsObjetos ORDER BY LKP_SymptomsCauses__r.TXT_SymptomsGroup__c, LKP_SymptomsCauses__r.LKP_SymptomsMaster__r.Name, ID
                    ];
                    
  
    VisRatList = new List<FCU_Visual_Rating__c>();
    VisRatList=[SELECT
                    Name, id, TXT_Value__c, LKP_VisualRating__r.name
                    , LKP_FCU__r.PICK_Language__c
                    , LKP_VisualRating__r.LKP_VisualRatingMaster__r.name
                    FROM
                    FCU_Visual_Rating__c
                    WHERE id IN : listaIDsObjetos
                    ];  
                  
     
    AccountDataList=[SELECT
                    Name, LKP_Account__c, LKP_Account__r.ZIPPostalCode__c, LKP_Account__r.StateProvince__c, LKP_Account__r.CountryRef__r.name, LKP_Account__r.Street__c, LKP_Account__r.Client_Code__c, LKP_Account__r.Name, LKP_Account__r.City__c,
                    TXTA_Note_body_ExternalConditions__c, TXTA_Note_body_SymptomsCauses__c, TXTA_Note_body_VisualRating__c, TXT_Note_title_ExternalConditions__c, TXT_Note_title_SymptomsCauses__c, TXT_Note_title_VisualRating__c,
                    RecordType.Name, CreatedDate, OwnerId                   
                    FROM
                    FieldCheckUp__c
                    WHERE id IN : listaIDsObjetos
                    ];
     
     ContactDataList=[SELECT 
                     LKP_Contact__c, LKP_Contact__r.Phone, LKP_Contact__r.Name, LKP_Contact__r.Email
                     FROM
                     FieldCheckUp__c
                     WHERE id IN : listaIDsObjetos 
                     ];
     
     FieldDataList=[SELECT
                     LKP_Field__c, LKP_Field__r.GPS_Position__c, LKP_Field__r.PICK_Cultivation_type__c, LKP_Field__r.Name
                     FROM
                     FieldCheckUp__c
                     WHERE id IN : listaIDsObjetos
                     ];
     
     AcreageDataList=[SELECT
                     LKP_Field__r.LKP_Acreage__c, LKP_Field__r.LKP_Acreage__r.AcrProductGroupRef__r.Name, LKP_Field__r.LKP_Acreage__r.AcrProductTypeRef__r.Name
                     FROM
                     FieldCheckUp__c
                     WHERE id IN : listaIDsObjetos
                     ];
                     
     StageDataList=[SELECT
                     LKP_SM_Stage__r.Name, LKP_SM_Stage__r.LKP_StageMaster__c, LKP_SM_Stage__r.LKP_StageMaster__r.Name
                     FROM
                     FieldCheckUp__c
                     WHERE id IN : listaIDsObjetos
                     ];
                    
     UserList = [SELECT CountryISOCode__c, Phone, Name FROM User Where Id =: AccountDataList[0].OwnerId];
     
   
     fieldSetAccount = readFieldSet('AccountFieldSet_'+UserList[0].CountryISOCode__c,'Account');
     if(fieldSetAccount !=null)
        acc=(Account)getRecordByFieldset(AccountDataList[0].LKP_Account__c, 'Account', fieldSetAccount );
     
     if(ContactDataList[0].LKP_Contact__c!=null)
     {
         fieldSetContact = readFieldSet('ContactFieldSet_'+UserList[0].CountryISOCode__c,'Contact');
         if(fieldSetContact !=null)
             cont=(Contact)getRecordByFieldset(ContactDataList[0].LKP_Contact__c, 'Contact', fieldSetContact );
     }
   
     fieldSetField = readFieldSet('FieldFieldSet_'+UserList[0].CountryISOCode__c,'Field__c');
     if(fieldSetField !=null)
         fie=(Field__c)getRecordByFieldset(FieldDataList[0].LKP_Field__c, 'Field__c', fieldSetField );
     
     fieldSetAcreage = readFieldSet('AcreageFieldSet_'+UserList[0].CountryISOCode__c,'Acreage__c');
     if(fieldSetAcreage !=null)
         acr=(Acreage__c)getRecordByFieldset(AcreageDataList[0].LKP_Field__r.LKP_Acreage__c, 'Acreage__c', fieldSetAcreage );
                    
     VRProductList=[SELECT
                  Name, LKP_Product__r.ProductDisplayName__c, LKP_Product__r.ProductTreatment__c, (select name, id from attachments),
                  (select id, TXT_Value__c, LKP_VisualRating__r.LKP_VisualRatingMaster__r.name, LKP_VisualRating__r.LKP_VisualRatingMaster__c
                  , LKP_FCU__r.PICK_Language__c
                   from FCU_Visual_ratings__r ORDER BY LKP_VisualRating__r.NUM_Order__c)
                  FROM
                  VisualRatingProduct__c
                  WHERE id IN : listaIDsObjetos ORDER by CreatedDate
                  ];
     
    NotesList=[select body, title from Note WHERE id IN : listaIDsObjetos ORDER BY CreatedDate];
                    
    List<Id> listaIDsECM = new List<Id>();
    List<Id> listaIDsSCM = new List<Id>();
    List<Id> listaIDsSM = new List<Id>();
    List<Id> listaIDsVR = new List<Id>();
    List<Id> listaIDsOB = new List<Id>();
    List<Id> listaIDsST = new List<Id>();
    for(FCU_External_Conditions__c extcond : ExtCondList)
    {       
        listaIDsECM.add(extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.Id);
    }
    for(FCU_Symptoms_Causes__c sympcaus : SymptCausList)
    {       
        listaIDsSCM.add(sympcaus.LKP_SymptomsCauses__r.LKP_CausesMaster__r.Id);
        listaIDsSM.add(sympcaus.LKP_SymptomsCauses__r.LKP_SymptomsMaster__r.Id);
        
    }
    for(FCU_Observations__c obs : ObsList)
    {
        listaIDsOB.add(obs.LKP_Observations__r.LKP_ObservationsMaster__r.Id);
    }
    for(VisualRatingProduct__c vrp : VRProductList)
    {
        for(FCU_Visual_rating__c vr : vrp.FCU_Visual_ratings__r)
        {
            listaIDsVR.add(vr.LKP_VisualRating__r.LKP_VisualRatingMaster__r.Id);
        }       
    } 
    for(FieldCheckUp__c stage : StageDataList)
    {       
        listaIDsST.add(stage.LKP_SM_Stage__r.LKP_StageMaster__c);
    }
    List<ExternalConditionsLanguage__c> eclList = [SELECT Name, LKP_ExternalConditionsMaster__c, PICK_Language__c FROM ExternalConditionsLanguage__c WHERE LKP_ExternalConditionsMaster__r.Id IN : listaIDsECM];
    List<SymptomsCausesLanguage__c> sclList = [SELECT Name, LKP_CausesMaster__c, PICK_Language__c FROM SymptomsCausesLanguage__c WHERE LKP_CausesMaster__r.Id IN : listaIDsSCM];
    List<SymptomsLanguage__c> slList = [SELECT Name, LKP_SymptomsMaster__c, PICK_Language__c FROM SymptomsLanguage__c WHERE LKP_SymptomsMaster__r.Id IN : listaIDsSM];
    List<VisualRatingLanguage__c> vrList = [SELECT Name, LKP_VisualRatingMaster__c, PICK_Language__c FROM VisualRatingLanguage__c WHERE LKP_VisualRatingMaster__c IN : listaIDsVR];
    List<ObservationsLanguage__c> obList = [SELECT Name, LKP_ObservationsMaster__c, PICK_Language__c FROM ObservationsLanguage__c WHERE LKP_ObservationsMaster__c IN : listaIDsOB];
    List<StageLanguage__c> stList = [SELECT Name, StageMaster__c, PICK_Language__c FROM StageLanguage__c WHERE StageMaster__c IN : listaIDsST];
    
    languagesMap = new Map<String, String>();
    
    for(ExternalConditionsLanguage__c extcondlang : eclList)
    {
        system.debug('nombre del external condition language: ' + extcondlang.Name);
        languagesMap.put(extcondlang.LKP_ExternalConditionsMaster__c+ '-' +extcondlang.PICK_Language__c, extcondlang.Name);
    }
    for(SymptomsCausesLanguage__c sympcauslang : sclList)
    {
        languagesMap.put(sympcauslang.LKP_CausesMaster__c+ '-' +sympcauslang.PICK_Language__c, sympcauslang.Name);       
    }    
    for(SymptomsLanguage__c symplang : slList)
    {
        languagesMap.put(symplang.LKP_SymptomsMaster__c+ '-' +symplang.PICK_Language__c, symplang.Name);     
    }
    for(VisualRatingLanguage__c vrlang : vrList)
    {
        languagesMap.put(vrlang.LKP_VisualRatingMaster__c + '-' +vrlang.PICK_Language__c, vrlang.Name);
    }
    for(ObservationsLanguage__c obslang : obList)
    {
        languagesMap.put(obslang.LKP_ObservationsMaster__c + '-' +obslang.PICK_Language__c, obslang.Name);
    }
    for(StageLanguage__c stlang : stList)
    {
        languagesMap.put(stlang.StageMaster__c + '-' +stlang.PICK_Language__c, stlang.Name);
    }  
    
    for(FCU_External_Conditions__c extcond : ExtCondList)
    {
        system.debug('Id del external condition master: ' + extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__c);
        system.debug('Language del Field Check Up: ' + extcond.LKP_FCU__r.PICK_Language__c);
        
        if(language(extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__c, generator.TXT_Language__c) != null)
        {
            extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.name=language(extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__c, generator.TXT_Language__c);          
        }
        listaIDsECM.add(extcond.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.Id);
    }
    
    for(FCU_Symptoms_Causes__c sympcaus : SymptCausList)
    {
        if(language(sympcaus.LKP_SymptomsCauses__r.LKP_CausesMaster__c, generator.TXT_Language__c) != null)
        {
            sympcaus.LKP_SymptomsCauses__r.LKP_CausesMaster__r.name = language(sympcaus.LKP_SymptomsCauses__r.LKP_CausesMaster__c, generator.TXT_Language__c);          
        }
        if(language(sympcaus.LKP_SymptomsCauses__r.LKP_SymptomsMaster__c, generator.TXT_Language__c) != null)
        {
            sympcaus.LKP_SymptomsCauses__r.LKP_SymptomsMaster__r.name = language(sympcaus.LKP_SymptomsCauses__r.LKP_SymptomsMaster__c, generator.TXT_Language__c);
        }
        listaIDsSCM.add(sympcaus.LKP_SymptomsCauses__r.LKP_CausesMaster__r.Id);
        listaIDsSM.add(sympcaus.LKP_SymptomsCauses__r.LKP_SymptomsMaster__r.Id);
        
    }
    for(VisualRatingProduct__c visratprod : VRProductList)
    {
        for(FCU_Visual_rating__c visrat : visratprod.FCU_Visual_ratings__r)
        {
            if(language(visrat.LKP_VisualRating__r.LKP_VisualRatingMaster__c, generator.TXT_Language__c) != null)
            {
            visrat.LKP_VisualRating__r.LKP_VisualRatingMaster__r.name = language(visrat.LKP_VisualRating__r.LKP_VisualRatingMaster__c, generator.TXT_Language__c);          
            }
        }
        
    }
    for(FCU_Observations__c obser : ObsList)
    {
        if(language(obser.LKP_Observations__r.LKP_ObservationsMaster__c, generator.TXT_Language__c) != null)
        {
            obser.LKP_Observations__r.LKP_ObservationsMaster__r.name = language(obser.LKP_Observations__r.LKP_ObservationsMaster__c, generator.TXT_Language__c);
        }
    }
    for(FieldCheckUp__c stage : StageDataList)
    {
        if(language(stage.LKP_SM_Stage__r.LKP_StageMaster__c, generator.TXT_Language__c) != null)
        {
            stage.LKP_SM_Stage__r.LKP_StageMaster__r.name = language(stage.LKP_SM_Stage__r.LKP_StageMaster__c, generator.TXT_Language__c);
        }
    }
    
    Map<Id, Id> IconsMap = new Map<Id, Id>();                        
    for(Attachment att : [select id, parentid from attachment where parentid in :listaIDsECM and (not (name like '%@2x%')) ])
    {
        IconsMap.put(att.parentId, att.Id);
    }
                        
    for(FCU_External_Conditions__c ec : ExtCondList)
    {
        ec.idDevice__c=IconsMap.get(ec.LKP_ExternalConditions__r.LKP_ExternalConditionsMaster__r.Id);
    }
    
    
                    
                    for(FieldCheckUp__c item3 : AccountDataList)
                    {
                        item3.TXTA_Note_body_ExternalConditions__c=(item3.TXTA_Note_body_ExternalConditions__c!=null?formatParagraph(item3.TXTA_Note_body_ExternalConditions__c):item3.TXTA_Note_body_ExternalConditions__c);
                        item3.TXTA_Note_body_SymptomsCauses__c=(item3.TXTA_Note_body_SymptomsCauses__c!=null?formatParagraph(item3.TXTA_Note_body_SymptomsCauses__c):item3.TXTA_Note_body_SymptomsCauses__c);
                        item3.TXTA_Note_body_VisualRating__c=(item3.TXTA_Note_body_VisualRating__c!=null?formatParagraph(item3.TXTA_Note_body_VisualRating__c):item3.TXTA_Note_body_VisualRating__c);
                    }
    
                    for(Note item5 : NotesList)
                    {
                        item5.body=formatParagraph(item5.body);
                    }  
                                                                                                                                    
  }
  
   public String language(String IDMaster, String lang)
   {
        return languagesMap.get(IDMaster + '-' + lang);
   }
   
   public String formatParagraph(String param)
   {
       if(param == null || param == '')
           return '';
        else
        {
            param = param.replaceAll('\n','</p><p class="normal">');
            param = '<p class="normal">'+param+'</p>';
            return param;
        }
   }
 
    public List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = null;
        if(SObjectTypeObj != null)
           DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        //system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));
    
        Schema.FieldSet fieldSetObj = null;
        if(SObjectTypeObj != null)
            fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
    
        //List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        //system.debug('fieldSetMemberList ====>' + fieldSetMemberList);  
        return fieldSetObj!=null?fieldSetObj.getFields():null;
     }

    private SObject getRecordByFieldset(String recordId, String objectType, List<Schema.FieldSetMember> fieldset)
    {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : fieldset) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id FROM ' + objectType + ' where id = \''+recordId+'\'';
        return Database.query(query);
    }
}