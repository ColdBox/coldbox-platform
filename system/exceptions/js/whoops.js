/**
 * ColdBox Error Reporter - Interactive JavaScript Functions
 * Provides enhanced error reporting interface with code preview, stack trace navigation,
 * and framework reinitalization capabilities for the ColdBox BugReport template.
 */

/**
 * Toggles the visibility of the code preview panel in the error reporter
 * Switches between expanded and collapsed states with appropriate icon changes
 */
function toggleCodePreview() {
    var codePreviewContainer = document.querySelector( ".code-preview" );
	var upIcon = document.querySelector( "#codetoggle-up" );
	var bottomIcon = document.querySelector( "#codetoggle-down" );

    if( codePreviewShow ){
        // Hide the code preview panel
        codePreviewContainer.classList.add( "hidePreview" );
		upIcon.classList.add( "hidden" );
		bottomIcon.classList.remove( "hidden" );
    } else {
        // Show the code preview panel
        codePreviewContainer.classList.remove( "hidePreview" );
        upIcon.classList.remove( "hidden" );
        bottomIcon.classList.add( "hidden" );
    }
    codePreviewShow = !codePreviewShow;
}

/**
 * Scrolls the code preview to center on a specific line number
 * Used when clicking on stack trace entries to highlight the error location
 * @param {number} line - The line number to scroll to and highlight
 */
function scrollToLine( line ) {
	if (!codeContainer || !line) return;

	setTimeout( () => {
		// Matches class like "line number24"
		const selector = ".line.number" + line;
		const selectedLine = codeContainer.querySelector( selector );
		const scrollContainer = document.getElementById( "code-container" );

		// Guard against missing elements
		if ( !selectedLine || !scrollContainer ) {
			return;
		}

		// Approach 1: Using scrollIntoView
		selectedLine.scrollIntoView({
			behavior: "smooth",
			block: "center",
			inline: "nearest"
		});

		// Approach 2: Direct scroll calculation as fallback
		setTimeout(() => {
			const lineRect = selectedLine.getBoundingClientRect();
			const containerRect = scrollContainer.getBoundingClientRect();
			const offset = lineRect.top - containerRect.top + scrollContainer.scrollTop;
			const centerOffset = offset - (scrollContainer.clientHeight / 2);

			scrollContainer.scrollTo({
				top: Math.max(0, centerOffset),
				behavior: "smooth"
			});
		}, 100);
	}, 200 );
}

/**
 * Manages the active state of stack trace entries in the error reporter
 * Removes the active class from the currently active entry and adds it to the new one
 * @param {string} id - The ID of the stack trace element to make active
 */
function toggleActiveClasses( id ) {
    document.querySelector( ".stacktrace--active" ).classList.remove( "stacktrace--active" );
    document.getElementById( id ).classList.add( "stacktrace--active" );
}

/**
 * Updates the code preview panel when a stack trace entry is clicked
 * Handles syntax highlighting, template source injection, and line highlighting
 * @param {string} id - The ID of the stack trace frame to display
 */
function changeCodePanel( id ) {
	// Activate the selected stackframe visually
	toggleActiveClasses( id );

	// Get access to pre tag so we can populate and highlight it
	var code = document.getElementById( id + "-code" );
	// Get access to pre > script tag so we can populate it with template code when needed
	var codeScript = document.getElementById( id + "-script" );
	// Get the template id for injecting the source
	var templateSource = document.getElementById( "stackframe-" + code.getAttribute( "data-template-id" ) );

	// Only assign sources if codeContainer exists, else ignore.
	if( codeContainer == null ){
		return;
	}

	// Activate syntax highlighting only if template not rendered already (performance optimization)
	if( code.getAttribute( "data-template-rendered" ) == "false" ){
		// Inject template source into highlighter source
		codeScript.innerHTML = templateSource.innerHTML;
		codeScript.setAttribute( "type", "syntaxhighlighter" );
		// Activate SyntaxHighlighter for code formatting
		SyntaxHighlighter.highlight( {}, id + "-script" );
		// Mark as rendered to avoid re-processing
		code.setAttribute( "data-template-rendered", "true" );
	}

	// Inject the highlighted source to the code container for visualization
	codeContainer.innerHTML = code.innerHTML;
	//console.log(  "Scroll to line: " + code.getAttribute( "data-highlight-line" ) );
	// Scroll to the highlighted error line
    scrollToLine( code.getAttribute( "data-highlight-line" ) );
}

/**
 * Reinitializes the ColdBox framework by submitting a reinit form
 * Can optionally prompt for a password if framework reinit password is required
 * @param {boolean} usingPassword - Whether to prompt for reinit password
 */
function reinitframework( usingPassword ){
	var reinitForm = document.getElementById( 'reinitForm' );
	if( usingPassword ){
		reinitForm.fwreinit.value = prompt( "Reinit Password?" );
	}
	reinitForm.submit();
}

/**
 * Filters and shows/hides different scope sections in the error report
 * Manages the active state of filter links and visibility of data tables
 * @param {HTMLElement} linkEl - The filter link element that was clicked
 * @param {string} filterID - The ID of the section to show (empty string shows all)
 */
function filterScopes(linkEl, filterID ) {
    // Remove active class from all filter links
    var links = document.querySelectorAll('div.data-filter a');
    for (var i = 0; i < links.length; i++){
        links[i].classList.remove('active');
    }
    // Add active class to clicked link
    linkEl.classList.add('active');

    var sections = document.querySelectorAll('div.data-table');
    if(filterID != ""){
        // Hide all sections and show only the selected one
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.add('hidden');
        }
        document.getElementById(filterID).classList.remove('hidden');
    } else {
        // Show all sections when no filter is selected
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.remove('hidden');
        }
    }
    // Reset scroll position to top after filtering
    document.getElementById('request-info-details').scrollTop = 0;
}

/**
 * Handles dropdown-based filtering for scope sections
 * @param {HTMLSelectElement} selectEl - The dropdown select element
 */
function filterScopesFromDropdown(selectEl) {
    var filterID = selectEl.value;
    var sections = document.querySelectorAll('div.data-table');

    if(filterID != ""){
        // Hide all sections and show only the selected one
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.add('hidden');
        }
        document.getElementById(filterID).classList.remove('hidden');
    } else {
        // Show all sections when no filter is selected
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.remove('hidden');
        }
    }
    // Reset scroll position to top after filtering
    document.getElementById('request-info-details').scrollTop = 0;
}

/**
 * Copies the text content of a specified element to the system clipboard
 * Supports both Internet Explorer and modern browsers with different clipboard APIs
 * @param {string} id - The ID of the element whose content should be copied
 */
function copyToClipboard( id ) {
	var elm = document.getElementById( id );

	// Legacy Internet Explorer clipboard support
	if( document.body.createTextRange ) {
		var range = document.body.createTextRange();
		range.moveToElementText( elm );
		range.select();
		document.execCommand( "Copy" );
	} else if ( window.getSelection ) {
		// Modern browsers using Selection API
		var selection = window.getSelection();
		var range = document.createRange();
		range.selectNodeContents( elm );
		selection.removeAllRanges();
		selection.addRange( range );
		document.execCommand("Copy");
	}
}

/**
 * Extends Element prototype to calculate absolute offset from document top
 * Recursively traverses up the parent chain to get total offset
 * @returns {number} The total offset from the top of the document
 */
Element.prototype.documentOffsetTop = function () {
    return this.offsetTop + ( this.offsetParent ? this.offsetParent.documentOffsetTop() : 0 );
};

// Global state variables for the error reporter interface
var codePreviewShow = true;  // Tracks whether code preview panel is currently visible
var codeWrapper 	= document.querySelector( ".code-preview" );  // Code preview container element
var codeContainer 	= document.getElementById( "code-container" );  // Main code display container

/**
 * Initialize stack trace keyboard navigation
 * Adds keyboard support for accessibility (Enter and Space keys)
 */
Array.from( document.querySelectorAll( ".stacktrace" ) )
    .forEach( function( stackTrace ) {
        // Mouse click handler
        stackTrace.addEventListener( "click", function( e ) {
            changeCodePanel( stackTrace.id );
        }, false );

        // Keyboard handler for accessibility
        stackTrace.addEventListener( "keydown", function( e ) {
            if ( e.key === "Enter" || e.key === " " ) {
                e.preventDefault();
                changeCodePanel( stackTrace.id );
            }
        }, false );
    } );

/**
 * Initialize the error reporter interface when DOM is ready
 * Automatically selects and displays the first stack trace entry
 */
document.addEventListener( "DOMContentLoaded", function() {
	var initialStackTrace = document.querySelector( ".stacktrace__list .stacktrace" );
    setTimeout( function(){
		changeCodePanel( initialStackTrace.id );
	}, 500 );  // Small delay to ensure all elements are properly rendered
} );
