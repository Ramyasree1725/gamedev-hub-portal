# GameDev Hub

A complete full-stack game development learning portal with 5 fully playable mini-games, live leaderboard, tutorials, and REST API.

## Features

- **5 Mini-Games**: Snake, Tic Tac Toe (with Minimax AI), Memory Match, Breakout, Pong
- **Full Backend**: Flask + CORS, score submission, leaderboard API
- **Frontend**: Modern dark UI, responsive, all buttons functional
- **Tutorials**: Game loop, Canvas, AI, full-stack scoring
- **Leaderboard**: Submit scores, view top players per game

## Dependencies

- Python 3.10+
- Flask 3.0.3
- Flask-CORS 4.0.1
- Gunicorn 22.0.0
- Pytest 8.3.2
- Pytest-cov 5.0.0

## Installation

Clone the repository and set up a virtual environment:

```bash
# Clone repository
git clone https://github.com/Ramyasree1725/gamedev-hub-portal.git
cd gamedev-hub-portal

# Create virtual environment
python -m venv venv
# On Windows
venv\Scripts\activate
# On Linux/macOS
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Build

To build the project or Docker container:

```bash
# Build Docker image
docker build -t gamedev-hub .
```

## Run

### Option 1: Direct Python Execution
```bash
python backend/app.py
```
Open your browser and navigate to: `http://localhost:5000`

### Option 2: Run with Docker
```bash
docker run -d -p 5000:5000 --name gamedev-hub-app gamedev-hub
```

### Option 3: Using npm scripts
```bash
npm start
```

## Usage

1. Open `http://localhost:5000` in any modern web browser.
2. Select any of the 5 mini-games: Snake, Tic Tac Toe, Memory Match, Breakout, or Pong.
3. Play games, submit high scores to the live leaderboard, and review game development tutorials.

### Controls:
- **Snake**: Arrow keys / WASD
- **Tic Tac Toe**: Mouse click
- **Memory**: Mouse click
- **Breakout**: Arrow / WASD / Mouse
- **Pong**: W/S or Arrow Up/Down

## Testing

Run the automated test suite with coverage:

```bash
pytest backend/tests --cov=backend
```

## API Endpoints

- `GET /api/games` - List all games
- `GET /api/leaderboard` - Get all leaderboard scores
- `GET /api/leaderboard/<game_id>` - Get scores for a specific game
- `POST /api/score` - Submit score: `{ "game": "snake", "name": "Player", "score": 100 }`
- `GET /api/health` - API Health check status
