	$(document).ready(function() {
      $('select').material_select();
      $(".button-collapse").sideNav();
      $('.datepicker').pickadate({
      format: 'mm/dd/yyyy'
      });
      $('.modal-trigger').leanModal();
  	});


  	$(".dropdown-button").dropdown();
  	$('.fixed-action-btn').openFAB();
  	$('.fixed-action-btn').closeFAB();

  

  $('.button-collapse').sideNav({
      menuWidth: 300, // Default is 240
      edge: 'right', // Choose the horizontal origin
      closeOnClick: true // Closes side-nav on <a> clicks, useful for Angular/Meteor
    }
  );