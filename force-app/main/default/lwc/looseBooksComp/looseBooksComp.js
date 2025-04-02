import { LightningElement,api,wire, track } from 'lwc';
import getCourseName from '@salesforce/apex/lightningButtonController.getCourseName';
import getStocksCenters from '@salesforce/apex/lightningButtonController.getStocksCenters';
import generateLooseBooksDO from '@salesforce/apex/lightningButtonController.generateLooseBooksDO';
export default class LooseBooksComp extends LightningElement {
    @api parameters;
    @api recordId;
    @track accountId;
    @track courses = [];
    @track showPopup = { title: '', message: '', variant: '' };
    @track calculation = {
        noOfItems : 0,
        booksname : [],
        show : false
    };
    @track stocks = [];
    @track stocksCenters = [];
    @track showCenters = false;
    @track showcheckqty = false;
    @track arrayscenters = [];
    // @track qty = 0;
    @track isLoaded = false;
   
    connectedCallback(){
        // to set the recordId
        if(this.parameters){
            console.dir(this.parameters)
        }
		if (Object.prototype.hasOwnProperty.call(this.parameters, 'id')) {
			this.recordId = this.parameters.id;
        } 
        if (Object.prototype.hasOwnProperty.call(this.parameters, 'accid')) {
			this.accountId = this.parameters.accid;
        } 
    }

    @wire(getCourseName, { opportunityId: '$recordId'})
	getCourseDetails({ error, data }) {
		console.log('enter for get course details ' + this.recordId);
		if (data) {
           var i = 0;
           var booksname = [];
           var result = data.map(function(el) {
                var obj = {"id" : i,"name": el,"selected":false};
                if (!booksname.includes(el)) {
                    booksname.push(el);   
                }
                i = i + 1;
                return obj;
            })
            this.courses = result;
            console.log(JSON.stringify(this.courses));
            if(this.courses.length <= 0){
                this.showHtmlMessage('Failed to get courses.!','Please check respective SKU','error');
            }else{
                console.log('booksname '+JSON.stringify(booksname));
                this.checkStockQuantity(booksname);
            }
		} else if (error) {
			console.error(error);
		}
    }

    // input1OnChange(event){
    //     this.qty = event.target.value;
    // }

    handleClick(event) {
        let value = event.currentTarget.dataset.value;
        console.log('value ==> '+value);
        this.courses.forEach(element => {
            if(element.name === value) {
                if(element.selected) {
                    element.selected = false;
                    --this.calculation.noOfItems;  
                    var array = this.calculation.booksname;
                    this.calculation.booksname = this.removeA(array, element.name);
                }else if(!element.selected) {
                    element.selected = true;
                    ++this.calculation.noOfItems;
                    var array = this.calculation.booksname;
                    if (Array.isArray(array) && array.length && !array.includes(element.name)) {
                        array.push(element.name);   
                    }else if(!array.includes(element.name)){
                        var emptyarray = [element.name];
                        this.calculation.booksname = emptyarray;
                    }
                }
                this.Checkforquantity();
            }
        });
        console.log(JSON.stringify(this.calculation));
        if(Array.isArray(this.calculation.booksname) && this.calculation.booksname.length){
            console.log('true');
        }else{
            this.showCenters = false;
            this.stocksCenters = [];
            this.arrayscenters = [];
        }
    }

    handleClickforcenters(event) {
        let value = event.currentTarget.dataset.value;
        console.log('value ==> '+value);
        this.stocksCenters.forEach(element => {
            if(element.name === value) {
                if(element.selected) {
                    element.selected = false;
                    var array = this.arrayscenters;
                    this.arrayscenters = this.removeA(array, element.name);
                }else if(!element.selected) {
                    element.selected = true;
                    var array = this.arrayscenters;
                    if (Array.isArray(array) && array.length && !array.includes(element.name)) {
                        array.push(element.name);   
                    }else if(!array.includes(element.name)){
                        var emptyarray = [element.name];
                        this.arrayscenters = emptyarray;
                    }
                    
                    if(Array.isArray(this.arrayscenters) && this.arrayscenters.length && this.arrayscenters.length >1){
                        console.log('arrayscenters len '+this.arrayscenters.length);
                        this.showHtmlMessage('Warning !','Please choose only one AEP.','warning');
                        this.arrayscenters = this.removeA(this.arrayscenters, element.name);
                        element.selected = false;
                    }
                    console.log('arrayscenters '+JSON.stringify(this.arrayscenters));
                }

               
            }
        });
    }

    checkStockQuantity(booksname) {
        getStocksCenters({Booksname : booksname})
        .then(result => {
            this.stocks = result;
            console.log(JSON.stringify(this.stocks));
            // for (const property in this.stocks) {
            //     console.log(`${property}: ${this.stocks[property]}`);
            // }
        })
        .catch(error => {
            console.log("error", error);
            this.showHtmlMessage('Error!','No Stocks available for .'+booksname,'error');
        });
    }

    removeA(arr) {
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax= arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    }
    
    Checkforquantity(){
        // console.log('check for quantity call');
        var booksaar = this.calculation.booksname;
        let duplicate = [];
        let undefinedcenter = false;
        // console.log('booksaar '+booksaar);
        booksaar.forEach(course => {
            // let temp = this.stocks.has(course) ? this.stocks[course] : '';
            let temp = this.stocks[course];
            console.log('temp '+temp);
            if(temp !== undefined){
                if(duplicate.length == 0) {
                    // console.log('length '+duplicate.length + 'temp '+temp);
                    duplicate = temp;
                } else {
                    duplicate = duplicate.filter(function(val) {
                        return temp.indexOf(val) != -1;
                    });
                }
            }else{
                undefinedcenter = true;
                this.stocksCenters = [];
                this.showCenters = false;
                this.showcheckqty = false;
            }
        });
        console.log(JSON.stringify(duplicate) + ' undefinedcenter '+undefinedcenter);
        if(!undefinedcenter){
            var i = 0;
            var result = duplicate.map(function(el) {
                var obj = {"id" : i,"name": el,"selected":false};
                i = i + 1;
                return obj;
            })
            
            this.stocksCenters = result;
            this.showCenters = true;
        }
        console.log(JSON.stringify(this.stocksCenters));
        if(this.stocksCenters.length === 0){
            this.showHtmlMessage('Warning !','No matching AEP available','warning');
            this.showCenters = false;
            this.showcheckqty = false;
        }else{
            this.showcheckqty = true;
        }

    }

    GenerateLoosBooksDO(){
        // console.log(this.qty);
        // if(this.qty <= 0){
        //     this.qty = 1
        // }
        this.isLoaded = true;
        generateLooseBooksDO({centerName : this.arrayscenters[0],booksname : this.calculation.booksname, opportunityId : this.recordId, qty : 1, accountId : this.accountId})
        .then(result => {
            console.log(JSON.stringify(result));
            this.isLoaded = false;
            this.showHtmlMessage('Success!','Loose Book DO Created Id: '+result,'success');  
            // window.location.reload();
            var result = confirm("Loose Book DO Created Id: "+result);
            if (result) {
                window.location.reload();
            }
        })
        .catch(error => {
            console.log("error", error);
            this.isLoaded = false;
            this.showHtmlMessage('Error!','Something went wrong','error');
            var result = confirm("Something went wrong.Are you want to retry?");
            if (result) {
                window.location.reload();
            }
            // window.location.reload();
        });
    }

     // To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }

}