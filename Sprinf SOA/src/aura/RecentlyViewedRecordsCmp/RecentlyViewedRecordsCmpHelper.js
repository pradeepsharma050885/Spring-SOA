({
    getRecords : function(component, event) {
        var action = component.get('c.getRecentlyViewedRecords');
        
        // passing parameters to the apex method
        action.setParams({
            objectName : component.get("v.objectName"),
            fieldSet : component.get("v.fieldSet")
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state : '+state);
            if (state === "SUCCESS") {
                // response from server     
                console.log('response.getReturnValue()');
                console.log(response.getReturnValue());
                // setting response in recDetails attribute
                component.set("v.recDetails",response.getReturnValue());                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})