import { LightningElement, track, api, wire } from "lwc";
import uploadFile from "@salesforce/apex/lightningButtonController.uploadFile";
import getAEPRequestDetails from "@salesforce/apex/lightningButtonController.getAEPRequestDetails";
import updateAEPRequest from "@salesforce/apex/lightningButtonController.updateAEPRequest";
import ContactMobile from "@salesforce/schema/Case.ContactMobile";

export default class UploadDocumentForAEPRequest extends LightningElement {
  @track showPopup = { title: "", message: "", variant: "" };
  @api parameters;
  @api recordId;
  fileData;
  objAEPRequest = {};
  formatAccepted;
  formatTest;

  get acceptedFormats() {
    return ['.pdf', '.png'];
  }


  connectedCallback() {
    console.log("dsf");
    if (this.parameters) {
      console.dir(this.parameters);
    }
    if (Object.prototype.hasOwnProperty.call(this.parameters, "id")) {
      this.recordId = this.parameters.id;
    }
    this.formatAccepted = ["pdf", "png", "jpg", "jpeg", "zip"];
  }

  @wire(getAEPRequestDetails, { aepRequestID: "$recordId" })
  getAEPRequestDetails({ error, data }) {
    console.log("enter for get course details " + this.recordId);
    if (data) {
      console.log(JSON.stringify(data));
      this.objAEPRequest = data[0];
    } else if (error) {
      console.error(error);
      this.showHtmlMessage("Something went wrong.", error, "error");
      // this.checkData = false;
    }
  }

  handleUploadFinished(event) {
    const file = event.target.files[0];
    const size = (file.size / 1024 / 1024).toFixed(2); // in MB
    const fileformat = file.name.split(".");
    console.log(size)
    
    this.formatTest = this.formatAccepted.includes(fileformat[fileformat.length - 1]);
    if (size <= 3 && this.formatTest) {
      console.log(file);
      var reader = new FileReader();
      reader.onload = () => {
        var base64 = reader.result.split(",")[1];
        this.fileData = {
          filename: file.name,
          base64: base64,
          size: file.size
        };
        console.log(this.fileData);
      };
      reader.readAsDataURL(file);
    } else if (size > 3) {
      this.showHtmlMessage('Invalid File.', 'File size exceeds 3 MB', 'warning');
      event.target.files = null;
    } else {
      this.showHtmlMessage('Invalid File.', 'File format should be in "pdf", "png", "jpg", "jpeg", "zip"', 'warning');
      event.target.files = null;

    }
  }

  onSubmit() {
    console.log('dfsf');
    const { base64, filename, size } = this.fileData;
    uploadFile({ base64, filename }).then((result) => {
      if (result) {
        this.fileData = null;
        console.log(result);
        this.uploadDocumentLink(result);
      } else {
        this.showHtmlMessage("Something went wrong.", "File cannot be uploaded", "error");
      }
    });
  }

  uploadDocumentLink(fileURL) {
    console.log(fileURL);
    updateAEPRequest({ aepRequestId: this.recordId, documentLink: fileURL })
      .then((response) => {
        if (response != null) {
          this.showHtmlMessage("Success!", "Invoice Document updated successfully", "success");
        }
      })
      .catch((error) => {
        console.log(error);
        this.showHtmlMessage("Something went wrong.", error, "error");
      });
  }

  showHtmlMessage(title, message, variant) {
    this.showPopup.title = title;
    this.showPopup.message = message;
    this.showPopup.variant = variant;
    this.template.querySelector("c-lwc-custom-toast").showCustomNotice();
  }
}