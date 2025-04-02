import { LightningElement, track, wire } from 'lwc';
import getProgramDetails from "@salesforce/apex/AEPMerchandiseController.getProgramDetails";
import getProgramDates from "@salesforce/apex/AEPMerchandiseController.getProgramDates";
import getMapOfInterviewSlot from "@salesforce/apex/AEPMerchandiseController.getMapOfInterviewSlot";
import saveChangedDated from "@salesforce/apex/AEPMerchandiseController.saveChangedDated";
import LightningConfirm from 'lightning/confirm';
//import { NavigationMixin } from 'lightning/navigation';
//import getCancelDates from "@salesforce/apex/AEPMerchandiseController.getCancelDates";

const interSlotColumn = [
    { label: 'Interview Date', fieldName: 'Interview_Date__c', type: 'date', sortable: true },
    { label: 'Start time', fieldName: 'Start_time__c', type: 'String' },
    { label: 'End time', fieldName: 'End_time__c', type: 'String' }
];



const editSummaryColumn = [
    { label: 'Field Name', fieldName: 'name', type: 'String' },
    { label: 'Old Value', fieldName: 'oldValue', type: 'string' },
    {
        label: 'New Value', fieldName: 'newValue', type: 'string', cellAttributes: {
            class: 'slds-text-title_bold',
        },
    }
];
export default class ImportantDates extends LightningElement {
    programList = {};
    mapOfTypeVsCategoryVsProgramDate = {};
    mapOfInterviewSlot = {};
    @track programSelectedList = {};
    @track transposeColumn = [];
    @track transposeSelectedProgram = [];
    @track transposeColumnFIrstColumRemoved = [];
    interSlotColumn = interSlotColumn;
    @track lstInterviewSlot = [];
    @track isButtonAvailable = false;
    @track isInterviewModalOpen = false;
    @track originalConvertedProgramDate = [];
    @track convertedProgramDate = [];
    @track isEditModalOpen = false;
    @track editColumn = [];
    @track editNewColumn = {};
    @track isSummaryModalOPen = false;
    editSummaryColumn = editSummaryColumn;
    @track editSummaryData = [];
    fieldType = [];
    @track isNeedToShowApplicationInput = false;
    @track isNeedToShowPaymentInput = false;
    @track isNeedToShowLateFeeInput = false;
    @track isNeedToShowCancellationDate = false;
    @track isNeedToShowVideoVerification = false;

    @track multiSelectedPickList = [];
    @track multiSelectedValue;
    @track isTableHasRow = false;
    @track loanPaymentStartDateReadOnly;
    @track isShowSpinner = false;
    @track tabelData = [];
    @track isCancelDateVisible = false;
    @track paymentConfigId = '';

    get chooseProgramType() {
        return [
            { label: 'Certificate Programs', value: 'Certificate Programs' },
            { label: 'Diploma Programs', value: 'Diploma Programs' },
            { label: 'MBA (Distance) Programs', value: 'MBA (Distance) Programs' },
            { label: 'Bachelor Programs', value: 'Bachelor Programs' },
            { label: 'Master Programs', value: 'Master Programs' },
            { label: 'Professional Programs', value: 'Professional Programs' },
            { label: 'MBA (Online) Programs', value: 'MBA (Online) Programs'}
        ];
    }

    @wire(getProgramDetails)
    getProgramDetails({ error, data }) {
        this.isShowSpinner = true;
        if (data) {
            // console.log(JSON.stringify(data))
            this.programList = {};
            data.forEach(program => {
                let lstProgram = !this.programList.hasOwnProperty(program.nm_Type__c) ? [] : this.programList[program.nm_Type__c];
                let val = program.hasOwnProperty('Specialisation__c') ? program.Specialisation__c : 'null';
                lstProgram.push({ label: program.Name + ' | ' + program.nm_ProgramName__c, value: program.nm_Type__c + ' | ' + val });
                
                this.programList[program.nm_Type__c] = lstProgram;
                console.log('error');
                
            });
            //console.log(JSON.stringify(this.programList));
        } else if (error) {
            console.log(JSON.stringify(error))
        }
        this.isShowSpinner = false;
    }

    @wire(getProgramDates)
    getProgramDates({ error, data }) {
        this.isShowSpinner = true;
        if (data) {
            //console.log('getProgramDates data' ,JSON.stringify(data))
            this.mapOfTypeVsCategoryVsProgramDate = data;
        } else if (error) {
            console.log('getProgramDates error', JSON.stringify(error))
        }
        this.isShowSpinner = false;
    }

    @wire(getMapOfInterviewSlot)
    getMapOfInterviewSlot({ error, data }) {
        this.isShowSpinner = true;
        if (data) {
            // console.log('getMapOfInterviewSlot data' ,JSON.stringify(data))
            this.mapOfInterviewSlot = data;
        } else if (error) {
            console.log('getMapOfInterviewSlot error', JSON.stringify(error))
        }
        this.isShowSpinner = false;
    }

    // @wire(getCancelDates)
    // getCancelDates({ error, data }) {

    // }

    onChooseProgramChange(event) {
        let programValue = event.detail.value.split(' | ')
        this.programSelectedList = this.programList[programValue[0]];
        this.transposeColumn = [];
        this.transposeSelectedProgram = [];
        this.isTableHasRow = false;
    }
    onProgramChange(event) {
        const multiSet = new Set();
        let programValue = event.detail.value.split(' | ');
        console.log(programValue)
        let mapOfCategoryVsProgramDate = this.mapOfTypeVsCategoryVsProgramDate[programValue[0]];
        let lstProgramDates = [];
        if (mapOfCategoryVsProgramDate === undefined) {
            return;
        }
        Object.keys(mapOfCategoryVsProgramDate).forEach(key => {
            if (key.split('_')[1] == programValue[1]) {
                lstProgramDates.push(mapOfCategoryVsProgramDate[key])
            }
        });
        let interviewSlotList = this.mapOfInterviewSlot[programValue[1]];
        let convertedInterviewSlotList = [];
        if (interviewSlotList) {
            interviewSlotList.forEach(interview => {
                let intSlot = { ...interview };
                intSlot.Start_time__c = intSlot.hasOwnProperty('Start_time__c') ? this.convertInToISTTime(intSlot.Start_time__c) : '';
                intSlot.End_time__c = intSlot.hasOwnProperty('End_time__c') ? this.convertInToISTTime(intSlot.End_time__c) : '';
                convertedInterviewSlotList.push(intSlot);
            })
        }
        this.lstInterviewSlot = convertedInterviewSlotList ? convertedInterviewSlotList : [];

        this.isButtonAvailable = this.lstInterviewSlot.length > 0 ? true : false;
        let convertedProgramDate = [];
        //console.log('lstProgramDates--->' + lstProgramDates);
        lstProgramDates.forEach((programDates, index) => {
            //let lstCancelDates = [];
            multiSet.add(programDates.admissionCategory);
            let programDate = { ...programDates };
            programDate.paymentStartDate = programDates.hasOwnProperty('paymentStartDate') ? this.convertDateTimeUTCToIST(programDates.paymentStartDate) : '-';
            programDate.paymentEndDate = programDates.hasOwnProperty('paymentEndDate') ? this.convertDateTimeUTCToIST(programDates.paymentEndDate) : '-';
            programDate.loanWindowStartDate = programDates.hasOwnProperty('paymentStartDate') ? this.convertDateTimeUTCToIST(programDates.paymentStartDate) : '-';
            programDate.loanWindowEndDate = programDates.hasOwnProperty('loanWindowEndDate') ? this.convertDateTimeUTCToIST(programDates.loanWindowEndDate) : '-';
            programDate.ApplicationStartDate = programDates.hasOwnProperty('ApplicationStartDate') ? this.convertDateINToISTDate(programDates.ApplicationStartDate) : '-';
            programDate.ApplicationEndDate = programDates.hasOwnProperty('ApplicationEndDate') ? this.convertDateINToISTDate(programDates.ApplicationEndDate) : '-';
            programDate.LateFeeStartDateSlab1 = programDates.hasOwnProperty('LateFeeStartDateSlab1') ? this.convertDateINToISTDate(programDates.LateFeeStartDateSlab1) : '-';
            programDate.LateFeeStartDateSlab2 = programDates.hasOwnProperty('LateFeeStartDateSlab2') ? this.convertDateINToISTDate(programDates.LateFeeStartDateSlab2) : '-';
            //programDate.LateFeeStartDateSlab3 = programDates.hasOwnProperty('LateFeeStartDateSlab3') ? this.convertDateINToISTDate(programDates.LateFeeStartDateSlab3) : '-';
            programDate.LateFeeEndDateSlab1 = programDates.hasOwnProperty('LateFeeEndDateSlab1') ? this.convertDateINToISTDate(programDates.LateFeeEndDateSlab1) : '-';
            programDate.LateFeeEndDateSlab2 = programDates.hasOwnProperty('LateFeeEndDateSlab2') ? this.convertDateINToISTDate(programDates.LateFeeEndDateSlab2) : '-';
            //programDate.LateFeeEndDateSlab3 = programDates.hasOwnProperty('LateFeeEndDateSlab3') ? this.convertDateINToISTDate(programDates.LateFeeEndDateSlab3) : '-';
            programDate.paymentStartDateUTC = programDates.hasOwnProperty('paymentStartDate') ? this.convertDateTimeUTCToISTString(programDates.paymentStartDate) : '';
            programDate.paymentEndDateUTC = programDates.hasOwnProperty('paymentEndDate') ? this.convertDateTimeUTCToISTString(programDates.paymentEndDate) : '';
            programDate.loanWindowStartDateUTC = programDates.hasOwnProperty('paymentStartDate') ? this.convertDateTimeUTCToISTString(programDates.paymentStartDate) : '';
            programDate.loanWindowEndDateUTC = programDates.hasOwnProperty('loanWindowEndDate') ? this.convertDateTimeUTCToISTString(programDates.loanWindowEndDate) : '';
            programDate.ApplicationStartDateUTC = programDates.hasOwnProperty('ApplicationStartDate') ? this.convertDateTimeUTCToISTString(programDates.ApplicationStartDate) : '';
            programDate.ApplicationEndDateUTC = programDates.hasOwnProperty('ApplicationEndDate') ? this.convertDateTimeUTCToISTString(programDates.ApplicationEndDate) : '';
            programDate.LateFeeStartDateSlab1UTC = programDates.hasOwnProperty('LateFeeStartDateSlab1') ? this.convertDateTimeUTCToISTString(programDates.LateFeeStartDateSlab1) : '';
            programDate.LateFeeStartDateSlab2UTC = programDates.hasOwnProperty('LateFeeStartDateSlab2') ? this.convertDateTimeUTCToISTString(programDates.LateFeeStartDateSlab2) : '';
            //programDate.LateFeeStartDateSlab3UTC = programDates.hasOwnProperty('LateFeeStartDateSlab3') ? this.convertDateTimeUTCToISTString(programDates.LateFeeStartDateSlab3) : '';
            programDate.LateFeeEndDateSlab1UTC = programDates.hasOwnProperty('LateFeeEndDateSlab1') ? this.convertDateTimeUTCToISTString(programDates.LateFeeEndDateSlab1) : '';
            programDate.LateFeeEndDateSlab2UTC = programDates.hasOwnProperty('LateFeeEndDateSlab2') ? this.convertDateTimeUTCToISTString(programDates.LateFeeEndDateSlab2) : '';
            programDate.videoVerificationLastDate = programDates.hasOwnProperty('videoVerificationLastDate') ? this.convertDateINToISTDate(programDates.videoVerificationLastDate) : '';
            programDate.videoVerificationLastDateUTC = programDates.hasOwnProperty('videoVerificationLastDate') ?  this.convertDateTimeUTCToISTString(programDates.videoVerificationLastDate) : '';
            //programDate.paymentConfigId = programDates.hasOwnProperty('paymentConfigId')
            //programDate.LateFeeEndDateSlab3UTC = programDates.hasOwnProperty('LateFeeEndDateSlab3') ? this.convertDateTimeUTCToISTString(programDates.LateFeeEndDateSlab3) : '';
            // lstCancelDates = programDates.hasOwnProperty('lstCancelDate') ? programDates.lstCancelDate : [];
            // lstCancelDates.forEach((cancelDate, indexs) => {
            //     console.log('cancelDate.To_Date__c--->' + cancelDate.To_Date__c + ' ' + lstCancelDates.length + ' ' + index);
            //     index = indexs + 1;
            //     console.log('index--->' + index);
                // const cancelToDate = 'cancelToDate' + index;
                // const cancelFromDate = 'cancelFromDate' + index;
                // const percentage = 'percentage' + index;
                // const amount = 'amount' + index;
                // const admissionFee = 'admissionFee' + index;
                //const cancelationDateId = 'Cancelation Date' + index; 
                // if (programDate.hasOwnProperty('cancelToDate' + index)) {
                //     programDate[cancelToDate] = this.convertDateINToISTDate(cancelDate.To_Date__c);
                //     programDate[cancelFromDate] = this.convertDateINToISTDate(cancelDate.From_Date__c);
                //     console.log(' programDate[cancelToDate]--->' +  programDate[cancelToDate]);
                //     programDate[percentage] = cancelDate.Percentage__c;
                //     programDate[amount] = cancelDate.Amount__c;
                //     programDate[admissionFee] = cancelDate.Admission_Fee__c;
                // }
                // else {
                //     programDate[cancelToDate] = this.convertDateINToISTDate(cancelDate.To_Date__c);
                //     programDate[cancelFromDate] = this.convertDateINToISTDate(cancelDate.From_Date__c);
                //     programDate[percentage] = cancelDate.Percentage__c;
                //     programDate[amount] = cancelDate.Amount__c;
                //     programDate[admissionFee] = cancelDate.Admission_Fee__c;
                // }
                
                //programDate[cancelationDateId] = cancelDate.Id;
            //})
            programDate.key = index;
            convertedProgramDate.push(programDate);
            //count = lstCancelDates.length > count ? lstCancelDates.length : count;
        })
        let setOptions =  [];
        const multiArray = [...multiSet];
        multiArray.forEach(elm => {
            setOptions.push({ 'label': elm, 'value': elm })
        })
        this.multiSelectedPickList = setOptions;
        this.multiSelectedValue = JSON.stringify(multiArray);
        this.convertedProgramDate = convertedProgramDate;
        this.isTableHasRow = this.convertedProgramDate.length > 0 ? true : false;
        this.originalConvertedProgramDate = convertedProgramDate;
        console.log(JSON.stringify(this.multiSelectedPickList), 'this.multiSelectedPickList')
        this.transposeTable();
    }

    transposeTable() {
        this.isShowSpinner = true;
        // const verColumns = [
        //     { label: 'Admission Category', fieldName: 'admissionCategory', type: 'string' },
        //     { label: 'Semester', fieldName: 'semester', type: 'string' },
        //     { label: 'Session', fieldName: 'session' },
        //     { label: 'Year', fieldName: 'year', type: 'string' },
        //     { label: 'Specialization', fieldName: 'specialization', type: 'string' },
        //     { label: 'Application Start Date', fieldName: 'ApplicationStartDate', type: 'date' },
        //     { label: 'Application End Date', fieldName: 'ApplicationEndDate', type: 'date' },
        //     { label: 'Payment Start Date', fieldName: 'paymentStartDate', type: 'dateTime' },
        //     { label: 'Payment End Date', fieldName: 'paymentEndDate', type: 'dateTime' },
        //     { label: 'Loan Window Start Date', fieldName: 'loanWindowStartDate', type: 'dateTime' },
        //     { label: 'Loan Window End Date', fieldName: 'loanWindowEndDate', type: 'dateTime' },
        //     { label: 'Late Fee Start Date Slab 1', fieldName: 'LateFeeStartDateSlab1', type: 'date' },
        //     { label: 'Late Fee End Date Slab 1', fieldName: 'LateFeeEndDateSlab1', type: 'date' },
        //     { label: 'Late Fee Start Date Slab 2', fieldName: 'LateFeeStartDateSlab2', type: 'date' },
        //     { label: 'Late Fee End Date Slab 2', fieldName: 'LateFeeEndDateSlab2', type: 'date' },
        //     {label: 'Cancelation Dates', 
        //         type: "button",
		// 			initialWidth: 180,
		// 			typeAttributes: {
		// 				label: "view",
		// 				name: "view",
		// 				variant: "base",
		// 			}
        //     },
        //     // { label: 'Late Fee Start Date Slab 3', fieldName: 'LateFeeStartDateSlab3', type: 'date' },
        //     // { label: 'Late Fee End Date Slab 3', fieldName: 'LateFeeEndDateSlab3', type: 'date' },
        // ];
        // verColumns.push({
        //     label: 'Cancelation Dates',
        //     type: 'button',
        //     fieldName: 'paymentConfigId',
        //     typeAttributes: {
        //         label: 'View',
        //         name: 'view_details',
        //         variant: 'brand',
        //         title: 'View Details',
        //         iconName: 'utility:preview',
        //         iconPosition: 'right'
        //     }
        // });

        // Define the desired fields for the table
        const fieldLabels = [
            { id: '0', fieldLabel: 'Edit' , fieldName: 'Edit'},
            { id: '1', fieldLabel: 'Admission Category', fieldName: 'admissionCategory', type: 'string' },
            { id: '2', fieldLabel: 'Semester', fieldName: 'semester', type: 'string' },
            { id: '3', fieldLabel: 'Session', fieldName: 'session' },
            { id: '4', fieldLabel: 'Year', fieldName: 'year', type: 'string' },
            { id: '5', fieldLabel: 'Specialization', fieldName: 'specialization', type: 'string' },
            { id: '6', fieldLabel: 'Application Start Date', fieldName: 'ApplicationStartDate', type: 'date' },
            { id: '7', fieldLabel: 'Application End Date', fieldName: 'ApplicationEndDate', type: 'date' },
            { id: '8', fieldLabel: 'Payment Start Date', fieldName: 'paymentStartDate', type: 'dateTime' },
            { id: '9', fieldLabel: 'Payment End Date', fieldName: 'paymentEndDate', type: 'dateTime' },
            { id: '10', fieldLabel: 'Loan Window Start Date', fieldName: 'loanWindowStartDate', type: 'dateTime' },
            { id: '11', fieldLabel: 'Loan Window End Date', fieldName: 'loanWindowEndDate', type: 'dateTime' },
            { id: '12', fieldLabel: 'Late Fee Start Date Slab 1', fieldName: 'LateFeeStartDateSlab1', type: 'date' },
            { id: '13', fieldLabel: 'Late Fee End Date Slab 1', fieldName: 'LateFeeEndDateSlab1', type: 'date' },
            { id: '14', fieldLabel: 'Late Fee Start Date Slab 2', fieldName: 'LateFeeStartDateSlab2', type: 'date' },
            { id: '15', fieldLabel: 'Late Fee End Date Slab 2', fieldName: 'LateFeeEndDateSlab2', type: 'date' },
            { id: '16', fieldLabel: 'Last Date for Video Verification', fieldName: 'videoVerificationLastDate', type: 'date'},
            { id: '17', fieldLabel: 'Cancelation Dates', fieldName: 'cancelationDate' }
        ];
        //console.log('convertedProgramDate--->' + JSON.stringify(this.convertedProgramDate));
        this.tabelData = [];
        this.fieldType = fieldLabels;
        // Generate the tableData dynamically
        this.tableData = fieldLabels.map((field) => {
            const row = {
                id: field.id,
                fieldLabel: field.fieldLabel,
                fieldName: field.fieldName,
                records: [] // Array to store dynamic record values
            };

            // Dynamically add recordName keys based on JSON data size
            // this.convertedProgramDate.forEach((record, index) => {
            //     row[`recordName${index + 1}`] = record[field.fieldName] || '';
            // });

            // Populate records dynamically based on the array size
            this.convertedProgramDate.forEach((record, index) => {
                row.records.push({
                    key: `${field.id}-${index}`, // Unique key for each cell
                    value: record[field.fieldName] || '' // Field value
                });
            });

            // Set cancel button visibility based on a condition
            row.showCancelDateButton = field.fieldLabel === 'Cancelation Dates';
            row.showEditButton = field.fieldLabel === 'Edit'; 

            return row;
        });

        // Output the result
        console.log('tabeldata-->' + this.tableData);

        //tabel header
        this.transposeColumn = [];
        this.transposeColumn.push({ label: 'Label' });
        this.convertedProgramDate.forEach((programDate,index) => {
            let verColumnNumber = index + 1;
            this.transposeColumn.push({ label: 'Column - ' + verColumnNumber, fieldName: 'Column - ' + verColumnNumber, wrapText: true });
        });

        
        /*this.fieldType = verColumns;
        let horColumn = verColumns;
        // console.log('horColumn BEFore' ,JSON.stringify(horColumn))
        horColumn.forEach((column, verticalIndex) => {
            this.convertedProgramDate.forEach((programData, horizontalIndex) => {
                // console.log('programData -->'+ horizontalIndex + ' ---> ' + JSON.stringify(programData))
                let columnNo = 'Column - ' + Number(parseInt(horizontalIndex) + 1);
                if (column.label === 'Cancelation Dates') {
                    horColumn[verticalIndex][columnNo] = true;
                }
                else {
                    horColumn[verticalIndex][columnNo] = programData[column.fieldName]
                }
                console.log('column--->' + column + ' ' + verticalIndex);
                console.log('horColumn[verticalIndex][columnNo]--->' + horColumn[verticalIndex][columnNo] + ' ' + programData[column.fieldName]);
                console.log(`Column: ${column.label}, Row: ${horizontalIndex + 1}, Value:`, horColumn[verticalIndex][columnNo]);

            })
        })

        let varColumnObject = Object.keys(horColumn[0]);
        let forDeletion = ['fieldName', 'type'];
        varColumnObject = varColumnObject.filter(item => !forDeletion.includes(item))
        let varColumTable = [];
        varColumnObject.forEach((item, i) => {
            if (i != 0) {
                console.log('item-->' + item + ' ' + i);
                varColumTable.push({ label: item, fieldName: item, wrapText: true })
            }
        })
        // console.log('horColumn AFTER' ,JSON.stringify(horColumn))
        console.log('varColumTable', JSON.stringify(varColumTable))
        let transdata = [];
        horColumn.forEach(rate => {
            let pu = [];
            varColumnObject.forEach(col => {
                console.log('col--->' + col);
                pu.push(rate[col]);
            })
            transdata.push(pu)
        })
        this.transposeColumn = [];
        this.transposeSelectedProgram = [];
        this.transposeColumn = [{ label: 'Label' }, ...varColumTable];
        // let previousFirstElementOfTheArray = varColumTable;
        // console.log('previousFirstElementOfTheArray' ,previousFirstElementOfTheArray.shift())
        this.transposeColumnFIrstColumRemoved = varColumTable;
        console.log('transposeColumnFIrstColumRemoved', JSON.stringify(this.transposeColumnFIrstColumRemoved))

        this.transposeSelectedProgram = transdata;
        this.isShowSpinner = false;
        console.log('transposeSelectedProgram--->' + this.transposeSelectedProgram);*/
        this.isShowSpinner = false;
    }

    handleSelectOptionList(event) {
        console.log('handleSelectOptionList called')
        console.log(event.detail);
        this.convertedProgramDate = this.originalConvertedProgramDate.filter(res =>event.detail.includes(res.admissionCategory));
        this.transposeTable();
    }

    onOpenInterviewModal(event) {
        this.isInterviewModalOpen = true;
    }

    onCloseInterviewModal(event) {
        this.isInterviewModalOpen = false;
    }

    onHandleEdit(event) {
        this.refreshChildComponent();
        let value = event.currentTarget.dataset.key;
        let recordIndex = value.split('-')[1];
        console.log(value + ' ' +  recordIndex);
        this.editColumn = this.convertedProgramDate[recordIndex];
        this.isEditModalOpen = true;
        this.isNeedToShowApplicationInput = false;
        this.isNeedToShowPaymentInput = false;
        this.isNeedToShowLateFeeInput= false;
        this.paymentConfigId = this.editColumn.paymentConfigId;
        this.isNeedToShowCancellationDate = this.paymentConfigId !== '' && this.paymentConfigId !== null ? true : false;
        this.isNeedToShowVideoVerification = this.paymentConfigId !== '' && this.paymentConfigId !== null ? true : false;
        if (this.editColumn.admissionCategory == 'Re-Registration' || this.editColumn.admissionCategory == 'Admission' ) {
            if (this.editColumn.hasOwnProperty('CalenderId')) {
                this.isNeedToShowApplicationInput = true;
            }
            if (this.editColumn.hasOwnProperty('paymentConfigId')) {
                this.isNeedToShowPaymentInput = true;
            }
            this.isNeedToShowLateFeeInput= true;
        }
        if (this.editColumn.admissionCategory == 'Registration' || this.editColumn.admissionCategory == 'Is Lateral' ) {
            this.isNeedToShowLateFeeInput= true;
        }
        if (this.editColumn.admissionCategory == 'Repeat Term' || this.editColumn.admissionCategory == 'Live Lectures') {
            this.isNeedToShowApplicationInput = true;
        }
        this.loanPaymentStartDateReadOnly = this.editColumn.paymentStartDateUTC
        console.log('onHandleEdit --> ' + JSON.stringify(this.editColumn));
    }

    // handleRedirect(paymentConfig) {
    //     console.log('redirect');
    //     const baseUrl = window.location.origin;
    //     const targetUrl = `${baseUrl}/apex/c__showCancelationDates?param1=${paymentConfig}`;
    //     console.log('targetUrl--->' + targetUrl);
        
    //     //window.location.href = targetUrl; // Perform the redirect
    // }

    handleCancelDateClose() {
        // Hide child component when closed
        this.isCancelDateVisible = false;
        this.paymentConfigId = '';
    }
    

    handleCancelDateClick(event) {
        let value = event.currentTarget.dataset.key;
        let recordIndex = value.split('-')[1];
        console.log(value + ' ' +  recordIndex);
        this.refreshChildComponent();
        
        this.paymentConfigId = '';
        this.paymentConfigId = this.convertedProgramDate?.[recordIndex]?.paymentConfigId || '';
        this.isCancelDateVisible = this.paymentConfigId !== '' && this.paymentConfigId !== null ? true : false;
        console.log('paymentConfig--->'  + this.paymentConfigId);
    }

    refreshChildComponent() {
        setTimeout(() => {
            const allComponents = this.template.querySelectorAll('c-Show-Cancelation-Dates');
            console.log('All c-show-cancelation-dates components:', allComponents);
            allComponents.forEach((component) => {
                let result = component.refresh();
                console.log('result--->' + result);
            });
        }, 0);
    }

    onCloseEditModal(event) {
        this.isEditModalOpen = false;
        this.isSummaryModalOPen = false;
        this.editSummaryData = [];
        this.editSummaryData = [];
        this.editNewColumn = {};
        this.editColumn = {};
    }

    handleInputChange(event) {
        let inputName = event.currentTarget.dataset.inputName;
        console.log(inputName + ' --- ' + event.detail.value);
        if (event.detail.value) {
            this.editNewColumn[inputName] = event.detail.value;
            if (inputName == 'paymentStartDateUTC') {
                this.loanPaymentStartDateReadOnly = event.detail.value
            }
            const elm = this.template.querySelector(`[data-input-name="${inputName}"]`);
            // elm.setCustomValidity('');
            // elm.reportValidity();
            event.target.setCustomValidity('');
            event.target.reportValidity();

        } else {
            delete this.editNewColumn[inputName];
        }
        console.log(JSON.stringify(this.editNewColumn));
    }

    onCloseCancelationDateModal() {
        //this.dispatchEvent(new CustomEvent('close'));
        this.isCancelDateVisible = false;
    }

    onSaveEditValue(event) {
        let summaryData = [];
        if (Object.keys(this.editNewColumn).length == 0) {
            alert('At least change 1 value')
        } else {
            // Get a reference to the child component
            const childComponent = this.template.querySelector('c-Show-Cancelation-Dates');

            if (childComponent) {
                // Call the child's method and get the text
                const msg = childComponent.validateParentSaveButton();
                console.log('msg---->' + msg);
                if (msg) {
                    alert('Save the cancellation date changes by clicking the "Save Changes" button');
                    return;
                }
            }
            const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            const ApplicationStartDateUTC = this.template.querySelector('[data-input-name="ApplicationStartDateUTC"]');
            const ApplicationEndDateUTC = this.template.querySelector('[data-input-name="ApplicationEndDateUTC"]');
            const paymentStartDateUTC = this.template.querySelector('[data-input-name="paymentStartDateUTC"]');
            const paymentEndDateUTC = this.template.querySelector('[data-input-name="paymentEndDateUTC"]');
            const loanWindowStartDateUTC = this.template.querySelector('[data-input-name="loanWindowStartDateUTC"]');
            const loanWindowEndDateUTC = this.template.querySelector('[data-input-name="loanWindowEndDateUTC"]');
            const LateFeeStartDateSlab1UTC = this.template.querySelector('[data-input-name="LateFeeStartDateSlab1UTC"]');
            const LateFeeEndDateSlab1UTC = this.template.querySelector('[data-input-name="LateFeeEndDateSlab1UTC"]');
            const LateFeeStartDateSlab2UTC = this.template.querySelector('[data-input-name="LateFeeStartDateSlab2UTC"]');
            const LateFeeEndDateSlab2UTC = this.template.querySelector('[data-input-name="LateFeeEndDateSlab2UTC"]');
            const videoVerificationLastDateUTC = this.template.querySelector('[data-input-name="videoVerificationLastDateUTC"]');
            // const LateFeeStartDateSlab3UTC = this.template.querySelector('[data-input-name="LateFeeStartDateSlab3UTC"]');
            // const LateFeeEndDateSlab3UTC = this.template.querySelector('[data-input-name="LateFeeEndDateSlab3UTC"]');
            console.log('ApplicationStartDateUTC --> ', videoVerificationLastDateUTC)
            let validAll = [];
            validAll.push(allValid);
            validAll.push(this.validateFormGroup(ApplicationStartDateUTC, ApplicationEndDateUTC, 'Application'));
            validAll.push(this.validateFormGroup(paymentStartDateUTC, paymentEndDateUTC, 'Payment'));
            validAll.push(this.validateFormGroup(loanWindowStartDateUTC, loanWindowEndDateUTC, 'Loan'));
            validAll.push(this.validateFormGroup(LateFeeStartDateSlab1UTC, LateFeeEndDateSlab1UTC, 'LateFee Slab 1'));
            validAll.push(this.validateFormGroup(LateFeeStartDateSlab2UTC, LateFeeEndDateSlab2UTC, 'Late Fee Slab 2'));
            //validAll.push(this.validateFormGroup(videoVerificationLastDateUTC,'','Video Verification'));
            //validAll.push(this.validateFormGroup(LateFeeStartDateSlab3UTC, LateFeeEndDateSlab3UTC, 'Late Fee Slab 3'));

            const allValidationPassed = validAll.every(result => result);
            console.log('allValidationPassed --> ', allValidationPassed);
            
            if (allValidationPassed) {
                this.isEditModalOpen = false;
                this.isSummaryModalOPen = true;
                Object.keys(this.editNewColumn).forEach(element => {
                    console.log('this.editNewColumn[element]--> ' + this.editNewColumn[element] + ' --- ' + this.editColumn[element]);
                    if (this.editNewColumn[element] != this.editColumn[element]) {
                        const labelName = element.split('UTC')[0];
                        let selectedRow;
                        this.fieldType.forEach(f => {
                            if (f.fieldName == labelName) {
                                selectedRow = f;
                            }
                        });
                        //console.log('summary-->' + JSON.stringify(selectedRow));

                        summaryData.push({
                            ...this.editColumn,
                            CalenderId: this.editColumn['CalenderId'], paymentConfigId: this.editColumn['paymentConfigId'],
                            oldValue: selectedRow.type == 'dateTime' ? this.convertDateTimeString(this.editColumn[element]) : selectedRow.type == 'date' ? this.convertDateINToISTDate(this.editColumn[element]) : this.editColumn[element],
                            newValue: selectedRow.type == 'dateTime' ? this.convertDateTimeString(this.editNewColumn[element]) : selectedRow.type == 'date' ? this.convertDateINToISTDate(this.editNewColumn[element]) : this.editNewColumn[element],
                            label: selectedRow.label,
                            LateFeeSlab1Id: this.editColumn['LateFeeSlab1Id'],
                            LateFeeSlab2Id: this.editColumn['LateFeeSlab2Id'],
                            videoVerificationLastDate: this.editColumn['videoVerificationLastDate'],
                            //LateFeeSlab3Id: this.editColumn['LateFeeSlab3Id'],
                            name: labelName
                        })
                    }
                })
                this.editSummaryData = summaryData;
                console.log('this.editSummaryData--->' + this.editSummaryData);
            } else {
                alert('Please update the invalid form entries and try again.');
            }
        }
    }

    async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: 'Are you sure want to apply changes ?',
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
        if (result) {
            this.isShowSpinner = true;
            saveChangedDated({jsonString: JSON.stringify(this.editSummaryData)})
            .then(result => {
                console.log('saveChangedDated then -->',  result);
                alert('Successfully updated')
                this.isShowSpinner = false;
                this.isEditModalOpen = false;
                this.isSummaryModalOPen = false;
                this.editSummaryData = [];
                this.editSummaryData = [];
                this.editNewColumn = {};
                this.editColumn = {};
                window.location.reload();
            }).catch(error => {
                console.log('saveChangedDated catch -->',JSON.stringify(error))
                alert('Something went wrong, kindly try again later')
                this.isShowSpinner = false;
                this.isEditModalOpen = false;
                this.isSummaryModalOPen = false;
                this.editSummaryData = [];
                this.editSummaryData = [];
                this.editNewColumn = {};
                this.editColumn = {};
                window.location.reload();
            })
        } else {
            alert('No Seelcted');
        }
    }

    onCloseSummaryModal(event) {
        this.isEditModalOpen = false;
        this.isSummaryModalOPen = false;
        this.editSummaryData = [];
        this.editSummaryData = [];
        this.editNewColumn = {};
        this.editColumn = {};
        //window.location.reload();
    }

    convertDateTimeUTCToIST(dateTime) {
        const date = new Date(dateTime);
        // date.setUTCHours(date.getUTCHours() + 5);
        // date.setUTCMinutes(date.getUTCMinutes() + 30);
        const formattedDate = date.toLocaleString('en-IN', {
            timeZone: 'Asia/Kolkata',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
        return formattedDate;
    }

    convertDateTimeString(dateTime) {
        const date = new Date(dateTime);
        const month = date.getMonth() >= 0 ? date.getMonth() + 1 : 0;
        console.log('date--->' + date + ' ' + dateTime);
        const formattedDate = date.toLocaleString('en-IN', {
            timeZone: 'Asia/Kolkata',
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
        console.log('getMonth()-->' + date.getMonth() + ' ' + formattedDate + ' ' + date + ' ' + month);
        return month ? formattedDate : '-';
    }
    convertDateTimeUTCToISTString(dateTime) {
        const date = new Date(dateTime);
        // date.setUTCHours(date.getUTCHours() + 5);
        // date.setUTCMinutes(date.getUTCMinutes() + 30);
        return date.toJSON();
    }

    convertDateINToISTDate(dateStr) {
        const date = new Date(dateStr);
        const months = date.getMonth() >= 0 ? date.getMonth() + 1 : 0;
        console.log('dateStr -->' + dateStr);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = String(date.getFullYear());
        const formattedDate = `${day}/${month}/${year}`;
        console.log('formattedDate--->' + formattedDate);
        return  months ? formattedDate : '-';
    }

    convertInToISTTime(timeStr) {
        const date = new Date(timeStr);
        console.log('timeStr --->' + timeStr);
        date.setUTCHours(date.getUTCHours() - 5);
        date.setUTCMinutes(date.getUTCMinutes() - 30);
        const formattedDate = date.toLocaleString('en-IN', {
            timeZone: 'Asia/Kolkata',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        });
        return formattedDate;
    }

    validateFormGroup(startDate, endDate, groupName) {
        //console.log(startDate.value, endDate.value, groupName, typeof(startDate.value), '---> validateFormGroup', startDate.value && endDate.value && (new Date(endDate.value) < new Date(startDate.value)) )
        
        // if (startDate.value && groupName === 'Video Verification') {
        //     startDate.setCustomValidity(`Last date cannot be less than Today.`);
        //     startDate.reportValidity();
        //     return false;
        // } 
        if (startDate && endDate && startDate.value && !endDate.value) {
            console.log(`End date for ${groupName} cannot be null if start date has a value.`);
            endDate.setCustomValidity(`End date for ${groupName} cannot be null if start date has a value.`);
            endDate.reportValidity();
            return false;
        } else if (startDate && endDate && !startDate.value && endDate.value) {
            console.log(`Start date for ${groupName} cannot be null if End date has a value.`);
            startDate.setCustomValidity(`Start date for ${groupName} cannot be null if End date has a value.`);
            startDate.reportValidity();
            return false;
        } else if (startDate && endDate && startDate.value && endDate.value && (new Date(endDate.value) < new Date(startDate.value))) {
            endDate.setCustomValidity(`End date for ${groupName} cannot be smaller than start date.`);
            endDate.reportValidity();
            return false;
        } {
            return true;
        }
    }
}