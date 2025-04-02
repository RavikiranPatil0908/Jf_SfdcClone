import { LightningElement } from 'lwc';

export default class DemoLifeCycleHooks extends LightningElement {

 constructor(){
    super();
    console.log('constructor is called');
    this.message='This is a demo message When Constuctor is called';
 }

 connectedCallback(){
    console.log('connectedCallback is called');
    this.message='This is a demo message When connectedCallback is called';
 }

 renderedCallback(){
    console.log('renderedCallback is called');
    this.message='This is a demo message When renderedCallback is called';
 }

 disconnectedCallback(){
    console.log('disconnectedcallback is called');
    this.message='This is a demo message When disconnectedCallback is called';
}

}