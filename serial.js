var connectionId;

function serialPut(value) {
    value = parseInt(value);
    var buffer = new ArrayBuffer(3);
    var uint8View = new Uint8Array(buffer);
    uint8View[0] = value / 100 + 48;
    uint8View[1] = ((value / 10) % 10) + 48;
    uint8View[2] = (value % 10) + 48;
    chrome.serial.write(connectionId, buffer, function() {});
}

function onSerialOpen(openInfo) {
    connectionId = openInfo.connectionId;
    if (connectionId == -1) {
        console.log('Could not open');
        return;
    }
    console.log('Connected');
    console.log(openInfo)

    $('#beacon_none').css({'display': 'none'});
    $('#beacon_present').css({'display': 'block'});
    $('#beacon_button').css({'display': 'block'});
}

function openPort(port) {
    chrome.serial.open(port, onSerialOpen);
}


var timer;
$(document).ready(function() {
    timer = setInterval(function() {
        chrome.serial.getPorts(function(ports) {
            for (var k in ports) {
                if (ports[k] === '/dev/tty.usbmodem641') {
                    openPort(ports[k]);
                    clearInterval(timer);
                    break;
                }
            }
        });
    }, 2000);

    document.getElementById('beacon_button').onclick = function (event) {
        serialPut(0);
        event.preventDefault();

        var title = $("input[name=\"title\"]").val();
        var photo1 = $("input[name=\"photo1\"]").val();
        var photo2 = $("input[name=\"photo2\"]").val();
        var photo3 = $("input[name=\"photo3\"]").val();

        $.post('http://beacons-kicknate.appspot.com/createDonation', {
            title: title,
            photo1: photo1,
            photo2: photo2,
            photo23: photo3
        }, function success() {
            $("#newd_form").css({'display': 'none'});
            $("#block_success").css({'display': 'block'});
        })


    };
});