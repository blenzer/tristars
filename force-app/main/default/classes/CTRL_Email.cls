public class CTRL_Email {
    //Email contents
    public String emailFrom {get; set;}
    public String emailAddressesSerialized {get; set;}
    public String ccAddressesSerialized {get; set;}
    public String emailSubject {get; set;}
    public String emailBody {get; set;}
    public String sObjectType ;
    public String sRetURL {get;set;}
    
    //Source object context
    public Id sourceObjectId {get; set;}

    
    public CTRL_Email(apexpages.standardsetcontroller ctrl) 
    {
        for (String s:Apexpages.currentpage().Getparameters().keyset())
        {
            system.debug('******parameters: ' + s + ': ' + Apexpages.currentpage().Getparameters().get(s));
        }
        sRetURL = Apexpages.currentpage().Getparameters().get('retURL');
        
        emailAddressesSerialized = '';
        list<sobject> lSO = ctrl.getSelected();
        system.debug('************lSO size: ' + lSO.size());
        if (lSO != null && lSO.size() > 0)
        {
            sObjectType = lSO[0].getsobjecttype().getdescribe().getName();            
        }
        if (sObjectType != null)
        {
            String sSOQL = 'Select Email__c from ' + sObjectType + ' WHERE Id in: lSO group by Email__c';
            for (aggregateResult oAR : database.query(sSOQL))
            {
                emailAddressesSerialized  = emailAddressesSerialized + (String)oAR.get('Email__c') + ';';
            }
            emailAddressesSerialized  = emailAddressesSerialized.left(emailAddressesSerialized.length() -1);
        }
        String sUserId = userinfo.getUserId();        
        emailFrom = [Select Email from user where id =:sUserId limit 1].email;
    }

    
    public PageReference doCancel()
    {
        return null;
    }

    //Gather data and add them to the email.
    public PageReference composeEmail() 
    {
        Id emailRecordId;
        list<String> emailAddresses = emailAddressesSerialized.split(';');
        list<String> ccAddresses = ccAddressesSerialized.split(';');

        if((emailSubject != null) && (emailSubject != '') && (emailBody != null) && (emailBody != '') && (emailAddresses != null) && (emailAddresses.size() > 0))
        {
            
            String senderEmail = emailFrom;
            String senderName = emailFrom;
            
            //Fetch sender address from OrgWideEmailAddresses
            List<OrgWideEmailAddress> senderAddress = [SELECT Id, Address, DisplayName 
                                                    FROM OrgWideEmailAddress 
                                                    WHERE Address =: senderEmail];

            //Reserve email capacity
            Messaging.reserveSingleEmailCapacity(2);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(senderAddress.size() > 0)
                //Set sender address
                mail.setOrgWideEmailAddressId(senderAddress[0].Id);
            else
                // Specify the sender name used as the display name.
                mail.setSenderDisplayName(senderName);            

            //Set recipient address
            mail.setToAddresses(emailAddresses);

            //Set CC addresses if not empty
            if(ccAddresses.size() > 0 && ccAddresses.size() < 25 && ccAddresses[0].length() > 0)
                mail.setCcAddresses(ccAddresses);

            //Set email subject
            mail.setSubject(emailSubject);

            //Set email body
            mail.setPlainTextBody(emailBody);


            //Will not automatically create an EmailMessage record. This is done manually.
            mail.setSaveAsActivity(false);


            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Reise__c oReise = [Select Id from Reise__c where Aktiv__c = true limit 1];
            emailmessage oMail = new emailmessage();
            //oMail.RelatedToId = oReise.Id;
            oMail.FromName = userinfo.getusername();
            oMail.TextBody = emailBody;
            oMail.ToAddress = emailaddresses[0];
            oMail.an__c = json.serialize(emailAddresses);
            oMail.Subject = emailSubject;
            oMail.Reise__c = oReise.Id;
            oMail.Status = '3';
            insert oMail;

        }
        return null;
    }
    
}