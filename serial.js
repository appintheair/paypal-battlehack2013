var connectionId;

var currentState;
var physicalAddress;
var uuid;

function serialPut(value) {
    value = parseInt(value);
    var buffer = new ArrayBuffer(3);
    var uint8View = new Uint8Array(buffer);
    uint8View[0] = value / 100 + 48;
    uint8View[1] = ((value / 10) % 10) + 48;
    uint8View[2] = (value % 10) + 48;
    chrome.serial.write(connectionId, buffer, function() {});
}

function syncPhysical() {
    currentState = 1;
    physicalAddress = '';
    var buffer = new ArrayBuffer(1);
    var uint8View = new Uint8Array(buffer);
    uint8View[0] = 1;
    chrome.serial.write(connectionId, buffer, function() {});

    setTimeout(syncUuid, 3000);
}

function syncUuid() {
    currentState = 2;
    uuid = '';
    var buffer = new ArrayBuffer(1);
    var uint8View = new Uint8Array(buffer);
    uint8View[0] = 2;
    chrome.serial.write(connectionId, buffer, function() {});

    setTimeout(displaySyncResult, 3000);
}

function displaySyncResult() {

    $('input[name="physical_address"]').val(physicalAddress);
    $('input[name="uuid"]').val(uuid);

    currentState = 3;

    $('#beacon_ready').css({'display': 'none'});
    $('#beacon_present').css({'display': 'block'});
    $('#beacon_button').css({'display': 'block'});
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
    $('#beacon_ready').css({'display': 'block'});

    chrome.serial.read(connectionId, 1, onSerialRead);
    setTimeout(syncPhysical, 3000);
}

function openPort(port) {
    chrome.serial.open(port, onSerialOpen);
}

function onSerialRead(readInfo) {
    var uint8View = new Uint8Array(readInfo.data);
    for (var i=0; i<readInfo.bytesRead; i++) {
        var value = String.fromCharCode(uint8View[i]);
        if (currentState == 1) {
            physicalAddress += value;
        } else if (currentState == 2) {
            uuid += value;
        }
    }
    if (currentState == 3) {
        return;
    }
    chrome.serial.read(connectionId, 1, onSerialRead);
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
            photo3: photo3,
            uuid: uuid,
            physical_address: physicalAddress
        }, function success() {
            $("#newd_form").css({'display': 'none'});
            $("#block_success").css({'display': 'block'});
        })


    };
});