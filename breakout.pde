// Breakout Game in Processing (No Classes, fixed arrays)
// Single hard mode, normal paddle and ball speed

// Game modes
int mode;
final int INTRO = 0;
final int PLAY = 1;
final int PAUSE = 2;
final int GAMEOVER = 3;
final int WIN = 4;

// Window
final int WIDTH = 800;
final int HEIGHT = 600;

// Paddle
float paddleX;
float paddleW = 120;
boolean leftKey, rightKey;

// Balls (max 100)
int ballCount;
float[] bx = new float[100];
float[] by = new float[100];
float[] bvx = new float[100];
float[] bvy = new float[100];
float ballR = 10;

// Respawn timer
int respawnCounter;

// Red orb
boolean redActive;
float redX, redY;
float redSpeed = 3;
int orbTimer;

// Bricks
int brickCount;
float[] brickX;
float[] brickY;
float[] brickR;
color[] brickC;
boolean[] brickAlive;

// Intro flash
int titleCounter;

void settings() {
  size(WIDTH, HEIGHT);
}

void setup() {
  initBricks();
  mode = INTRO;
}

void draw() {
  background(0);
  if (mode == INTRO) intro();
  if (mode == PLAY) game();
  if (mode == PAUSE) pauseMode();
  if (mode == GAMEOVER) gameOver();
  if (mode == WIN) win();
}

// Handle mouse clicks per mode
void mousePressed() {
  if (mode == INTRO) introClicks();
  else if (mode == PLAY) gameClicks();
  else if (mode == PAUSE) pauseClicks();
  else if (mode == GAMEOVER) gameOverClicks();
  else if (mode == WIN) winClicks();
}

void keyPressed() {
  if (mode == PLAY) {
    if (key == 'p' || key == 'P') mode = PAUSE;
    if (keyCode == LEFT) leftKey = true;
    if (keyCode == RIGHT) rightKey = true;
  }
}

void keyReleased() {
  if (mode == PLAY) {
    if (keyCode == LEFT) leftKey = false;
    if (keyCode == RIGHT) rightKey = false;
  }
}

// -------- BRICKS INITIALIZATION --------
void initBricks() {
  int rows = 6;
  brickCount = rows * (rows + 1) / 2;
  brickX = new float[brickCount];
  brickY = new float[brickCount];
  brickR = new float[brickCount];
  brickC = new color[brickCount];
  brickAlive = new boolean[brickCount];
  int index = 0;
  float sizeB = 50;
  float startY = 50;
  float spacing = 20;
  for (int row = rows; row > 0; row--) {
    float offsetX = (WIDTH - row * (sizeB + spacing)) / 2;
    for (int i = 0; i < row; i++) {
      brickX[index] = offsetX + i * (sizeB + spacing) + sizeB/2;
      brickY[index] = startY + (rows - row) * (sizeB + spacing) + sizeB/2;
      brickR[index] = sizeB/2;
      float rnd = random(1);
      if (rnd < 0.5) brickC[index] = color(random(100,200), 0, random(100,200));
      else brickC[index] = color(random(200,255), 0, 0);
      brickAlive[index] = true;
      index++;
    }
  }
}

// -------- INTRO --------
void intro() {
  titleCounter++;
  int phase = titleCounter % 60;
  if (phase < 30) fill(0,255,0);
  else fill(255,255,0);
  textAlign(CENTER, CENTER);
  textSize(64);
  text("BREAKOUT", WIDTH/2, HEIGHT/2);
}

void introClicks() {
  initGame();
  mode = PLAY;
}

// -------- GAME --------
void initGame() {
  paddleX = WIDTH/2;
  ballCount = 1;
  bx[0] = WIDTH/2;
  by[0] = HEIGHT/2;
  bvx[0] = 3;
  bvy[0] = -3;
  respawnCounter = 0;
  orbTimer = 0;
  redActive = false;
}

void game() {
  fill(255);
  textSize(20);
  textAlign(LEFT, TOP);
  text("Balls: " + ballCount, 10, 10);

  if (leftKey) paddleX -= 7;
  if (rightKey) paddleX += 7;
  paddleX = constrain(paddleX, paddleW/2, WIDTH - paddleW/2);
  fill(255); noStroke(); arc(paddleX, HEIGHT, paddleW, paddleW, PI, TWO_PI);

  orbTimer++;
  if (orbTimer >= 900) {
    redActive = true; redX = random(WIDTH); redY = 0; orbTimer = 0;
  }
  if (redActive) {
    fill(255,0,0); ellipse(redX, redY, 15, 15);
    redY += redSpeed;
    float dx = redX - paddleX;
    float dy = redY - HEIGHT;
    float d = sqrt(dx*dx + dy*dy);
    if (d <= ballR + paddleW/2) {
      int c = ballCount;
      for (int i = 0; i < c; i++) {
        bx[c] = bx[i]; by[c] = by[i];
        bvx[c] = -bvx[i]; bvy[c] = bvy[i];
        c++;
      }
      ballCount = c;
      redActive = false;
    }
    if (redY > HEIGHT) redActive = false;
  }

  for (int i = 0; i < ballCount; i++) {
    bx[i] += bvx[i]; by[i] += bvy[i];
    if (bx[i] < ballR || bx[i] > WIDTH-ballR) bvx[i] = -bvx[i];
    if (by[i] < ballR) bvy[i] = -bvy[i];
    float dx = bx[i] - paddleX;
    float dy = by[i] - HEIGHT;
    float dist = sqrt(dx*dx + dy*dy);
    if (dist <= ballR + paddleW/2 && bvy[i] > 0) {
      float sp = sqrt(sq(bvx[i]) + sq(bvy[i]));
      if (dist > 0) { bvx[i] = dx/dist * sp; bvy[i] = dy/dist * sp; }
    }
    if (by[i] > HEIGHT) {
      for (int j = i; j < ballCount-1; j++) {
        bx[j] = bx[j+1]; by[j] = by[j+1]; bvx[j] = bvx[j+1]; bvy[j] = bvy[j+1];
      }
      ballCount--; i--; respawnCounter = 60;
    }
  }

  if (ballCount == 0 && respawnCounter > 0) {
    respawnCounter--;
    fill(255); textSize(32); textAlign(CENTER, CENTER);
    text(ceil(respawnCounter/60.0), WIDTH/2, HEIGHT/2);
    if (respawnCounter == 0) {
      ballCount = 1;
      bx[0] = paddleX; by[0] = HEIGHT - 30;
      bvx[0] = 3; bvy[0] = -3;
    }
  }

  boolean hit = false;
  for (int j = 0; j < brickCount && !hit; j++) {
    if (brickAlive[j]) {
      for (int i = 0; i < ballCount && !hit; i++) {
        float dx = bx[i] - brickX[j];
        float dy = by[i] - brickY[j];
        float d = sqrt(dx*dx + dy*dy);
        if (d <= ballR + brickR[j]) {
          brickAlive[j] = false;
          float sp = sqrt(sq(bvx[i]) + sq(bvy[i]));
          if (d > 0) { bvx[i] = dx/d * sp; bvy[i] = dy/d * sp; }
          hit = true;
        }
      }
    }
  }

  boolean anyAlive = false;
  for (int j = 0; j < brickCount; j++) {
    if (brickAlive[j]) {
      anyAlive = true;
      fill(brickC[j]); ellipse(brickX[j], brickY[j], brickR[j]*2, brickR[j]*2);
    }
  }
  if (!anyAlive) mode = WIN;
}

void gameClicks() { mode = PAUSE; }

// -------- PAUSE --------
void pauseMode() {
  stroke(255); strokeWeight(8);
  line(WIDTH/2-10, HEIGHT/2-30, WIDTH/2-10, HEIGHT/2+30);
  line(WIDTH/2+10, HEIGHT/2-30, WIDTH/2+10, HEIGHT/2+30);
}

void pauseClicks() { mode = PLAY; }

// -------- GAMEOVER --------
void gameOver() {
  fill(255,0,0); textAlign(CENTER, CENTER); textSize(48);
  text("GAME OVER", WIDTH/2, HEIGHT/2);
  textSize(24); text("Click to Restart", WIDTH/2, HEIGHT/2+40);
}

void gameOverClicks() { initBricks(); mode = INTRO; }

// -------- WIN --------
void win() {
  fill(0,255,0); textAlign(CENTER, CENTER); textSize(48);
  text("YOU WIN!", WIDTH/2, HEIGHT/2);
  fill(255,255,0); textSize(24); text("Click to Menu", WIDTH/2, HEIGHT/2+40);
}

void winClicks() { initBricks(); mode = INTRO; }
