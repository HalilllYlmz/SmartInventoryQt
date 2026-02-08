var baseUrl = "http://localhost:5113/api/devices";

function getDevices(callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            if(xhr.status === 200) {
                callback(JSON.parse(xhr.responseText));
            }else {
                console.log("Get Error: " + xhr.status + " " + xhr.responseText);
            }
        }
    }
    xhr.open("GET", baseUrl);
    xhr.send();
}

function addDevice(deviceObj, callback) {
    var xhr = new XMLHttpRequest();
    var data = JSON.stringify(deviceObj);

    xhr.open("POST", baseUrl);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 201 || xhr.status === 200) {
                callback();
            } else {
                console.log("Add Error: " + xhr.status + " " + xhr.responseText);
            }
        }
    }
    xhr.send(data);
}

function updateDevice(id, deviceObj, callback) {
    var xhr = new XMLHttpRequest();
    var url = baseUrl + "/" + id;
    var data = JSON.stringify(deviceObj);

    xhr.open("PUT", url);
    xhr.setRequestHeader("Content-Type", "application/json");

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 204 || xhr.status === 200) {
                callback();
            } else {
                console.log("Update Error: " + xhr.status + " " + xhr.responseText);
            }
        }
    }
    xhr.send(data);
}

function deleteDevice(id, callback) {
    var xhr = new XMLHttpRequest();
    var url = baseUrl + "/" + id;

    xhr.open("DELETE", url);

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 204 || xhr.status === 200) {
                callback();
            } else {
                console.log("Delete Error: " + xhr.status + " " + xhr.responseText);
            }
        }
    }
    xhr.send();
}

