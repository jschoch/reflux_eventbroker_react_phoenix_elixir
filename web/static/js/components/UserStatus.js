import TheStore from "../stores/TheStore"


export default React.createClass({
  mixins: [Reflux.connect(TheStore)],
    getInitialState(){
        return({user_count: 0, hits: 0, users: []} )
    },
    render: function() {
        return (
        <div className="panel panel-default">
 <div className="panel-heading">Status</div>
  <div className="panel-body">Current Users: <span className="badge">{this.state.user_count}</span> Hits: <span className="badge">{this.state.hits}</span></div>
 </div>
        );
    }
});
