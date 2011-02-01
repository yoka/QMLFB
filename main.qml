import Qt 4.7
import QtWebKit 2.1

Rectangle {
    id: main
    width: 320
    height: 480

    property string fbid: facebook.user_facebook_id
    property string fbtoken: facebook.user_facebook_token
    property bool logged_in: facebook.user_is_authenticated
    property string name: ""

    Flipable {
        id: container
        height: main.height;
        width: parent.width;
        property int angle: 0
        property bool flipped: !main.logged_in

        // FRONT SIDE HAS SOME APPLICATION
        front:  Rectangle {
            id: basic_view
            anchors.fill: parent

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SHOW ME MY FACE APP"
                font.pixelSize: 25
            }

            Image {
                id: my_picture
                source: facebook.my_pic_url
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: my_name
                anchors.verticalCenter: my_picture.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: facebook.me.name
                color: "silver"
                font.pixelSize: 18
            }
        }

        // BACK SIDE HAS THAT FACEBOOK LOGIN
        back:  Rectangle {
                height: main.height;
                width: main.width;

                Facebook {
                    id: facebook
                    property string facebook_display_style: "touch" // or "wap"
                    property string facebook_application_id: "<YOUR FACEBOOK APP ID>"

                    function whenUserIsAuthenticated(userid, usertoken){
                        console.log("do something if u want to.");
                    }
                }
        }

        transform: Rotation {
            origin.x: container.width/2; origin.y: container.height/2
            axis.x: 0; axis.y: 1; axis.z: 0 // rotate around y-axis
            angle: container.angle
        }


        states: State {
            name: "back"
            PropertyChanges { target: container; angle: 180 }
            when: container.flipped
        }

        transitions: Transition {
            NumberAnimation { properties: "angle"; duration: 500 }
        }


    }

}
