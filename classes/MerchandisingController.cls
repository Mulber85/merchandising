public with sharing class MerchandisingController {

	public String accId { get; set; }
	public String attachmentType { get; set; }
	public AttachmentWrapper attachments { get; set; }

	public MerchandisingController() {

	}

	@RemoteAction
	public static String getAttachment(String accId, String newFirstImg, String newSecondImg, String descr) {
		String imageURL='/servlet/servlet.FileDownload?file=';
		String customImageURL = '';
		String brandImageURL = '';
		List<Attachment> attachedFiles = [SELECT Id, Name FROM Attachment WHERE parentId =: accId AND Description = :descr];

		if (attachedFiles.size() == 0) {
			return NULL;
		}

		if (attachedFiles.size() > 2) {
			List<Attachment> attachedFilesToDelete = new List<Attachment>();
			String newFirstImgName = newFirstImg.split(';')[0];
			String newFirstImgId = newFirstImg.split(';')[1];
			String newSecondImgName;
			String newSecondImgId;
			if (newSecondImg != null) {
				newSecondImgName = newSecondImg.split(';')[0];
				newSecondImgId = newSecondImg.split(';')[1];
			}

			for (Integer i = 0; i <= attachedFiles.size() - 1; i++) {
				if (newSecondImg == null && attachedFiles[i].Id != newFirstImgId && attachedFiles[i].Name.contains(newFirstImgName)) {
					attachedFilesToDelete.add(attachedFiles[i]);
					attachedFiles.remove(i);
				}
				else if (newSecondImg != null && attachedFiles[i].Id != newFirstImgId && attachedFiles[i].Id != newSecondImgId) {
					attachedFilesToDelete.add(attachedFiles[i]);
					attachedFiles.remove(i);
				}
			}
			delete attachedFilesToDelete;
		}

		if(attachedFiles.size() > 1) {
			brandImageURL = (attachedFiles[0].Name.contains('Brand')) ? imageURL + attachedFiles[0].id : imageURL + attachedFiles[1].id;
			customImageURL = (attachedFiles[0].Name.contains('Custom')) ? imageURL + attachedFiles[0].id : imageURL + attachedFiles[1].id;
		}
		else if (attachedFiles.size() == 1) {
			brandImageURL = (attachedFiles[0].Name.contains('Brand')) ? imageURL + attachedFiles[0].id : NULL;
			customImageURL = (attachedFiles[0].Name.contains('Custom')) ? imageURL + attachedFiles[0].id : NULL;
		}
		AttachmentWrapper attachments = new AttachmentWrapper(customImageURL, brandImageURL);
		return JSON.serialize(attachments);
	}

	@RemoteAction
	public static String saveMerchandisingMarks(String accId, String newBrandMarks, String newCustomerMarks) {

		Merchandising_Marks__c newBrandMark;
		Merchandising_Marks__c newCustomerMark;

		List<Merchandising_Marks__c> merchandisingMarksToDelete = [SELECT Id, Name, Cmarks__c, Account__r.Name FROM Merchandising_Marks__c WHERE Account__c =: accId LIMIT 2];

		delete merchandisingMarksToDelete;

		newBrandMark = new Merchandising_Marks__c();
		newBrandMark.Name = 'Brand' + accId;
		newBrandMark.Account__c = accId;
		newCustomerMark = new Merchandising_Marks__c();
		newCustomerMark.Name = 'Customer' + accId;
		newCustomerMark.Account__c = accId;


		List<Merchandising_Marks__c> marksToInsert = new List<Merchandising_Marks__c>();
		if (newBrandMarks != NULL) {

			newBrandMark.Cmarks__c = newBrandMarks;

			//for (String svgItem : newBrandMarks.split('<svg')) {
			//	if (svgItem.contains('rect')) {
			//		if (newBrandMark.Cmarks__c == NULL) {
			//			newBrandMark.Cmarks__c = '<svg' + svgItem;
			//		}
			//		else {
			//			newBrandMark.Cmarks__c += '<svg' + svgItem;
			//		}
			//	}

			//}
			marksToInsert.add(newBrandMark);
		}
		if (newCustomerMarks != NULL) {

			newCustomerMark.Cmarks__c = newCustomerMarks;

			//for (String svgItem : newCustomerMarks.split('<svg')) {
			//	if (svgItem.contains('rect')) {
			//		if (newCustomerMark.Cmarks__c == NULL) {
			//			newCustomerMark.Cmarks__c = '<svg' + svgItem;
			//		}
			//		else {
			//			newCustomerMark.Cmarks__c += '<svg' + svgItem;
			//		}
			//	}
			//}
			marksToInsert.add(newCustomerMark);
		}

		if(marksToInsert.size() > 0) {
			try {
				upsert marksToInsert;
			}
			catch (Exception e) {
				System.debug(e.getMessage());
			}
		}

		return 'OK';
	}

	@RemoteAction
	public static String getMerchandisingMarks(String accId) {

		List<Merchandising_Marks__c> marks = [SELECT Id, Name, Cmarks__c, Account__r.Name FROM Merchandising_Marks__c WHERE Account__c =: accId LIMIT 2];

		if (marks.size() == 0) {
			return NULL;
		}
		List<MerchandisingMarksWrapper> merchandisingMarksWrapList = new List<MerchandisingMarksWrapper>();
		for (Integer i = 0; i <= marks.size() - 1; i++) {
			merchandisingMarksWrapList.add(new MerchandisingMarksWrapper(marks[i]));
		}
		return JSON.serialize(merchandisingMarksWrapList);
	}

	private class AttachmentWrapper {

		private String customImageURL { get; private set; }
		private String brandImageURL { get; private set; }

		public AttachmentWrapper(String customImageURL, String brandImageURL) {
			this.customImageURL = customImageURL;
			this.brandImageURL = brandImageURL;
		}
	}

	private class MerchandisingMarksWrapper {

		private String Name { get; private set; }
		private String Cmarks { get; private set; }

		public MerchandisingMarksWrapper(Merchandising_Marks__c merchandisingMarks) {
			this.Name = merchandisingMarks.Name;
			this.Cmarks = merchandisingMarks.Cmarks__c;
		}
	}
}