public class ProductCatalogNewController {

    public ProductCatalogNewController(ApexPages.StandardController controller) {

    }
    
    public PageReference redirect()
    {
        return new PageReference('/a0G/e?retURL=%2Fa0G%2Fo&RecordType='+Util.urlParameters.get('RecordType')+'&ent=01ID0000000m3eo&Name='+Label.thisFieldWillBeCalculated+'&nooverride=1&CF00ND0000004V0uQ='+Util.currentUser.Country);
    }

}