import Actions from "../Actions"
import TheStore from "../stores/TheStore"

export default React.createClass({
    mixins: [Reflux.connect(TheStore)],
    getInitialState(){
        return {"name":"btnb"};
    },
    handleClick(){
        console.log(this.state.name,"clicked",this.state.test);
        Actions.swap(this.state.test)
    },
    render(){
        return (
            <button onClick={this.handleClick}> This is BtnB </button>
        )
    }
})
