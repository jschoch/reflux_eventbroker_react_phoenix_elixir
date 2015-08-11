//import Reflux from "bower_components/reflux/dist/reflux";
import Actions from "../Actions";
  

export default Reflux.createStore({
  listenables: Actions,

  init() {
    this.test = true;
    //this.socket = new Phoenix.Socket("/socket",{user: "me",pass: "the magic word"});
    this.socket = new Phoenix.Socket("/status",{logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }})
    var r = Math.floor((Math.random() * 1000) + 1);
    this.auth = {user: "me"+r,pass: "the magic word"}
    this.socket.connect(this.auth)
    this.socket.onOpen(this.onOpen)
    this.socket.onError(this.onError)
    this.socket.onClose(this.onClose)
    this.user_chan = this.socket.channel("all")
    console.log("chan", this.user_chan)
    this.user_chan.on("status_users",data => {
      console.log("chan on hook",data);
      this.onUpdate(data)
    })
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
  onOpen(thing){
    console.log("onOpen",thing, this)
  },
  onClose(){
    console.log("onClose")
  },
  onError(){
    console.log("onError") 
  },
  onUpdate(update){
    console.log("update",update);
    console.log("this",this);
    this.trigger(update)
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
