import TheStore from "../stores/TheStore"


export default React.createClass({
  mixins: [Reflux.connect(TheStore)],
    getInitialState(){
        return({user_count: 0, hits: 0, users: []} )
    },
    render: function() {
        var doItem = function(item){
          return (<span> name: {item} </span>)
        }
        return (
        <div className="panel panel-default">
 <div className="panel-heading">Status: me: {this.state.me} -- hits: <span clasName="badge">{this.state.hits}</span> </div>
  <div className="panel-body">
    Current Users: {this.state.users.map(doItem)} <span className="badge">{this.state.user_count}</span> Hits: <span className="badge">{this.state.hits}</span></div>
 </div>
        );
    }
});
