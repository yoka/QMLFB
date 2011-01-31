/*
/   qmlFBAuth Example by Jesse Ikonen 2011
/   MIT license or something like that. Send me money if this helps.
*/


import Qt 4.7
import QtWebKit 2.1

Rectangle {
    id: main
    width: 320
    height: 480
    property string userid: ""
    property string usertoken: ""

    WebView {
        id: fbAuth
        preferredWidth: parent.width
        preferredHeight: parent.height
        property string fb_display: "wap"
        property string fb_app_id: "<YOUR FB APP ID HERE>"
        property string fb_redirect_url: "http://www.facebook.com/connect/login_success.html"
        property string fb_response_type: "code_and_token"
        property string fb_authentication_url: "https://www.facebook.com/dialog/oauth?client_id="+fb_app_id+"&redirect_uri="+fb_redirect_url+"&display="+fb_display+"&response_type="+fb_response_type

        url: ""
        function urlObserver(){
            var matchable = url.toString();
            console.log(matchable);
            if (/access_token/.test(matchable)) {
                main.userid = matchable.match(/access_token=(.*)&expires_in=/)[1];
                main.usertoken = matchable.match(/-(\d*)\|/)[1];
                console.log("Your FB token is: "+main.usertoken);
                console.log("Your FB id is: "+main.userid);
            } else if (!/fb_authentication_url/.test(matchable)){
                url = fb_authentication_url;
            }
        }

        onUrlChanged: { urlObserver() }
        Component.onCompleted: { url = fb_authentication_url }

    }
}
