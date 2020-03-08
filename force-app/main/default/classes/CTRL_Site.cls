public class CTRL_Site 
{
    public Reise__c oReise {get;set;}
    public list<selectoption> lSO {get;set;}
    public String sFilter {get;set;}

    
    public CTRL_Site () 
    {
        oReise = [Select Id, name, start__c, ende__c from Reise__c where Aktiv__c = true limit 1];
        lSO = new list<SelectOption>();
        lSO.add(new SelectOption('Bezahlt', 'Bezahlt'));
        //lSO.add(new SelectOption('Bestätigt', 'Bestätigt'));
        //lSO.add(new SelectOption('Interesse', 'Interesse - noch nicht bestätigt'));
        //lSO.add(new SelectOption('Offen', 'Offen'));
        //lSO.add(new SelectOption('Sonstig', 'Sonstig - z.B. Organisator'));        
        sFilter = 'Bezahlt';
    }

    public pagereference refresh()
    {
        
        return null;
    }
    
    public list<Teilnehmer__c> getTeilnehmer()
    {
        String sSOQL = 'Select id, Name, STatus__c from Teilnehmer__c where Reise__c = \'' + oReise.Id + '\'';
        sSOQL = sSOQL + ' AND Status__c = \'' + sFilter + '\' ';
        system.debug('**************sSOQL: ' + sSOQL);
        sSOQL = sSOQL + ' Order By Name';
        
        list<Teilnehmer__c> lTN = database.query(sSOQL);
        return lTN;
    }

    
       
}