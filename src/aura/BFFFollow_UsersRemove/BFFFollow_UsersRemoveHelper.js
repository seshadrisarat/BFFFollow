({
	removeFollowedUsers: function(component, BFFHelper){
		var selectedUser = component.find('removeSelectedUsers').get('v.value');
		
		if(selectedUser == 0){
			return null;
		}

		var followedUsers = component.get('v.followedUsers');

		var followedUsersNew = Array();

		for(var i=0; i < followedUsers.length; i++){
			if(followedUsers[i].id !=  selectedUser){
				followedUsersNew.push({id: followedUsers[i].id, name: followedUsers[i].name});
			}
		}

		if(JSON.stringify(followedUsers) == JSON.stringify(followedUsersNew)){
			return null;
		}else{
			return JSON.stringify(followedUsersNew);
		}
	},
	saveFollowedUsers : function(component, helper, BFFHelper, followedUsers) {
		//Add current user to existing user list
		//var followedUsers = this.processFollowedUsers(component, BFFHelper);

		//If no changes were made then no need for Apex call
		if(followedUsers == null){
			return;
		}
		BFFHelper.log({m: followedUsers});

		
		var apexBridge = component.find("ApexBridge");
        apexBridge.callApex({
            component: component, 
            data: {
                operation: "BFFFollow_Controller",
                input: {mode: 'saveFollowedUsers', followedUsers: followedUsers},
                debug: component.get('v.debug')
            },
            callBackMethod: function (data) {

            	BFFHelper.log({m: data});
        		if(data.outputFlag == true){
        			//component.set('v.followedUsers', followedUsers);
        			helper.alertForFollowedUsers(component, BFFHelper, followedUsers);
        		}
            }
        });
        /**/
        
	},
	alertForFollowedUsers: function(component, BFFHelper, followedUsers){
		var appEvent = $A.get("e.c:BFFFollow_UsersUpdated");
		BFFHelper.log({m: 'appEvent: '+ appEvent});
		appEvent.setParams({ "followedUsers" : JSON.parse(followedUsers) });
		BFFHelper.log({m: 'Firing e.c:BFFFollow_UsersUpdated'});
		appEvent.fire();
	}
})