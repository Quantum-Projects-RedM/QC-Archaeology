// Initialize variables
let canvas, ctx, isDrawing = false;
let lastX = 0, lastY = 0;
const radius = 50;

// Create separate canvases for different layers
const baseCanvas = document.createElement('canvas');
const dirtCanvas = document.createElement('canvas');
const maskCanvas = document.createElement('canvas');
const backgroundDirtCanvas = document.createElement('canvas');

function initializeCanvases() {
    canvas = document.getElementById('rockCanvas');
    if (!canvas) {
        console.error('Canvas element not found!');
        return;
    }
    ctx = canvas.getContext('2d');
    if (!ctx) {
        console.error('2D context not supported!');
        return;
    }

    // Read canvas dimensions from HTML attributes
    const canvasWidth = canvas.width;
    const canvasHeight = canvas.height;

    // Log canvas dimensions for debugging
    //console.log('Canvas dimensions from HTML:', canvasWidth, canvasHeight);

    // Set dimensions for layered canvases
    [baseCanvas, dirtCanvas, maskCanvas, backgroundDirtCanvas].forEach(c => {
        c.width = canvasWidth;
        c.height = canvasHeight;
    });
}

// Set up contexts
const baseCtx = baseCanvas.getContext('2d');
const dirtCtx = dirtCanvas.getContext('2d');
const maskCtx = maskCanvas.getContext('2d');
const bgDirtCtx = backgroundDirtCanvas.getContext('2d');

// Add a new variable for the dirt texture image
let dirtTextureImage = new Image();
dirtTextureImage.src = 'img/minigame/dirt.jpg'; // Path to your dirt texture image
dirtTextureImage.onerror = () => {
    console.error('Failed to load dirt texture: dirt.jpg');
};

function createDirtTexture(ctx, width, height, opacity = 1) {
    // Clear the canvas before drawing the dirt texture
    ctx.clearRect(0, 0, width, height);
    
    // Draw the dirt texture image
    ctx.globalAlpha = opacity; // Set the opacity
    ctx.drawImage(dirtTextureImage, 0, 0, width, height);
    ctx.globalAlpha = 1; // Reset opacity to 1 for future drawings
}

function drawBaseShape(rockImageSrc) {
    return new Promise((resolve) => {
        const rockImage = new Image();
        rockImage.onload = () => {
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
            //console.error('Failed to load rock image:', rockImageSrc);
        };
        rockImage.src = rockImageSrc; // Use the provided image source
    });
}

async function initCanvas(rockImageSrc) {
    await drawBaseShape(rockImageSrc);
    
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
}

// Ensure the dirt texture image is loaded before using it
dirtTextureImage.onload = () => {
    // Initialize the canvas once the image is loaded
    initCanvas();
};

function updateMainCanvas() {
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

    // Check cleaning progress
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
        // Immediately hide the container
        document.getElementById('fossilContainer').classList.add('display');
        
        // Send success message to client script
        fetch(`https://${GetParentResourceName()}/cleaningComplete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
}

function clean(e) {
    if (!isDrawing) return;
    
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    dirtCtx.globalCompositeOperation = 'destination-out';
    
    if (lastX && lastY) {
        const gradient = dirtCtx.createLinearGradient(lastX, lastY, x, y);
        gradient.addColorStop(0, 'rgba(255, 255, 255, 0.8)');
        gradient.addColorStop(1, 'rgba(255, 255, 255, 0.4)');
        
        dirtCtx.strokeStyle = gradient;
        dirtCtx.lineWidth = 20;
        dirtCtx.lineCap = 'round';
        dirtCtx.beginPath();
        dirtCtx.moveTo(lastX, lastY);
        dirtCtx.lineTo(x, y);
        dirtCtx.stroke();
    }

    lastX = x;
    lastY = y;
    
    updateMainCanvas();
}

// Event handlers
function setupEventListeners() {
    canvas.addEventListener('mousedown', (e) => {
        isDrawing = true;
        lastX = 0;
        lastY = 0;
        clean(e);
    });

    canvas.addEventListener('mousemove', clean);
    canvas.addEventListener('mouseup', () => {
        isDrawing = false;
        lastX = 0;
        lastY = 0;
    });
    canvas.addEventListener('mouseout', () => {
        isDrawing = false;
        lastX = 0;
        lastY = 0;
    });

    // Touch events
    canvas.addEventListener('touchstart', (e) => {
        isDrawing = true;
        lastX = 0;
        lastY = 0;
        e.preventDefault();
        const touch = e.touches[0];
        clean(touch);
    });

    canvas.addEventListener('touchmove', (e) => {
        e.preventDefault();
        const touch = e.touches[0];
        clean(touch);
    });

    canvas.addEventListener('touchend', () => {
        isDrawing = false;
        lastX = 0;
        lastY = 0;
    });

    // Handle ESC key
    document.addEventListener('keyup', (e) => {
        if (e.key === 'Escape') {
            fetch(`https://${GetParentResourceName()}/minigameFailed`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            });
        }
    });
}

window.addEventListener('message', (event) => {
    if (event.data.type === 'toggleUI') {
        const container = document.getElementById('fossilContainer');
        const chatBox = document.querySelector('.instructions-container');
        const titleBox = document.querySelector('.title-container');
        if (event.data.status) {
            container.classList.remove('display');
            chatBox.classList.remove('display'); // Show the chat box
            titleBox.classList.remove('display'); // Show the title box
            initializeCanvases();
            setupEventListeners();
            initCanvas(event.data.rockImageSrc); // Pass the rock image source
        } else {
            container.classList.add('display');
            chatBox.classList.add('display'); // Hide the chat box
            titleBox.classList.add('display'); // Hide the title box
        }
    }
});