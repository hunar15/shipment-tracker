document.addEventListener('DOMContentLoaded', () => {
    var dropdown = document.getElementById('dropdown');
    //TODO: how to debug extensions
    // - check logging / breakpoint information

    var xhr = new XMLHttpRequest();
    xhr.open("GET", "http://www.bpost2.be/bpostinternational/track_trace/find.php?search=s&lng=en&trackcode=312014853400000769000219190151", true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState == 4) {
            var resp = xhr.responseText;
            console.log("Received from aftership.com ", resp);
        }
    };
    xhr.send();
});
