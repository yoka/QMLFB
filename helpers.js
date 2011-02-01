function getJSON(url, callback){
    var headers = [{name:'Accept', value: 'application/json'}, {name:'Content-type', value: 'application/json'}];
    var xhr = new XMLHttpRequest;
    xhr.open("GET", url);
    if (headers) {
        for (var i = 0; i<headers.length; i++) {
          xhr.setRequestHeader(headers[i].name, headers[i].value);
        }
    }
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            var json = JSON.parse(xhr.responseText);
            callback.call(json);
        }
    }
    xhr.send();
}
