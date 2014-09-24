var data = {};
var filter = ["", "", "", "", "", "", ""];
var rev = [false, false, false, false, false, false, false]
var last = -1;

function reload() {
	xmlreq("run.log", function(log) {
		data = log.split("\n");
		while(data[data.length - 1] == "") {
			data.pop();
		}

		for(var i = 0; i < data.length; i++) {
			data[i] = data[i].split("\t");
		}

		redraw();
	});

	return false;
}

function sort(idx, el) {
	if(idx == last) {
		rev[idx] = !rev[idx];
	}

	data.sort(function(left, right) {
		var ord;
		if(isNaN(left[idx])) {
			ord = left[idx].localeCompare(right[idx]);
		} else {
			ord = left[idx] - right[idx];
		}
		return rev[idx] ? -ord : ord;
	});

	last = idx;
	redraw();
	el.textContent = el.textContent.replace(/\u25b4|\u25be/, rev[idx] ? "\u25b4" : "\u25be");

	return false;
}

function change(idx, input) {
	filter[idx] = input.value;
	redraw();
}

function xmlreq(url, done) {
	var req = new XMLHttpRequest();
	req.onload = function() { done(req.responseText); };
	req.open("get", url, true);
	req.send();
}

function mkcol(text) {
	var col = document.createElement("td");
	col.textContent = text;
	return col;
}

function redraw() {
	var table = document.getElementById("table");
	while(table.firstChild) {
		table.removeChild(table.firstChild);
	}

	for(var i = 0; i < data.length; i++) {
		var skip = false;

		for(var j = 0; j < filter.length; j++) {
			if(filter[j]) {
				reg = new RegExp(filter[j]);
				if(!reg.test(data[i][j])) {
					skip = true;
				}
			}
		}

		if(skip)
			continue;

		var row = document.createElement("tr");

		for(var j = 0; j < data[i].length; j++)
			row.appendChild(mkcol(data[i][j]));

		table.appendChild(row);
	}
}

window.onload = function() { reload(); };

redraw();
