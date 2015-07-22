(function($) {

  var taskManager = {
    init: function() {
      $('#date').datepaginator();
    },
  };

  $(function() {
    taskManager.init()
  });

})(jQuery)
