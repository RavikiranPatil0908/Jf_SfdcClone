import { LightningElement, track } from 'lwc';
import { formatDate } from 'c/formatedDate';

export default class ChatBotComp extends LightningElement {

    program;
    isSubmit = false;
    agentTyping = false;
    @track messagelist;

    connectedCallback() {
        // Set welcome message
        this.setWelcomeMsg();
    }

    renderedCallback() {
        this.scrollToBottom();
    }

    get textareaClass() {
        let styleClass = 'chasitorText textarea uiInput uiInputTextArea uiInput--default uiInput--textarea textarea-font-style';
        let classes = this.agentTyping ? `${styleClass} isDisabled` : styleClass;
        return classes;
    }

    get options() {
        return [
            { label: 'MBAX', value: 'MBAX' },
            { label: 'MBA (WX)', value: 'MBAWX' },
            { label: 'M.Sc. (AI & ML Ops)', value: 'M.Sc. (AI & ML Ops)' },
            { label: 'PG / Certificate / Diploma / MSc AF', value: 'PG / Certificate / Diploma / MSc AF' },
            { label: 'PD-DM', value: 'PD-DM' },
            { label: 'MBA (D) / Certificate / Diploma', value: 'MBA (D) / Certificate / Diploma' },
            { label: 'PDWM', value: 'PDWM' },
            { label: 'Bachelors', value: 'Bachelors' },
            { label: 'Professional', value: 'Professional' },
            { label: 'Modular PDDM', value: 'Modular PDDM' }
        ];
    }

    async getBotResponse(query) {
        console.log(query);
        this.agentTyping = true;
        this.messagelist.push(this.setMessage('bot', 'typing'));
        let indexVal = this.messagelist.length - 1;
        const calloutURI = 'https://ngasce-content.nmims.edu/ml-student-support/response';
        const payload = {
            query: query,
            subject: this.program
        };
        try {
            await fetch(calloutURI, {
                method: "POST",
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            })
            .then((response) => response.json())
            .then(data => {
                console.log(data);
                this.agentTyping = false;
                this.messagelist[indexVal].message = data.response;
                this.messagelist[indexVal].isTyping = false;
                this.messagelist[indexVal].time = formatDate(new Date(),'h:mm TT','');
            });
        } catch (error) {
            console.log(error);
            this.agentTyping = false;
            this.messagelist.push(this.setMessage('bot', 'Something went wrong, try again later'));
        }
        
    }

    setMessage(userType, msg) {
        let botStyle2 = 'plaintextContent agent embeddedServiceLiveAgentStateChatPlaintextMessageDefaultUI';
        let userStyle2 = 'plaintextContent chasitor embeddedServiceLiveAgentStateChatPlaintextMessageDefaultUI';
        return {
            isBot: userType === 'bot' ? true : false,
            user: userType === 'bot' ? 'Bot' : 'User',
            contentStyle: userType === 'bot' ? botStyle2 : userStyle2,
            message: msg,
            isTyping: msg === 'typing' ? true : false,
            time: formatDate(new Date(),'h:mm TT',''),
            index: this.messagelist.length === 0 ? 0 : this.messagelist.length + 1,
        };
    }

    handleEnter(event) {
        if(event.keyCode === 13){
            console.log('event.target.value ==>'+event.target.value);
            this.messagelist.push(this.setMessage('user', event.target.value));
            if(event.target.value.length >= 8) {
                this.getBotResponse(event.target.value);
            } else {
                let msg = 'Your question seems a bit short. Could you please provide a bit more detail or describe your question in a little more detail? This will help me understand your query better and provide you with a more accurate response. Thank you!';
                this.messagelist.push(this.setMessage('bot', msg));
            }
            event.target.value = '';
            event.preventDefault();
        }
    }

    handleChange(event) {
        this.program = event.detail.value;
    }

    onSubmit() {
        if(this.program) {
            this.isSubmit = true;
            this.setWelcomeMsg();
        }
    }

    handleClick() {
        this.program = null;
        this.isSubmit = false;
    }

    scrollToBottom() {
        console.log('called');
        if(this.refs.messageArea) {
            this.isScrollUp = false;
            this.refs.messageArea.scrollTo({ left: 0, top: this.refs.messageArea.scrollHeight, behavior: "smooth" });
            console.log('Current value of the input Top: ' + this.refs.messageArea.scrollTop);
            console.log('Current value of the offsetHeight: ' + this.refs.messageArea.offsetHeight);
            console.log('Current value of the height: ' + this.refs.messageArea.scrollHeight);
        }
    }

    setWelcomeMsg() {
        this.messagelist = [];
        let welcomeMsg = `Hi! I am, your virtual assitant.`;
        this.messagelist.push(this.setMessage('bot',welcomeMsg));
    }
}