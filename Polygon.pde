

class Polygon {
  
   ArrayList<Point> p     = new ArrayList<Point>();
   ArrayList<Edge>  bdry = new ArrayList<Edge>();
     
   Polygon( ){  }
   
   
   boolean isClosed(){ return p.size() >= 3; }
   
   
   //Helper function, returns midpoint of an edge.
   Point getMidpoint(Edge e)
   {
     float x = (e.p0.getX() + e.p1.getX())/2;  //x coord of midpoint
     float y = (e.p0.getY() + e.p1.getY())/2;  //y coord of midpoint
     Point mid = new Point(x, y);   //midpoint of current diagonal
         
     return mid;
   }

   
   //How isSimple() works//
   //----- The logic -----
   //A simple polygon is one who's boundary edges don't intersect (outside shared vertices).
   //Each edge shares it's vertices with two edges. It's first vertex is shared with the edge before it, it's second vertex with the edge after it.
   //So each edge should intersect with only two edges, the edge before and the edge after.
   //Since my code only checks each edge with every edge after it, only the first edge will be checked with the edge "before" it, since the edge "before" it is the edge last in the list.
   //This means that when checking the first edge I expect 2 intersections, for every other edge I expect 1.
   //----- The code -----
   //-Gets each edge
   //-Checks to see how many times that edge intersects with edges after it
   //-return false if:
   //--we are checking the first edge, there are more than two intersections
   //--or we are checkuing any other edge, there is more than one intersection
   boolean isSimple(){
     if(!isClosed()) //if it isn't closed it isn't simple.
       return false;
     
     ArrayList<Edge> bounds = getBoundary();  //Stores boundaries.
     int size = bounds.size();  //Stores size, so I only call bounds.size() once.
     
     int intersectCount = 0;  //Stores the number of intersections per outer loop iteration.
     Edge outer = null;  //Stores the current edge for the outer loop (to only call bounds.get(i) once).
     
     for(int i = 0; i < size; i++)
     {
       intersectCount = 0;      //Reset intersectCount before the inner loop.
       outer = bounds.get(i);   //Get the edge for this iteration.
       
       for(int j = i + 1; j < size; j++)  //For each edge after the outer edge
       { 
         if(outer.intersectionTest(bounds.get(j)))  //Check if outer intersects that edge
           intersectCount++;  //If it does add an intersection
       }
       
       //if we aren't testing the first edge, only one intersection is expected.
       //if we are testing the first edge, there should be two.
       //Anything more than that should return false.
       if((intersectCount > 1 && i != 0) || (i == 0 && intersectCount > 2))
         return false;
     }
       
     return true;  //If we make it here, no edge had more intersections than it should. So the polygon is simple.
   }
   
   
   //----- The logic -----//
   //Even-odd algorithm
   //Pick a ray from the point to infinity
   //count number of intersections with boundary edges
   //if odd at the "end" (quotes since it's infinite), the point was inside.
   //if even at the "end", the point was outside.
   //-every jump goes from outside to inside or vice versa. 
   //-Since it always ends outside, we know that every two jumps it goes from outside to inside (1 jump) then inside to outside (2nd jump).
   //so if there is an odd number of intersections at the end, the point was inside.
   //if even at the end, the point was outside.
   //Straightforward but there's multiple issues
   //-rays: rays go from one point until infinity. 
       //Computers can't model infinity. So we need to use an edge instead of a ray, which means we need some endpoint for our testing edge.
   //-Degenerate intersections: some intersections don't actually go from inside to outside
       //Such as if the intersecting edge has the same slope as the testing edge. Or if the intersection point is a vertex of the bounds.
       //We'll need to test multiple edges, then pick the more frequent result. Odd or even.
   //-How to pick multiple edges: computers can't just pick a random location, and there's no guarantee those won't be degenerate cases too.
   //To solve both of these, we form a box encompassing, but not touching, the polygon.
   //-Since there are no vertices past the box, having our test edges end at the box means they don't have to be infinite. Since they won't cross the polygon again.
   //-We can generate testing endpoints from the box so they don't need to be random. I use 8 points: the 4 corners of the box and the 4 midpoints of the sides of the box.
   //-Then we can generate testing edges from p to each of those testing points.
   //-and finally we can see if we had more even/odd testing edges for our result.
   //----- The code -----//
   //get corners of the box
   //-find the highest (max) and lowest (min) x/y coordinates the polygon reaches.
   //-increase/decrease these by adding/subtracting 10% from the maxes/mins to ensure every point on the box is outside the polygon.
   //make the box and get the testing endpoints
   //-set 4 points for the corners. (first 4 test points)
   //-make 4 edges for the sides of the box
   //-get 4 midpoints, one per edge. (second set of 4 test points)
   //-add 8 testing edges to an arraylist, each edge is from p to one of the testing points
   //for each testing edge
   //-count the number of intersections with the boundary edges
   //-If there were more than 0 intersections:
   //  -increment odd if the number of intersections is odd. Otherwise increment even.
   //if odd and even are both still 0, return false
   //else return whichever is greater
   boolean pointInPolygon( Point p ){
     //I don't think this should ever be called on a nonclosed polygon. But just to be safe.
     if(!isClosed())
       return false;
     
     ArrayList<Edge> bdry = getBoundary();  //list of the boundary edges
     int size = bdry.size();                //save size so we don't need it again
     
     float minX = 0;  //Will store smallest X in the boundary
     float maxX = 0;  //Largest X
     float minY = 0;  //Smallest Y
     float maxY = 0;  //Largest Y
     
     //This section gets the bounds of the box
     Edge cEdge = null;  //To store current edge in the min/max loop
     for(int i = 0; i < size; i++)
     {
       cEdge = bdry.get(i);  //get current Edge
       
       maxX = max(cEdge.p0.getX(), cEdge.p1.getX(), maxX);  //if either point's X > maxX, set maxX to the largest X
       minX = min(cEdge.p0.getX(), cEdge.p1.getX(), minX);  //if either point's X < minX, set minX to the smallest X
       
       maxY = max(cEdge.p0.getY(), cEdge.p1.getY(), maxY);  //if either point's Y > maxY, set maxY to the largest Y
       minY = min(cEdge.p0.getY(), cEdge.p1.getY(), minY);  //if either point's Y < minY, set minY to the smallest Y
     }
     
     //We increase the maxes and decrease the mins to ensure the bounds of the box do not intercept the polygon
     maxX = maxX * 1.1;
     minX = minX * 0.9;
     maxY = maxY * 1.1;
     minY = minY * 0.9;
     
     //Now we make the box
     //first the corners
     Point topR = new Point(maxX, maxY);
     Point topL = new Point(minX, maxY);
     Point botR = new Point(maxX, minY);
     Point botL = new Point(minX, minY);
     
     //then the sides
     Edge top = new Edge(topL, topR);
     Edge bottom = new Edge(botL, botR);
     Edge rightSide = new Edge(botR, topR);
     Edge leftSide = new Edge(botL, topL);
     
     //then midpoints of the sides
     Point topMid = getMidpoint(top);
     Point botMid = getMidpoint(bottom);
     Point rightMid = getMidpoint(rightSide);
     Point leftMid = getMidpoint(leftSide);

     //Then we make test edges using those points
     ArrayList<Edge> testEdge = new ArrayList<Edge>();  //Stores the testing edges, each starts at p and ends at a testing point
     
     //Each of these lines adds an edge. From p, to each corner of the box.
     testEdge.add(new Edge(p, topR));   //top right corner
     testEdge.add(new Edge(p, topL));   //top left corner
     testEdge.add(new Edge(p, botR));   //bottom right corner
     testEdge.add(new Edge(p, botL));   //bottom left corner
     
     //Each of these lines adds an edge. From p, to each side's midpoint.
     testEdge.add(new Edge(p, botMid));  //midpoint of the bottom
     testEdge.add(new Edge(p, topMid));  //midpoint of the top
     testEdge.add(new Edge(p, rightMid));  //midpoint of the right side
     testEdge.add(new Edge(p, leftMid));  //midpoint of the left side

     //Now, finally, we test each test edge to see how many times each intersects the boundaries.
     //even intersection count = point is outside polygon
     //odd intersection count = point is inside polygon
     //Since we can't account for degenerate cases, see if even counts or odd counts happen more.
     int intersectCount = 0;  //intersection count for current edge
     int even = 0;  //number of edges with an even intersections count
     int odd = 0;   //number of edges with an odd intersection count
     cEdge = null;  //remember this and size exist
     for(int i = 0; i < testEdge.size(); i++) //for each test edge
     {
       cEdge = testEdge.get(i);  //get current test edge
       
       for(int j = 0; j < size; j++)  //for each boundary edge
       {
         if(cEdge.intersectionTest(bdry.get(j)))  //check if it intersects the current test edge
           intersectCount++;  //increment the count if it does
       }
       
       //see if we had an odd or even number of intersections
       if(intersectCount != 0)  //if the current test edge didn't intersect any boundaries, don't increment anything.
       {
         if(intersectCount % 2 == 0)  //if: it's even, else: it's odd
           even++;  //increment even if it's even
         else
           odd++;  //increment odd if it's odd
       }
       
       intersectCount = 0;  //reset count for the next iteration
     }
     
     //if the point is inside, every test edge should intersect
     //But I made it < 4 instead just in case.
     if(even + odd == 0 || even + odd < 4) //if: too few or zero test edges intersected a boundary edge, somehow
       return false;           //return false, impossible for an interior point to not intersect
     else if(even >= odd)      //if there's equal or more even intersections than odd
       return false;           //the point is external. Return false.
     else                      //there's more odd intersection counts
       return true;            //the point is internal. Return true.
   }
   
   
   //----- The logic -----
   //A valid diagonal:
   //-Is internal
   //-Doesn't intersect the boundaries (except endpoints)
   //Since *each* vertex of a valid diagonal belongs to two edges, a valid diagonal will intersect at least 4 boundary edges.
   //Also, a valid diagonal won't intersect any edges besides edges it shares vertices with.
   //-So a valid diagonal should only intersect 4 edges.
   //Once that is checked, we know the diagonal does not go in/out of the polygon. Since that would require an additional intersection.
   //This means that the diagonal is entirely internal or entirely external.
   //-So only a single point needs to be tested to find out if the diagonal is internal/external.
   //-I use the midpoint since it's easy to work-with/visualize.
   //----- The code -----
   //check how many times the diagonal intercects the boundary edges.
   //-if we exceed 4 intersections: return false early, don't need to check rest of the boundary edges
   //-if the diagonal has exactly 4 intersections and the diagonal's midpoint is inside the polygon: return true
   //-else: return false
   boolean isValidDiagonal(Edge test) 
   {
     ArrayList<Edge> bdry = getBoundary();
     
     int bSize = bdry.size();  //stores boundary size
     
     int intersectCount = 0;   //Will store how many times the diagonal intersects the boundaries.
     int j = 0;                //Stores the current boundary index being checked (since we want a while loop not a for loop)
     
     if(bSize <= 3)  //if there are 3 or less sides, there are no valid diagonals.
       return false;
       
     //This loop checks how many times the diagonal intercepts the boundaries.
     while(j < bSize && intersectCount <= 4)
     {
       if(test.intersectionTest(bdry.get(j)))  //Check if current diagonal intersects the boundaries.
         intersectCount++;  //If it does add an intersection
       
       j++;  //increment j to check the next boundary
     }
     
     if(intersectCount == 4 && pointInPolygon(getMidpoint(test))) //Check if the current diagonal's midpoint is inside the polygon         
       return true;  //The diagonal only intersects the boundaries 4 times and is internal. The diagonal is valid.
     else
       return false; //Diagonal has less than 4 intersections (shouldn't be possible), more than 4 intersectons, or is outside the polygon. Diagonal is invalid
   }
     
   
   //For each diagonal:
   //-if it is valid: add it to the return edge list
   //Pretty much all the work is done in the isValidDiagonal() function above.
   ArrayList<Edge> getDiagonals(){
     ArrayList<Edge> bdry = getBoundary();     
     ArrayList<Edge> ret  = new ArrayList<Edge>();
     
     if(bdry.size() <= 3)  //if there are 3 or less sides, there are no valid diagonals.
       return ret;         //return empty list
       
     ArrayList<Edge> diag = getPotentialDiagonals();  //stores potential diagonals
     int dSize = diag.size();  //stores number of potential diagonals
     Edge cDiag = null; //Stores current diagonal (loop below)
     
     //Check each diagonal to see if it is valid. Add valid diagonals to the return list.
     for(int i = 0; i < dSize; i++)
     {
       cDiag = diag.get(i);        //Gets the current diagonal
       if(isValidDiagonal(cDiag))  //Checks validity
            ret.add(cDiag);        //Adds it to return list if valid
     }
     return ret;
   }
   
   //For clockwise and ccw
   //-gets the area under the edge
   //-if area is positive, the edge is going left to right.
   //-abs(area) represents the area under the edge.
   //abs(area) of the top edges will be larger than the abs(area) under the bottom edges. Since area goes up as the y's increase.
   //-on cw polygons, the top edges all go from left to right. So the sum of the top edge areas is positive.
   //-on ccw polygons, the top goes from right to left. So the sum of the bottom edge areas is negative.
   //Since abs(area) of the top is always greater than the abs(area) of the bottom:
   //-on cw polygons, since the top is positive, summing all the areas will result in a positive value.
   //-on ccw polygons, since the top is negative, summing all the areas will result in a negative value.
   boolean ccw(){
     if( !isClosed() ) return false;
     if( !isSimple() ) return false;
     
     ArrayList<Edge> bounds = getBoundary();
     int size = bounds.size();  //stores size to not call .size() each iteration

     float area = 0;  //stores area under current edge
     Edge cEdge = null; //stores current edge
     float sum = 0;   //stores sum of every area
     
     //get the sum of areas
     for(int i = 0; i < size; i++)  //for each edge
     {
       cEdge = bounds.get(i);  //get current edge
       area = (cEdge.p1.getX() - cEdge.p0.getX()) * (cEdge.p1.getY() + cEdge.p0.getY());  //Find area under curve: if p1 x > p0 x, the result is positive (aka this edge is going left to right)
       sum += area;  //add the area to the sum
     }
     
     if(sum < 0)  //if sum is negative, top edge is going from right to left. so it is ccw.
       return true;
     else
       return false;
   }
   
   
   boolean cw(){
     if( !isClosed() ) return false;
     if( !isSimple() ) return false;
     
     ArrayList<Edge> bounds = getBoundary();
     int size = bounds.size();  //stores size to not call .size() each iteration

     float area = 0;  //stores area under current edge
     Edge cEdge = null; //stores current edge
     float sum = 0;   //stores sum of every area
     
     //get the sum of areas
     for(int i = 0; i < size; i++)  //for each edge
     {
       cEdge = bounds.get(i);  //get current edge
       area = (cEdge.p1.getX() - cEdge.p0.getX()) * (cEdge.p1.getY() + cEdge.p0.getY());  //Find area under curve: if p1 x > p0 x, the result is positive (aka this edge is going left to right)
       sum += area;  //add the area to the sum
     }
     
     if(sum > 0)  //if sum is positive, the top edge is going from left to right. so it is cw.
       return true;
     else
       return false;
   }
   
   
   //Same as area from project 1, which is the same as the area formula from M07 - polygons
   float area(){
     if(p.size() <= 2) //A line/point has an area of 0
       return 0;
     
     float area = 0;       //stores the area, of course
     int n = 0;            //stores the next point
     int size = p.size();  //stores the size (so p.size is only called once)
     
     for(int  i = 0; i < size; i++) //For each point in p...
     {
       n = (i + 1); //set n to the index of the next point
       
       if(n == size) //Check if n should wrap around to the first point
         n = 0; //set n to the first point.
       
       area += p.get(i).getX() * p.get(n).getY() - (p.get(i).getY() * p.get(n).getX());   //area = area + (iX * nY) - (iY * nX)
     }
     
     area = abs(area)/2;  //Divide in half. Abs because area is negative if the order is clockwise
     
     return area;  
   }
      
   
   //Helper function for the triangulation.
   //Gets the list of valid ears before any triangulation has occurred.
   //Used in the beginning.
   ArrayList<Integer> getEars()
   {
     ArrayList<Point> bounds = p;
     int size = bounds.size();
     ArrayList<Integer> ret = new ArrayList<Integer>();
     if(size <= 3)
       return ret;
      
     Point pPoint = null;  //stores the previous point
     Point nPoint = null;       //stores the next point
     
     for(int i = 0; i < size; i++)    //for each vertex
     {
        //gets the previous vertex
        if(i != 0)                      //if current vertex isn't the first vertex.
          pPoint = bounds.get(i - 1);   //then: it's previous vertex is the vertex before it.
        else                                       //else: current vertex is the first vertex.
          pPoint = bounds.get(bounds.size() - 1);  //then: previous vertex will be the last vertex.
      
        //gets the next vertex
        if(i != bounds.size() - 1)     //if current vertex isn't the last vertex
          nPoint = bounds.get(i + 1);  //then: it's next vertex is the vertex after it.
        else                           //else: current vertex is the last vertex.
          nPoint = bounds.get(0);      //then: next vertex is the first vertex
    
        //Ensure the diagonal from p to n is valid
        if(isValidDiagonal(new Edge(pPoint, nPoint)))
        {
          ret.add(i);  //it's valid. Add it
        }
     }
     return ret; //finished
   }
   
   //----- The logic -----//
   //ear-based triangulation - Same as what we covered in class
   //initialize ear status of the vertices
   //while there's more than 3 nonclipped vertices:
   //-take a vertex that is a valid ear tip
   //-clip it, add to output
   //-update status of adjacent edges
   //----- The code -----//
   //we have two lists:
   //-one keeps track of which vertices are currently valid ears - as in they pass the ear test helper function. (earList)
   //-one keeps track of "valid" vertices - aka ones which have not been clipped. (vList)
   //vList starts with every vertex in it, in order. earList starts with every vertex that is a valid ear
   //Until there are only 3 vertices left:
     //-get the vertex of the next valid ear
     //-get the two vertices before and after the ear
     //-add triangle formed by: (previous v, current v, and next v) to output
     //-remove current vertex from earList and vList
     //---this vertex will now be called the removed vertex
     //store the next v for later
     //Then, to retest:
       //-set the previous v as the current v
       //-find the new previous v
       //-find the new next v
       //-test if current v is an ear tip now
       //if current v is an ear tip now, and it is not present in earList (it wasn't an eartip before this iteration, but is now)
       //-add it to earList
       //if current v is not an ear tip now, and it was present in earList (it was an eartip before this iteration, but not anymore)
       //-remove it from earList
       //-If it is an ear tip now, and was an ear tip before, do nothing. If it is not an ear tip now, and was not an ear tip before, do nothing.
     //the previous point of the removed point has now been tested. Repeat retesting with the next point of the removed point.
   //end loop
   //There are now three vertices left in vList, these will form the final triangle
   //check v0v1, v0v2, and v1v2 to find a valid ear tip. Doesn't matter which one. Probably doesn't matter overall.
   //add triangle(v0, v1, v2) to the return list
   //return it
   ArrayList<Triangle> getTriangulation(){
    ArrayList<Triangle> ret = new ArrayList<Triangle>();  //list of triangles to return
    
    if(p.size() < 3) //no triangles possible
      return ret;
      
    else if(p.size() == 3) //one triangle possible
    {
      ret.add(new Triangle(p.get(0), p.get(1), p.get(2)));
      return ret;
    }
    
    ArrayList<Integer> vList = new ArrayList<Integer>(); //array list of vertexes that are unclipped
    for(int i = 0; i < p.size(); i++)
    {
      vList.add(i);  //add each vertex
    }
    
    ArrayList<Integer> earList = getEars();  //itialize the ear tip status of each vertex.
    if(earList.size() == 0)
      return ret;  //no valid ears, return empty. Shouldn't ever happen.
    
    //note that these represent indexes which correspond to points in the lists.
    //ex: earList = [3, ....]
    //    vList = [1, 2, 7, 9]
    //    currP = earList.get(0) == 9
    //    The corresponding index in vList is 3. Since vertex 9, stored is in vList[3]
    //    so index = 3
    //    nextP will be vertex 1, stored in vList[0]
    //    prevP will be vertex 7, stored in vList[2]
    int currP = 0; //Index in earList that stores the current ear tip point
    int index = 0; //Index in vList that matches earList[currP]
    int prevP = 0; //will be the point, in vList, that comes before currP
    int nextP = 0; //will be the point in vList that comes after currP
    int storedNext = 0; //stores nextP temporarily when we recheck prevP
    
    while(vList.size() > 3 && earList.size() > 0)  //until there are 3 or less vertices left
    {
      currP = earList.get(0);        //gets the next ear tip point, first point in earList
      index = vList.indexOf(currP);  //index in vList of current point
      
      //gets the point in vList before currP
      if(index != 0)                   //if: currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                    //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      
      //gets the point in vList after currP
      if(index != vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(index + 1);   //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(0);  //then: next point is the first vertex in vList
    
      //Finished finding previous and next points.
    
      ret.add(new Triangle(p.get(prevP), p.get(currP), p.get(nextP)));  //adds the ear triangle to the return list
    
      //now we need to clip currP then retest prevP and nextP
      vList.remove(index); //clip currP
      earList.remove(0); //remove it from the earList
    
      //retest prevP and nextP
      //to retest prevP, need the points before and after prevP in vList
      //luckily, the if/elses above do that. 
      //So we will store nextP for later. Then move prevP to currP
      //then reuse the code above to find the new prevP and nextP
      //Then we will move our stored nextP to currP and reuse the code again
      storedNext = nextP;  //store next p to test it after
      
      //make prevP the new current point
      currP = prevP;    //make currP = prevP
      index = vList.indexOf(currP); //get index of prevP (which is now currP)
      
      //gets the point in vList before prevP (which is now currP)
      if(index != 0)        //if currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                 //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      
      //gets the point in vList after currP
      if(index == vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(0); //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(index + 1);  //then: next point is the first vertex in vList
    
      //retest the ear
      if(isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && !earList.contains(currP))   //if: the ear is valid now and the ear was not valid before
        earList.add(currP);   //then: add it to the valid ear list
      else if(!isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && earList.contains(currP))  //if: the ear is not valid now and the ear was valid before
        earList.remove(earList.indexOf(currP));  //remove it from the valid ear list (need the index)
      else
      {
        //The ear is valid now and was valid before: do nothing OR
        //The ear isn't valid now and wasn't valid before: do nothing
      }
    
      currP = storedNext;  //retrieve our stored nextP. Then repeat the test
      index = vList.indexOf(currP); //get index of prevP (which is now currP)
      
      //gets the point in vList before prevP (which is now currP)
      if(index != 0)        //if currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                 //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      
      //gets the point in vList after currP
      if(index == vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(0); //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(index + 1);  //then: next point is the first vertex in vList
    
      //retest the ear
      if(isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && !earList.contains(currP))   //if: the ear is valid now and the ear was not valid before
        earList.add(currP);   //then: add it to the valid ear list
      else if(!isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && earList.contains(currP))  //if: the ear is not valid now and the ear was valid before
        earList.remove(earList.indexOf(currP));  //remove it from the valid ear list (need the index)
      else
      {
        //The ear is valid now and was valid before: do nothing
        //The ear isn't valid now and wasn't valid before: do nothing
      }
    }
    
    //All but 3 points are left. Whichever one of these edges are valid is the edge of the ear. With the not included vertex as the ear tip.
    //If any of them are valid, we make a triangle from the ear.
    //Pretty sure it doesn't matter if the polygon is simple. Probably doesn't matter either way.
    if(isValidDiagonal(new Edge(p.get(vList.get(0)), p.get(vList.get(1)))) || isValidDiagonal(new Edge(p.get(vList.get(0)), p.get(vList.get(2)))) || isValidDiagonal(new Edge(p.get(vList.get(1)), p.get(vList.get(2)))))
      ret.add(new Triangle(p.get(vList.get(0)), p.get(vList.get(1)), p.get(vList.get(2))));
     
     return ret;
   }

//Code specific to the final project//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Get ears with steps helper function
//Instead of getting a list of ears and returns that, it gets a list of ears, and attaches it to a step
//It also attaches a list of edges (diagList) which are the diagonals for the valid ears.
  //I could generate the diagonals after, but, they are made here to test them anyways. Might as well store them.
//Then I return the step. The triangulation with steps algorithm gets the ear list from the step.
 Step getEarSteps(ArrayList<Integer> VL)  //Since I'm making the step here I have to include the vList to attach to it
 {
   ArrayList<Point> bounds = p;
   int size = bounds.size();
   
   //**Makes the step to return, sets the type, and attaches the vList.
   Step ret = new Step(this);
   ret.setVList(VL);
   ret.setType(stepType.vToEList);

   //**Makes the two lists which will be attached to our step.
   ArrayList<Integer> earList = new ArrayList<Integer>();
   ArrayList<Edge> diagList = new ArrayList<Edge>();
   
   if(size <= 3)
     return ret;
    
   Point pPoint = null;    //stores the previous point
   Point nPoint = null;    //stores the next point
   
   for(int i = 0; i < size; i++)    //for each vertex
   {
      //gets the previous vertex
      if(i != 0)                      //if current vertex isn't the first vertex.
        pPoint = bounds.get(i - 1);   //then: it's previous vertex is the vertex before it.
      else                                       //else: current vertex is the first vertex.
        pPoint = bounds.get(bounds.size() - 1);  //then: previous vertex will be the last vertex.
    
      //gets the next vertex
      if(i != size - 1)              //if current vertex isn't the last vertex
        nPoint = bounds.get(i + 1);  //then: it's next vertex is the vertex after it.
      else                           //else: current vertex is the last vertex.
        nPoint = bounds.get(0);      //then: next vertex is the first vertex
  
      //Ensure the diagonal from p to n is valid
      if(isValidDiagonal(new Edge(pPoint, nPoint)))
      {
        earList.add(i);  //it's valid. Add it
        //**Also add it to the diagonal list
        diagList.add(new Edge(pPoint, nPoint));
      }
   }
   
   //**Attach our lists and return
   ret.setEarList(earList);
   ret.setDiagList(diagList);
   return ret; //finished
 }


//Triangulation with steps function//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Most of the code is the same as triangulation without steps. New comments have ** in front of them.
//Eseentially, the algorithm does the entire triangulation without stopping. But it outputs stages to display to the user as a steps list.
//Note that NONE of the steps actually *perform* the steps of the algorithm. They simply display information to the user.
//Don't think of this function as going "step by step". It runs through the whole thing and outputs a sequence of 'states' to be displayed afterwards.
//The information for the states is attached to the states (such as vList, earList, and triList)
//Most of the code is the same as the project, additions are marked with **
ArrayList<Step> getTriangulationSteps(){
    ArrayList<Triangle> ret = new ArrayList<Triangle>();  //list of triangles to return
    ArrayList<Step> steps = new ArrayList<Step>();  //**list of steps to return
    
    if(p.size() < 3) //no triangles possible
    {
      Step toAdd = new Step(this);
      toAdd.setType(stepType.noTrianglePossible);  //**Add step for this edge case
      steps.add(toAdd);
      
      return steps;  //**Return because that's all we can do
    }
    else if(p.size() == 3) //one triangle possible
    {
      Step toAdd = new Step(this);
      toAdd.setType(stepType.oneTrianglePossible); //**Add step for this edge case
      
      ret.add(new Triangle(p.get(0), p.get(1), p.get(2)));  //make single triangle and add to triangle list
      toAdd.setTriList(ret);  //**Attach it to the step
      steps.add(toAdd);  //**Add the step
      
      return steps;  //**Return because that's all we can do
    }
    
    //**If the polygon isn't simple, add a step notifying the user.
    //**I debated on stopping the algorithm here but decided against it.
    if(!isSimple())
    {
      Step notSimple = new Step(this);
      notSimple.setType(stepType.isntSimple);
      steps.add(notSimple);
    }
    
    ArrayList<Integer> vList = new ArrayList<Integer>(); //array list of vertexes that are unclipped
    for(int i = 0; i < p.size(); i++)
    {
      vList.add(i);  //add each vertex
    }
    
    //**Add step for setting up v List
    Step setUpVList = new Step(this);  //Add step
    setUpVList.setType(stepType.vToVList);  //Attach things
    setUpVList.setVList(vList);
    steps.add(setUpVList);  //Add to the step list
    
    //**Add step for setting up ear list
    Step setUpEarList = new Step(this);
    //**Use the helper function to get the ear list and diag list
    setUpEarList = getEarSteps(vList);
    //**Make an ear list for the triangulation
    ArrayList<Integer> earList = new ArrayList<Integer>();
    //**Copy it over from the step
    for(int i : setUpEarList.getEarList())
      earList.add(i);
    //**Add step to list
    steps.add(setUpEarList);  
    
    if(earList.size() == 0)
      return steps;  //no valid ears, return now. Shouldn't ever happen.
    
    //**Add step start main loop and attach things, add to list.
    //**Explains how the main loop does.
    Step startLoop = new Step(this);
    startLoop.setType(stepType.startMainLoop);
    startLoop.setVList(vList);
    startLoop.setEarList(earList);
    steps.add(startLoop);
    
    //note that these represent indexes which correspond to points in the lists.
    //ex: earList = [3, ....]
    //    vList = [1, 2, 7, 9]
    //    currP = earList.get(0) == 9
    //    The corresponding index in vList is 3. Since vertex 9, stored is in vList[3]
    //    so index = 3
    //    nextP will be vertex 1, stored in vList[0]
    //    prevP will be vertex 7, stored in vList[2]
    int currP = 0; //Index in earList that stores the current ear tip point
    int index = 0; //Index in vList that matches earList[currP]
    int prevP = 0; //will be the point, in vList, that comes before currP
    int nextP = 0; //will be the point in vList that comes after currP
    int storedNext = 0; //stores nextP temporarily when we recheck prevP
    
    while(vList.size() > 3 && earList.size() > 0)  //until there are 3 or less vertices left
    {
      currP = earList.get(0);        //gets the next ear tip point, first point in earList
      index = vList.indexOf(currP);  //index in vList of current point
      
      //gets the point in vList before currP
      if(index != 0)                   //if: currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                    //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      
      //gets the point in vList after currP
      if(index != vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(index + 1);   //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(0);  //then: next point is the first vertex in vList
    
      //Finished finding previous and next points.
    
      ret.add(new Triangle(p.get(prevP), p.get(currP), p.get(nextP)));  //adds the ear triangle to the return list
    
      //now we need to clip currP then retest prevP and nextP
      vList.remove(index); //clip currP
      earList.remove(0); //remove it from the earList
      
      //**Adds a step for adding a new triangle
      Step addTriangle = new Step(this);
      addTriangle.setType(stepType.addTriangle);
      //**Attaches things
      addTriangle.setEarList(earList);
      addTriangle.setVList(vList);
      addTriangle.setTriList(ret);
      addTriangle.setRetestV(currP+1);  //Stores which vertex got added (remember the actual index is 1 less so we add 1)
      
      //**Add step to list
      steps.add(addTriangle);

      //**Don't retest if we're finished
      if(vList.size() <= 3)
        break;

      //retest prevP and nextP
      //to retest prevP, need the points before and after prevP in vList
      //luckily, the if/elses above do that. 
      //So we will store nextP for later. Then move prevP to currP
      //then reuse the code above to find the new prevP and nextP
      //Then we will move our stored nextP to currP and reuse the code again
      storedNext = nextP;  //store next p to test it after
      
      //make prevP the new current point
      currP = prevP;    //make currP = prevP
      index = vList.indexOf(currP); //get index of prevP (which is now currP)
      
      //**Create the step for retesting the previous vertex and add info to it
      Step retestPrev = new Step(this);
      retestPrev.setType(stepType.retestV);
      retestPrev.setVList(vList);
      retestPrev.setTriList(ret);
      retestPrev.setRetestV(currP+1);

      //gets the point in vList before prevP (which is now currP)
      if(index != 0)        //if currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                 //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      //gets the point in vList after currP
      if(index == vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(0); //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(index + 1);  //then: next point is the first vertex in vList
      
      //**Gets the temp edge
      Edge temp = new Edge(p.get(prevP), p.get(nextP));
      //**Determine if it's valid
      boolean isValid = isValidDiagonal(temp);
      boolean wasInEList = earList.contains(currP);
      
      //retest the ear
      if(isValid && !wasInEList)   //if: the ear is valid now and the ear was not valid before
        earList.add(currP);   //then: add it to the valid ear list
      else if(!isValid && wasInEList)  //if: the ear is not valid now and the ear was valid before
        earList.remove(earList.indexOf(currP));  //remove it from the valid ear list (need the index)
      else
      {
        //The ear is valid now and was valid before: do nothing OR
        //The ear isn't valid now and wasn't valid before: do nothing
      }
      
      //**Add this info to the step
      retestPrev.setEarList(earList);
      retestPrev.addDiag(temp);
      retestPrev.setValidDiagonalStatus(isValid);
      retestPrev.setWasInE(wasInEList);
      //**Add the step
      steps.add(retestPrev);
      
      //Retest the other vertex
      currP = storedNext;  //retrieve our stored nextP. Then repeat the test
      index = vList.indexOf(currP); //get index of prevP (which is now currP)
      
      //**Create the step for retesting the next vertex and add info to it
      Step retestNext = new Step(this);
      retestNext.setType(stepType.retestV);
      retestNext.setVList(vList);
      retestNext.setTriList(ret);
      retestNext.setRetestV(currP+1);
            
      //gets the point in vList before prevP (which is now currP)
      if(index != 0)        //if currP isn't the first vertex in vList
        prevP = vList.get(index - 1);  //then: it's previous point is the vertex before it in vList
      else                                 //else: index is the first vertex in vList
        prevP = vList.get(vList.size() - 1);  //then: previous point will be the last valid vertex.
      
      //gets the point in vList after currP
      if(index == vList.size() - 1)     //if cEarP isn't the final vertex in vList
        nextP = vList.get(0); //then: it's next point is the vertex in vList after it
      else                     //else: index is the final vertex in vList
        nextP = vList.get(index + 1);  //then: next point is the first vertex in vList
    
      //**Gets the temp edge
      temp = new Edge(p.get(prevP), p.get(nextP));
      //**Determine if it's valid
      isValid = isValidDiagonal(temp);
      wasInEList = earList.contains(currP);

      //retest the ear
      if(isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && !wasInEList)   //if: the ear is valid now and the ear was not valid before
        earList.add(currP);   //then: add it to the valid ear list
      else if(!isValidDiagonal(new Edge(p.get(prevP), p.get(nextP))) && wasInEList)  //if: the ear is not valid now and the ear was valid before
        earList.remove(earList.indexOf(currP));  //remove it from the valid ear list (need the index)
      else
      { //The ear is valid now and was valid before: do nothing
        //The ear isn't valid now and wasn't valid before: do nothing
      }
      
      //**Add this info to the step
      retestNext.setEarList(earList);
      retestNext.addDiag(temp);
      retestNext.setValidDiagonalStatus(isValid);
      retestNext.setWasInE(wasInEList);
      //**Add the step
      steps.add(retestNext);
      
      //End main loop iteration
    }
    
    //All but 3 points are left. Whichever one of these edges are valid is the edge of the ear. With the not included vertex as the ear tip.
    //If any of them are valid, we make a triangle from the ear.
    //Pretty sure it doesn't matter if the polygon is simple. Probably doesn't matter either way.
    if(isValidDiagonal(new Edge(p.get(vList.get(0)), p.get(vList.get(1)))) || isValidDiagonal(new Edge(p.get(vList.get(0)), p.get(vList.get(2)))) || isValidDiagonal(new Edge(p.get(vList.get(1)), p.get(vList.get(2)))))
      ret.add(new Triangle(p.get(vList.get(0)), p.get(vList.get(1)), p.get(vList.get(2))));
     
     //**Add a step for adding the final triangle, attach stuff, add to list
     Step finalT = new Step(this);
     finalT.setType(stepType.finalTriangle);
     finalT.setTriList(ret);
     finalT.setVList(vList);
     finalT.setEarList(earList);
     steps.add(finalT);
     
     //**Add endingStep
     Step theE = new Step(this);
     theE.setType(stepType.theEnd);
     theE.setTriList(ret);
     steps.add(theE);
     
     return steps;
   }
   
   //The below are all built in
   ArrayList<Edge> getBoundary(){
     return bdry;
   }


   ArrayList<Edge> getPotentialDiagonals(){
     ArrayList<Edge> ret = new ArrayList<Edge>();
     int N = p.size();
     for(int i = 0; i < N; i++ ){
       int M = (i==0)?(N-1):(N);
       for(int j = i+2; j < M; j++ ){
         ret.add( new Edge( p.get(i), p.get(j) ) );
       }
     }
     return ret;
   }
   
   void draw(){
     //println( bdry.size() );  commented out so it doesn't flood the console.
     for( Edge e : bdry ){
       e.draw();
     }
   }
   
   
   void addPoint( Point _p ){ 
     p.add( _p );
     if( p.size() == 2 ){
       bdry.add( new Edge( p.get(0), p.get(1) ) );
       bdry.add( new Edge( p.get(1), p.get(0) ) );
     }
     if( p.size() > 2 ){
       bdry.set( bdry.size()-1, new Edge( p.get(p.size()-2), p.get(p.size()-1) ) );
       bdry.add( new Edge( p.get(p.size()-1), p.get(0) ) );
     }
   }

}
