String[] lines = {
"4: could not find intersection between (560.0001/421.2808 - 564.0001/424.4499) and (564.0001/422.0 - 548.0001/422.0)",
//"6: could not find intersection between (544.0001/421.2808 - 548.0001/424.4499) and (564.0001/422.0 - 548.0001/422.0)",
//"0: could not find intersection between (544.0001/399.2808 - 548.0001/402.4499) and (564.0001/422.0 - 548.0001/422.0)",
//"2: could not find intersection between (560.0001/399.2808 - 564.0001/402.4499) and (564.0001/422.0 - 548.0001/422.0)"
};
float[] points;

void setup() {
  size(600,600);
  noLoop();
}

void draw() {
  background(0);


  for(int s=0; s<lines.length; s++) {
    String l = lines[s];
    String repl = l.replace("(","");
    repl = repl.replace(" could not find intersection between ","");
    repl = repl.replace("0:","");
    repl = repl.replace("2:","");
    repl = repl.replace("4:","");
    repl = repl.replace("6:","");
    repl = repl.replace("ischeck: ","");
    repl = repl.replace("line: ","");
    repl = repl.replace(")","");
    repl = repl.replace("/"," ");
    repl = repl.replace(" - "," ");
    repl = repl.replace(" and "," ");
    String[] terms = repl.split(" ");
    println(terms);
    println();

    points = new float[terms.length];
    for(int i=0; i<terms.length; i++) {
      points[i] = Float.parseFloat(terms[i]);
    }

    stroke(255);
    line(points[0],points[1],points[2],points[3]);

    if(points.length>4) {
      line(points[4],points[5],points[6],points[7]);
    }
  }
}
