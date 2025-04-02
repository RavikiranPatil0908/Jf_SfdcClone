import { LightningElement, api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import NewFormResource from '@salesforce/resourceUrl/NewFormResource';
import getLeadRecord from "@salesforce/apex/salesCadenceController.getLeadRecord";
import getLSMappings from "@salesforce/apex/salesCadenceController.getLSMappings";
export default class LeadScoreAndMoreInfo extends LightningElement {
    @api recordId;
    @api statusLoader;
    @track leadDetail;
    @track dispositions = [];
    @track leadScoreMapping;
    @track LSMap = { key: "", value: "" };
    @track leadScorePercentage = 0;
    @track pardotScorePercentage = 0;

    connectedCallback() {
		Promise.all([ loadScript(this, NewFormResource + '/script/radialIndicator.min.js') ]).then(() => {
			let myBar = this.template.querySelector('.myBar');
			// eslint-disable-next-line no-undef
			this.statusLoader = radialIndicator(myBar, {
				barColor: '#008000',
				barWidth: 5,
				initValue: 0,
                percentage: false,
			});
			//Using Instance
			this.statusLoader.animate(this.leadScorePercentage);
		});
	}


    @wire(getLeadRecord, { recordId: "$recordId" })
    getLeadRecord({ error, data }) {
    if (data) {
            console.log("LeadScore loaded--->");
            console.dir(data);
            this.leadDetail = data;
            if (this.leadDetail) {
            this.callForScore();
            }
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getLSMappings) LSMappingsValues;

    // renderedCallback(){
    //     console.log('mappings-===>'+JSON.stringify(this.LSMappingsValues));
    // }

    callForScore() {
        var leadScore;
        this.dispositions = [];
        // console.log("mappings " + JSON.stringify(this.LSMappingsValues.data));
        if (this.leadDetail.Age__c) {
            this.calculateAgeScore(this.leadDetail.Age__c, "Age");
            let arrayFilterData = this.calculateScore(this.LSMap);
            if(arrayFilterData && arrayFilterData.length > 0) {
                console.log("Lead Score for Age " + arrayFilterData[0].Lead_Score__c);
                leadScore = arrayFilterData[0].Lead_Score__c;
                let obj = { label: 'Age', value: this.leadDetail.Age__c};
                this.dispositions.push(obj);
                // leadScore = this.MathUtils.roundToPrecision(leadScore + leadScore , 1);
            }
        }
        if (this.leadDetail.nm_Qualification__c) {
            this.calculateQualficationScore(this.leadDetail.nm_Qualification__c,"Qualification");
            let arrayFilterData = this.calculateScore(this.LSMap);
            // leadScore += arrayFilterData[0].Lead_Score__c;
            if(arrayFilterData && arrayFilterData.length > 0 && arrayFilterData[0].Lead_Score__c){
                console.log("Lead Score for Qual " + arrayFilterData[0].Lead_Score__c);
                leadScore = this.MathUtils.roundToPrecision(leadScore + arrayFilterData[0].Lead_Score__c , 1);    
            }
            let obj = { label: 'Qualification', value: this.leadDetail.nm_Qualification__c};
            this.dispositions.push(obj);
        }
        if (this.leadDetail.nm_Designation__c){
            this.calculatedDesignationScore(this.leadDetail.nm_Designation__c,"Designation");
            let arrayFilterData = this.calculateScore(this.LSMap);
            // leadScore += arrayFilterData[0].Lead_Score__c;
            if(arrayFilterData && arrayFilterData.length > 0 && arrayFilterData[0].Lead_Score__c){
                console.log("Lead Score for Desig " + arrayFilterData[0].Lead_Score__c);
                leadScore = this.MathUtils.roundToPrecision(leadScore + arrayFilterData[0].Lead_Score__c , 1);
            }
            let obj = { label: 'Designation', value: this.leadDetail.nm_Designation__c};
            this.dispositions.push(obj);
        }
        if (this.leadDetail.Industry){
            this.calculatedIndustryScore(this.leadDetail.Industry, "Industry");
            let arrayFilterData = this.calculateScore(this.LSMap);
            // leadScore += arrayFilterData[0].Lead_Score__c;
            if(arrayFilterData && arrayFilterData.length > 0 && arrayFilterData[0].Lead_Score__c){
                console.log("Lead Score for Industry " + arrayFilterData[0].Lead_Score__c);
                leadScore = this.MathUtils.roundToPrecision(leadScore + arrayFilterData[0].Lead_Score__c , 1);
            }
            let obj = { label: 'Industry', value: this.leadDetail.Industry};
            this.dispositions.push(obj);
        }
        if (this.leadDetail.Agency__c){
            this.calculatedLeadSourceScore(this.leadDetail.Agency__c, "Source");
            let arrayFilterData = this.calculateScore(this.LSMap);
            // leadScore += arrayFilterData[0].Lead_Score__c;
            console.log("Lead Score for Source before " + arrayFilterData[0]);
            if(arrayFilterData && arrayFilterData.length > 0 && arrayFilterData[0].Lead_Score__c){
                console.log("Lead Score for Source " + arrayFilterData[0].Lead_Score__c);
                leadScore = this.MathUtils.roundToPrecision(leadScore + arrayFilterData[0].Lead_Score__c , 1);
            }
            let obj = { label: 'Agency', value: this.leadDetail.Agency__c};
            // this.dispositions.push(obj);
        }
        if (this.leadDetail.nm_WorkExperience__c){
            this.calculatedWorkExpScore(this.leadDetail.nm_WorkExperience__c, "Work Exp");
            let arrayFilterData = this.calculateScore(this.LSMap);
            // leadScore += arrayFilterData[0].Lead_Score__c;
            if(arrayFilterData && arrayFilterData.length > 0 && arrayFilterData[0].Lead_Score__c){
                console.log("Lead Score for Work Exp " + arrayFilterData[0].Lead_Score__c);
                leadScore = this.MathUtils.roundToPrecision(leadScore + arrayFilterData[0].Lead_Score__c , 1);
            }
            let obj = { label: 'Work Experience', value: this.leadDetail.nm_WorkExperience__c};
            this.dispositions.push(obj);
        }
        
        console.log("Lead Score " + leadScore);
        if(leadScore){
            this.leadScorePercentage = this.MathUtils.roundToPrecision(((leadScore / 6 ) * 100),1);
        }else{
            this.leadScorePercentage = 0;
        }
        this.statusLoader.animate(this.leadScorePercentage);
        console.log("Lead Score Percentage " + this.leadScorePercentage);
        if(this.leadDetail.nm_LeadWeightage__c){
            this.pardotScorePercentage = this.leadDetail.nm_LeadWeightage__c;
            let obj = { label: 'Pardot Score', value: this.leadDetail.nm_LeadWeightage__c};
            this.dispositions.push(obj);
        }

    }

    calculateAgeScore(Age, Category) {
        if (Age < 22) {
            this.LSMap.key = Category;
            this.LSMap.value = "Below 22";
        } else if (Age >= 22 && Age <= 25) {
            this.LSMap.key = Category;
            this.LSMap.value = "22-24";
        } else if (Age >= 25 && Age <= 30) {
            this.LSMap.key = Category;
            this.LSMap.value = "25-30";
        } else if (Age > 30 && Age < 35) {
            this.LSMap.key = Category;
            this.LSMap.value = "31-34";
        } else if (Age > 34 && Age <= 40) {
            this.LSMap.key = Category;
            this.LSMap.value = "35-40";
        } else if (Age > 40 && Age < 45) {
            this.LSMap.key = Category;
            this.LSMap.value = "41-44";
        } else if (Age > 44 && Age <= 50) {
            this.LSMap.key = Category;
            this.LSMap.value = "45-50";
        }
    }

    calculateQualficationScore(Qual,Category){
        if(Qual === 'HSC+Diploma'){
            this.LSMap.key = Category;
            this.LSMap.value = "HSC";
        }else if(Qual === 'SSC + Diploma'){
            this.LSMap.key = Category;
            this.LSMap.value = "SSC";
        }else{
            this.LSMap.key = Category;
            this.LSMap.value = Qual;
        }
    }

    calculatedDesignationScore(Desig,Category){
         this.LSMap.key = Category;
         this.LSMap.value = Desig;
    }

    calculatedIndustryScore(Industry,Category){
        this.LSMap.key = Category;
        this.LSMap.value = Industry;
    }

    calculatedLeadSourceScore(Source,Category){
        this.LSMap.key = Category;
        this.LSMap.value = Source;
    }

    calculatedWorkExpScore(WorkEx,Category){
        if (WorkEx === "0-1 Years" || WorkEx === "1-3 Years" || WorkEx === '3-5 Years'){
            this.LSMap.key = Category;;
            this.LSMap.value = "0-5";
        }else if (WorkEx === '5-10 Years'){
            this.LSMap.key = Category;
            this.LSMap.value = "6-10";
        }else if (WorkEx === "10+ Years"){
            this.LSMap.key = Category;
            this.LSMap.value = "11-15";
        }else{
            this.LSMap.key = Category;
            this.LSMap.value = WorkEx;
        }
    }

    calculateScore(mapofValues) {
        // need to be added
        var result = this.LSMappingsValues.data.filter(function (map) {
            return (
                map.Category__c == mapofValues.key &&
                map.Parameters__c == mapofValues.value
            );
        });
        return result;
    }

    MathUtils = {
        roundToPrecision: function(subject, precision) {
            return +((+subject).toFixed(precision));
        }
    };
}