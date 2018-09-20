/********
 * Name     :   RecentlyViewedRecords
 * Desc     :   This class will used to get recently viewed records of any Object
 ****/
public class RecentlyViewedRecords {
    
    /****
     * Name             :   getRecentlyViewedRecords
     * Description      :   get the recently viewed records
     ****/
    @AuraEnabled
    public static List<ObjectDataWrapper> getRecentlyViewedRecords(String objectName, String fieldSet){
        List<RecentlyViewed> lstRVRs = [SELECT Id, Name FROM RecentlyViewed  WHERE Type =: objectName];        
        
        // this will store the record ids of recently viewd records
        Set<String> recordIds = new Set<String>();
        
        // iterate over recentlyviewed records and store the ids in recordIds set
        for(RecentlyViewed rv : lstRVRs){
            recordIds.add(rv.id);
        }        
        
        // this will save the data to be returned
        List<ObjectDataWrapper> lstReturnData = new List<ObjectDataWrapper>();
        
        // this will save the field name
        List<string> lstFieldName = new List<string>();
            
        //this will save the list if field which will be displayed on componant with labels
        list<LabelWrapper> lstlabels = new list<LabelWrapper>();
        
        for(Schema.FieldSetMember fieldSetMemberObj : readFieldSet(fieldSet,objectName)){  //'testFldSet',  'DataTableFieldSet'
                lstFieldName.add(fieldSetMemberObj.getFieldPath());
            
                // getting refrence field value
                if(string.valueOf(fieldSetMemberObj.getType()).toLowerCase() == 'reference'){
                    string fName = fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
                    fName = fieldSetMemberObj.getFieldPath().replace('id', 'Name');
                    lstlabels.add(new LabelWrapper(fName,fieldSetMemberObj.getLabel()));
                }
                
                // adding non reference fields
                else{
                    lstlabels.add(new LabelWrapper(fieldSetMemberObj.getFieldPath(),fieldSetMemberObj.getLabel()));
                }
            }            
        
            // storing field name
            string fields = string.join(lstFieldName,',');
            
            
            string query = 'SELECT '
                            + fields
                            +' FROM '+ objectName
                            +' where id in :'
                            +' recordIds'
                            +' limit 10';
            system.debug('\n--query--'+query);
            
            
            // iteration of records
            for(sobject obj : Database.query(query)){
                lstReturnData.add(new ObjectDataWrapper(lstlabels,obj));
            }
            system.debug('\n--lstReturnData--'+lstReturnData);
        
        return lstReturnData;
    }
    
    /****
     * Name             :   readFieldSet
     * Description      :   THis will be used to get field set details based upon
     *                      object type and the field set name
     ****/ 
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }
    
    /**
     * This will be used to save the api name and the field name which will be used
     * to diplay on the component
     */
    public class LabelWrapper{
        @AuraEnabled 
        public string apiName {get;set;}
        @AuraEnabled 
        public string fieldLabel {get;set;}        
        @AuraEnabled
        public boolean displayField {get;set;}
        
        public LabelWrapper(string apiName, string fieldLabel){
            this.fieldLabel = fieldLabel;
            this.apiName = apiName;
            this.displayField = true; // this will used in future if we wanted to hide or display field
        }
    }
    
    /********************* WRapper Section ****************************/
    /***
     * This class will be used to display data in Lighting component
     * << enter lightning component name : "RecentlyViewedRecordsCmp" >>
     ***/
    public class ObjectDataWrapper{
        
        @AuraEnabled 
        List<LabelWrapper> lstHeaders {get;set;}
        
        // this will have the object instance
        @AuraEnabled 
        public sobject objData {get;set;}
        
        // constructor to set values
        public ObjectDataWrapper(list<LabelWrapper> lstHeaders, sobject objData){
            this.objData =    objData;
            this.lstHeaders =    lstHeaders;
        }
    }
}