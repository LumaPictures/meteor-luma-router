class @ExampleController extends Luma.Controllers.Base
  onBeforeAction: -> return
  data: -> 
  	data =
  		route: @route
  		routes: Luma.Router.collection.find()
  	return data if @ready()
  onAfterAction: -> return
  action: -> @render() if @ready()