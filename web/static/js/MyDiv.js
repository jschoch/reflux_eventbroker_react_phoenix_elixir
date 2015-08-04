//import React from "bower_components/react/react";
//import Reflux from "bower_components/reflux/dist/reflux";
import BtnA from "./components/BtnA"
import BtnB from "./components/BtnB"
import Actions from "./Actions"
import TheStore from "./stores/TheStore"


export default React.createClass({
    //mixins: [Reflux.connect(TheStore)],
    render(){
        return (
            <div> This holds our buttons! <br />
                <BtnA />  <BtnB />
            </div>
        )
    }
})
