import React, { useRef, useEffect } from 'react';

const BookSystem = ({ bookData, onClose }) => {
  const innerRef = useRef(null);
  const flipbookRef = useRef(null);
  const audioInitialized = useRef(false);

  useEffect(() => {
    if (!bookData || !bookData.pages || !window.$) return;

    initializeBook();
    initializeAudio();
  }, [bookData]);

  const initializeAudio = () => {
    const audio = document.getElementById('pageTurnSound');
    if (audio && !audioInitialized.current) {
      // Force load the audio
      audio.load();
      
      // Try to play and pause immediately to initialize (common workaround)
      const initPlay = async () => {
        try {
          audio.volume = 0.1; // Set a reasonable volume
          await audio.play();
          audio.pause();
          audio.currentTime = 0;
          audioInitialized.current = true;
        } catch (error) {
          // Will work after first user interaction
        }
      };
      
      initPlay();
    }
  };

  // Function to add a page to the book (exactly like original)
  const addPageToBook = (page, eventData) => {
    if (!window.$ || !innerRef.current) return;

    const $inner = window.$(innerRef.current);
    
    if (page.source === 'local') {
      const width = eventData.size ? eventData.size.width : '';
      const height = eventData.size ? eventData.size.height : '';
      const imagePath = `img/${eventData.book}/${page.pageName}.png`;
      
      if (page.type === 'hard') {
        $inner.append(`<div class="hard"><img src="${imagePath}" width="${width}" height="${height}"></div>`);
      } else if (page.type === 'normal') {
        $inner.append(`<div><img src="${imagePath}" width="${width}" height="${height}"></div>`);
      }
    } else if (page.source === 'web') {
      const width = eventData.size ? eventData.size.width : '';
      const height = eventData.size ? eventData.size.height : '';
      const imagePath = `web/${page.pageName}.png`;
      $inner.append(`<div><img src="${imagePath}" width="${width}" height="${height}"></div>`);
    }
  };

  const initializeBook = () => {
    if (!window.$ || !innerRef.current) return;

    const $inner = window.$(innerRef.current);
    
    // Clear previous pages (exactly like original)
    $inner.empty();
    
    // Add each page (exactly like original)
    bookData.pages.forEach(page => {
      addPageToBook(page, bookData);
    });

    // Initialize turn.js (exactly like original)
    if (bookData.size) {
      $inner.turn({
        gradients: true,
        autoCenter: true,
        width: bookData.size.width * 2,
        height: bookData.size.height,
        page: 1,
        acceleration: true,
      });
      
      // Add event listener for page turning (exactly like original)
      $inner.on('turning', function(event, page, view) {
        // Play the sound (exactly like original)
        const audio = document.getElementById('pageTurnSound');
        if (audio) {
          // Ensure audio is loaded
          if (audio.readyState < 2) { // Not enough data loaded
            audio.load();
          }
          
          // Reset audio to start
          audio.currentTime = 0;
          audio.volume = 0.1; // Set reasonable volume
          
          const playPromise = audio.play();
          if (playPromise !== undefined) {
            playPromise.catch((error) => {
              // Initialize audio for next time
              if (!audioInitialized.current) {
                audioInitialized.current = true;
              }
            });
          }
        }
      });
    }
  };

  // Handle dynamic page addition (exactly like original addPage functionality)
  useEffect(() => {
    const handleAddPage = (page) => {
      if (bookData && window.$) {
        addPageToBook(page, bookData);
        // You might need to reinitialize turn.js here depending on the library
      }
    };

    // Expose function globally like original
    window.addPageToArchaeologyBook = handleAddPage;
    
    return () => {
      if (window.addPageToArchaeologyBook) {
        delete window.addPageToArchaeologyBook;
      }
    };
  }, [bookData]);

  if (!bookData) return null;

  return (
    // Exact HTML structure from original book/index.html
    <div className="book-system">
      <div id="flipbook" className="flipbook" ref={flipbookRef}></div>
      <div id="inner" ref={innerRef}></div>
    </div>
  );
};

export default BookSystem;