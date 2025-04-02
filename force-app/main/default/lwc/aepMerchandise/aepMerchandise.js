import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, updateRecord, generateRecordInputForUpdate, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import Contact_Name from '@salesforce/schema/User.AccountId__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllProducts from "@salesforce/apex/AEPMerchandiseController.getAllProducts";
import getCenterUserData from '@salesforce/apex/AEPMerchandiseController.getCenterUserData';
import placeOrder from '@salesforce/apex/AEPMerchandiseController.placeOrder';
import siteUrl from '@salesforce/label/c.Site_Url'; 
export default class AepMerchandise extends NavigationMixin(LightningElement) {

    @track Products = [];
    @track Carts = [];
    @track TotalCartPrice = 0;
    @track showPopup = { title: '', message: '', variant: '' };
    @track isItemInCart = false;
    CenterId;
    @track allowProceed = false;
    @track isAuthorized = false;
    @track isOpenSizeChart = false;
    @track sizeChartImage; 
    connectedCallback() {
        console.log('sssss')
    }


    @wire(getCenterUserData, { userId: USER_ID })
    getAEPUserDetails({ error, data }) {
        console.log("data in getAEPUserDetails" + JSON.stringify(data));
        if (data) {
            console.log(JSON.stringify(data));
            if (Object.keys(data).length === 0 && data.constructor === Object) {
                this.isAuthorized = false;
                this.showHtmlMessage('Error', 'You are not authorize for this page....', 'error');
            } else {
                console.log(data);
                this.isAuthorized = true;
                this.CenterId = data.nm_Centers__c;
            }
        } else if (error) {
            this.showHtmlMessage('Error', 'something went Wrong', 'error');
            console.error(error);
        }
    }

    @wire(getAllProducts)
    getAllProducts({ error, data }) {
        if (data) {
            let pr = new Array();
            pr = data;
            pr.forEach((element, index) => {
                let product = {
                    key: element.Product.Id,
                    name: element.Product.Name,
                    price: parseFloat(element.Pricebook.UnitPrice) + (parseFloat(element.Pricebook.UnitPrice) * 0.05),
                    productSize: element.Product.Product_Size__c,
                    lstProductSize: element.Product.Product_Size__c ? element.Product.Product_Size__c.split(';') : [],
                    isSizeRequired: element.Product.Product_Size__c ? true : false,
                    isSizeSelected: false,
                    selectedSize: '',
                    addedToCart: false,
                    sizeChart: element.Product.Size_Chart__c,
                    isSizeChart: element.Product.Size_Chart__c ? true: false,
                    numberOFProductSelected: 1,
                    // imageOfProduct: element.Product.Product_Image__c,
                    product: element.Product,
                    pricebook: element.Pricebook,
                    isAddToCartButtonActivate: true

                };
                this.Products.push(product);

            });

        } else if (error) {
            this.showHtmlMessage('Error', 'something went Wrong', 'error');
            console.error(error);
        }
    }

    onClick() {

        this.showHtmlMessage('Email has been sent !', 'Email sent', 'success');
    }
    handleChange(event) {

        if (event.target.name === 'checkBoxChecked') {
            if (event.target.checked) {
                this.allowProceed = true;
            } else {
                this.allowProceed = false;
            }
        } 
    }


    validate(event) {
        var theEvent = event;
        console.log('validate')

        // Handle paste
        if (theEvent.type === 'paste') {
            key = event.clipboardData.getData('text/plain');
        } else {
            // Handle key press
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode(key);
        }
        var regex = /\d+/;
        // var regex = /[0-9]|\./;
        if (!regex.test(key)) {
            theEvent.returnValue = false;
            if (theEvent.preventDefault) theEvent.preventDefault();
        }
    }

    addNoProduct(event) {
        let value = event.currentTarget.dataset.value;
        this.Products.forEach(product => {
            if (product.key == value) {
                product.numberOFProductSelected++;
            }
        })
        let checkbox = this.template.querySelector('.checkboxSelected');
    }

    minusNoProduct(event) {
        let value = event.currentTarget.dataset.value;
        this.Products.forEach(product => {
            if (product.key == value) {
                product.numberOFProductSelected--;
            }
        })
    }


    changeCartNo(event) {
        let value = event.currentTarget.dataset.value;
        console.log('value ==> ' + value);
        this.Carts.forEach(cart => {
            if (cart.key == value) {
                cart.NumberOfProduct = event.target.value ? event.target.value : cart.NumberOfProduct;
                event.target.value = cart.NumberOfProduct;
                cart.TotalPrice = parseFloat(cart.NumberOfProduct) * parseFloat(cart.singlePrice)
            }
        })
        this.totalCartPrice();
    }

    changeProductNo(event) {
        let value = event.currentTarget.dataset.value;
        console.log('value ==> ' + value);
        this.Products.forEach(product => {
            if (product.key == value) {
                product.numberOFProductSelected = event.target.value ? event.target.value : product.numberOFProductSelected;
                event.target.value = product.numberOFProductSelected;
            }
        })
        this.totalCartPrice();
    }

    addNoCart(event) {
        let value = event.currentTarget.dataset.value;
        this.Carts.forEach(cart => {
            if (cart.key == value) {
                cart.NumberOfProduct++;
                cart.TotalPrice = parseFloat(cart.NumberOfProduct) * parseFloat(cart.singlePrice)
            }
        })
        this.totalCartPrice();
    }

    minusNoCart(event) {
        let value = event.currentTarget.dataset.value;
        this.Carts.forEach(cart => {
            if (cart.key == value) {
                cart.NumberOfProduct--;
                cart.TotalPrice = parseFloat(cart.NumberOfProduct) * parseFloat(cart.singlePrice)
            }
        })
        this.totalCartPrice();
    }

    toggleSize(event) {
        let productSize = event.currentTarget.dataset.productsize;
        let productIndex = event.currentTarget.dataset.index;
        this.template.querySelectorAll(`[data-productSize="${productSize}"]`).forEach(element => {
            if (element.innerHTML == productIndex) {
                element.classList.add('slds-button_outline-brand')

            } else {
                element.classList.remove('slds-button_outline-brand')
            }
        });
        this.Products.forEach(product => {
            if (product.key == productSize) {
                product.selectedSize = productIndex;
                product.isAddToCartButtonActivate = true;
                let cardButton = this.template.querySelector(`[data-cartbutton="${product.key}"]`);
                cardButton.removeAttribute('disabled')
                if (product.isAddToCartButtonActivate) {
                    cardButton.removeAttribute('disabled')
                } else {
                    cardButton.setAttribute('disabled', '')
                }
        
            }
        })
        this.totalCartPrice();

    }

    addToCart(event) {
        let value = event.currentTarget.dataset.value;
        this.Products.forEach(product => {
            if (product.key == value) {
                console.log('inside')
                let cart = {
                    key :this.generateUniqueId(),
                    productId: product.key,
                    ProductName : product.name,
                    productSize: product.selectedSize,
                    isSizeRequired :product.isSizeRequired,
                    NumberOfProduct : product.numberOFProductSelected,
                    singlePrice : product.price,
                    TotalPrice: parseFloat(product.numberOFProductSelected) * parseFloat(product.price)
                };
            

                this.Carts.push(cart);
                console.log(this.Carts)
                product.selectedSize = '';
                product.numberOFProductSelected = 1;
                this.template.querySelectorAll(`[data-productSize="${value}"]`).forEach(element => {
                    element.classList.remove('slds-button_outline-brand')
                });
                this.showHtmlMessage('Add To Cart', 'Product Added To Cart....', 'success');
                console.log('addToCart')
            }
        })
        this.totalCartPrice();
    }

    removeCart(event) {
        let value = event.currentTarget.dataset.value;
        this.Carts = this.Carts.filter(cart => {
            if (cart.key != value) {
                return cart;
            }
        })
        this.showHtmlMessage('Remove Cart', 'Product Removed From Cart....', 'error');
        this.totalCartPrice();

    }

    totalCartPrice() {
        this.TotalCartPrice = 0;
        this.Carts.forEach(cart => {
            this.TotalCartPrice = this.TotalCartPrice +  cart.TotalPrice
        })
    }

    generateUniqueId() {
        return Math.floor(Math.random() * Math.floor(Math.random() * Date.now()));
    }

    openSizeChart(event) {
        let value = event.currentTarget.dataset.value;
        console.log(value);
        this.Products.forEach(product => {
            console.log(product.isSizeChart)
            console.log(product.sizeChart)
            if (product.key == value && product.isSizeChart) {
               this.isOpenSizeChart = true;
               this.sizeChartImage = product.sizeChart;
            }
        })
    }
    closeSizeChart(event) {
        this.isOpenSizeChart = false;
        this.sizeChartImage = '';
    }

    cashOnDelivery(event) {
        let OrderPlaced = this.createOrder();
        let orderString = JSON.stringify(OrderPlaced);
        placeOrder({ CenterId: this.CenterId, orderString: orderString})
            .then((response) => {
                console.log(response)
                if (response != null) {
                    if (response == 'order created') {
                        console.log('order created')
                        this.showHtmlMessage('Order', 'Order Placed....', 'success');
                        this.Carts = [];
                        this.allowProceed = false;
                        this.template.querySelector('.checkboxSelected').checked = false;

                    }
                }
            })
            .catch((error) => {
                console.log(error);
                this.showHtmlMessage('Error', error.body.message, 'error');
            });
    }

    onlinePayment(event) {
        let OrderPlaced = this.createOrder();
        console.log(OrderPlaced);
        let orderString = JSON.stringify(OrderPlaced);
        placeOrder({ CenterId: this.CenterId, orderString: orderString})
            .then((response) => {
                console.log(response)
                if (response != null) {
                    if (response == 'order created') {
                        console.log('order created')
                        this.showHtmlMessage('Order', 'Order Placed....', 'success');
                        this.Carts = [];
                        this.allowProceed = false;
                        this.template.querySelector('.checkboxSelected').checked = false;
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__webPage',
                            attributes: {
                                url: ''
                            }
                        }).then(url => {
                            console.log(url)
                            // window.open("/apex/StudentInterviewRating", "_self");
                            window.open(siteUrl + 'nmAdditonalCharge?aepCenId=' + this.CenterId + '&random=' + Math.random(), "_self");
                        });

                    }
                }
            })
            .catch((error) => {
                console.log(error);
                this.showHtmlMessage('Error', error.body.message, 'error');
            });
    }


    createOrder() {
        let OrderPlaced = [];
        this.Carts.forEach(cart => {
            let order = {};
            order.ProductName = cart.ProductName;
            order.ProductId = cart.productId;
            if (cart.isSizeRequired) {
                console.log('is Size required')
                order.selectedSize = cart.productSize;
            }
            order.NumberOfProduct = cart.NumberOfProduct;
            // order.singlePrice = cart.singlePrice;
            order.TotalPrice = cart.TotalPrice;
            OrderPlaced.push(order);
        })
        let total = {
            TotalCartPrice: this.TotalCartPrice
        }
        OrderPlaced.push(total);
        return OrderPlaced;
    }


    renderedCallback() {
        if (this.Products.length > 0) {
            this.Products.forEach(product => {
                if (product.isSizeRequired) {
                    product.isAddToCartButtonActivate = product.selectedSize ? true : false;
                }
                let cardButton = this.template.querySelector(`[data-cartbutton="${product.key}"]`);
                if(cardButton) {
                    cardButton.removeAttribute('disabled')
                    if (product.isAddToCartButtonActivate) {
                        cardButton.removeAttribute('disabled')
                    } else {
                        cardButton.setAttribute('disabled', '')
                    }
                }
                let minusButton = this.template.querySelector(`[data-minbutton="${product.key}"]`);
                if (minusButton) {
                    minusButton.removeAttribute('disabled')
                    if (product.numberOFProductSelected > 1) {
                        minusButton.removeAttribute('disabled');
                        minusButton.classList.remove('disable-add-button');
                    } else {
                        minusButton.setAttribute('disabled', '');
                        minusButton.classList.add('disable-add-button');
                    }
                }
    
            })
        }

        if(this.Carts.length > 0) {
            this.Carts.forEach(cart => {
                let minusButton = this.template.querySelector(`[data-mincardbutton="${cart.key}"]`);
                minusButton.removeAttribute('disabled')
                if (cart.NumberOfProduct > 1) {
                    minusButton.removeAttribute('disabled');
                    minusButton.classList.remove('disable-add-button');
                } else {
                    minusButton.setAttribute('disabled', '');
                    minusButton.classList.add('disable-add-button');
                }
            })
        }

        
    }



    showHtmlMessage(title, message, variant) {
        this.showPopup.title = title;
        this.showPopup.message = message;
        this.showPopup.variant = variant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}