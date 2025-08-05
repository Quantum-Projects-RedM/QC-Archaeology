import React, { useState, useEffect } from 'react';
import BookSystem from './components/BookSystem';
import MinigameSystem from './components/MinigameSystem';
import './App.css';

const App = () => {
  const [minigameVisible, setMinigameVisible] = useState(false);
  const [bookVisible, setBookVisible] = useState(false);
  const [rockImageSrc, setRockImageSrc] = useState('');
  const [bookData, setBookData] = useState(null);

  useEffect(() => {
    const handleMessage = (event) => {
      const { data } = event;

      // Handle minigame toggle (exactly like original minigame/index.js)
      if (data.type === 'toggleUI') {
        if (data.status) {
          // Close book if open
          setBookVisible(false);
          setBookData(null);
          // Open minigame
          setMinigameVisible(true);
          setRockImageSrc(data.rockImageSrc);
        } else {
          setMinigameVisible(false);
          setRockImageSrc('');
        }
      }

      // Handle book system (exactly like original book/index.js)
      if (data.event === 'book') {
        if (data.show == true) {
          if (data.pages) {
            // Close minigame if open
            setMinigameVisible(false);
            setRockImageSrc('');
            // Open book
            setBookData(data);
            setBookVisible(true);
          }
        } else if (data.show == false) {
          setBookVisible(false);
          setBookData(null);
        }
      }

      // Handle adding pages (exactly like original)
      if (data.event === 'addPage') {
        if (bookData) {
          setBookData(prev => ({
            ...prev,
            pages: [...(prev.pages || []), data.page]
          }));
        }
      }
    };

    const handleKeyUp = (e) => {
      // ESC key handling for both systems
      if (e.keyCode === 27) {
        if (bookVisible) {
          // Book ESC handling - clean close
          setBookVisible(false);
          setBookData(null);
          const innerElement = document.getElementById('inner');
          if (innerElement && window.$) {
            window.$('#inner').turn('page', 1);
            window.$('#inner').turn('destroy');
            innerElement.style = "";
          }
          fetch(`https://${window.GetParentResourceName()}/escape`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
          }).catch(() => {});
        }
        
        if (minigameVisible) {
          // Minigame ESC handling (exactly like original)
          fetch(`https://${window.GetParentResourceName()}/minigameFailed`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
          }).catch(() => {});
        }
      }
    };

    window.addEventListener('message', handleMessage);
    document.addEventListener('keyup', handleKeyUp);

    // Mock GetParentResourceName for development
    if (!window.GetParentResourceName) {
      window.GetParentResourceName = () => 'qc-archaeology';
    }

    return () => {
      window.removeEventListener('message', handleMessage);
      document.removeEventListener('keyup', handleKeyUp);
    };
  }, [bookVisible, minigameVisible, bookData]);

  return (
    <div className="app">
      {minigameVisible && (
        <MinigameSystem 
          rockImageSrc={rockImageSrc}
          onComplete={() => setMinigameVisible(false)}
        />
      )}
      {bookVisible && bookData && (
        <BookSystem 
          bookData={bookData}
          onClose={() => setBookVisible(false)}
        />
      )}
    </div>
  );
};

export default App;