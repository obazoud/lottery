var socket = io.connect(null, {
  'reconnect': true,
  'reconnection delay': 1500,
  'max reconnection attempts': 100
});
var myself, state, mybet, bets, connected = false;

socket.on('connect', function () {
  $('#feedback')[0].innerHTML = 'Bienvenue à la loterie.';
  $('#loadingModal').modal('hide');
  if (!connected) {
    $('#loginModal').modal({show: true, keyboard: false, backdrop: 'static'});
    $("#nick").focus();
  }
  connected = true;
});

socket.on('reconnect', function () {
  $('#feedback')[0].innerHTML = 'Vous êtes reconnecté au serveur de la loterie.';
});

socket.on('reconnecting', function () {
  $('#feedback')[0].innerHTML = '<strong>Nous tentons de vous reconnecter au serveur de la loterie.</strong>';
  $('#wheelL').attr('class', '');
  $('#wheelR').attr('class', '');
  $('#loadingModal').modal({show: true, keyboard: false, backdrop: 'static'});
});

socket.on('error', function (e) {
  $('#feedback')[0].innerHTML = '<strong>Un problème technique est servenu.</strong>';
});

socket.on('nicknames', function (nicknames) {
  $('#nicknames').empty();
  if (nicknames.length > 0) {
    for (var i in nicknames) {
      if (nicknames[i] == myself) {
        $('#nicknames').append('<li><i class=\"icon-ok-sign\"></i><i class=\"icon-user\"></i> ' + nicknames[i] + '</li>');
      } else {
        $('#nicknames').append('<li><i class=\"icon-user\"></i> ' + nicknames[i] + '</li>');
      }
    }
  } else {
    $('#nicknames').append('<li> Aucun utilisateur connecté.</li>');
  }
});

socket.on('lottery clock', function (event) {
  $('#clock')[0].innerHTML = '&nbsp;&nbsp;' + event.timer + '&nbsp;s';
  if (event.timer > 2 && event.timer <= 8 && !$('#wheelL').is('.trans2d')) {
    $('#wheelL').attr('class', '');
    $('#wheelL').css({
      "-webkit-transform" : "", "-webkit-animation-timing-function" : "",
      "-moz-transform" : "", "-moz-animation-timing-function" : ""
    });
    $('#wheelL').attr('class', 'trans2d');
    $('#wheelR').attr('class', '');
    $('#wheelR').css({
      "-webkit-transform" : "", "-webkit-animation-timing-function" : "",
      "-moz-transform" : "", "-moz-animation-timing-function" : ""
    });
    $('#wheelR').attr('class', 'trans2d');
  }
  if (event.timer == 0) {
    $('#wheelL').attr('class', '');
    $('#wheelR').attr('class', '');
  }
});

socket.on('lottery draw show', function (event) {
  $('#feedback')[0].innerHTML = 'Tirage effectué, il y a ' + event.winners.length + ' gagnant(s)';
  $('#lottery-grid span').removeClass('badge-success badge-warning').addClass('badge-info');
  $('#winners').empty();
  $('#draw1')[0].innerHTML = '&nbsp;Numéro gagnant:&nbsp;<strong>' + event.draw + '</strong>';
  $('#draw2')[0].innerHTML = '&nbsp;Effectué le ' + moment(event.date).format("DD/MM/YYYY") + ' à ' + moment(event.date).format("HH:mm:ss");
  $('#draw3')[0].innerHTML = '&nbsp;Il y a eu <strong>' + event.winners.length + '</strong> gagnant(s).';
  if (event.winners.length > 0) {
    for (var i in event.winners) {
      $('#winners').append('<li><i class=\"icon-gift\"></i> ' + event.winners[i].nickname + '</li>');
    }
  } else {
    $('#winners').append('<li> Aucun gagnant.</li>');
  }
});

socket.on('lottery draw', function (event) {
  // got 2s to play with css3 ;)
  var fromL = getRotationDegrees(document.getElementById("wheelL"));
  var fromR = getRotationDegrees(document.getElementById("wheelR"));
  var degreeL = 360 - (36 * parseInt(event.draw / 10, 10) + 18);
  if (degreeL < fromL) degreeL += 360
  var degreeR = 360 - (36 * (event.draw - 10 * parseInt(event.draw / 10, 10)) + 18);
  if (degreeR < fromR) degreeR += 360
  $('#wheelL').attr('class', '');
  $('#wheelR').attr('class', '');

  $('#wheelL').css({
    "-webkit-transform" : "rotate("+ (fromL + 3) +"deg)", "-webkit-transition-duration" : "0ms",
    "-moz-transform" : "rotate("+ (fromL + 3) +"deg)", "-moz-transition-duration" : "0ms"
  });
  $('#wheelR').css({
    "-webkit-transform" : "rotate("+ (fromR + 3) +"deg)", "-webkit-transition-duration" : "0ms",
    "-moz-transform" : "rotate("+ (fromR + 3) +"deg)", "-moz-transition-duration" : "0ms"
  });

  setTimeout(function() {
   $('#wheelL').attr('class', '');
   $('#wheelL').attr('class', 'stop2d');
   $('#wheelR').attr('class', '');
   $('#wheelR').attr('class', 'stop2d');
   $('#wheelL').css({
     "-webkit-transform" : "rotate("+ degreeL +"deg)", "webkit-animation-timing-function" : "ease-out", "-webkit-transition-duration" : "2000ms",
     "-moz-transform" : "rotate("+ degreeL +"deg)", "moz-animation-timing-function" : "ease-out", "-moz-transition-duration" : "2000ms"
   });
   $('#wheelR').css({
     "-webkit-transform" : "rotate("+ degreeR +"deg)", "webkit-animation-timing-function" : "ease-out", "-webkit-transition-duration" : "2000ms",
     "-moz-transform" : "rotate("+ degreeR +"deg)", "moz-animation-timing-function" : "ease-out", "-moz-transition-duration" : "2000ms"
   });
  }, 25);
});

socket.on('lottery unfreeze', function (e) {
  state = e;
  mybet = null;
  $('#feedback')[0].innerHTML = 'Parier en cliquant sur un chiffre sur la grille';
});

socket.on('lottery freeze', function (e) {
  state = e;
  $('#feedback')[0].innerHTML = 'Les paris sont suspendus pour ce tirage';
});

socket.on('users bets', function (bets) {
  for (var i in bets) {
    if (bets[i] != mybet) {
      $('#lottery-grid span:eq(' + (bets[i] - 1) + ')').removeClass('badge-success badge-warning badge-info').addClass('badge-warning');
    }
  }
});

$(document).ready(function() {
  $('#loadingModal').modal({show: true, keyboard: false, backdrop: 'static'});

  $('#modal-form-submit').on('click', function(e) {
    e.preventDefault();
   $('#set-nickname').submit();
  });

  $("#help").popover({
    placement: 'bottom',
    title: 'Aide Loterie',
    content: $('#helpContent')[0].innerHTML
  });
  $('#set-nickname').submit(function (event) {
    $('#nickname-already-exists').css('visibility', 'hidden');
    $('#nickname-invalid').css('visibility', 'hidden');
    $('#nickname-too-many-nicknames').css('visibility', 'hidden');
    $('#control-group').removeClass('error');
    socket.emit('nickname', $('#nick').val(), function (set) {
      if (!set) {
        $('#loginModal').modal('hide');
        myself = $('#nick').val();
      }

      $('#control-group').addClass('error');
      $('#nickname-' + set).css('visibility', 'visible');
    });
    return false;
  });

  $('#lottery-grid span').click(function (e) {
    if (state != 'freeze' && !mybet) {
      var bet = parseInt($(this).text(), 10);
      if ($(this).is('.badge-warning')) {
        $('#feedback')[0].innerHTML = 'Un autre joueur a <strong>déjà joué le ' + bet + '</strong>.';
      } else {
        mybet = bet;
        $('#lottery-grid span:eq(' + (mybet - 1) + ')').removeClass('badge-success badge-warning badge-info').addClass('badge-success');
        socket.emit('user bet', mybet);
        $('#feedback')[0].innerHTML = 'Merci d\'avoir jouer le ' + mybet + '.';
      }
    } else {
      if (state == 'freeze') {
        $('#feedback')[0].innerHTML = 'Vous ne pouvez plus parier pour ce tirage.';
      } else {
        if (mybet) {
          $('#feedback')[0].innerHTML = 'Vous avez déjà parié sur le ' + mybet + '.';
        }
      }
    }
  });
});

function getRotationDegrees (element) {
  var style = window.getComputedStyle(element);
  var transformString = style['-webkit-transform']
                     || style['-moz-transform'];
  if (!transformString || transformString == 'none')
      return 0;
  var splits = transformString.split(',');
  var a = parseFloat(splits[0].substr(7));
  var b = parseFloat(splits[1]);
  var rad = Math.atan2(b, a);
  var deg = 180 * rad / Math.PI;
  if (deg < 0) deg += 360;
  return deg;
}
