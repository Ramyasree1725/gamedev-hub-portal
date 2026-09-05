import sys
import os

# Add backend directory to path
backend_path = os.path.join(os.path.dirname(__file__), 'backend')
if not os.path.exists(backend_path):
    backend_path = os.path.join(os.path.dirname(__file__), 'gamedev-hub (5)', 'gamedev-hub', 'backend')
sys.path.insert(0, backend_path)

try:
    from app import app
except ImportError:
    import app

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
