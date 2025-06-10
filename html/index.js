window.addEventListener('message', function(event) {
    if (event.data.event === 'book') {  // Check for the custom event name
        if (event.data.show == true) {
            if (event.data.pages) {
                $('#inner').empty(); // Clear previous pages
                $.each(event.data.pages, function(i, page) {
                    addPageToBook(page, event.data);
                });

                if (event.data.size) {
                    $('#inner').turn({
                        gradients: true,
                        autoCenter: true,
                        width: event.data.size.width * 2,
                        height: event.data.size.height,
                        page: 1,
                        acceleration: true,
                    });
                    // Add event listener for page turning
                    $('#inner').on('turning', function(event, page, view) {
                        // Play the sound
                        document.getElementById('pageTurnSound').play();
                    });
                }

                $('body').css('display', 'block');
            }
        } else if (event.data.show == false) {
            $('body').css('display', 'none');
        }

        $(document).keyup(function(e) {
            if (e.keyCode == 27) {
                $('body').css('display', 'none');
                $('#inner').turn('page', 1);
                $('#inner').turn('destroy');
                inner.style = "";
                $.post(`https://${GetParentResourceName()}/escape`, JSON.stringify({}));
            }
        });
    }

    // New event listener for adding a page
    if (event.data.event === 'addPage') {
        addPageToBook(event.data.page, event.data);
    }
});

// Function to add a page to the book
function addPageToBook(page, eventData) {
    if (page.source === 'local') {
        if (page.type === 'hard') {
            $('#inner').append('<div class="hard"><img src="img/' + eventData.book + '/' + page.pageName + '.png" width=' + (eventData.size ? eventData.size.width : '') + ' height=' + (eventData.size ? eventData.size.height : '') + '></div>');
        } else if (page.type === 'normal') {
            $('#inner').append('<div><img src="img/' + eventData.book + '/' + page.pageName + '.png" width=' + (eventData.size ? eventData.size.width : '') + ' height=' + (eventData.size ? eventData.size.height : '') + '></div>');
        }
    } else if (page.source === 'web')
    // Handle web pages if necessary
    $('#inner').append('<div><img src="web/' + page.pageName + '.png" width=' + (eventData.size ? eventData.size.width : '') + ' height=' + (eventData.size ? eventData.size.height : '') + '></div>');
}