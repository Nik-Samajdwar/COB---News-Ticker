public with sharing class BOS311_EmergencyNotificationDBCntrl {
	public List<EmergencyNotificationWrapper> emergencyNotificationWrapperList {get;set;}	
	
	public BOS311_EmergencyNotificationDBCntrl(){
		emergencyNotificationWrapperList = new List<EmergencyNotificationWrapper>();

		createEmergencyNotificationWrapper();
	}

	public class EmergencyNotificationWrapper{
		public String sr_CaseId {get;set;}
		public String sr_CaseNumber {get;set;}
		public String sr_CreatedDate {get;set;}
		public String sr_LastModified {get;set;}
		public String sr_Address {get;set;}
		public String sr_Description {get;set;}
		public String sr_DistributionName {get;set;}
		public String sr_NeighbourHood {get;set;}
		public List<EmergencyNotificationComments> comments {get;set;}

		public EmergencyNotificationWrapper(){
			comments = new List<EmergencyNotificationComments>();
		}
	}

	public class EmergencyNotificationComments{
		public String comment {get;set;}
		public String createdDate {get;set;}
		public String createdBy {get;set;}
	}

	public void createEmergencyNotificationWrapper(){
		List<Case> serviceRequestList = queryEmergencyNotifications();
		System.debug('serviceRequestList-------------->>>'+serviceRequestList);

		if(!serviceRequestList.isEmpty()){
			for(Case caseObj :  serviceRequestList){
				EmergencyNotificationWrapper emergencyNotificationWrapper = new EmergencyNotificationWrapper();
				emergencyNotificationWrapper.sr_CaseId = caseObj.Id;
				emergencyNotificationWrapper.sr_CaseNumber = caseObj.Incap311__Service_Request_Number__c;
				emergencyNotificationWrapper.sr_CreatedDate = String.valueof(caseObj.CreatedDate).replace('-','/');
				emergencyNotificationWrapper.sr_LastModified = String.valueof(caseObj.LastModifiedDate).replace('-','/');
				emergencyNotificationWrapper.sr_Address = caseObj.Address_Neighborhood__c;
				emergencyNotificationWrapper.sr_Description = caseObj.Description;
				emergencyNotificationWrapper.sr_DistributionName = caseObj.Distribution_Name__c;
				emergencyNotificationWrapper.sr_NeighbourHood = caseObj.Incap311__Neighborhood__c;

				if(!caseObj.CaseComments.isEmpty()){
					for(CaseComment caseComment : caseObj.CaseComments){
						EmergencyNotificationComments  emergencyNotificationComments = new EmergencyNotificationComments();
						emergencyNotificationComments.comment = caseComment.CommentBody;
						emergencyNotificationComments.createdDate = String.valueof(caseComment.CreatedDate).replace('-','/');
						emergencyNotificationComments.createdBy = caseComment.CreatedBy.Name;

						emergencyNotificationWrapper.comments.add(emergencyNotificationComments);
					}
				}

				emergencyNotificationWrapperList.add(emergencyNotificationWrapper);
			}
			System.debug('emergencyNotificationWrapperList-------------->>>'+emergencyNotificationWrapperList);
		}
	}

	public List<Case> queryEmergencyNotifications(){
		List<Case> serviceRequestList = [Select Id, CaseNumber, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, Incap311__Neighborhood__c,
										 Address_Neighborhood__c, Incap311__Service_Request_Number__c, Description, Distribution_Name__c,
										 (Select Id, CommentBody, CreatedDate, CreatedBy.Name FROM CaseComments Order BY CreatedDate DESC LIMIT 1)
										 FROM Case
										 WHERE Subject = 'Emergency Notifications'
										 AND Status = 'Open'];

		return serviceRequestList;
	}
}