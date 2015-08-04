import {Socket} from "phoenix"
//import Reflux from "bower_components/reflux/dist/reflux"
//import React from "bower_components/react/react";
import MyDiv from "./MyDiv";

React.render(
  <MyDiv />,
  document.getElementById("mydiv")
);

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", resp => {
//   console.log("Joined succesffuly!", resp)
// })

let App = {
}

export default App
