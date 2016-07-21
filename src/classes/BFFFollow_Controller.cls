public with sharing class BFFFollow_Controller extends ETLC_ApexBridge_Abstract  {
	private static Boolean debugFlag;
	public override void process(ETLC_ApexBridge_Data data) {
		debugFlag = data.debug;
        if (data.debug) System.debug(data);
		// Depending on the mode, determine which operation to perform
        String mode = (String) data.getInputValue('mode');

        if (mode == 'fetchFollowedUsers') {
        	data.output = fetchFollowedUsers(UserInfo.getUserId());
        	data.outputFlag = (data.output == null)?false:true;
        	if(debugFlag){System.debug(data);}
        } else if (mode == 'saveFollowedUsers') {
        	data.outputFlag = saveFollowedUsers(Userinfo.getUserid(),(String)data.getInputValue('followedUsers'));
        } else if (mode == 'fetchUserFeed') {
        	data.outputFlag = fetchUserFeed((String)data.getInputValue('userId'));
        }
    }
	/**
	 *
	 */
	public String fetchFollowedUsers(Id followedById){
		String soql = 'SELECT FollowedUsers__c FROM BFFFollow__c WHERE FollowedBy__c=\''+followedById+'\' limit 1';
		try{
			if(debugFlag){System.debug('fetchFollowedUsers:soql:'+soql);}
			List<sObject> dbRecords = ETLC_SecuredDB.query(soql);
			if(debugFlag){System.debug(dbRecords);}
			if(dbRecords.size() > 0){
				if(debugFlag){
					System.debug('FollowedUsers__c::' + dbRecords[0].get('FollowedUsers__c'));
				}
				return (String)dbRecords[0].get('FollowedUsers__c');
			}
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		return null;
	}
	/**
	 *
	 */
	public boolean saveFollowedUsers(Id followedById, String followedUsers){
		String soql = 'SELECT Id FROM BFFFollow__c WHERE FollowedBy__c=\''+followedById+'\' limit 1';

		try{
			if(debugFlag){System.debug('fetchFollowedUsers:soql:'+soql);}
			List<sObject> dbRecords = ETLC_SecuredDB.query(soql);
			BFFFollow__c record = new BFFFollow__c();
			if(dbRecords.size() > 0){
				record.Id = (Id)dbRecords[0].get('Id');
			}
			record.followedUsers__c = followedUsers;
			record.followedBy__c = followedById;
			upsert record;
			if(debugFlag){ System.debug(record); }
			return true;
		}catch(Exception e){
			System.debug(e.getMessage());
		}
		return false;
	}

	public Boolean fetchUserFeed(Id userId){
		ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(Network.getNetworkId(), ConnectApi.FeedType.UserProfile, userId);
		System.debug(fep);

		return false;
	}
}