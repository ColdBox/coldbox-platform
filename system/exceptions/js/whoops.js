/**
 * ColdBox Error Reporter - Alpine.js Component
 * Provides reactive error reporting interface with code preview, stack trace navigation,
 * and framework reinitalization capabilities for the ColdBox BugReport template.
 */

/**
 * Main Alpine.js component for the Whoops error reporter
 * @returns {object} Alpine.js data object
 */
function whoopsReporter() {
    console.log( 'Initializing whoopsReporter Alpine.js component' );

    return {
        // State variables
        codePreviewShow: true,
        activeFrame: 'stack1',
        currentFilePath: '',
        currentLineNumber: 0,
		currentIdeLink: '',

		 // Default height in pixels
        codePreviewHeight: 600,
		// Default dragging state + dimensions
        isDragging: false,
        dragStartY: 0,
        dragStartHeight: 0,
        minHeight: 300,
        maxHeight: 800,

        // DOM references
        codeContainer: null,
		reinitForm: null,

        /**
         * Initialize the component when Alpine loads
         */
        init() {
            try {
                // Set up DOM references
                this.codeContainer = document.getElementById( 'code-container' );
				this.reinitForm = document.getElementById( 'reinitForm' );

                // Initialize first stack trace automatically
                this.$nextTick( () => {
                    const initialStackTrace = document.querySelector( '.stacktrace__list .stacktrace' );
                    if ( initialStackTrace ) {
                        setTimeout( () => {
                        	 this.changeCodePanel( initialStackTrace.id );
                        }, 500 );
                    }
                } );
            } catch ( error ) {
                console.error( 'Error in Alpine.js init:', error );
            }
        },

        /**
         * Toggles the visibility of the code preview panel
         */
        toggleCodePreview() {
            this.codePreviewShow = !this.codePreviewShow;
        },

        /**
         * Handles mouse down event on the slider handle
         * @param {MouseEvent} event - The mouse down event
         */
        startDrag( event ) {
            this.isDragging = true;
            this.dragStartY = event.clientY;
            this.dragStartHeight = this.codePreviewHeight;

            // Prevent text selection during drag
            event.preventDefault();
            event.stopPropagation();

            // Add global event listeners with bound context
            this.boundHandleDrag = this.handleDrag.bind( this );
            this.boundEndDrag = this.endDrag.bind( this );

            document.addEventListener( 'mousemove', this.boundHandleDrag );
            document.addEventListener( 'mouseup', this.boundEndDrag );

            // Prevent page scrolling during drag
            document.body.style.userSelect = 'none';
        },

        /**
         * Handles mouse move during drag
         * @param {MouseEvent} event - The mouse move event
         */
        handleDrag( event ) {
            if ( !this.isDragging ) return;

            event.preventDefault();

            const deltaY = event.clientY - this.dragStartY;
            const newHeight = Math.max(
                this.minHeight,
                Math.min( this.maxHeight, this.dragStartHeight + deltaY )
            );

            this.codePreviewHeight = newHeight;

            // Ensure preview is shown when dragging
            if ( !this.codePreviewShow ) {
                this.codePreviewShow = true;
            }
        },

        /**
         * Handles mouse up to end drag
         * @param {MouseEvent} event - The mouse up event
         */
        endDrag( event ) {
            this.isDragging = false;

            // Remove global event listeners
            if ( this.boundHandleDrag ) {
                document.removeEventListener( 'mousemove', this.boundHandleDrag );
            }
            if ( this.boundEndDrag ) {
                document.removeEventListener( 'mouseup', this.boundEndDrag );
            }

            // Restore page interaction
            document.body.style.userSelect = '';

            // Clean up bound references
            this.boundHandleDrag = null;
            this.boundEndDrag = null;
        },

        /**
         * Handles click on slider handle for full toggle
         * @param {MouseEvent} event - The click event
         */
        handleSliderClick( event ) {
            // Only toggle if we haven't moved significantly (not a drag)
            const currentY = event.clientY;
            const dragThreshold = 5; // pixels

            if ( Math.abs( currentY - this.dragStartY ) < dragThreshold ) {
                this.toggleCodePreview();
            }
        },

        /**
         * Scrolls the code preview to center on a specific line number
         * @param {number} line - The line number to scroll to and highlight
         */
        scrollToLine( line ) {
            if ( !this.codeContainer || !line ) return;

            setTimeout( () => {
                // Matches class like "line number24"
                const selector = ".line.number" + line;
                const selectedLine = this.codeContainer.querySelector( selector );
                const scrollContainer = document.getElementById( "code-container" );

                // Guard against missing elements
                if ( !selectedLine || !scrollContainer ) {
                    return;
                }

                // Using scrollIntoView for smooth centering
                selectedLine.scrollIntoView( {
                    behavior: "smooth",
                    block: "center",
                    inline: "nearest"
                } );

                // Fallback scroll calculation
                setTimeout( () => {
                    const lineRect = selectedLine.getBoundingClientRect();
                    const containerRect = scrollContainer.getBoundingClientRect();
                    const offset = lineRect.top - containerRect.top + scrollContainer.scrollTop;
                    const centerOffset = offset - ( scrollContainer.clientHeight / 2 );

                    scrollContainer.scrollTo( {
                        top: Math.max( 0, centerOffset ),
                        behavior: "smooth"
                    } );
                }, 100 );
            }, 200 );
        },

        /**
         * Updates the code preview panel when a stack trace entry is clicked
		 *
         * @param {string} target - The clicked stack trace frame element
         */
        changeCodePanel( target ) {

			// The target can be an id or the actual currentTarget element
			if ( typeof target === 'string' ) {
				target = document.getElementById( target );
			}

			// Get the Info from the target element
			const {
				stackframe,
				location,
				idelink,
				line
			}  = target.dataset;

            try {
                // Update active frame
                this.activeFrame = stackframe;
				this.currentFilePath = location || '';
				this.currentIdeLink = idelink || '';
				this.currentLineNumber = parseInt( line ) || 0;

                // Get access to pre tag so we can populate and highlight it
                const code = document.getElementById( this.activeFrame + "-code" );
                if ( !code ) {
                    console.warn( 'Code element not found:', this.activeFrame + "-code" );
                    return;
                }

                // Get access to pre > script tag so we can populate it with template code when needed
                const codeScript = document.getElementById( this.activeFrame + "-script" );
                if ( !codeScript ) {
                    console.warn( 'Code script element not found:', this.activeFrame + "-script" );
                    return;
                }

                // Get the template id for injecting the source
                const templateId = "stackframe-" + code.getAttribute( "data-template-id" );
                const templateSource = document.getElementById( templateId );
                if ( !templateSource ) {
                    console.warn( 'Template source not found:', templateId );
                    return;
                }

                // Only assign sources if codeContainer exists, else ignore.
                if ( this.codeContainer == null ) {
                    console.warn( 'Code container not found' );
                    return;
                }

                // Activate syntax highlighting only if template not rendered already (performance optimization)
                if ( code.getAttribute( "data-template-rendered" ) == "false" ) {
                    // Inject template source into highlighter source
                    codeScript.innerHTML = templateSource.innerHTML;
                    codeScript.setAttribute( "type", "syntaxhighlighter" );
                    // Activate SyntaxHighlighter for code formatting
                    if ( typeof SyntaxHighlighter !== 'undefined' ) {
                        SyntaxHighlighter.highlight( {}, this.activeFrame + "-script" );
                    }
                    // Mark as rendered to avoid re-processing
                    code.setAttribute( "data-template-rendered", "true" );
                }

                // Inject the highlighted source to the code container for visualization
                this.codeContainer.innerHTML = code.innerHTML;
                // Scroll to the highlighted error line
                this.scrollToLine( code.getAttribute( "data-highlight-line" ) );
            } catch ( error ) {
                console.error( 'Error in changeCodePanel:', error );
            }
        },

        /**
         * Reinitializes the ColdBox framework by submitting a reinit form
         * @param {boolean} usingPassword - Whether to prompt for reinit password
         */
        reinitFramework( usingPassword ) {
            if ( usingPassword ) {
                this.reinitForm.fwreinit.value = prompt( "Reinit Password?" );
            }
            this.reinitForm.submit();
        },

        /**
         * Handles dropdown-based filtering for scope sections
         * @param {HTMLSelectElement} selectEl - The dropdown select element
         */
        filterScopesFromDropdown( selectEl ) {
            const filterID = selectEl.value;
            const sections = document.querySelectorAll( 'div.data-table' );

            if ( filterID != "" ) {
                // Hide all sections and show only the selected one
                for ( let i = 0; i < sections.length; i++ ) {
                    sections[ i ].classList.add( 'hidden' );
                }
                document.getElementById( filterID ).classList.remove( 'hidden' );
            } else {
                // Show all sections when no filter is selected
                for ( let i = 0; i < sections.length; i++ ) {
                    sections[ i ].classList.remove( 'hidden' );
                }
            }
            // Reset scroll position to top after filtering
            document.getElementById( 'request-info-details' ).scrollTop = 0;
        },

        /**
         * Copies the text content of a specified element to the system clipboard
         * @param {string} id - The ID of the element whose content should be copied
         */
        copyToClipboard( id ) {
            const elm = document.getElementById( id );
            if ( !elm ) return;

            // Copy to clipboard
            const textToCopy = elm.textContent || elm.innerText;
            let copySuccess = false;

            // Modern clipboard API
            if ( navigator.clipboard && window.isSecureContext ) {
                navigator.clipboard.writeText( textToCopy ).then( () => {
                    copySuccess = true;
                    this.showCopyFeedback( elm );
                }).catch( () => {
                    // Fallback if modern API fails
                    this.fallbackCopy( elm );
                });
                return;
            }

            // Fallback for older browsers
            this.fallbackCopy( elm );
        },

        /**
         * Fallback copy method for older browsers
         * @param {HTMLElement} elm - The element to copy from
         */
        fallbackCopy( elm ) {
            if ( window.getSelection ) {
                const selection = window.getSelection();
                const range = document.createRange();
                range.selectNodeContents( elm );
                selection.removeAllRanges();
                selection.addRange( range );

                try {
                    const success = document.execCommand( "Copy" );
                    if ( success ) {
                        this.showCopyFeedback( elm );
                    }
                } catch ( e ) {
                    console.warn( 'Copy to clipboard failed:', e );
                } finally {
                    selection.removeAllRanges();
                }
            }
        },

        /**
         * Shows visual feedback when content is copied to clipboard
         * @param {HTMLElement} elm - The element that was copied from
         */
        showCopyFeedback( elm ) {
            // Add the success animation class
            elm.classList.add( 'copy-success' );

            // Remove the class after animation completes
            setTimeout( () => {
                elm.classList.remove( 'copy-success' );
            }, 800 ); // Match the animation duration
        }
    };
}
