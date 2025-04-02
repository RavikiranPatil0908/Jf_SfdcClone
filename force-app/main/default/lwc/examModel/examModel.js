import { LightningElement, wire, api, track } from 'lwc';
import getQuestionBanks from '@salesforce/apex/Survey.getQuestionBanks';
import createNewSurveyTaker from '@salesforce/apex/Survey.createNewSurveyTaker';
import upsertSurveyQuestionResponse from '@salesforce/apex/Survey.upsertSurveyQuestionResponse';
import submitAssessment from '@salesforce/apex/Survey.submitAssessment';

export default class ExamModel extends LightningElement {
	@api parameters;
	@api params;
	@api recordId;
	@api experience;
	@track lstQuestions = [];
	@track surveyTaker;
	@track CounselorId;
	@track counsellorName = '';
	@track timer;
	@track openPopup = false;
	@track calledSaveAndNextAfterTimerEnd = false;
	@track showPopup = { title: '', message: '', variant: '' };

	allowExam = false;
	isFormNotSubmitted = true;
	reviewExam = false;
	beginExam = false;
	currentQuestionNo;
	doNotAllowToProceed = true;
	objSurveyTaker = {};
	assessment = {};
	cpRecord = {};
	totalResponse = {
		Answered: 0,
		NotAnswered: 0,
		rightAnswered: 0,
		wrongAnswered: 0,
		totalMarks: 0,
		totalMarksObtained: 0,
		totalQuestions: 0,
		finalScore: 0
	};
	imgMProfile = 'https://www.lightningdesignsystem.com/assets/images/avatar1.jpg';
	imgFProfile = 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg';

	connectedCallback() {
		const parameter = this.getQueryParameters();
		this.CounselorId = parameter['CounselorId'];
		this.recordId = this.recordId ? this.recordId : parameter['id'];
		if(this.CounselorId && this.recordId) {
			this.allowExam = true;
		}
	}

	get isPreviousBtnDisabled() {
		return this.currentQuestionNo == 1 ? true : false; 
	}

	get getProfileImage() {
		// return this.counsellorName ? this.cpRecord.Employee_Image_URL__c : 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg';
		return this.counsellorName ? 
		(this.cpRecord.Gender__c && this.cpRecord.Gender__c=='Male' ? this.imgMProfile : this.imgFProfile) :
		this.imgFProfile;
	}

	get allowToContinue() {
		return this.timer != '00:00' ? false : true;
	}

	get checkExamSubmitted() {
		let submitted = this.objSurveyTaker.hasOwnProperty('Assessment_Submitted__c') && this.objSurveyTaker.Assessment_Submitted__c ? true : false;
		return submitted; 
	}
	
	get timeTaken() {
		let timeRemaining = this.timer ? this.timer.split(':')[0] : '0';
		timeRemaining = parseInt(timeRemaining) > 0 ? parseInt(timeRemaining) : 0;
		let timeTaken = parseInt(this.assessment['Timer__c']) - timeRemaining;
		return timeTaken;
	}

	@wire(getQuestionBanks, { surveyId: '$recordId' })
	getQuestionBanks({ error, data }) {
		if (data && Object.getOwnPropertyNames(data).length !== 0) {
			this.lstQuestions = this.processData(data);
			this.error = undefined;
		}
		else {
			this.allowExam = false;
			this.error = error;
			// alert(this.error);
			// this.showHtmlMessage('No Record Found!','error','error');
		}
	}

	getQueryParameters() {
		var params = {};
		var search = location.search.substring(1);
		if (search) {
			params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
				return key === "" ? value : decodeURIComponent(value)
			});
		}
		return params;
	}


	processData(data) {
		let options = ['Single Choice', 'Multiple Choice'];
		let listQuestions = [];
		let listSurveyResponse = [];
		this.assessment = data.objSurvey;
		this.currentQuestionNo = 1;
		createNewSurveyTaker({ SurveyId: this.recordId, CounselorId: this.CounselorId })
			.then(surveyData => {
				if (surveyData) {
					this.surveyTaker = surveyData.surveyTakerId
					listSurveyResponse = surveyData.lstSurveyQuestionResponse;
					this.counsellorName = surveyData.counselorName;
					this.cpRecord = surveyData.objAEPProfile;
					this.objSurveyTaker = surveyData.objSurveyTaker;
					let QBdata = this.randomizeQuestion(data.lstQBank);
					QBdata.forEach((element, index) => {
						let qb = {
							question: element,
							options: [],
							index: index + 1,
							show: index == 0 ? true : false,
							isRadio: element.Type__c == 'Single Choice' ? true : false,
							isCheckBox: element.Type__c == 'Multiple Choice' ? true : false,
							isDescriptive: element.Type__c == 'Descriptive' ? true : false,
							answer: '',
							selectedAnswer:'',
							surveyQuestionId: '',
							multipleChoice: [],
							selectedMultipleChoice: [],
							multipleChoiceAnswer: [],
							questionType: element.Type__c,
							status: index == 0 ? 'Not Answered' : 'Not Visited',
							statusColor: index == 0 ? 'slds-button slds-button_destructive' : 'slds-button slds-button_neutral',
							isRightAnswer: false
						};
						data.lstSurveyQuestion.forEach((surveyQuestion, index) => {
							if (surveyQuestion.Question_Bank__c == element.Id) {
								qb.surveyQuestionId = surveyQuestion.Id
							}
						})
						// split the choises..
						if (options.includes(element.Type__c)) {
							let choices = element.Choices__c.split(/\r\n|\n\r|\n|\r/);
							let options = [];
							choices.forEach(option => {
								let newOption = { label: option, value: option };
								options.push(newOption);
							});
							qb.options = options;
						}
						listQuestions.push(qb);
					});
					this.lstQuestions = this.setResponse(listSurveyResponse,listQuestions);
					this.calculateTotalResponse();
				}
			});
	}

	setResponse(listSurveyResponse,listQuestions) {
		this.totalResponse.rightAnswered = 0;
		this.totalResponse.wrongAnswered = 0;
		this.totalResponse.totalMarks = 0;
		this.totalResponse.totalMarksObtained = 0;
		this.totalResponse.totalQuestions = listQuestions.length;
		this.totalResponse.finalScore = 0;
		if (listSurveyResponse && listSurveyResponse.length > 0) {
			listQuestions.forEach(ltQuestion => {
				listSurveyResponse.forEach(lstSurvey => {
					if (lstSurvey.Survey_Question__c == ltQuestion.surveyQuestionId) {
						this.checkAnswer(ltQuestion,lstSurvey);
					}
				})
				// this.totalResponse.totalMarks = this.totalResponse.totalMarks + ltQuestion.question.Mark__c;
			})
			// this.totalResponse.finalScore = (this.totalResponse.totalMarksObtained / this.totalResponse.totalMarks) * 100;
			// this.totalResponse.finalScore = this.totalResponse.finalScore > 0 ? this.totalResponse.finalScore.toFixed(2) : this.totalResponse.finalScore;
		}
		return listQuestions;
	}

	randomizeQuestion(data) {
		data = data.slice().sort(() => Math.random() - 0.5);
		return data;
	}

	submitModal() {
		this.isFormNotSubmitted = false;
		this.openPopup = true;
		this.totalResponse.Answered = 0;
		this.totalResponse.totalMarks = 0;
		this.totalResponse.NotAnswered = 0;
		this.totalResponse.totalQuestions = this.lstQuestions.length;
		this.totalResponse.finalScore = 0;
		// this.lstQuestions.forEach(element => {
		// 	if(element.status == 'Answered') {
		// 		++this.totalResponse.Answered;
		// 	} else {
		// 		++this.totalResponse.NotAnswered;
		// 	}
		// 	this.totalResponse.totalMarks = this.totalResponse.totalMarks + element.question.Mark__c;
		// });
		// this.totalResponse.finalScore = (this.totalResponse.totalMarksObtained / this.totalResponse.totalMarks) * 100;
		// this.totalResponse.finalScore = this.totalResponse.finalScore > 0 ? this.totalResponse.finalScore.toFixed(2) : this.totalResponse.finalScore;
		this.calculateTotalResponse();
	}

	onPaletteClick(event) {
		let index = event.target.dataset.index;
		this.currentQuestionNo = parseInt(index);
		this.lstQuestions.forEach(element => {
			element.show = index == element.index ? true : false;
			element = this.setPaletteStatus(element);
		});

	}

	setPaletteStatus(element) {
		if(element.show && !element.SurveyQuestionResponseId && element.status != 'Marked') {
			element.status = 'Not Answered';
			element.statusColor = 'slds-button slds-button_destructive';
		} else if(element.SurveyQuestionResponseId) {
			element.status = 'Answered';
			element.statusColor = 'slds-button slds-button_success';
		} else if(!element.SurveyQuestionResponseId && element.status == 'Marked') {
			element.statusColor = 'slds-button slds-button_destructive slds-button_marked';
		} else {
			element.status = 'Not Visited';
			element.statusColor = 'slds-button slds-button_neutral';
		}
		return element;
	}

	startTimer() {
		let newTime = 0;
		let examTime = this.assessment['Timer__c'] ? parseInt(this.assessment['Timer__c']) : 40;
		if(this.objSurveyTaker.hasOwnProperty('Time_Taken__c') && this.objSurveyTaker.Time_Taken__c > 0) {
			let timeTaken = this.objSurveyTaker.Time_Taken__c;
			newTime = parseInt(examTime) - parseInt(timeTaken);
		}
		let duration = newTime > 0  ? newTime * 60 : examTime * 60;
		let timer = duration, minutes, seconds;
		let interval = setInterval(() => {
			minutes = parseInt(timer / 60, 10);
			seconds = parseInt(timer % 60, 10);
			minutes = minutes < 10 ? "0" + minutes : minutes;
			seconds = seconds < 10 ? "0" + seconds : seconds;
			this.timer = minutes + ":" + seconds
			if (--timer < 0) {
				this.calledFromTimer();
				clearInterval(interval);
			} 
			else if(this.timer === '10:00') {
				this.showHtmlMessage(`Less than ${this.timer} minutes left.`,'warning','warning');
			}
		}, 1000);
	}

	calledFromTimer() {
		if (!this.calledSaveAndNextAfterTimerEnd) {
			this.calledSaveAndNextAfterTimerEnd = true;
			this.onSaveAndNextClick();
		}
	}


	onSaveAndNextClick() {
		let index = this.currentQuestionNo - 1;
		let surveyQuestionResponse = {
			Answer__c: '',
			Id: null
		}
		let answerOfQuestion = '';
		this.lstQuestions[index].answer = this.lstQuestions[index].selectedAnswer;
		this.lstQuestions[index].multipleChoice = this.lstQuestions[index].selectedMultipleChoice;
		answerOfQuestion = this.lstQuestions[index].answer;
		let surveyQuestionId = this.lstQuestions[index].surveyQuestionId;
		let SurveyQuestionResponseId = this.lstQuestions[index].SurveyQuestionResponseId;
		surveyQuestionResponse.Survey_Question__c = surveyQuestionId;
		surveyQuestionResponse.SurveyTaker__c = this.surveyTaker;
		surveyQuestionResponse.Id = SurveyQuestionResponseId;
		surveyQuestionResponse.Answer__c = answerOfQuestion;
		if (surveyQuestionResponse.Survey_Question__c && surveyQuestionResponse.SurveyTaker__c && surveyQuestionResponse.Answer__c) {
			upsertSurveyQuestionResponse({ objSurveyQuestionResponse: surveyQuestionResponse, timeTaken: this.timeTaken })
				.then((result) => {
					this.lstQuestions[index].SurveyQuestionResponseId = result.Id;
					++this.currentQuestionNo;
					this.checkAnswer(this.lstQuestions[index],result);
					this.calculateTotalResponse();
					if(this.calledSaveAndNextAfterTimerEnd) {
						this.SubmitExamAssessment();
						return;
					}
					if(this.currentQuestionNo > this.lstQuestions.length) {
						this.currentQuestionNo = 1;
					}
					this.lstQuestions.forEach(element => {
						element.show = this.currentQuestionNo == element.index ? true : false;
						element = this.setPaletteStatus(element);
					});
				})
		} else if(this.calledSaveAndNextAfterTimerEnd) {
			this.SubmitExamAssessment();
			return;
		}
	}

	SubmitExamAssessment() {
		this.objSurveyTaker['TotalMarksObtain__c'] = this.totalResponse.totalMarksObtained;
		this.objSurveyTaker['Time_Taken__c'] = this.timeTaken;
		this.objSurveyTaker['Total_Marks__c'] = this.totalResponse.totalMarks;
		submitAssessment({ objSurveyTaker: this.objSurveyTaker})
		.then((result) => { 
			if(result) {
				this.objSurveyTaker = result;
				this.submitModal();
			}
		})
	}

	checkAnswer(question,response) {
		// this.totalResponse.totalMarks = this.totalResponse.totalMarks + question.question.Mark__c;
		question.answer = response.Answer__c ? response.Answer__c.trim() : response.Answer__c;
		if(question.questionType != 'Multiple Choice') {
			if(question.question.Answer__c === response.Answer__c) {
				question.isRightAnswer = true;
				// this.totalResponse.totalMarksObtained = this.totalResponse.totalMarksObtained + question.question.Mark__c;
				// ++this.totalResponse.rightAnswered;
			} else {
				question.isRightAnswer = false;
				// ++this.totalResponse.wrongAnswered;
			}
		} else if (question.questionType == 'Multiple Choice') {
			question.multipleChoice = response.Answer__c.split(';');
			question.multipleChoiceAnswer = question.question.Answer__c.split(';');
			let is_equal = question.multipleChoice.length==question.multipleChoiceAnswer.length && question.multipleChoice.every(function(v,i) { return (question.multipleChoiceAnswer.includes(v))});
			if(is_equal) {
				question.isRightAnswer = true;
				// this.totalResponse.totalMarksObtained = this.totalResponse.totalMarksObtained + question.question.Mark__c;
				// ++this.totalResponse.rightAnswered;
			} else {
				question.isRightAnswer = false;
				// ++this.totalResponse.wrongAnswered;
			}
		}
		question.SurveyQuestionResponseId = response.Id;
		question = this.setPaletteStatus(question);
		return question;
	}

	calculateTotalResponse() {
		console.log('Called --> calculateTotalResponse')
		let rightAnswered = 0;
		let wrongAnswered = 0;
		let Answered = 0;
		let NotAnswered = 0;
		let totalMarksObtained = 0;
		let totalMarks = 0;
		if (this.lstQuestions.length > 0) {
			this.lstQuestions.forEach(question => {
				totalMarks += question.question.Mark__c;
				if (question.isRightAnswer) {
					++rightAnswered;
					totalMarksObtained += question.question.Mark__c;
				} else {
					++wrongAnswered;
				}
				if(question.status == 'Answered') {
					++Answered;
				} else {
					++NotAnswered;
				}
				
			});
			this.totalResponse.Answered = Answered;
			this.totalResponse.NotAnswered = NotAnswered;
			this.totalResponse.rightAnswered = rightAnswered;
			this.totalResponse.wrongAnswered = wrongAnswered;
			this.totalResponse.totalMarksObtained = totalMarksObtained;	
			this.totalResponse.totalMarks = totalMarks;	
			this.totalResponse.finalScore = (this.totalResponse.totalMarksObtained / this.totalResponse.totalMarks) * 100;
			this.totalResponse.finalScore = this.totalResponse.finalScore > 0 ? this.totalResponse.finalScore.toFixed(2) : this.totalResponse.finalScore;
			console.log(JSON.stringify(this.totalResponse), 'this.totalResponse');
		}
	}

	onPreviousClick() {
		--this.currentQuestionNo;
		this.lstQuestions.forEach(element => {
			element.show = this.currentQuestionNo == element.index ? true : false;
			element = this.setPaletteStatus(element);
		});
	}

	onNextClick() {
		this.lstQuestions[this.currentQuestionNo-1].status = 'Marked';
		this.currentQuestionNo = this.currentQuestionNo == this.lstQuestions.length ? 1 : this.currentQuestionNo + 1;
		this.lstQuestions.forEach(element => {
			element.show = this.currentQuestionNo == element.index ? true : false;
			element = this.setPaletteStatus(element);
		});
	}

	onRadioButtonChange(event) {
		const selectedOption = event.detail.value;
		this.lstQuestions.forEach(element => {
			if (this.currentQuestionNo == element.index) {
				// element.answer = selectedOption;
				element.selectedAnswer = selectedOption;
			}
		})
	}

	onDescriptiveChange(event) {
		const descriptive = event.detail.value;
		this.lstQuestions.forEach(element => {
			if (this.currentQuestionNo == element.index) {
				// element.answer = descriptive;
				element.selectedAnswer = descriptive;
			}
		})
	}

	onMultipleChange(event) {
		const multipleChoice = event.detail.value;
		let arrayOfMultipleChoice = [];
		multipleChoice.forEach(el => {
			arrayOfMultipleChoice.push(el)
		})

		this.lstQuestions.forEach(element => {
			if (this.currentQuestionNo == element.index) {
				// element.answer = arrayOfMultipleChoice.join(';');
				// element.multipleChoice = arrayOfMultipleChoice;
				element.selectedAnswer = arrayOfMultipleChoice.join(';');
				element.selectedMultipleChoice = arrayOfMultipleChoice;
			}
		})
	}

	handleChange(event) {
		if(event.target.name === 'undertakingForLicense'){
            if(event.target.checked) {
                this.doNotAllowToProceed = false;
            } else {
                this.doNotAllowToProceed = true;
            }
        }
	}

	handleClick(event) {
		let name = event.target.dataset.name;
		if(name === 'proceedToExam') {
			if(this.checkExamSubmitted) {
				this.submitModal();
			} else {
				this.beginExam = true;
				this.startTimer();
			}
		} else if(name === 'submit') {
			this.SubmitExamAssessment();
		} else if(name === 'review') {
			this.reviewExam = true;
			this.openPopup = false;
		} else if(name === 'cancel') {
			this.openPopup = false;
			this.isFormNotSubmitted = true;
		}
	}

	// To show Toast message
	showHtmlMessage(title, message, variant) {
		this.showPopup.title = title;
		this.showPopup.message = message;
		this.showPopup.variant = variant;
		this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
	}
}