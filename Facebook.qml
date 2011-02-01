/////////////////////////////////////////////////////////////////////////////////
//
//	QMLFB version 0.1b by Jesse Ikonen
//  =======================================*
//
//	Simple QML Component that authenticates your users using Facebook Graph.
//
/////////////////////////////////////////////////////////////////////////////////
import Qt 4.7
import QtWebKit 2.1
import "helpers.js" as Helpers

WebView {
    id: fbAuth
    url: fb_app_id && !fb_app_id.match("<YOUR FACEBOOK APP ID>") ? fb_authentication_url : ""
    anchors.fill: parent
    settings.javascriptEnabled: false //false
    property string fb_display: facebook_display_style // "wap" OR "touch"
    property string fb_app_id: facebook_application_id
    property string fb_redirect_url: "http://www.facebook.com/connect/login_success.html"
    property string fb_response_type: "token"
    property string fb_scope: "user_about_me"
    property string fb_authentication_url: "https://www.facebook.com/dialog/oauth?client_id="+fb_app_id+"&redirect_uri="+fb_redirect_url+"&display="+fb_display+"&response_type="+fb_response_type+"&scope="+fb_scope
    property string fb_logout_url: "https://api.facebook.com/restserver.php?access_token="+main.user_facebook_token+"&method=auth.expireSession&format=json"
    property string user_facebook_id: ""
    property string user_facebook_token: ""
    property variant me: ""
    property string my_pic_url: ""
    property bool user_is_authenticated: false

    // functions

    // saves fb token and fb user id
    function loginObserver(){
        var token_re            = "access_token=(.*)&expires_in=", // token
            id_re               = "-([0-9]*)", // fuid
            login_success_re    = "^http://www.facebook.com/connect/login_success.html", // to test login_success page
            matchable           = url.toString(), // url string
            fb_token            = undefined,
            fb_uid              = undefined;

        if ( matchable.match(login_success_re) && /access_token/.test(matchable) ) { // if page is login_success and contains access_token
            fb_token    = matchable.match(token_re)[1].replace(/\\u00257C/g, "|"); // replace unicode if found (if js redirect is followed it will be found)
            fb_uid      = fb_token.match(id_re)[1];
        } else if (matchable.match(login_success_re) && /error/.test(matchable)){ // if user does not allow
            settings.javascriptEnabled = false;
            url = fb_authentication_url // ask again :)
            return false
        } else {
            return false
        }

        if (fb_uid && fb_token) { // when we have token and user id
            user_facebook_id = fb_uid; // save id
            user_facebook_token = fb_token; // save token
            user_is_authenticated = true; // set booolean
            my_graph(function(){me = this});
            set_my_pic();
            whenUserIsAuthenticated(user_facebook_id, user_facebook_token);
            return true
        }
    }

    function whenUserIsAuthenticated(user_id, user_token){
        console.log("User authenticated and received token: "+user_facebook_token);
        console.log("User FB id is: "+user_facebook_id);
        console.log("Remember to override Facebook.whenUserIsAuthenticated(userid, usertoken) function.")
    }

    // some graph stuff

    function my_graph(callback){
        Helpers.getJSON("https://graph.facebook.com/"+user_facebook_id+"?access_token="+user_facebook_token, callback)
    }

    function set_my_pic(opts){
        var opts = opts || {}
        var size = opts.size || "large"
        my_pic_url = "https://graph.facebook.com/"+user_facebook_id+"/picture?type="+size
    }

    // signal handlers


    onUrlChanged: {
        if ( /login.php/.test(url.toString()) ) { // enable JS on login page
            settings.javascriptEnabled = true
        } else {
            settings.javascriptEnabled = false
        }
    }

    onLoadFinished: {
        loginObserver();
        // this allows us to follow jasvascript redirects even though js is turned off (this is required as long as FB gets their shit together)
        if (html.match('<html><head><script type="text/javascript">')) {
            var target_arr = html.match(/window\.location\.href="(.*)"/)
            if (target_arr){
                var crappy_target_url = target_arr[1] // formatting is: http:\/\/www.facebook.com\/
                var actual_target_url = crappy_target_url.replace(/\\\//g, "/").replace("\u00257C", "|")  // fix formatting
                url = actual_target_url // and go there.
            }
        }
    }


}


