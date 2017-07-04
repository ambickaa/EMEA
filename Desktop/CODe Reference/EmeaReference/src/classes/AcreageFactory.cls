public with sharing class AcreageFactory implements AccountListObjectFactory
{
    public static final String ACREAGE_RT_PRODUCT = 'AcreagesPerProduct';
    public static final String ACREAGE_RT_PRODUCT_GROUP = 'AcreagesPerProductGroup';
    
    public Set<String> selectFields
    {
        get
        {
            if(selectFields == null)
            {
                selectFields = new Set<String> { 'id', 'Ownerid', 'AcrProductRef__c', 'AcrProductRef__r.Name', 'AcrPrevTrend__c', 'AcrYearRef__c',
                          'AcrLastModified__c', 'AcrFarmRef__c', 'AcrPrevTotalAcreages__c'};
            }
            return selectFields;
        }
        set;
    }
    
    public boolean isProductRelated{get;set;}
    
    public AcreageFactory (boolean theIsProduct)
    {
        isProductRelated = theIsProduct;
    }

    public List<AccountListObjectWrapper> createObjectWrapperForAccountId (String theAccountId)
    {
        al.SoqlBuilder aBuilder = new al.SoqlBuilder().selectx(selectFields).fromx('Acreage__c');
        al.AndCondition aCondition = new al.AndCondition();
        aCondition.add(new al.FieldCondition('AcrFarmRef__c', theAccountId));
        al.OrCondition aYearCondition = new al.OrCondition();
        if(Util.currentYear != null)
        {
            aYearCondition.add(new al.FieldCondition('AcrYearRef__c', Util.currentYear.Id));
        }
        if(Util.lastYear != null)
        {
            al.AndCondition aPrevYearCond = new al.AndCondition();
            aPrevYearCond.add(new al.FieldCondition('AcrYearRef__c', Util.lastYear.Id));
            aPrevYearCond.add(new al.FieldCondition('AcrTotalAcreages__c', al.Operator.GREATER_THAN, 0));
            aYearCondition.add(aPrevYearCond);
        }
        aCondition.add(aYearCondition);
        aCondition.add(new al.FieldCondition('RecordType.DeveloperName', isProductRelated ? ACREAGE_RT_PRODUCT : ACREAGE_RT_PRODUCT_GROUP));
        
        aBuilder.wherex(aCondition);
        List<Acreage> aResult = new List<Acreage>();
        String aResSoql = aBuilder.toSOQL();
        System.debug('***Acreages SOQL' + aResSoql);
        List<Acreage__c> aMainList = (List<Acreage__c> ) Database.query(aResSoql);
        
        System.debug('***Acreages Result:' + aMainList);
        Map<Id, Acreage__c> aLastYearMap = new Map<Id, Acreage__c>();
        for (Acreage__c anAcreage: aMainList)
        {
            if (anAcreage.AcrYearRef__c == Util.lastYear.Id)
            {
                aLastYearMap.put(anAcreage.Id, anAcreage);
            }
        }
        for (Acreage__c anAcreage: aMainList)
        {
            if (anAcreage.AcrYearRef__c == Util.currentYear.Id)
            {
                Acreage__c aPrevAcr = anAcreage.PreviousAcreageRef__c == null ? null : aLastYearMap.get(anAcreage.PreviousAcreageRef__c);
                aResult.add(new Acreage(anAcreage, aPrevAcr));
                if (aPrevAcr != null)
                {
                    aLastYearMap.remove(aPrevAcr.Id);
                }
            }
        }
        for (Acreage__c anAcreage: aLastYearMap.values())
        {
            aResult.add(new Acreage(anAcreage, false));
        }
        return aResult;
    }
    
    public AccountListObjectWrapper createAnEmptyRecord (String theAccountId)
    {
        Acreage anAcreage = new Acreage(isProductRelated ? ACREAGE_RT_PRODUCT : ACREAGE_RT_PRODUCT_GROUP);
        
        if (!isProductRelated && anAcreage.acreage.AcrProviderRef__c == null)
        {
            anAcreage.acreage.AcrProviderRef__c = Util.DEFAULT_DISTRIBUTOR_ACREAGE_PROVIDER;
        }
        
        return anAcreage;
    }
}