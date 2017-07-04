public with sharing class AccountAcreageListController extends AccountListVirtualController
{
    public final static String JUMPER_ACREAGES = 'AccountAcreageList';
    private final static String DEFAULT_PICKLIST_VALUE = 'None';
    public static final Set<String> READ_ONLY_FIELDS = new Set<String> {'AcrProviderRef__c', 'AcrProductGroupRef__c',
              'AcrProductTypeRef__c', 'PreviousAcreageRef__r.AcrTotalAcreages__c'};
    public static final Map<String, String> FIELD_LABELS = new Map<String, String> {
                  'PreviousAcreageRef__r.AcrTotalAcreages__c' => Schema.sObjectType.Acreage__c.fields.AcrPrevTotalAcreages__c.getLabel(),
                  'PreviousAcreageRef__r.AcrTrend__c' => Schema.sObjectType.Acreage__c.fields.AcrPrevTrend__c.getLabel()};
    
    public static final String PRODUCT_GROUP_RT_NAME = 'ProductGroup';
    public static final String PRODUCT_TYPE_RT_NAME = 'ProductType';
    
    public Year__c currentYear
    {
        get
        {
            return Util.currentYear;
        }
    }
    
    //Method populate Product group pick list 
    private void updateProductGroupitems()
    {
        if (productGroupItems == null)
        {
            productGroupItems = new List<Selectoption>();
            for (Product_Grouping__c productGroup : [
                    SELECT Name
                    FROM Product_Grouping__c 
                    WHERE RecordTypeId =:Util.recordType.get('Product_Grouping__c:' + PRODUCT_GROUP_RT_NAME)])
            {
                productGroupItems.add(new SelectOption(
                productGroup.Id,
                productGroup.Name));
            }
        }
    }
    
    public List<Selectoption> productGroupItems{get; set;}
    public String selectedProductGroup 
    {
        get
        {
            if (selectedProductGroup == null)
            {
                selectedProductGroup = productGroupItems[0].getValue();
            }
            
            return selectedProductGroup;
        }
        set;
    }
    
    public List<Selectoption> productTypeItems{get; set;}
    
    //Method populate Product type pick list depends on selected product group
    public PageReference updateProductTypeItems()
    {
        // TO DO
        selectedProductType = null;
        
        if (selectedProductGroup != null)
        {
            productTypeItems = new List<Selectoption>();
            productTypeItems.add(new SelectOption(DEFAULT_PICKLIST_VALUE, Label.Default_pick_list_option));
            for (Product_Grouping__c productType : [
                SELECT Name 
                FROM Product_Grouping__c 
                WHERE RecordTypeId =:Util.recordType.get('Product_Grouping__c:' + PRODUCT_TYPE_RT_NAME)
                  AND ProductGroupRef__c = :selectedProductGroup])
            {
                productTypeItems.add(new SelectOption(
                productType.Id,
                productType.Name));
            }
        }
        
        return null;
    }
    
    public String selectedProductType{get;set;}
    
    public AccountAcreageListController()
    {
        jumperTag = JUMPER_ACREAGES;
        mode = 'acreageEdit';
        fieldSetManager = new AcreagesFieldManager();
        AcreageFactory aFactory = new AcreageFactory(false);
        objectFactory = aFactory; 
        System.debug('***:::::::::::::FIELDS: ' + fieldSetManager.getSOQLFields());
        for(String aField : fieldSetManager.getSOQLFields())
        {
            aFactory.selectFields.add(aField);
        }
        updateProductGroupitems(); 
        updateProductTypeItems();
    }
    
    public AcreagesFieldManager getAcreageFieldSetManager()
    {
        return (AcreagesFieldManager) fieldSetManager;
    }
    
    public List<Acreage> getMerchandiseManagements()
    {
        return (List<Acreage>) wrapperObjects;
    }
    
    public Boolean getIsAutoCreateAcreage()
    {
        return new CountryAdapter().isAutoCreateAcreages();
    }
    
    public List<Acreage> getAcreageList()
    {
        return (List<Acreage>) wrapperObjects;
    }
    
    public class AcreagesFieldManager extends FieldSetMemberxManager
    {
        public AcreagesFieldManager()
        {
            super(Schema.SObjectType.Acreage__c, JUMPER_ACREAGES);
        }
        
        protected override FieldSetMemberx createFieldSetMember(FieldSetMember theMember)
        {
            return new AcreagesFieldMember(theMember);
        }
        
        public List<AcreagesFieldMember> getAcreageFieldMembers()
        {
            List<AcreagesFieldMember> aReturn  = new List<AcreagesFieldMember>();
            for (FieldSetMemberx aMember: managedFieldSetMembers)
            {
                aReturn.add((AcreagesFieldMember)aMember);
            }
            return aReturn;
        }
    }
    
    public class AcreagesFieldMember extends FieldSetMemberx
    {
        public Boolean isPrevField{get;set;}
        public Boolean isProductGroup {get; set;}
        public Boolean isProductType {get; set;}
        public AcreagesFieldMember(FieldSetMember theMember)
        {
            super(theMember);
            String aLabel = AccountAcreageListController.FIELD_LABELS.get(theMember.fieldPath);
            if (aLabel != null)
            {
                label = aLabel;
                isPrevField = true;
            }
            if(theMember.fieldPath == 'AcrProductGroupRef__c')
            {
                isProductGroup = true;
            }
            if(theMember.fieldPath == 'AcrProductTypeRef__c')
            {
                isProductType = true;
            }
        }
        
        public Boolean getIsReadOnly()
        {
            return AccountAcreageListController.READ_ONLY_FIELDS.contains(fieldPath);
        }
    }
    
    public override Pagereference save()
    {
        for (Acreage anAcreage : (List<Acreage>)getMerchandiseManagements())
        {
            if (anAcreage.isNewAcreage)
            {
                anAcreage.acreage.AcrProductGroupRef__c = selectedProductGroup;
                
                //TO DO
                if (selectedProductType != DEFAULT_PICKLIST_VALUE)
                {
                    anAcreage.acreage.AcrProductTypeRef__c = selectedProductType;
                }
            }
        }
        return super.save();
    }
    //for Acreages button visibility ( for country lead)
    public boolean getIsGermanyAPCountryLead()
    {
        if(Util.CountryView.isGermanActionPlan)
        {    infoUser =[
                        SELECT Is_Country_Manager__c, Is_Regional_Manager__c, Is_Sales_Rep__c, Profile.Name, StandardDivision__c
                        FROM User 
                        WHERE ID = :userInfo.getUserID()
                        ];

            if(infoUser.Is_Country_Manager__c==true)
            {
                return true;
            }
            else 
                return false;
         }else
             return false;
            
    }
}