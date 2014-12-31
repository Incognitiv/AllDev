<<<<<<< HEAD
try {
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    audioContext = new AudioContext();
} catch(e) {
    throw Error("AudioContext not found!");
}
 
/* if (!window.AudioContext) {
    if (!window.webkitAudioContext) {
        alert('AudioContext not found!');
    }
    window.AudioContext = window.webkitAudioContext;
} */
var context = new AudioContext();
var audioBuffer;
=======
var context = new AudioContext();
>>>>>>> parent of 65c8114... ???
var sourceNode;
var analyser;
var javascriptNode;
var ctx = $("#music").get()[0].getContext("2d");
var gradient = ctx.createLinearGradient(0, 0, 0, 255);

<<<<<<< HEAD
gradient.addColorStop(1, '#FFFFFF');
gradient.addColorStop(0, '#000000');

setupAudioNodes();

function setupAudioNodes() {
=======
gradient.addColorStop(1, '#A3FFFF');
gradient.addColorStop(0, '#C5D5ED');

if (!window.AudioContext) {
    if (!window.webkitAudioContext) {
        alert('AudioContext not found!');
    }
    window.AudioContext = window.webkitAudioContext;
}

function setupAudioNodes() {
    "use strict";
>>>>>>> parent of 65c8114... ???
    javascriptNode = context.createScriptProcessor(2048, 1, 1);
    javascriptNode.connect(context.destination);
    analyser = context.createAnalyser();
    analyser.smoothingTimeConstant = 0.795;
    analyser.fftSize = 2048;
    sourceNode = context.createBufferSource();
    sourceNode.connect(analyser);
    analyser.connect(javascriptNode);
    sourceNode.connect(context.destination);
}

<<<<<<< HEAD
function loadSound(url) {
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.responseType = 'arraybuffer';
    request.onload = function() {
        context.decodeAudioData(request.response, function(buffer) {
            playSound(buffer);
        }, onError);
    }
    request.send();
}

function playSound(buffer) {
    sourceNode.buffer = buffer;
    sourceNode.start(0);
}

function onError(e) {
    console.log(e);
}

javascriptNode.onaudioprocess = function() {
=======
setupAudioNodes();

function playSound(buffer) {
    "use strict";
    sourceNode.buffer = buffer;
    sourceNode.start(0);
    window.setInterval(function (e) {
    	console.log(sourceNode.context.currentTime);
    }, 1000);
}

function onError(e) {
    "use strict";
    console.log(e);
}

function loadSound(url) {
    "use strict";
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.responseType = 'arraybuffer';
    request.onload = function () {
        context.decodeAudioData(request.response, function (buffer) {
            playSound(buffer);
        }, onError);
    };
    request.send();
}

function drawSpectrum(array) {
    "use strict";
    var i = 0, value;
    while (i < (array.length)) {
        i = i + 1;
        value = array[i];
        ctx.fillRect(i * 8, 260 - value, 4, 260);
    }
}

javascriptNode.onaudioprocess = function () {
    "use strict";
>>>>>>> parent of 65c8114... ???
    var array = new Uint8Array(analyser.frequencyBinCount);
    analyser.getByteFrequencyData(array);
    ctx.clearRect(0, 0, 2048, 255);
    ctx.fillStyle = gradient;
    drawSpectrum(array);
<<<<<<< HEAD
}

function drawSpectrum(array) {
    for (var i = 0; i < (array.length); i++) {
        var value = array[i];
        ctx.fillRect(i * 8, 260 - value, 4, 260);
    }
}
=======
};
>>>>>>> parent of 65c8114... ???
