/********
* Name     :   ContactCountTriggerHelper
* Desc     :   This helper Class will used to update account field by number of contact assciated with it by using trigger
****/
public class ContactCountTriggerHelper {
    
    /****
     * Name             :   updateAccountByContactCount
     * Description      :   method used to update account with number of contacts
     ****/
    public static void updateAccountByContactCount(List<Contact> contactList, map<id,contact> contactMap){
        
        //set of accounts associated with contacts
        set<id> accIdSet = new set<id>();
        
        // fiill set of account ids associated with contacts
        for(Contact objContact:contactList){
        
            // checking if the map is null which means that update use case
            if(contactMap != null){
                Contact oldRec = contactMap.get(objContact.Id);
                
                // checking if the contact has to be process or not
                if(oldRec.AccountId != objContact.AccountId){
                    
                    if(oldRec.AccountId != null)                    
                        accIdSet.add(oldRec.AccountId);
                    
                    if(objContact.AccountId != null)
                        accIdSet.add(objContact.AccountId);
                }
            }
            else{        
                // check if account is exists for this contact or not
                if(objContact.AccountId != null){
                    
                    // add account id to accIdSet
                    accIdSet.add(objContact.AccountId);
                }
            }
        }
        
        // checking wheather set is empty or not
        if(!accIdSet.isEmpty() && accIdSet.size() > 0){
            
            // query on account and fill the map of account to update it by contact size
            Map<id,Account> objAccMap=new Map<id,Account>([select id,ContactCount__c,(select id from contacts) from account where id in:accIdSet]);
            system.debug('objAccMap::'+objAccMap);
            
            //iterate over set of account ids
            for(Id accId : accIdSet){
                // get the account from map using account id from accIdSet
                Account objAccount = objAccMap.get(accId);
                
                // assign number of contacts to contact count field of account
                if(!objAccount.contacts.isEmpty())
                    objAccount.ContactCount__c = objAccount.contacts.size();
                else
                    objAccount.ContactCount__c = 0;
            }
            // update accounts
            update objAccMap.values();
        }
    }
}