// counter.js

$(document).ready(function(){
    if($('#micropost_content').length > 0){
      // form for microposts exists -> create counter
      new MicropostsCounter().construct();
    }
});

/* ---------- START MicropostsCounter ---------- */
function MicropostsCounter(){

  var counter;
  var textArea   = $('#micropost_content');
  var counterDiv = $('#form_counter');
  var limit      = 140;

  this.construct = function(){
    textArea.attr('maxlength',limit);
    MicropostsCounter.printCounter();
    this.bindEvent();
  }

  MicropostsCounter.setCounter = function(){
    counter = 140 - textArea.val().length;
  }

  MicropostsCounter.printCounter = function(){
    MicropostsCounter.setCounter();
    if(counter == 0){
      counterDiv.text('No characters left');
    } else if(counter > 1){
      counterDiv.text(counter + ' characters left');
    } else {
      counterDiv.text(counter + ' character left');
    }
  }

  this.bindEvent = function(){
    textArea.keydown(function(){
        MicropostsCounter.printCounter();
    });
    textArea.keyup(function(){
        MicropostsCounter.printCounter();
    });
  }

}
/* ---------- END MicropostsCounter ---------- */
