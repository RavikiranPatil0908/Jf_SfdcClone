({
   
    onChatEnded: function(cmp, evt, helper) {
       
        /*let conversation = cmp.find( "conversationKit" );
        let recordId = evt.getParam( "recordId" );
        console.log( "recordId:" + recordId );*/
        let notificationSound = new Audio($A.get('$Resource.ChatDisconnected'));   
        notificationSound.play();   
        console.log('beep');
    }
   
})