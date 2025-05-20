let designs = {};

// Listen for messages from the game
window.addEventListener('message', function(event) {
    var data = event.data;
    
    if (data.action === "openTagMenu") {
        designs = data.designs;
        openTagMenu();
    }
});

// Open the tagging menu
function openTagMenu() {
    // Show the menu
    document.getElementById('tag-menu').style.display = 'flex';
    
    // Reset form
    document.getElementById('tag-text').value = '';
    document.getElementById('tag-color').value = '#ff0000';
    document.getElementById('tag-size').value = '1.0';
    document.getElementById('size-value').textContent = '1.0';
    document.getElementById('tag-gang').value = '';
    
    // Load designs
    loadDesigns();
}

// Load available designs into the grid
function loadDesigns() {
    const designsContainer = document.getElementById('designs-container');
    designsContainer.innerHTML = '';
    
    let firstDesign = null;
    
    // Add each design to the grid
    for (const [key, design] of Object.entries(designs)) {
        if (!firstDesign) firstDesign = key;
        
        const designItem = document.createElement('div');
        designItem.className = 'design-item';
        designItem.dataset.design = key;
        
        // Create image element (placeholder for now)
        const img = document.createElement('img');
        img.src = `images/${design.texture}.png`;
        img.alt = design.label;
        
        // Create label
        const label = document.createElement('p');
        label.textContent = design.label;
        
        // Append elements
        designItem.appendChild(img);
        designItem.appendChild(label);
        
        // Add click handler
        designItem.addEventListener('click', function() {
            // Remove selected class from all designs
            document.querySelectorAll('.design-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            // Add selected class to this design
            this.classList.add('selected');
        });
        
        // Add to container
        designsContainer.appendChild(designItem);
    }
    
    // Select first design by default
    if (firstDesign) {
        document.querySelector(`.design-item[data-design="${firstDesign}"]`).classList.add('selected');
    }
}

// Update size value display when slider changes
document.getElementById('tag-size').addEventListener('input', function() {
    document.getElementById('size-value').textContent = this.value;
});

// Cancel button - close the menu
document.getElementById('cancel-btn').addEventListener('click', function() {
    closeMenu();
});

// Spray button - send data to game and close menu
document.getElementById('spray-btn').addEventListener('click', function() {
    const text = document.getElementById('tag-text').value;
    
    if (!text || text.trim() === '') {
        // Flash the input to indicate it's required
        const input = document.getElementById('tag-text');
        input.style.border = '2px solid red';
        setTimeout(() => {
            input.style.border = '1px solid #444';
        }, 500);
        return;
    }
    
    // Get selected design
    const selectedDesign = document.querySelector('.design-item.selected');
    if (!selectedDesign) return;
    
    // Gather all data
    const data = {
        text: text,
        design: selectedDesign.dataset.design,
        color: document.getElementById('tag-color').value.replace('#', ''),
        size: parseFloat(document.getElementById('tag-size').value),
        gang: document.getElementById('tag-gang').value
    };
    
    // Send to game
    fetch('https://graffiti_system/createTag', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => {
        // Close menu after sending data
        closeMenu();
    });
});

// Close the menu and reset focus
function closeMenu() {
    document.getElementById('tag-menu').style.display = 'none';
    fetch('https://graffiti_system/closeMenu', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
}

// Close on escape key
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});