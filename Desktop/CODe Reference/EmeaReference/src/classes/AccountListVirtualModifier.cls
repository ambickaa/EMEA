public with sharing virtual class AccountListVirtualModifier implements AccountListObjectModifier
{
    // save standard sObjects using MixedDMLOps. filled records from object wrapper can be returned
    public virtual void save( List<AccountListObjectWrapper> objects )
    {
        for( AccountListObjectWrapper anObjects : objects )
        {
            System.debug(':::::::::::::::::::::anObjects' + anObjects);
            System.debug(':::::::::::::::::::::anObjects()' + anObjects.getSelectedRecords());
            List<sObject> aList;
            
            if(Util.countryView.isAccountSharingEnabled){
                aList = new List<sObject>();
                for(sObject s : anObjects.getFilledRecords()){
                    if(s.getSObjectType() == new CampaignLineItem__c().getSObjectType()){
                        if(s.ID == null || ((ID)s.get('OwnerID')) == Util.currentUser.ID){
                            aList.add(s);
                            System.debug('Saved: ' + s);
                        }else{
                            System.debug('Not saved: ' + s);
                        }
                    }else{
                        aList.add(s);
                    }
                }
            }else{
                aList = anObjects.getFilledRecords();
            }
            MixedDMLOps.add(aList);
        }
        MixedDMLOps.ups();
    }

    // deletes selected records; uses MixedDMLOps
    public virtual void deletex( List<AccountListObjectWrapper> objects )
    {
        for( AccountListObjectWrapper o : objects )
        {
            MixedDMLOps.add( o.getSelectedRecords() );
        }
        
    MixedDMLOps.del();
    }
}