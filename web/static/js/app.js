import {Socket} from "phoenix"
import MyDiv from "./MyDiv";

React.render(
  <MyDiv />,
  document.getElementById("mydiv")
);

let socket = new Socket("/socket")
socket.connect()
let chan = socket.channel("rooms:lobby", {})
chan.join().receive("ok", chan => {
  console.log("Welcome to Phoenix Chat!")
})

let App = {
}

export default App
