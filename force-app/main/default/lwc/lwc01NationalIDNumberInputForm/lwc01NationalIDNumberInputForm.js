import { LightningElement } from 'lwc';
import insertNationalIdSearch from '@salesforce/apex/LWC01_NationalIDNumberInputController.insertNationalIdSearch';
import getPublicHolidays from '@salesforce/apex/LWC01_NationalIDNumberInputController.getPublicHolidays';

export default class Lwc01NationalIDNumberInputForm extends LightningElement {
    searchDisabled = true;
    nationalId;
    displayPubHol = false;
    pubHolTitle = 'Public Holidays in ';
    publicHolidays = [];

    checkValidity(evt) {
        let nationalIdNumber = evt.target.value;

        if(nationalIdNumber.length == 13 && !isNaN(nationalIdNumber) && (nationalIdNumber.substring(10, 11) == 0 || nationalIdNumber.substring(10, 11) == 1)) {
            this.searchDisabled = false;
            this.setInvalidMessage(evt.target, '');
            this.nationalId = nationalIdNumber;
        }else {
            this.searchDisabled = true;
            this.setInvalidMessage(evt.target, 'Id Invalid');
            this.publicHolidays = [];
            this.displayPubHol = false;
            this.pubHolTitle = 'Public Holidays in ';
        }        
    }   

    setInvalidMessage(messageTarget, message) {
        messageTarget.setCustomValidity(message);
        messageTarget.reportValidity();
    }

    handleClick() {
        insertNationalIdSearch({ nationalIdNumber : this.nationalId })
            .then((result) => {
                this.pubHolTitle = this.pubHolTitle + result;

                getPublicHolidays({ year : result })
                    .then((res) => {                                                
                        this.publicHolidays = res;
                        this.displayPubHol = true;
                    })
            });
    }  
}