//import Reflux from "bower_components/reflux/dist/reflux";
import Actions from "../Actions";

export default Reflux.createStore({
  listenables: Actions,

  init() {
    this.test = true;
  },
  getInitialState(){
    return this;
  },
  onSwap(x){
    console.log("switch triggered in: ",x)
    console.log("TheStore test is",this.test)
    this.trigger({test: !x})
  }
})
