document.addEventListener("DOMContentLoaded",function(){
  // replace textareas with <pre> elements
  $("textarea").each(function(){
    var parent = this.parentNode,
        lines = this.value.trim().split("\n"),
        i, last=lines.length,
        pre, div = document.createElement("div");
    div.setAttribute("class","codeblock");
    for(i=0; i<last; i++) {
      pre = document.createElement("pre");
      if(lines[i]==='') { pre.innerHTML = "&nbsp;"; }
      else { pre.innerHTML = syntax_highlight(lines[i]); }
      div.appendChild(pre);
    }
    parent.insertBefore(div, this);
    parent.removeChild(this);
  });
},false);

keywords = ["abstract","continue","for","new","switch",
            "assert","default","goto","package","synchronized",
            "boolean","do","if","private","this",
            "break","double","implements","protected","throw",
            "byte","else","import","public","throws",
            "case","enum","instanceof","return","transient",
            "catch","extends","int","short","try",
            "char","final","interface","static","void",
            "class","finally","long","strictfp","volatile",
            "const*","float","native","super","while"];

function syntax_highlight(line) {
  // line comments
  var parts = line.split("//");
  var line = parts[0];
  var comment = "";
  if (parts[1]) {
    comment = "<span class=\"comment\">//" + parts[1] + "</span>";
  }

  // strings
  line = line.replace(/"([^"]+)"/g,"<span clss=\"string\">\"$1\"</span>");
  line = line.replace(/'([^']+)'/g,"<span clss=\"string\">'$1'</span>");

  // keywords
  var k, last=keywords.length;
  for(k=0; k<last; k++) {
    line = line.replace(new RegExp("\\b"+keywords[k]+"\\b","g"), "<span clss=\"keyword\">"+keywords[k]+"</span>");
  }

  // numbers
  line = line.replace(/([\d,.]+)/g,"<span class=\"number\">$1</span>");

  line = line.replace(/clss=/g,"class=");
  return line + comment;
}