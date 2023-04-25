public with sharing class LWC01_NationalIDNumberInputController {

    @AuraEnabled
    public static String insertNationalIdSearch(String nationalIdNumber) {
        Integer year;
        List<SANationalIDSearch__c> nationalIDSearch = [SELECT Id, Name, NumberOfSearch__c, DateOfBirth__c FROM SANationalIDSearch__c WHERE Name = :nationalIdNumber LIMIT 1];

        if(!nationalIDSearch.isEmpty()) {
            nationalIDSearch[0].NumberOfSearch__c = nationalIDSearch[0].NumberOfSearch__c + 1;
            Database.update(nationalIDSearch);

            year = nationalIDSearch[0].DateOfBirth__c.year();
        }else {
            Integer day = Integer.valueOf(nationalIdNumber.substring(4, 6)); 
            Integer month = Integer.valueOf(nationalIdNumber.substring(2, 4));
            year = Integer.valueOf(nationalIdNumber.substring(0, 2));
            String currentYear = String.valueOf(System.today().year()).substring(2,4);                          
            if(year >= Integer.valueOf(currentYear)) {
                year = 1900 + year;
            }else {
                year = 2000 + year;
            }
            Date birthdate = Date.newInstance(year, month, day);

            Integer genderCode = Integer.valueOf(nationalIdNumber.substring(6, 10));
            String gender;
            if(genderCode < 5000) {
                gender = 'Female';
            }else {
                gender = 'Male';
            }

            Boolean SACitizen = false;
            if(nationalIdNumber.substring(10, 11) == '0') {
                SACitizen = true;
            }

            SANationalIDSearch__c newSearch = new SANationalIDSearch__c();
            newSearch.Name = nationalIdNumber;
            newSearch.DateOfBirth__c = birthdate;
            newSearch.Gender__c = gender;
            newSearch.NumberOfSearch__c = 1;
            newSearch.SACitizen__c = SACitizen;

            Database.insert(newSearch);
        }

        return String.valueOf(year);        
    }

    @AuraEnabled
    public Static List<String> getPublicHolidays(String year) {
        String apiBaseUrl = 'https://calendarific.com/api/v2';
        String endpoint = '/holidays';
        String apiKey = '2d87e618be3612567d14226d69493cda5c7a1e36';
        String isoCode = 'ZA';
        String request = apiBaseUrl + endpoint + '?api_key=' + apiKey + '&country=' + isoCode + '&year=' + year;

        Http httpObj = new Http();
        HttpRequest requestBody = new HttpRequest();
        requestBody.setEndpoint(request);
        requestBody.setMethod('POST');
        HttpResponse responseBody = httpObj.send(requestBody);

        Map<String, Object> mapRes = (Map<String, Object>) JSON.deserializeUntyped(responseBody.getBody());
        Map<String, Object> obj = (Map<String, Object>) mapRes.get('response');
        List<Object> holidays = (List<Object>) obj.get('holidays');

        List<String> publicHolidays = new List<String>();
        for(Object hol : holidays) {
            Map<String, Object> pubHol = (Map<String, Object>)hol;
            if(pubHol.get('primary_type') == 'Public Holiday') {
                publicHolidays.add(String.valueOf(pubHol.get('name')));
            }
        }
        
        return publicHolidays;
    }    
    
}