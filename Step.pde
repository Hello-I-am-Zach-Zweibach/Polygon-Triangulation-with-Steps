enum stepType
{
  none, isntSimple, noTrianglePossible, oneTrianglePossible, vToVList, vToEList, startMainLoop, addTriangle, retestV, finalTriangle, theEnd
}

private class Step {

  Polygon basePolygon = new Polygon();
  stepType type = stepType.none;
  ArrayList<Integer> vList = new ArrayList<Integer>();
  ArrayList<Integer> earList = new ArrayList<Integer>();
  ArrayList<Edge> diagList = new ArrayList<Edge>();
  ArrayList<Triangle> triList = new ArrayList<Triangle>();
  int retestV = 0;
  boolean validDiagonal = false;
  boolean wasInEarList = false;

  Step( Polygon base ) {
    basePolygon = base;
  }

  //Getter/////////////////////////////////////////////////////////////////////////////////////////////////
  ArrayList<Integer> getEarList() { return earList; }

  //Setters/////////////////////////////////////////////////////////////////////////////////////////////////
  void setType( stepType ty) { type = ty; }
  void setRetestV( int v ) { retestV = v; }
  void setWasInE(boolean b) { wasInEarList = b; }
  void setValidDiagonalStatus( boolean b ) { validDiagonal = b; }
  void setVList( ArrayList<Integer> VL )
  {
    vList.clear();

    for (int i : VL)
      vList.add(i);
  }

  void setEarList( ArrayList<Integer> EL )
  {
    earList.clear();

    for (int i : EL)
      earList.add(i);
  }

  void setDiagList( ArrayList<Edge> DL )
  {
    diagList.clear();

    for (Edge i : DL)
      diagList.add(i);
  }
  
  void addDiag( Edge e )
  {
    diagList.add(e);
  }

  void setTriList( ArrayList<Triangle> tri)
  {
    triList.clear();

    for (Triangle i : tri)
      triList.add(i);
  }
  
  //Helper functions//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Triangle drawing with red/green fill from provided code in skeleton
  void drawTriangles()
  {
    Edge e0 = null;
    Edge e1 = null;
    Edge e2 = null;
    
    noStroke();
    for (int i = 0; i < triList.size(); i++)
    {
      Triangle currT = triList.get(i);

      //Triangle drawing with red/green fill from provided code in skeleton
      noStroke();
      fill( 100, 100, 100 );
      if ( currT.ccw() ) fill( 200, 100, 100 );
      if ( currT.cw()  ) fill( 100, 200, 100 );
      currT.draw();

      //Get edges of the triangle
      e0 = new Edge(currT.p0, currT.p1);
      e1 = new Edge(currT.p0, currT.p2);
      e2 = new Edge(currT.p1, currT.p2);

      //Want to draw the most recent triangle with blue edges.
      if (i != triList.size() - 1)  
        stroke(100, 100, 100);  //If this triangle isn't the most recent, make the color black
      else
        stroke(100, 100, 200);  //Else the color is blue
      
      //Draw the edges
      fill(0);
      e0.draw();
      e1.draw();
      e2.draw();
    }
  }
  
  //uses provided code from skeleton
  void drawPointsNormal()
  {
    fill(0);
    noStroke();
    for ( Point p : basePolygon.p ) {
      p.draw();
    }

    fill(0);
    stroke(0);
    textSize(18);

    for ( int i = 0; i < basePolygon.p.size(); i++ ) {
      textRHC( i+1, basePolygon.p.get(i).p.x+5, basePolygon.p.get(i).p.y+15 );
    }
  }

  //Draws the vertices with colors
  //Blue - vertex is in ear list
  //Green - vertex is in v list
  //Black - vertex is in neither
  void drawPointsVEColored()
  {
    noStroke();
    
    //Need an arraylist to keep track of which vertices are drawn
    ArrayList<Integer> drawn = new ArrayList<Integer>();
    for (int i = 0; i < basePolygon.p.size(); i++)
      drawn.add(0, 0);

    //Draw the ear tips
    if (earList.size() > 0)
    {
      fill(100, 100, 200);
      for ( int i : earList )  //Draw points in earList as blue
      {
        drawn.set(i, 1);  //Mark them as drawn
        basePolygon.p.get(i).draw();
      }
    }

    //Draw the v list vertices
    if (vList.size() > 0)
    {
      fill(100, 200, 100);
      for (int i : vList)  //Draw points in vList as green
      {
        if (drawn.get(i) == 0)
        {
          drawn.set(i, 1);  //Mark them as drawn
          basePolygon.p.get(i).draw();
        }
      }
    }

    //Draw the rest
    fill(0);
    for (int i = 0; i < drawn.size(); i++)  //Draw nondrawn points as black
    {
      if (drawn.get(i) == 0)  //If value is still 0, they haven't been drawn
      {
        basePolygon.p.get(i).draw();
      }
    }

    //Print the numbering
    //All black
    //Uses provided code from the skeleton
    fill(0);
    stroke(0);
    textSize(18);
    for ( int i = 0; i < basePolygon.p.size(); i++ ) {
      textRHC( i+1, basePolygon.p.get(i).p.x+5, basePolygon.p.get(i).p.y+15 );
    }
  }

  //Prints contents of vList and earList to the console
  void printLists()
  {
    //Prints vList
    if(vList.size() > 0)
    {
      print("vList: ");
      for(int i = 0; i < vList.size(); i++)
        print(vList.get(i)+1, " ");
      println("");
    }
    //Prints earList
    if(earList.size() > 0)
    {
      print("earList: ");
      for(int i = 0; i < earList.size(); i++)
        print(earList.get(i)+1, " ");
      println("");
    }
  }
  
  //Step functions//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //A brief description of what the functions do is above them.
  //Every function draws triangles (if there are any) and draws points. So I won't say when it does this (since that's every time).
  //Note that NONE of the steps actually *perform* the steps of the algorithm. This is all strictly for displaying information to the user.
  //The algorithm does the entire triangulation without stopping. But it outputs stages to display to the user as a steps list.
  //Steps that occur once/////////////////////////////////////////////////////////////////////////////////////////////////
  
  //Adds all vertices to v list
  //Explains how vList is populated and how valid points are displayed
  void vToVListFunc()
  {    
    textRHC("All vertices start out valid. They are all added to v list.", 10, height - 20);
    textRHC("These are always ordered least to greatest. V list is printed to the console each step.", 10, height - 40);
    textRHC("Valid vertices are shown as green.", 10, height - 60);
    println("All vertices start out valid. They are all added to v list. These are always ordered least to greatest. V list is printed here each step. Valid vertices are shown as green.");
    printLists();

    drawPointsVEColored();
  }
  
  //Add valid ear tips to ear list
  //Explains how valid ear tips are identified and displayed.
  //Draws the diagonals from prev to next for each valid ear tip.
  void vToEListFunc()
  {    
    textRHC("If the vertices before and after a vertex have a valid diagonal between them, that vertex is an ear tip.", 10, height - 20);
    textRHC("The ordering of the ear list varies as they are added and removed.", 10, height - 40);
    textRHC("The ear list is printed to the console in each step.", 10, height - 60);
    textRHC("Valid ear tips are shown as blue.", 10, height - 80);
    println("If the vertices before and after a vertex have a valid diagonal between them, that vertex is an ear tip.");
    println("The ordering of the ear list varies as they are added and removed. The ear list is printed here each step. Valid ear tips are shown as blue.");
    printLists();

    //Draws the diagonals for the valid ear tips.
    stroke(100, 100, 200);
    fill(0);
    for ( Edge e : diagList)
    {
      e.draw();
    }
    
    drawPointsVEColored();
  }

  //Start main loop step
  //Explains how the main loop runs
  void startMainLoopFunc()
  {
    textRHC("The main loop will now start. While there are more than three vertices left in v list:", 10, height - 20);
    textRHC("- The first vertex in ear list is popped from ear list and v list.", 10, height - 40);
    textRHC("- A triangle is made from the previous vertex, the popped vertex, and the next vertex.", 10, height - 60);
    textRHC("- Then the previous/next vertices are checked to see if they are valid ear tips.", 10, height - 80);
    println("The main loop will now start. While there are more than three vertices left in v list:");
    println("- The first vertex in ear list is popped from ear list and v list.");
    println("- A triangle is made from the previous vertex, the popped vertex, and the next vertex.");
    println("- Then the previous/next vertices are checked to see if they are valid ear tips.");
    printLists();
    
    drawPointsVEColored();
  }
  
  //Final triangle step
  //Explains how the last triangle is added.
  void finalTriangleFunc()
  {    
    textRHC("Our main loop is done since there are only three vertices left in vList.", 10, height - 20);
    textRHC("These three vertices must form our last triangle. A triangle has been made from them.", 10, height - 40);
    println("Our main loop is done since there are only three vertices left in vList. These three vertices must form our last triangle.");
    printLists();
    
    drawTriangles();
    drawPointsVEColored();
  }
  
  //The end step
  //Will display the triangulated polygon but no blue triangle.
  //Tells user the algorithm has ended.
  void theEndFunc()
  {
    textRHC("Triangulation has completed, here is the resulting polygon.", 10, height - 20);
    println("Triangulation has completed, here is the resulting polygon.");
    
    //This is the draw triangles function but I remove the bit which makes one triangle print blue
    Edge e0 = null;
    Edge e1 = null;
    Edge e2 = null;
    
    noStroke();
    for (int i = 0; i < triList.size(); i++)
    {
      Triangle currT = triList.get(i);

      //Triangle drawing with red/green fill from provided code in skeleton
      noStroke();
      fill( 100, 100, 100 );
      if ( currT.ccw() ) fill( 200, 100, 100 );
      if ( currT.cw()  ) fill( 100, 200, 100 );
      currT.draw();

      //Get edges of the triangle
      e0 = new Edge(currT.p0, currT.p1);
      e1 = new Edge(currT.p0, currT.p2);
      e2 = new Edge(currT.p1, currT.p2);
      
      //Set color to black
      stroke(100, 100, 100);
      fill(0);
      //Draw the edges
      e0.draw();
      e1.draw();
      e2.draw();
    }
    
    //Draw points
    drawPointsVEColored();
  }
  
  //Steps that occur multiple times/////////////////////////////////////////////////////////////////////////////////////////////////

  //Add triangle step (called once per triangle added)
  //Explains which ear tip triangle was just added.
  void addTriangleFunc()
  {    
    textRHC("Vertex " + retestV + " was the first entry in the ear list.", 10, height - 20);
    textRHC("So, a triangle was made using this vertex, the vertex before it, and the vertex after it.", 10, height - 40);
    textRHC("Vertex " + retestV + " was then removed from the ear list and the v list.", 10, height - 60);
    textRHC("The vertices before and after vertex " + retestV + " must be tested to see if they are ear tips.", 10, height - 80);
    println("Vertex " + retestV + " was the first entry in the ear list. So a triangle was made using this vertex, the vertex before it, and the vertex after it.");
    println("Vertex " + retestV + " was then removed from the ear list and the v list. The vertices before and after vertex " + retestV + " in vList must be tested to see if they are ear tips.");
    printLists();

    drawTriangles();
    drawPointsVEColored();
  }
  
  //Retest vertex step (fires twice per triangle)
  //Draws vertex that was retested as red.
  //Draws the diagonal that was tested as green if it's valid. Otherwise red.
  //Explains if the ear tip was removed/added/neither to the ear list and why.
  void retestVFunc()
  {    
    //Draw triangles and vertices
    drawTriangles();
    drawPointsVEColored();
    
    //Draw the retest vertex as red to make it standout.
    noStroke();
    fill(200, 100, 100);
    basePolygon.p.get(retestV-1).draw();  //draw it in red (the actual point in point list is 1 less than the vertex. ex: point 0 is vertex 1. So subtract 1)
    
    //Draw the diagonal being tested as green, if it is valid. Or red, if it is invalid.
    fill(0);
    if(validDiagonal)
      stroke(100, 200, 100);
    else
      stroke(200, 100, 100);
    
    //Draw the diagonal
    diagList.get(0).draw();
    
    textRHC("Test if vertex " + retestV + " is a valid ear tip.", 10, height - 20);
    
    //Print things depending on if the vertex is/isn't a valid ear tip and if it was/wasn't in the ear list.
    if(validDiagonal && !wasInEarList)  //is valid and wasn't in ear list. Print that it was added to ear list.
    {
      textRHC("The diagonal is valid, so vertex " + retestV + " is a valid ear tip.", 10, height - 40);
      textRHC("Since vertex " + retestV + " wasn't in the ear list before, it has been added.", 10, height - 60);
      println("The diagonal is valid, so vertex " + retestV + " is a valid ear tip. Since vertex " + retestV + " wasn't in the ear list before, it has been added.");
    }
    else if(!validDiagonal && wasInEarList)  //isn't valid and was in ear list. Print that it was removed from ear list.
    {
      textRHC("The diagonal is not valid, so vertex " + retestV + " is not a valid ear tip.", 10, height - 40);
      textRHC("Since vertex " + retestV + " was in the ear list before, it has been removed.", 10, height - 60);
      println("The diagonal is not valid, so vertex " + retestV + " is not a valid ear tip. Since vertex " + retestV + " was in the ear list before, it has been removed.");
    }
    else if(validDiagonal && wasInEarList)  //is valid and was in ear list. Print that nothing happens.
    {
      textRHC("The diagonal is valid, so vertex " + retestV + " is a valid ear tip.", 10, height - 40);
      textRHC("Since vertex " + retestV + " was already in the ear list, nothing needs to be done.", 10, height - 60);
      println("The diagonal is valid, so vertex " + retestV + " is a valid ear tip. Since vertex " + retestV + " was already in the ear list, nothing needed to be done.");
    }
    else if(!validDiagonal && !wasInEarList)  //isn't valid and wasn't in ear list. Print that nothing happens.
    {
      textRHC("The diagonal is not valid, so vertex " + retestV + " is not a valid ear tip.", 10, height - 40);
      textRHC("Since vertex " + retestV + " was absent from the the ear list before, nothing needs to be done.", 10, height - 60);
      println("The diagonal is not valid, so vertex " + retestV + " is not a valid ear tip. Since vertex " + retestV + " was absent from the the ear list before, nothing needed to be done.");
    }
    //Print lists
    printLists();
  }
  
  //The actual draw function.
  //Draws the boundary
  //Then there's a large if else statement which will print what the step type is and call the correct step function.
  void draw()
  {
    //Draw the boundary
    stroke(0);
    fill(0);
    basePolygon.draw();
    

    if(type == stepType.retestV)  //Will occur twice for every addTriangle step
    {
      println("Testing if vertex " + retestV + " is a valid ear tip");
      retestVFunc();
    }
    else if (type == stepType.addTriangle)  //Will occur multiple times
    {
      println("Adding triangle from ear tip " + retestV);
      addTriangleFunc();
    }
    else if(type == stepType.theEnd)
    {
      println("Completed triangulation");
      theEndFunc();
    }
    else if(type == stepType.finalTriangle)  //Should be the second to last step
    {
      println("The final triangle");
      finalTriangleFunc();
    }
    else if (type == stepType.startMainLoop)  //Should be step 3
    {
      println("Starting main loop");
      startMainLoopFunc();
    }
    else if (type == stepType.vToEList)  //Should be step 2
    {
      println("Populating ear list");
      vToEListFunc();
    } 
    else if (type == stepType.vToVList)  //Should be step 1
    {
      println("Populating vList");
      vToVListFunc();
    }
    //The step types below here are edge cases
    else if (type == stepType.oneTrianglePossible)  //There are exactly three points, only one triangle is possible. No triangulation is needed.
    {
      println("Edge case: Making the only triangle");
      
      textRHC("There are three vertices, only one triangle is possible.", 10, height - 20);
      println("There are three vertices, only one triangle is possible.");

      //Triangle drawing from provided code in skeleton
      //No helper function used since the last triangle shouldn't be blue
      stroke(0);
      fill( 100, 100, 100 );
      if ( triList.get(0).ccw() ) fill( 200, 100, 100 );
      if ( triList.get(0).cw()  ) fill( 100, 200, 100 );
      triList.get(0).draw();

      drawPointsNormal();
    }
    else if (type == stepType.noTrianglePossible)   //Too few points to do anything.
    {
      println("Edge case: There are no triangles possible");
      
      textRHC("There are less than three vertices, so there are no triangles possible.", 10, height - 20);
      println("There are less than three vertices, so there are no triangles possible.");

      drawPointsNormal();
    }
    else if(type == stepType.isntSimple)
    {
      println("Edge case: this polygon isn't simple");
      
      textRHC("The polygon isn't simple. The triangulation will likely be not be what is intended.", 10, height - 20);
      textRHC("However, steps generated will still be shown rather than exiting.", 10, height - 40);
      println("The polygon isn't simple. The triangulation will likely be not be what is intended. However, steps will still be shown rather than exiting.");

      drawPointsNormal();
    }
    else
    {
      println("Error: Step is not a recognized step type. Nothing will display for this step.");
      println("Please contact your local triangulation administrator");
    }
    
  }
}
