/**
 * code preprocessor to wrap all "new" statements
 * to find out whether there's constant object
 * creation.
 */
function preProcessProcessingCode(code) {
  var lines = code.split("\n"), l=0, last = lines.length;
  var search = "(([a-zA-Z\d]+)\\s*=\\s*new\\s+([A-Z][A-Za-z\\d]+).+;)";
  var replace;
	
  for(l=0; l<last; l++) {
       replace = "$1\nComputer.create(\"$2\",\"$3\", "+l+");";
    lines[l] = lines[l].replace(new RegExp(search,'gm'), replace);
  }
	  
  var cnt = document.createElement("textarea");
  cnt.style.display = "block";
  cnt.style.height = "900px";
  cnt.style.width = "1024px";
	  
  cnt.innerHTML = lines.join("\n");
  document.body.appendChild(cnt);
  return lines;
}
	
PJScreates = {};

function showPJSstats() {
  var s = "";
  for(type in PJScreates) {
    s += type + ": " + PJScreates[type].length + "\n";
  }
  window.console.log(s);
}

preProcesingProcessingCode("");
