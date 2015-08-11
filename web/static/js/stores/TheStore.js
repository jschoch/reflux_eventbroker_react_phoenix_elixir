//import Reflux from "bower_components/reflux/dist/reflux";
import Actions from "../Actions";

export default Reflux.createStore({
  listenables: Actions,

  init() {
    this.test = true;
    //this.socket = new Phoenix.Socket("/socket",{user: "me",pass: "the magic word"});
    this.socket = new Phoenix.Socket("/status")
    this.auth = {user: "me",pass: "the magic word"}
    this.socket.connect(this.auth)
    this.socket.onOpen(this.onOpen)
    this.socket.onError(this.onError)
    this.socket.onClose(this.onClose)
    this.user_chan = this.socket.channel("all")
    console.log("chan", this.user_chan)
    this.user_chan.join(this.auth).receive("ok", chan => {
      console.log("joined")
     })
     .receive("error", chan => {
        console.log("error",chan);
    })
  },
  getInitialState(){
    return this;
  },
  onOpen(){
    console.log("onOpen")
  },
  onClose(){
    console.log("onClose")
  },
  onError(){
    console.log("onError") 
  },
  onLogin(username){
    // login and setup listeners
    //var chan = this.socket.channel("all",{})
    //chan.on("status_user", data => {
      //console.log("event",data);
    //});
  },
  onSwap(x){
    console.log("switch triggered in: ",x)
    console.log("TheStore test is",this.test)
    this.trigger({test: !x})
  }
})
