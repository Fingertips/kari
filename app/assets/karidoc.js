jQuery(document).ready(function(){
  $(".header").click(function() {
    $(this).next().slideToggle("fast");
  });
});