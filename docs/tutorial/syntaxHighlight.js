(function(){

  // our list of highlightable syntax - Processing/Java
  var keywords = ["abstract","continue","for","new","switch",
                  "assert","default","goto","package","synchronized",
                  "boolean","do","if","private","this",
                  "break","double","implements","protected","throw",
                  "byte","else","import","public","throws",
                  "case","enum","instanceof","return","transient",
                  "catch","extends","int","short","try",
                  "char","final","interface","static","void",
                  "class","finally","long","strictfp","volatile",
                  "const*","float","native","super","while"];

  // make magic happen on DOMContentLoaded
  document.addEventListener("DOMContentLoaded", function() {
    // replace textareas with <pre> elements
    $("textarea").each(function(){
      // 1: don't convert if told not to
      if(this.getAttribute("data-noconvert")) return;

      // 2: convert otherwise
      var parent = this.parentNode,
          lines = this.value.replace(/[\s+\n?]$/,'').split("\n"),
          i, last=lines.length,
          pre, div, container = document.createElement("div");

      // 4: build a new codeblock for the content
      container.setAttribute("class","codeblock");
      for(i=0; i<last; i++) {
        div = document.createElement("div"),

        // line number
        pre = document.createElement("pre");
        pre.setAttribute("class","code-linenumber");
        pre.innerHTML = (i+1);
        div.appendChild(pre);
        
        // process each line as a <pre> block
        pre = document.createElement("pre");
        pre.setAttribute("class","code-line");

        if(lines[i]==='') { pre.innerHTML = "&nbsp;"; }
        else { pre.innerHTML = syntax_highlight(lines[i]); }
        div.appendChild(pre);
        container.appendChild(div);
      }

      // 5: replace original textarea
      parent.insertBefore(container, this);
      parent.removeChild(this);
    });
  },false);

  function syntax_highlight(line) {
    // 1: process line comments
    var parts = line.split("//");
    var line = parts[0];
    var comment = "";
    if (parts[1]) { comment = "<span class=\"comment\">//" + parts[1] + "</span>"; }

    // 2: process double-quoted strings (keyword safe, because "class" is a keyword)
    line = line.replace(/"([^"]+)"/g,"<span clss=\"string\">\"$1\"</span>");
    line = line.replace(/'([^']+)'/g,"<span clss=\"string\">'$1'</span>");
    
    // 3: highlight all keywords
    var k, last=keywords.length, search, replace;
    for(k=0; k<last; k++) {
      search = new RegExp("\\b"+keywords[k]+"\\b","g");
      replace = "<span clss=\"keyword\">"+keywords[k]+"</span>";
      line = line.replace(search, replace);
    }

    // 4: process numerals
    line = line.replace(/([\d,.]+)/g,"<span class=\"number\">$1</span>");
    
    // 5: colour constants
    line = line.replace(/(\b[A-Z]+\b)/g,"<span class=\"constant\">$1</span>");

    // 6: enable all classes
    line = line.replace(/clss=/g,"class=");
    return line + comment;
  }

}());