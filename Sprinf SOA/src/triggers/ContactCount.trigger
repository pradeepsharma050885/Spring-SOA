/********
 * Name     :   ContactCount
 * Desc     :   This trigger will used to get contact count on Account Record
 ****/
trigger ContactCount on Contact (after insert, after delete, after undelete, after update) {
    
    // checking for event is either insert, update or undelete and passing Trigger.new to helper class
    if(Trigger.isAfter){
        
        // checking what is context
        if(Trigger.isInsert
            || Trigger.isUndelete){     
            ContactCountTriggerHelper.updateAccountByContactCount(Trigger.new,null);        
        }
        
        else if(Trigger.isUpdate){
            ContactCountTriggerHelper.updateAccountByContactCount(Trigger.new,trigger.oldMap);      
        }
        
        else if(Trigger.isDelete){
            ContactCountTriggerHelper.updateAccountByContactCount(Trigger.old,null);        
        }
    }
    
}