global class Schedule_CLIDistributorBatchable implements Schedulable {

    global void execute(SchedulableContext sc) {

        //Sets up query base for start method in batch
        String q = 'SELECT Id, OwnerId, Owner.IsActive, LKP_Responsible_ST__c, LKP_Responsible_ST__r.IsActive FROM Account WHERE RecordType.Name = ' + '\'' + 'Dist./Ret./PoS' + '\'' + ' AND (CountryRef__r.Name = ';
        
        //Gets the countries for which the batch must be executed
        String strCountries = System.Label.Dist_AP_Countries;
        List<String> countryList = new List <String>();
        countryList = strCountries.split('\r\n');

        //Gets divisions
        String strDivision = System.Label.Dist_AP_Division;
        List<String> divList = new List <String>();
        divList = strDivision.split('\r\n');

        //Gets bags units
        String strUnits = System.Label.Dist_AP_UoM;
        List<String> unitsList = new List <String>();
        unitsList = strUnits.split('\r\n');

        //Gets Document Types
        String strDocs = System.Label.Dist_AP_OrderDocType;
        List<String> docsList = new List <String>();
        docsList = strDocs.split('\r\n');

        //Gets Start and end date for campaigns
        List<String> datesList = (System.Label.Dist_AP_Dates).split(',');
        String startDate = datesList.get(0);
        String endDate = datesList.get(1);

        //Define variables in countryList
        String country;
        String code;
        String owner;
        Integer batchsize;
        List <String> labelCountry= new List<String>();
        
        //Define Counter variables to determine the last item.
        Integer C1=countryList.size();
        Integer C2=divList.size();
        Integer i = 0;
        Integer j = 0;
        Boolean isLastItem=false;

        //Country parameter passed for each execution
        for(String countryName : countryList){
            i++;
            for(String strDiv : divList){
                j++;
                labelCountry = countryName.split('-');
                country = labelCountry.get(0);
                code = labelCountry.get(1);
                owner = labelCountry.get(2);
                batchsize = integer.valueof(labelCountry.get(3).trim());
                if(i==C1 && j==C2) {
                    isLastItem=true;
                } else if (j==C2){
                    j=0;
                }
                system.debug('Batch parameters: Country is ' + labelCountry.get(0) + '-' + labelCountry.get(1) + ' with ownerId as ' + labelCountry.get(2) + ' and division '+ strDiv + ' for dates:' + startDate + ' & ' + endDate + '& IsLastItem?' + isLastItem);                

                //Start Edited 27/04/2017 Add country area
                String query = q + '\'' + country + '\' OR CountryRef__r.Area__r.Name = \'' + country + '\')';
                //End Edited 27/04/2017

                //Id batchInstanceId = Database.executeBatch (new CampaignLineItemDistributorBatchable(query,country,strDiv),10);
                Id batchInstanceId = Database.executeBatch (new CampaignLineItemDistributorBatchable(query,country,unitsList,docsList,strDiv,code,owner,startDate,endDate,isLastItem),batchsize);
            }
        }
    }
}