window.TrelloClone = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    new TrelloClone.Routers.Router();
    Backbone.history.start();
  },
};

$(document).ready(function(){
  TrelloClone.initialize();
});
