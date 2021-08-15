class Cells
{
  
  boolean hasMoved = false;
  int size = 10, positionX , positionY, velocityX , velocityY;
  int state = 0; // 0 - AIR, 1 - ROCK, 2 - SAND, 3 - WATER, 4 - OIL, 5 - FIRE

  Cells(int posX_, int posY_, int state_, int size_)
  {
    size = size_;
    state = state_; 
    positionX = posX_;
    positionY = posY_;
  }

  void reset(int posX_, int posY_)
  {
    positionX = posX_;
    positionY = posY_;
  }

  void update(boolean moved)
  {
    hasMoved = moved;
  }

  void drawing()
  {
    switch (state) {
    case 0: 
      fill(255, 255, 255); 
      break;
    case 1: 
      fill(128, 128, 128); 
      break;
    case 2: 
      fill(255, 255, 0); 
      break;
    case 3: 
      fill(0, 0, 255); 
      break;
    case 4: 
      fill(160, 70, 160); 
      break;
    case 5: 
      fill(255, 70, 0); 
      break;
    default: 
      fill(255, 0, 0); 
      break;
    }

    rect(positionX, positionY, size, size);
  }
}
