import Actions from "../Actions"
import TheStore from "../stores/TheStore"

export default React.createClass({
    mixins: [Reflux.connect(TheStore)],
    getInitialState(){
        return {"name":"BtnA"};
    },
    handleClick(){
      console.log(this.state.name,"clicked",this.state.test);
      Actions.swap(this.state.test)
      Actions.hit();
    },
    render(){
        return (
            <button className="btn btn-danger" onClick={this.handleClick}> This is {this.state.name}: val: {this.state.test.toString()} </button>
        )
    }
})
