public with sharing class DeletePageController {
        
        public list<Account> accToDel{get;set;}
        public list<Contact> conToDel{get;set;}
        public list<CampaignLineItem__c> cliToDel{get;set;}
        public list<Acreage__c> acrToDel{get;set;}
        public String accToFind{get;set;}
        public String conToFind{get;set;}
        public boolean clientCodes{get;set;}
        public boolean monsantoIDs{get;set;}
        
        public void DeletePageController(){
                init();
        }
        public void init(){
                accToDel=new list<Account>();
                conToDel=new list<Contact>();
                cliToDel=new list<CampaignLineItem__c>();
                acrToDel=new list<Acreage__c>();
                clientCodes=false;
                monsantoIDs=false;

                accToFind='';
                conToFind='';
        }
        public PageReference doFindAcc(){
                accToFind.replaceAll('(\\s+)', '');
                if(accToFind.replaceAll('(\\s+)', '')==''){
                    Util.AddWarningMessage('You have not selected any Account');
                    return null;
                }
                if(clientCodes){
                        String accFormCC='\''+(accToFind.replaceAll('(\\s+)', '')).replace(',','\',\'')+'\'';
                        accToDel=Database.query('SELECT Id, Name, OwnerId, Owner.Name, Phone, Client_Code__c, CountryRef__r.Name, GC_Email_Address__c, Category__c FROM Account WHERE Client_Code__c IN ('+accFormCC+')');
                        String aux='';
                        for(Account acc : accToDel)
                            aux += String.valueOf(acc.id)+',';
                        String accForm='\''+ (aux.Substring(0,aux.length()-1)).replace(',','\',\'')+'\'';   
                        conToDel=Database.query('SELECT Id, Name, Account.Name, AccountId,  OwnerId, Owner.Name,Email, Phone, CountryRef__r.Name, De_MonsantoID__c FROM Contact WHERE AccountId IN ('+accForm+')');
                        cliToDel=Database.query('SELECT Id, Name, RecordType.Name, Agreed__c, CampaignRef__r.Name, FarmRef__c, FarmName__c, FinalOrderRef_RSA__r.Name,PreliminaryOrderRef_RSA__r.Name,  Forecast__c,POG__c, ProductName_RSA__c  FROM CampaignLineItem__c WHERE FarmRef__c IN ('+accForm+')');
                        acrToDel=Database.query('SELECT Id, Name, AcrTotalAcreages__c,AcrPrevTotalAcreages__c, AcrFarmRef__c, AcrFarmRef__r.Name,AcrProductRef__r.Name FROM Acreage__c WHERE AcrFarmRef__c IN ('+accForm+')');
                }else{
                    try{
                        String accForm='\''+(accToFind.replaceAll('(\\s+)', '')).replace(',','\',\'')+'\'';
                        accToDel=Database.query('SELECT Id, Name, OwnerId, Owner.Name, Phone, Client_Code__c, CountryRef__r.Name, GC_Email_Address__c, Category__c FROM Account WHERE Id IN ('+accForm+')');
                        conToDel=Database.query('SELECT Id, Name, Account.Name, AccountId, OwnerId, Owner.Name,Email, Phone, CountryRef__r.Name, De_MonsantoID__c  FROM Contact WHERE AccountId IN ('+accForm+')');
                        cliToDel=Database.query('SELECT Id, Name, RecordType.Name, Agreed__c, CampaignRef__r.Name, FarmRef__c, FarmName__c, FinalOrderRef_RSA__r.Name,PreliminaryOrderRef_RSA__r.Name,  Forecast__c,POG__c, ProductName_RSA__c FROM CampaignLineItem__c WHERE FarmRef__c IN ('+accForm+')');
                        acrToDel=Database.query('SELECT Id, Name, AcrTotalAcreages__c,AcrPrevTotalAcreages__c, AcrFarmRef__c, AcrFarmRef__r.Name,AcrProductRef__r.Name FROM Acreage__c WHERE AcrFarmRef__c IN ('+accForm+')');
                    }catch (Exception e){
                        Util.AddWarningMessage(e.getmessage());
                        return null;
                    }
                }
                return null;                                                                                      
        }
        public PageReference doFindCon(){
                conToFind.replaceAll('(\\s+)', '');
                if(conToFind.replaceAll('(\\s+)', '')==''){
                    Util.AddWarningMessage('You have not selected any Contact');
                    return null;
                }                
                if(monsantoIDs){
                    String conFormCC='\''+(conToFind.replaceAll('(\\s+)', '')).replace(',','\',\'')+'\'';
                    conToDel=Database.query('SELECT Id, Name, Account.Name, AccountId, OwnerId, Owner.Name,Email, Phone, CountryRef__r.Name, De_MonsantoID__c  FROM Contact WHERE De_MonsantoID__c IN ('+conFormCC+')');                                         
                }else{
                    try{
                    String conForm='\''+(conToFind.replaceAll('(\\s+)', '')).replace(',','\',\'')+'\'';
                    conToDel=Database.query('SELECT Id, Name, Account.Name, AccountId, OwnerId, Owner.Name,Email, Phone, CountryRef__r.Name, De_MonsantoID__c  FROM Contact WHERE Id IN ('+conForm+')');                    
                    }catch (Exception e){
                        Util.AddWarningMessage(e.getmessage());
                        return null;
                    }                   
                }
                accToDel=new list<Account>();
                cliToDel=new list<CampaignLineItem__c>();
                acrToDel=new list<Acreage__c>();                       
                return null;              
        }
        public PageReference doDelete(){
            System.savepoint sp = Database.setSavepoint();
            try{
                if(acrToDel.size()>0)
                        delete acrToDel;
                if(cliToDel.size()>0)
                        delete cliToDel;        
                if(conToDel.size()>0)
                        delete conToDel;        
                if(AccToDel.size()>0)
                        delete accToDel;
                init(); 
                Util.addConfirmMessage('The process has been completed succesfully');   
                return null;
            }catch(Exception e){
                Database.rollback(sp);
                init();
                Util.addErrorMessage('The process cannot be completed due to: '+e.getMessage());
                return null;
                }
        }
}