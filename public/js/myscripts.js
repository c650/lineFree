	$(document).ready(function() {
      $('select').material_select();
      $(".button-collapse").sideNav();
  	});
  	$(".dropdown-button").dropdown();
  	$('.fixed-action-btn').openFAB();
  	$('.fixed-action-btn').closeFAB();

  $('.datepicker').pickadate({
      selectMonths: true, // Creates a dropdown to control month
      selectYears: 15 // Creates a dropdown of 15 years to control year
  });

  $('.button-collapse').sideNav({
      menuWidth: 300, // Default is 240
      edge: 'right', // Choose the horizontal origin
      closeOnClick: true // Closes side-nav on <a> clicks, useful for Angular/Meteor
    }
  );