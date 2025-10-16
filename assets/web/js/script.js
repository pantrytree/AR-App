// RoomieLab AR Studio Functionality
document.addEventListener('DOMContentLoaded', function() {
    // Initialize the application
    initRoomieLab();
});

function initRoomieLab() {
    console.log('RoomieLab AR Studio initialized');
    initializeFurnitureSelection();
    initializeCategorySelection();
    initializeControlButtons();
    initializeCaptureButton();
    loadGalleryItems();

    // Set up communication with Flutter
    setupFlutterCommunication();
}

// Furniture selection functionality
function initializeFurnitureSelection() {
    const furnitureItems = document.querySelectorAll('.furniture-item');
    const selectedItemSpan = document.querySelector('.selected-item span');

    furnitureItems.forEach(item => {
        item.addEventListener('click', function() {
            // Remove active class from all items
            furnitureItems.forEach(i => i.classList.remove('active'));
            // Add active class to clicked item
            this.classList.add('active');
            // Update selected item text
            const itemName = this.querySelector('.furniture-name').textContent;
            selectedItemSpan.textContent = itemName;

            // Notify AR system about furniture selection
            selectFurnitureInAR(itemName);

            // Notify Flutter about selection
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('furnitureSelected', itemName);
            }
        });
    });
}

// Category selection functionality
function initializeCategorySelection() {
    const categoryItems = document.querySelectorAll('.category-list li');

    categoryItems.forEach(item => {
        item.addEventListener('click', function() {
            // Remove active class from all items
            categoryItems.forEach(i => i.classList.remove('active'));
            // Add active class to clicked item
            this.classList.add('active');

            // Filter furniture items by category
            filterFurnitureByCategory(this.textContent);

            // Notify Flutter about category change
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('categoryChanged', this.textContent);
            }
        });
    });
}

// Control buttons functionality
function initializeControlButtons() {
    const controlButtons = document.querySelectorAll('.control-btn');

    controlButtons.forEach(button => {
        button.addEventListener('click', function() {
            const action = this.textContent.trim();
            handleFurnitureControl(action);

            // Notify Flutter about control action
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('controlAction', action);
            }
        });
    });
}

// Capture button functionality
function initializeCaptureButton() {
    const captureBtn = document.querySelector('.capture-btn');

    captureBtn.addEventListener('click', function() {
        captureDesign();

        // Notify Flutter about capture action
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('captureDesign');
        }
    });
}

// AR Integration Functions
function selectFurnitureInAR(furnitureName) {
    console.log(`Furniture selected in AR: ${furnitureName}`);

    // Update the camera placeholder to show selected furniture
    const cameraPlaceholder = document.querySelector('.camera-placeholder');
    cameraPlaceholder.innerHTML = `
        <div style="font-size: 48px; margin-bottom: 10px;">🛋️</div>
        <p><strong>${furnitureName}</strong> selected</p>
        <p>Use controls to rotate, move, and scale</p>
        <p style="font-size: 12px; color: #666;">AR integration coming soon</p>
    `;
}

function handleFurnitureControl(action) {
    console.log(`Furniture control action: ${action}`);

    // Show visual feedback for the action
    showControlFeedback(action);

    switch(action) {
        case '↻ Rotate':
            showNotification('Rotate: Drag with one finger to rotate', 'info');
            break;
        case '↔ Move':
            showNotification('Move: Drag with two fingers to move', 'info');
            break;
        case '↕ Scale':
            showNotification('Scale: Pinch to zoom in/out', 'info');
            break;
        case '🔄 Reset':
            showNotification('Furniture position reset', 'success');
            // Reset camera view
            const selectedItem = document.querySelector('.selected-item span').textContent;
            selectFurnitureInAR(selectedItem);
            break;
        case '❌ Remove':
            showNotification('Furniture removed from scene', 'info');
            const cameraPlaceholder = document.querySelector('.camera-placeholder');
            cameraPlaceholder.innerHTML = `
                <i>📷</i>
                <p>Camera view will appear here</p>
                <p>Select furniture to place in AR</p>
            `;
            break;
        case '💾 Save Position':
            showNotification('Furniture position saved', 'success');
            break;
    }
}

function captureDesign() {
    console.log('Capturing design...');

    // Show capture animation
    showCaptureAnimation();

    // Simulate capture process
    setTimeout(() => {
        // Save to gallery
        saveToGallery();

        // Show success message
        showNotification('Design captured and saved to gallery!', 'success');
    }, 1500);
}

function filterFurnitureByCategory(category) {
    console.log(`Filtering furniture by category: ${category}`);

    const furnitureItems = document.querySelectorAll('.furniture-item');

    // Simple filtering simulation
    if (category === 'All Furniture') {
        furnitureItems.forEach(item => item.style.display = 'block');
    } else {
        // In a real app, this would filter based on category data
        showNotification(`Showing ${category}`, 'info');
    }
}

function showCaptureAnimation() {
    const captureBtn = document.querySelector('.capture-btn');
    const originalText = captureBtn.innerHTML;

    // Add loading animation
    captureBtn.innerHTML = '<i>⏳</i> Capturing...';
    captureBtn.disabled = true;
    captureBtn.style.opacity = '0.7';

    // Reset after animation
    setTimeout(() => {
        captureBtn.innerHTML = originalText;
        captureBtn.disabled = false;
        captureBtn.style.opacity = '1';
    }, 1500);
}

function showControlFeedback(action) {
    const buttons = document.querySelectorAll('.control-btn');
    buttons.forEach(btn => btn.style.backgroundColor = '');

    const activeBtn = Array.from(buttons).find(btn => btn.textContent.trim() === action);
    if (activeBtn) {
        activeBtn.style.backgroundColor = 'var(--primary-color)';
        activeBtn.style.color = 'white';

        setTimeout(() => {
            activeBtn.style.backgroundColor = '';
            activeBtn.style.color = '';
        }, 1000);
    }
}

function saveToGallery() {
    // Get current design information
    const selectedItem = document.querySelector('.selected-item span').textContent;
    const currentDate = new Date().toLocaleDateString();
    const timestamp = new Date().toLocaleTimeString();

    // Create new gallery item
    const newDesign = {
        id: Date.now(),
        name: `${selectedItem} Design`,
        date: currentDate,
        time: timestamp,
        furniture: selectedItem
    };

    // Add to gallery
    addDesignToGallery(newDesign);
}

function addDesignToGallery(design) {
    const galleryGrid = document.querySelector('.gallery-grid');

    const galleryItem = document.createElement('div');
    galleryItem.className = 'gallery-item';
    galleryItem.setAttribute('data-design-id', design.id);
    galleryItem.innerHTML = `
        <div class="gallery-img" style="background: linear-gradient(135deg, #6C63FF, #FF6584); color: white; font-weight: bold;">
            ${design.furniture}
        </div>
        <div class="gallery-info">
            <div class="gallery-name">${design.name}</div>
            <div class="gallery-date">${design.date} • ${design.time}</div>
        </div>
    `;

    // Add click event to view design
    galleryItem.addEventListener('click', function() {
        viewDesign(design);
    });

    // Add to beginning of gallery
    galleryGrid.insertBefore(galleryItem, galleryGrid.firstChild);

    // If this is the first item, remove the "no designs" message
    const emptyMessage = document.querySelector('.gallery-empty-message');
    if (emptyMessage) {
        emptyMessage.remove();
    }
}

function viewDesign(design) {
    console.log(`Viewing design: ${design.name}`);
    showNotification(`Opening ${design.name} in AR Studio...`, 'info');

    // Simulate loading the design in AR studio
    setTimeout(() => {
        selectFurnitureInAR(design.furniture);
        showNotification(`${design.name} loaded in AR Studio`, 'success');
    }, 1000);
}

function loadGalleryItems() {
    // In a real implementation, this would load saved designs from storage
    console.log('Loading gallery items...');

    // For demo purposes, check if gallery is empty and show message
    const galleryGrid = document.querySelector('.gallery-grid');
    if (galleryGrid.children.length === 0) {
        galleryGrid.innerHTML = `
            <div class="gallery-empty-message" style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--light-text);">
                <div style="font-size: 48px; margin-bottom: 20px;">📷</div>
                <h3>No designs yet</h3>
                <p>Capture your first AR design to see it here!</p>
            </div>
        `;
    }
}

function showNotification(message, type = 'info') {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.notification');
    existingNotifications.forEach(notification => notification.remove());

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;

    // Add styles for notification
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#f44336' : '#2196F3'};
        color: white;
        padding: 12px 20px;
        border-radius: 5px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        z-index: 1000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
        max-width: 300px;
        word-wrap: break-word;
    `;

    document.body.appendChild(notification);

    // Animate in
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);

    // Animate out and remove
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (notification.parentNode) {
                document.body.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

// Flutter communication setup
function setupFlutterCommunication() {
    // Listen for messages from Flutter
    window.addEventListener('flutterMessage', function(event) {
        const message = event.detail;
        handleFlutterMessage(message);
    });

    // Alternative method for webview communication
    if (window.flutter_inappwebview) {
        // Set up message handlers for Flutter
        console.log('Flutter WebView detected - communication ready');
    }
}

function handleFlutterMessage(message) {
    console.log('Received message from Flutter:', message);

    switch(message.action) {
        case 'loadDesign':
            loadDesignFromFlutter(message.data);
            break;
        case 'updateFurniture':
            updateFurnitureSelection(message.data);
            break;
        case 'showMessage':
            showNotification(message.data.text, message.data.type);
            break;
    }
}

function loadDesignFromFlutter(designData) {
    console.log('Loading design from Flutter:', designData);
    showNotification(`Loading ${designData.name}...`, 'info');

    // Simulate design loading
    setTimeout(() => {
        selectFurnitureInAR(designData.furniture);
        showNotification('Design loaded successfully', 'success');
    }, 1000);
}

function updateFurnitureSelection(furnitureData) {
    const selectedItemSpan = document.querySelector('.selected-item span');
    selectedItemSpan.textContent = furnitureData.name;

    // Update furniture items to show selection
    const furnitureItems = document.querySelectorAll('.furniture-item');
    furnitureItems.forEach(item => {
        item.classList.remove('active');
        if (item.querySelector('.furniture-name').textContent === furnitureData.name) {
            item.classList.add('active');
        }
    });

    selectFurnitureInAR(furnitureData.name);
}

// Export functions for use by Flutter
window.RoomieLab = {
    selectFurnitureInAR,
    handleFurnitureControl,
    captureDesign,
    saveToGallery,
    showNotification,
    addDesignToGallery
};

console.log('RoomieLab JavaScript loaded successfully');