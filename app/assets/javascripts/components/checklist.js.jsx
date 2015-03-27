var Checklist = React.createClass({
  render: function() {
    return (
      <div>
        <h3><a href="{this.props.repository_path}">{this.props.github_repository_full_name}</a></h3>
        <h3>{this.props.name}</h3>
        <div class="row">
          <div class="col-xs-10">
            <a href="{this.props.edit_path}">Edit</a> | <a href="{this.props.index_path}">Back</a>
          </div>
        </div>
      </div>
    );
  }
})

window.Checklist = Checklist