
#!/bin/bash

echo ""
echo "Setting up DevNest for local development..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v18 or later."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version $NODE_VERSION detected. Please upgrade to Node.js v18 or later."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm."
    exit 1
fi

echo "✅ Node.js and npm are installed"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

echo ""
echo "ℹ️  Note: This project uses JSON file-based storage (no database required)"
echo "📁 Data is stored in /data directory"

# Function to kill processes on port 3031
kill_server() {
    echo "🔍 Checking for existing server on port 3031..."
    
    # Find processes using port 3031
    PIDS=$(lsof -ti:3031 2>/dev/null)
    
    if [ ! -z "$PIDS" ]; then
        echo "🛑 Found existing server processes. Killing them..."
        echo "$PIDS" | xargs kill -9 2>/dev/null
        sleep 2
        echo "✅ Server processes terminated"
    else
        echo "✅ No existing server found on port 3031"
    fi
}

# Function to start the development server
start_server() {
    echo "🚀 Starting development server..."
    echo ""

    # Kill any existing server first
    kill_server

    echo ""
    # Ensure dist directory exists
    echo "📁 Ensuring dist directory exists..."
    mkdir -p dist
    
    # Build client before starting server to ensure latest changes
    echo "🔄 Building client with latest changes..."
    npx vite build
    if [ $? -ne 0 ]; then
        echo "❌ Client build failed. Please check for errors above."
        exit 1
    fi
    echo "✅ Client built successfully"
    
    echo ""
    echo "🔨 Building server bundle..."
    
    # Create temporary build script for server
    cat > dist/build-temp.mjs << 'EOF'
import { build } from 'esbuild';

async function buildServer() {
  try {
    const result = await build({
      entryPoints: ['server/server.ts'],
      bundle: true,
      platform: 'node',
      format: 'esm',
      outfile: 'dist/server.js',
      minify: true,
      treeShaking: true,
      external: [
        'express',
        'ws',
        'bcryptjs',
        'jsonwebtoken',
        'cookie-parser',
        'express-session',
        'connect-pg-simple',
        'drizzle-orm',
        '@neondatabase/serverless',
        'multer',
        'zod',
        'nanoid',
        '@babel/*',
        'lightningcss',
        'esbuild',
        'vite',
        '@vitejs/*',
        '@replit/*',
        'autoprefixer',
        'postcss',
        'tailwindcss',
        'tsx',
        'typescript',
        'vitest',
        'bufferutil'
      ],
      target: 'node18',
      sourcemap: process.env.NODE_ENV === 'development',
      logLevel: 'info'
    });
    console.log('✅ Server bundle created successfully');
  } catch (error) {
    console.error('❌ Server build failed:', error);
    process.exit(1);
  }
}

buildServer();
EOF
    
    # Run the build script
    node dist/build-temp.mjs
    
    if [ $? -ne 0 ]; then
        echo "❌ Server build failed. Please check for errors above."
        rm -f dist/build-temp.mjs
        exit 1
    fi
    
    # Clean up temporary file
    rm -f dist/build-temp.mjs
    echo "✅ Server built successfully"
    
    # Start the server in the background
    NODE_ENV=development npm run dev &
    SERVER_PID=$!
    
    echo "🎯 Server starting with PID: $SERVER_PID"
    echo "📡 Server will be available at: http://localhost:3031"
    echo "ℹ️  No database required - using JSON file storage"
    echo ""
    echo "To stop the server, run: kill $SERVER_PID"
    echo "Or use Ctrl+C if running in foreground"
    
    # Wait a moment to check if server started successfully
    sleep 3
    
    if kill -0 $SERVER_PID 2>/dev/null; then
        echo ""
        echo "✅ Server started successfully!"
        echo ""
        echo "🌐 URL to Open in your browser : http://localhost:3031 "
        echo ""
        echo "💡 Note: Client is automatically rebuilt on each startup to ensure latest changes are served"
    else
        echo "❌ Server failed to start. Check the logs above for errors."
        exit 1
    fi
}

echo ""
echo "🚀 Setup complete! Starting development server..."
start_server
echo ""
