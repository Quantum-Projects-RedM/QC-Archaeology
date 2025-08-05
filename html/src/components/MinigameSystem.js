import React, { useRef, useEffect, useState } from 'react';

const MinigameSystem = ({ rockImageSrc, onComplete }) => {
  const canvasRef = useRef(null);
  const [isInitialized, setIsInitialized] = useState(false);
  
  // All variables from original minigame.js
  const gameStateRef = useRef({
    canvas: null,
    ctx: null,
    isDrawing: false,
    lastX: 0,
    lastY: 0,
    radius: 50,
    baseCanvas: null,
    dirtCanvas: null,
    maskCanvas: null,
    backgroundDirtCanvas: null,
    baseCtx: null,
    dirtCtx: null,
    maskCtx: null,
    bgDirtCtx: null,
    dirtTextureImage: null
  });

  useEffect(() => {
    if (!rockImageSrc || isInitialized) return;
    
    initializeGame();
    setIsInitialized(true);
  }, [rockImageSrc, isInitialized]);

  // Exact copy of initializeCanvases function from original
  const initializeCanvases = () => {
    const canvas = canvasRef.current;
    if (!canvas) {
      console.error('Canvas element not found!');
      return;
    }
    
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      console.error('2D context not supported!');
      return;
    }

    // Read canvas dimensions from HTML attributes (exactly like original)
    const canvasWidth = canvas.width;
    const canvasHeight = canvas.height;

    // Create separate canvases for different layers (exactly like original)
    const baseCanvas = document.createElement('canvas');
    const dirtCanvas = document.createElement('canvas');
    const maskCanvas = document.createElement('canvas');
    const backgroundDirtCanvas = document.createElement('canvas');

    // Set dimensions for layered canvases (exactly like original)
    [baseCanvas, dirtCanvas, maskCanvas, backgroundDirtCanvas].forEach(c => {
      c.width = canvasWidth;
      c.height = canvasHeight;
    });

    // Set up contexts (exactly like original)
    const baseCtx = baseCanvas.getContext('2d');
    const dirtCtx = dirtCanvas.getContext('2d');
    const maskCtx = maskCanvas.getContext('2d');
    const bgDirtCtx = backgroundDirtCanvas.getContext('2d');

    // Store in gameState
    gameStateRef.current = {
      ...gameStateRef.current,
      canvas,
      ctx,
      baseCanvas,
      dirtCanvas,
      maskCanvas,
      backgroundDirtCanvas,
      baseCtx,
      dirtCtx,
      maskCtx,
      bgDirtCtx
    };
  };

  // Exact copy of createDirtTexture function from original
  const createDirtTexture = (ctx, width, height, opacity = 1) => {
    // Clear the canvas before drawing the dirt texture
    ctx.clearRect(0, 0, width, height);
    
    if (gameStateRef.current.dirtTextureImage) {
      // Draw the dirt texture image
      ctx.globalAlpha = opacity;
      ctx.drawImage(gameStateRef.current.dirtTextureImage, 0, 0, width, height);
      ctx.globalAlpha = 1;
    } else {
      // Fallback solid color
      ctx.fillStyle = '#654321';
      ctx.fillRect(0, 0, width, height);
    }
  };

  // Exact copy of drawBaseShape function from original
  const drawBaseShape = (rockImageSrc) => {
    return new Promise((resolve) => {
      const rockImage = new Image();
      rockImage.onload = () => {
        const { canvas, baseCtx, maskCtx } = gameStateRef.current;
        
        // Calculate scaling to fit the canvas while maintaining aspect ratio
        const scale = Math.min(
          canvas.width / rockImage.width,
          canvas.height / rockImage.height
        );
        const width = rockImage.width * scale;
        const height = rockImage.height * scale;
        const x = (canvas.width - width) / 2;
        const y = (canvas.height - height) / 2;

        // Draw the rock image
        baseCtx.clearRect(0, 0, canvas.width, canvas.height);
        baseCtx.drawImage(rockImage, x, y, width, height);

        // Create shape mask
        maskCtx.clearRect(0, 0, canvas.width, canvas.height);
        maskCtx.drawImage(rockImage, x, y, width, height);
        
        resolve();
      };
      rockImage.onerror = () => {
        console.error('Failed to load rock image:', rockImageSrc);
        resolve();
      };
      rockImage.src = rockImageSrc;
    });
  };

  // Exact copy of initCanvas function from original
  const initCanvas = async (rockImageSrc) => {
    await drawBaseShape(rockImageSrc);
    
    const { canvas, dirtCtx, bgDirtCtx, dirtCanvas, maskCanvas } = gameStateRef.current;
    
    // Clear all canvases
    dirtCtx.clearRect(0, 0, canvas.width, canvas.height);
    bgDirtCtx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Create solid background
    bgDirtCtx.fillStyle = '#654321'; // Dark brown
    bgDirtCtx.fillRect(0, 0, canvas.width, canvas.height);
    createDirtTexture(bgDirtCtx, canvas.width, canvas.height, 0.8);
    
    // Create fully opaque dirt layer for the object
    createDirtTexture(dirtCtx, canvas.width, canvas.height, 1);
    
    // Apply the mask to the dirt layer
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = canvas.width;
    tempCanvas.height = canvas.height;
    const tempCtx = tempCanvas.getContext('2d');
    
    tempCtx.drawImage(dirtCanvas, 0, 0);
    tempCtx.globalCompositeOperation = 'destination-in';
    tempCtx.drawImage(maskCanvas, 0, 0);
    
    dirtCtx.clearRect(0, 0, canvas.width, canvas.height);
    dirtCtx.drawImage(tempCanvas, 0, 0);
    
    updateMainCanvas();
  };

  // Exact copy of updateMainCanvas function from original
  const updateMainCanvas = () => {
    const { 
      ctx, canvas, baseCanvas, dirtCanvas, maskCanvas, backgroundDirtCanvas,
      maskCtx, dirtCtx 
    } = gameStateRef.current;
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw background
    ctx.drawImage(backgroundDirtCanvas, 0, 0);
    
    // Use a temporary canvas for the cleaned areas
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = canvas.width;
    tempCanvas.height = canvas.height;
    const tempCtx = tempCanvas.getContext('2d');
    
    // Draw the image only in cleaned areas
    tempCtx.drawImage(baseCanvas, 0, 0);
    tempCtx.globalCompositeOperation = 'destination-in';
    tempCtx.drawImage(maskCanvas, 0, 0); // Apply object mask
    
    // Create another temp canvas for the cleaning mask
    const cleanMask = document.createElement('canvas');
    cleanMask.width = canvas.width;
    cleanMask.height = canvas.height;
    const cleanCtx = cleanMask.getContext('2d');
    
    cleanCtx.fillStyle = '#ffffff';
    cleanCtx.fillRect(0, 0, canvas.width, canvas.height);
    cleanCtx.globalCompositeOperation = 'destination-out';
    cleanCtx.drawImage(dirtCanvas, 0, 0);
    
    tempCtx.globalCompositeOperation = 'destination-in';
    tempCtx.drawImage(cleanMask, 0, 0);
    
    // Draw the revealed image
    ctx.drawImage(tempCanvas, 0, 0);
    
    // Draw the dirt layer
    ctx.drawImage(dirtCanvas, 0, 0);

    // Check cleaning progress (exactly like original)
    const maskData = maskCtx.getImageData(0, 0, canvas.width, canvas.height).data;
    const dirtData = dirtCtx.getImageData(0, 0, canvas.width, canvas.height).data;
    let totalObjectPixels = 0;
    let cleanPixels = 0;
    
    for (let i = 3; i < maskData.length; i += 4) {
      if (maskData[i] > 0) {
        totalObjectPixels++;
        if (dirtData[i] < 50) {
          cleanPixels++;
        }
      }
    }

    if (totalObjectPixels > 0 && (cleanPixels / totalObjectPixels) > 0.99) {
      // Send success message to client script (exactly like original)
      fetch(`https://${window.GetParentResourceName()}/cleaningComplete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      }).catch(() => {});
      
      onComplete();
    }
  };

  // Exact copy of clean function from original
  const clean = (e) => {
    if (!gameStateRef.current.isDrawing) return;
    
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const { dirtCtx } = gameStateRef.current;

    dirtCtx.globalCompositeOperation = 'destination-out';
    
    if (gameStateRef.current.lastX && gameStateRef.current.lastY) {
      const gradient = dirtCtx.createLinearGradient(
        gameStateRef.current.lastX, 
        gameStateRef.current.lastY, 
        x, 
        y
      );
      gradient.addColorStop(0, 'rgba(255, 255, 255, 0.8)');
      gradient.addColorStop(1, 'rgba(255, 255, 255, 0.4)');
      
      dirtCtx.strokeStyle = gradient;
      dirtCtx.lineWidth = 20;
      dirtCtx.lineCap = 'round';
      dirtCtx.beginPath();
      dirtCtx.moveTo(gameStateRef.current.lastX, gameStateRef.current.lastY);
      dirtCtx.lineTo(x, y);
      dirtCtx.stroke();
    }

    gameStateRef.current.lastX = x;
    gameStateRef.current.lastY = y;
    
    updateMainCanvas();
  };

  // Exact copy of setupEventListeners function from original
  const setupEventListeners = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const handleMouseDown = (e) => {
      gameStateRef.current.isDrawing = true;
      gameStateRef.current.lastX = 0;
      gameStateRef.current.lastY = 0;
      clean(e);
    };

    const handleMouseMove = (e) => {
      clean(e);
    };

    const handleMouseUp = () => {
      gameStateRef.current.isDrawing = false;
      gameStateRef.current.lastX = 0;
      gameStateRef.current.lastY = 0;
    };

    const handleTouchStart = (e) => {
      gameStateRef.current.isDrawing = true;
      gameStateRef.current.lastX = 0;
      gameStateRef.current.lastY = 0;
      e.preventDefault();
      const touch = e.touches[0];
      clean(touch);
    };

    const handleTouchMove = (e) => {
      e.preventDefault();
      const touch = e.touches[0];
      clean(touch);
    };

    // All event listeners exactly like original
    canvas.addEventListener('mousedown', handleMouseDown);
    canvas.addEventListener('mousemove', handleMouseMove);
    canvas.addEventListener('mouseup', handleMouseUp);
    canvas.addEventListener('mouseout', handleMouseUp);
    canvas.addEventListener('touchstart', handleTouchStart);
    canvas.addEventListener('touchmove', handleTouchMove);
    canvas.addEventListener('touchend', handleMouseUp);

    return () => {
      canvas.removeEventListener('mousedown', handleMouseDown);
      canvas.removeEventListener('mousemove', handleMouseMove);
      canvas.removeEventListener('mouseup', handleMouseUp);
      canvas.removeEventListener('mouseout', handleMouseUp);
      canvas.removeEventListener('touchstart', handleTouchStart);
      canvas.removeEventListener('touchmove', handleTouchMove);
      canvas.removeEventListener('touchend', handleMouseUp);
    };
  };

  const initializeGame = () => {
    initializeCanvases();
    
    // Load dirt texture (exactly like original)
    const dirtTextureImage = new Image();
    dirtTextureImage.src = 'img/minigame/dirt.jpg';
    dirtTextureImage.onload = () => {
      gameStateRef.current.dirtTextureImage = dirtTextureImage;
      initCanvas(rockImageSrc);
    };
    dirtTextureImage.onerror = () => {
      console.error('Failed to load dirt texture: dirt.jpg');
      initCanvas(rockImageSrc);
    };

    setupEventListeners();
  };

  return (
    // Exact HTML structure from original minigame/index.html
    <div className="minigame-system">
      <div className="instructions-container" id="instructions-container">
        <div className="chat-box" id="instructionsBox">
          <h3>How to Play</h3>
          <p>1. Click on the dirt to find the fossil.</p>
          <p>2. Sometimes you wont find anything, that is normal.</p>
          <p>3. Avoid clicking on empty rocks to save time.</p>
        </div>
      </div>
      <div className="title-container" id="title-container">
        <div className="title-box" id="titlebox">
          <h2>Find the Fossil</h2>
        </div>
      </div>
      <div id="fossilContainer" className="container">
        <div className="game-container">
          <canvas 
            ref={canvasRef}
            id="rockCanvas" 
            width="400" 
            height="320"
          />
        </div>
      </div>
    </div>
  );
};

export default MinigameSystem;