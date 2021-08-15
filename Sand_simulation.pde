import controlP5.*;

int cellSize = 0, Scale_factor = 6, selectedState = 0, pastMousePosX, pastMousePosY;
int verticalNumberOfCells, horizontalNumberOfCells, lineSize = 2;
boolean stopStart = false;
Cells[][] world;
PFont arialFont;
float array[];
ControlP5 cp5;

void setup() 
{ 
  size(1920, 520, P2D);
  cp5 = new ControlP5(this);
  surface.setResizable(true);
  arialFont = createFont("arial", 20); 
  strokeWeight(1);
  cellReset();
  stroke(0);
}

int gcd(int a, int b)
{
  // Everything divides 0
  if (a == 0 || b == 0)
    return 0;

  // base case
  if (a == b)
    return a;

  // a is greater
  if (a > b)
    return gcd(a - b, b);
  return gcd(a, b - a);
}

void keyPressed() 
{
  if ((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) 
  {
    if (key == 'A' ||key == 'a')
    {
      selectedState = 0; //AIR
    } else if (key == 'R' ||key == 'r')
    {
      selectedState = 1; //ROCK
    } else if (key == 'S' ||key == 's')
    {
      selectedState = 2; //SAND
    } else if (key == 'W' ||key == 'w')
    {
      selectedState = 3; //WATER
    } else if (key == 'O' ||key == 'o')
    {
      selectedState = 4; //OIL
    } else if (key == 'F' ||key == 'f')
    {
      selectedState = 5; //FIRE
    } else if (key == 'T' ||key == 't')
    {
      cellReset();
    } else if (key == 'P' ||key == 'p')
    {
      stopStart = !stopStart;//pause
    }
  }
}

void mouseWheel(MouseEvent event) {
  lineSize = (lineSize + event.getCount()) > 0 ? lineSize + event.getCount() :  1;

  println(lineSize);
}

void brush()
{
  if (mousePressed && mouseY < height && mouseX < width && mouseY >= 0 && mouseX >= 0)
  {
    linearInterpolation();
  }

  //pastMousePosX = (pastMousePosX > horizontalNumberOfCells) ? horizontalNumberOfCells - 1 : ((pastMousePosX < 0) ? 0 : mouseX/cellSize); // I don't know why this ternary operator doesn't work.
  //pastMousePosY = (pastMousePosY > verticalNumberOfCells) ? verticalNumberOfCells - 1 : ((pastMousePosY < 0) ? 0 : mouseY/cellSize);

  pastMousePosX = mouseX/cellSize;
  pastMousePosY = mouseY/cellSize;
}

void linearInterpolation()
{

  int newMousePosX = mouseX/cellSize, newMousePosY = mouseY/cellSize;
  int xIncrease = pastMousePosX < newMousePosX ? 1 : -1;  
  int yIncrease = pastMousePosY < newMousePosY ? 1 : -1;
  int deltaX =  abs(newMousePosX - pastMousePosX);
  int deltaY = -abs(newMousePosY - pastMousePosY);
  int error = deltaX + deltaY;

  while (true && pastMousePosX < horizontalNumberOfCells && pastMousePosX > -1 && pastMousePosY < verticalNumberOfCells && pastMousePosY > -1)
  {
    world[pastMousePosX][pastMousePosY].state = selectedState;

    if ((pastMousePosX == newMousePosX) && (pastMousePosY == newMousePosY)) break;

    int doubleError = 2 * error;

    if (doubleError >= deltaY) 
    { 
      error += deltaY;
      pastMousePosX += xIncrease;
    }

    if (doubleError <= deltaX)
    {
      error += deltaX;
      pastMousePosY += yIncrease;
    }
  }
}

void cellReset()
{
  int groundHeight = 2;
  cellSize = int(gcd(width, height)/Scale_factor);

  verticalNumberOfCells = int(height/cellSize);
  horizontalNumberOfCells = int(width/cellSize);
  world = new Cells[horizontalNumberOfCells][verticalNumberOfCells];

  for (int i = 0; i < verticalNumberOfCells - groundHeight; i++)
  {
    for (int j = 0; j < horizontalNumberOfCells; j++)
    {
      world[j][i] = new Cells(j * cellSize, i * cellSize, 0, cellSize); //(i * verticalNumberOfCells + j) % 6
    }
  }

  for (int i = verticalNumberOfCells - groundHeight; i < verticalNumberOfCells; i++)
  {
    for (int j = 0; j < horizontalNumberOfCells; j++)
    {
      world[j][i] = new Cells(j * cellSize, i * cellSize, 1, cellSize); //(i * verticalNumberOfCells + j) % 6
    }
  }

  for (int y = verticalNumberOfCells/2; y < verticalNumberOfCells/2 + 10; ++y) {
    for (int x = horizontalNumberOfCells/2; x < horizontalNumberOfCells/2 + 10; ++x) {
      world[x][y].state = 2;
    }
  }
}

void update()
{
  for (int i = verticalNumberOfCells - 1; i > 0; i--)
  {
    for (int j = 0; j < horizontalNumberOfCells; j++)
    {
      world[j][i].update(false);
    }
  }

  for (int y = verticalNumberOfCells - 1; y > 0; y--)
  {
    for (int x = 0; x < horizontalNumberOfCells; x++)
    {
      if (world[x][y].hasMoved)
      {
        continue;
      } else if (world[x][y].state == 0 || world[x][y].state == 1)
      {
        world[x][y].hasMoved = true;
        continue;
      } else if (canMove(world[x][y].state, x, y + 1)) 
      {
        move(x, y, x, y + 1);
        continue;
      } else
      {

        boolean checkLeftFirst = world[x][y].velocityX == -1 ? true : (world[x][y].velocityX == 1 ? false : (checkLeftFirst = (random(1) < 0.5f) ? true: false));

        if (checkLeftFirst) 
        {
          if (canMove(world[x][y].state, x - 1, y) && canMove(world[x][y].state, x - 1, y + 1)) 
          {
            move(x, y, x - 1, y + 1); // Next, try to move down+left
          } else if (canMove(world[x][y].state, x + 1, y) && canMove(world[x][y].state, x + 1, y + 1)) 
          {
            move(x, y, x + 1, y + 1);// Next, try to move down+right
          }
        } else 
        {
          if (canMove(world[x][y].state, x + 1, y) && canMove(world[x][y].state, x + 1, y + 1)) 
          {
            move(x, y, x + 1, y + 1);// Next, try to move down+right
          } else if (canMove(world[x][y].state, x - 1, y) && canMove(world[x][y].state, x - 1, y + 1)) 
          {
            move(x, y, x - 1, y + 1); // Next, try to move down+left
          }
        }


        if ((world[x][y].state == 3 || world[x][y].state == 4) && y < verticalNumberOfCells - 1)
        {
          // If we're above a layer of water, spread out to left and right
          if (checkLeftFirst) 
          {
            if (canMove(world[x][y].state, x - 1, y)) 
            {  
              move(x, y, x - 1, y);// Next, try to move left
            } else if (canMove(world[x][y].state, x + 1, y)) 
            {   
              move(x, y, x + 1, y);// Next, try to move right
            }
          } else 
          {
            if (canMove(world[x][y].state, x + 1, y)) 
            {
              move(x, y, x + 1, y);// Next, try to move right
            } else if (canMove(world[x][y].state, x - 1, y)) 
            {
              move(x, y, x - 1, y);// Next, try to move left
            }
          }
        }
      }
    }
  }
}


void move(int fromX, int fromY, int toX, int toY) 
{
  int oldState = world[toX][toY].state;

  world[toX][toY].state = world[fromX][fromY].state;
  world[fromX][fromY].state = oldState;
  world[fromX][fromY].hasMoved = true;
  world[toX][toY].hasMoved = true;

  world[fromX][fromY].velocityX = 0;
  world[fromX][fromY].velocityY = 0;

  if (toX > fromX) 
  { 
    world[toX][toY].velocityX = 1;
  } else if (toX < fromX) 
  { 
    world[toX][toY].velocityX = -1;
  } else 
  { 
    world[toX][toY].velocityX = 0;
  }

  if (toY > fromY) 
  { 
    world[toX][toY].velocityY = 1;
  } else if (toY < fromY) 
  { 
    world[toX][toY].velocityY = -1;
  } else 
  { 
    world[toX][toY].velocityY = 0;
  }
}


boolean canMove(int state, int positionX, int positionY)
{
  if (positionX < 0 || positionX >= horizontalNumberOfCells || positionY < 0 || positionY >= verticalNumberOfCells)
  {
    return false;
  }

  int otherSubstance = world[positionX][positionY].state;

  if (otherSubstance == 0)
  {
    return true;
  } else if (otherSubstance == 1)
  {
    return false;
  } else if (state == 2 && otherSubstance == 3 && random(1) < 0.5)
  {
    return true;
  } else if (state == 2 && otherSubstance == 4 && random(1) < 0.5)
  {
    return true;
  } else if (state == 3 && otherSubstance == 4)
  {
    return true;
  } else if (state == 5) 
  {
    return (otherSubstance == 4);
  }


  return false;
}

void draw() 
{

  brush();

  if (stopStart)
  {
    update();
  }

  for (int i = 0; i < verticalNumberOfCells; i++)
  {
    for (int j = 0; j < horizontalNumberOfCells; j++)
    {
      world[j][i].drawing();
    }
  }

  fill(0);
  textAlign(LEFT);
  textLeading(18);
  textFont(arialFont, 20);
  String advice = " A - air\n R - rock\n S - sand\n W - water\n O - oil\n F - fire\n T - restart\n P - pause\n";

  text(advice, 10, 10, 365, 410);
}
