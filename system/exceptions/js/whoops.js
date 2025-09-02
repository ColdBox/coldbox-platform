/**
 * ColdBox Error Reporter - Alpine.js Component
 * Provides reactive error reporting interface with code preview, stack trace navigation,
 * and framework reinitalization capabilities for the ColdBox BugReport template.
 */

/**
 * Main Alpine.js component for the Whoops error reporter
 *
 * @returns {object} Alpine.js data object
 */
function whoopsReporter( eventDetails, serverInfo, databaseInfo ) {
    console.log( 'Initializing whoopsReporter Alpine.js component' );

    return {
        // State variables
        codePreviewShow: true,
        activeFrame: 'stack1',
        currentFilePath: '',
        currentLineNumber: 0,
		currentIdeLink: '',

		// Data Variables
		eventDetails,
		serverInfo,
		databaseInfo,

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

		// Stacktrace state
		stacktraceData: {
			showRaw: false,
			allFrames: [],
			filteredFrames: [],
			searchTerm: ''
		},

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

				// Initialize enhanced stacktrace
				this.initializeStacktrace();
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
		 * @param {string} highlightTargetId - Optional ID to highlight after copying
         */
        copyToClipboard( id, highlightTargetId ) {
            const target = document.getElementById( id );
            if ( !target ) return;

            // Copy to clipboard
            const textToCopy = target.textContent || target.innerText;
            let copySuccess = false;

            // Modern clipboard API
            if ( navigator.clipboard && window.isSecureContext ) {
                navigator.clipboard.writeText( textToCopy ).then( () => {
                    copySuccess = true;
                    this.showCopyFeedback( highlightTargetId ? document.getElementById( highlightTargetId ) : target );
                }).catch( () => {
                    // Fallback if modern API fails
                    this.fallbackCopy( target );
                });
                return;
            }

            // Fallback for older browsers
            this.fallbackCopy( target );
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
        },

		/**
		 * Initialize stacktrace data from raw trace
		 */
		initializeStacktrace() {
			const rawTrace = document.getElementById( 'stacktrace-raw' );
			if ( rawTrace && rawTrace.textContent ) {
				const lines = rawTrace.textContent.split( '\n' ).filter( line => line.trim() !== '' );
				this.stacktraceData.allFrames = lines;
				this.stacktraceData.filteredFrames = lines;
				this.renderStacktraceFrames();
				this.updateFrameCount();
			}
		},

		/**
		 * Toggle between enhanced and raw stacktrace views
		 */
		toggleStacktraceView() {
			this.stacktraceData.showRaw = !this.stacktraceData.showRaw;
		},

		/**
		 * Filter stacktrace frames based on search input
		 */
		filterStacktraceFrames() {
			const searchTerm = this.stacktraceData.searchTerm.toLowerCase();

			if ( searchTerm === '' ) {
				this.stacktraceData.filteredFrames = this.stacktraceData.allFrames;
			} else {
				this.stacktraceData.filteredFrames = this.stacktraceData.allFrames.filter( frame =>
					frame.toLowerCase().includes( searchTerm )
				);
			}

			this.renderStacktraceFrames();
			this.updateFrameCount();
		},

		/**
		 * Render filtered stacktrace frames to the DOM
		 */
		renderStacktraceFrames() {
			// This will be handled by Alpine.js template rendering
			// The actual rendering happens in the HTML template
			this.$nextTick( () => {
				if ( window.eva ) eva.replace();
			} );
		},

		/**
		 * Update the frame count display
		 */
		updateFrameCount() {
			// This is reactive and handled by Alpine.js bindings
		},

		/**
		 * Clear the search and reset filters
		 */
		clearSearch() {
			this.stacktraceData.searchTerm = '';
			this.filterStacktraceFrames();
		},

		/**
		 * Copy a specific stacktrace frame to clipboard
		 * @param {number} index - The index of the frame to copy
		 */
		copyStacktraceFrame( index ) {
			if ( this.stacktraceData.filteredFrames[ index ] ) {
				// Create temporary element for copying
				const tempEl = document.createElement( 'div' );
				tempEl.textContent = this.stacktraceData.filteredFrames[ index ];
				tempEl.id = 'temp-frame-' + index;
				tempEl.style.display = 'none';
				document.body.appendChild( tempEl );

				// Use the existing copyToClipboard method
				this.copyToClipboard( 'temp-frame-' + index, 'stacktrace-frame-' + index );

				// Clean up
				setTimeout( () => {
					if ( document.body.contains( tempEl ) ) {
						document.body.removeChild( tempEl );
					}
				}, 100 );
			}
		},

		/**
		 * Highlight search matches in text
		 * @param {string} text - The text to highlight
		 * @param {string} searchTerm - The search term to highlight
		 * @returns {string} - The text with highlighted matches
		 */
		highlightMatch( text, searchTerm ) {
			if ( !text ) return text;

			// First apply file type highlighting
			let highlightedText = this.highlightFileTypes( text );

			// Then apply search term highlighting if provided
			if ( searchTerm ) {
				const regex = new RegExp( '(' + searchTerm.replace( /[.*+?^${}()|[\]\\]/g, '\\$&' ) + ')', 'gi' );
				highlightedText = highlightedText.replace( regex, '<mark class="stacktrace-highlight">$1</mark>' );
			}

			return highlightedText;
		},

		/**
		 * Highlight file extensions and paths in stacktrace frames
		 * @param {string} text - The text to highlight
		 * @returns {string} - The text with file type highlights
		 */
		highlightFileTypes( text ) {
			if ( !text ) return text;

			// Define file type patterns and their corresponding classes
			const filePatterns = [
				{
					regex: /(\b\w+\.cfc)(?=[\s:\)]|$)/gi,
					class: 'file-type-cfc',
					tooltip: 'CFML Component'
				},
				{
					regex: /(\b\w+\.cfm)(?=[\s:\)]|$)/gi,
					class: 'file-type-cfm',
					tooltip: 'CFML Markup'
				},
				{
					regex: /(\b\w+\.cfs)(?=[\s:\)]|$)/gi,
					class: 'file-type-cfs',
					tooltip: 'CFML Script'
				},
				{
					regex: /(\b\w+\.bx)(?=[\s:\)]|$)/gi,
					class: 'file-type-bx',
					tooltip: 'BoxLang Class'
				},
				{
					regex: /(\b\w+\.bxm)(?=[\s:\)]|$)/gi,
					class: 'file-type-bxm',
					tooltip: 'BoxLang Markup'
				},
				{
					regex: /(\b\w+\.bxs)(?=[\s:\)]|$)/gi,
					class: 'file-type-bxs',
					tooltip: 'BoxLang Script'
				},
				{
					regex: /(\b\w+\.java)(?=[\s:\)]|$)/gi,
					class: 'file-type-java',
					tooltip: 'Java Source'
				}
			];

			let result = text;

			// Apply each file type highlighting
			filePatterns.forEach( pattern => {
				result = result.replace(
					pattern.regex,
					`<span class="${ pattern.class }" title="${ pattern.tooltip }">$1</span>`
				);
			} );

			// Highlight full file paths (anything that looks like a file path)
			result = result.replace(
				/(\/[^\s\)]+\.(cfc|cfm|cfs|bx|bxm|bxs|java))/gi,
				'<span class="file-path" title="File Path">$1</span>'
			);

			// Highlight line numbers that follow file paths
			result = result.replace(
				/(:)(\d+)(?=[\s\)]|$)/g,
				'$1<span class="line-number-highlight" title="Line Number">$2</span>'
			);

			return result;
		},

		/**
		 * Open email client to send stacktrace
		 */
		emailStacktrace() {
			const rawTrace = document.getElementById( 'stacktrace-raw' );
			if ( !rawTrace ) return;

			// Get comprehensive error context
			const errorContext = this.collectErrorContext();

			// Compose enhanced email content
			const subject = encodeURIComponent( `ColdBox Exception Report - ${ errorContext.exceptionType }` );
			const body = encodeURIComponent(
				`ColdBox Framework Exception Report

=== ERROR SUMMARY ===
Type: ${ errorContext.exceptionType }
Message: ${ errorContext.exceptionMessage }
Environment: ${ errorContext.environment || 'Unknown' }
Timestamp: ${ errorContext.timestamp }

=== LOCATION ===
File: ${ errorContext.currentFile }
Line: ${ errorContext.currentLine }
URL: ${ errorContext.url }
Event: ${ errorContext.event || 'N/A' }
Route: ${ errorContext.route || 'N/A' }

=== FRAMEWORK CONTEXT ===
Framework: ${ errorContext.framework }
Language: ${ errorContext.language }
Severity: ${ errorContext.severity }

${ errorContext.databaseError ? `
=== DATABASE ERROR ===
Datasource: ${ errorContext.databaseError.datasource || 'N/A' }
SQL State: ${ errorContext.databaseError.sqlState || 'N/A' }
SQL: ${ errorContext.databaseError.sql || 'N/A' }
` : '' }

=== SERVER INFORMATION ===
Host: ${ errorContext.serverInfo.host || 'N/A' }
Server: ${ errorContext.serverInfo.server || 'N/A' }
Remote Address: ${ errorContext.serverInfo.remoteAddress || 'N/A' }
Browser: ${ errorContext.serverInfo.browser || 'N/A' }

=== CODE CONTEXT ===
${ errorContext.codeSnippet ? errorContext.codeSnippet : 'No code context available' }

=== FULL STACKTRACE ===
${ errorContext.stacktrace }

---
Generated by ColdBox Framework Whoops Error Reporter
${ new Date().toLocaleString() }`
			);

			// Create mailto URL
			const mailtoUrl = `mailto:?subject=${ subject }&body=${ body }`;

			// Open email client
			window.location.href = mailtoUrl;
		},

		/**
		 * Send error details to AI for analysis
		 */
		askAI() {
			// Collect comprehensive error context
			const errorContext = this.collectErrorContext();

			// Show AI analysis modal/interface
			this.showAIAnalysis( errorContext );
		},

		/**
		 * Collect comprehensive error context for AI analysis
		 * @returns {object} Error context object
		 */
		collectErrorContext() {
			const rawTrace = document.getElementById( 'stacktrace-raw' );
			const exceptionMessage = document.getElementById( 'exceptionMessage' );

			// Get exception details
			const exceptionType = document.querySelector( '.exception__type span' )?.textContent || '';
			const exceptionMsg = exceptionMessage?.textContent || '';

			// Get current file context
			const currentFile = this.currentFilePath || '';
			const currentLine = this.currentLineNumber || 0;

			// Get stacktrace
			const stacktrace = rawTrace?.textContent || rawTrace?.innerText || '';

			// Get framework info
			const framework = 'ColdBox Framework';
			const timestamp = new Date().toISOString();
			const url = window.location.href;

			// Extract detailed error information from data tables
			const errorDetails = this.extractScopeData( 'eventdetails' );
			const serverInfo = this.extractScopeData( 'serverinfo_scope' );
			const databaseInfo = this.extractScopeData( 'database_scope' );
			const rcInfo = this.extractScopeData( 'rc_scope' );
			const prcInfo = this.extractScopeData( 'prc_scope' );
			const headersInfo = this.extractScopeData( 'headers_scope' );

			// Get code snippet from current active frame if available
			let codeSnippet = '';
			const codeContainer = document.getElementById( 'code-container' );
			if ( codeContainer ) {
				const codeLines = codeContainer.querySelectorAll( '.line' );
				// Get a few lines around the error for context
				codeLines.forEach( ( line, index ) => {
					if ( index >= Math.max( 0, currentLine - 3 ) && index <= currentLine + 3 ) {
						codeSnippet += line.textContent + '\n';
					}
				} );
			}

			return {
				exceptionType,
				exceptionMessage: exceptionMsg,
				currentFile,
				currentLine,
				stacktrace,
				codeSnippet,
				framework,
				timestamp,
				url,
				// Enhanced context from data tables
				environment: errorDetails?.Environment || 'Unknown',
				event: errorDetails?.Event || '',
				route: errorDetails?.Route || '',
				routeName: errorDetails?.['Route Name'] || '',
				layout: errorDetails?.Layout || '',
				view: errorDetails?.View || '',
				module: errorDetails?.Module || '',
				// Server information
				serverInfo: {
					host: serverInfo?.Host || '',
					server: serverInfo?.Server || '',
					templatePath: serverInfo?.['Template Path'] || '',
					remoteAddress: serverInfo?.['Remote Address'] || '',
					browser: serverInfo?.Browser || '',
					referrer: serverInfo?.Referrer || ''
				},
				// Database error details (if applicable)
				databaseError: Object.keys( databaseInfo || {} ).length > 0 ? {
					datasource: databaseInfo?.Datasource || '',
					sqlState: databaseInfo?.['SQL State'] || '',
					sql: databaseInfo?.['SQL Sent'] || '',
					nativeErrorCode: databaseInfo?.NativeErrorCode || '',
					driverMessage: databaseInfo?.['Driver Error Message'] || ''
				} : null,
				// Request context
				requestContext: {
					rc: rcInfo,
					prc: prcInfo,
					headers: headersInfo
				},
				// Additional context
				language: this.detectLanguage( currentFile ),
				severity: this.assessErrorSeverity( exceptionType, exceptionMsg )
			};
		},

		/**
		 * Extract data from a scope data table
		 * @param {string} scopeId - The ID of the scope data table
		 * @returns {object} Extracted scope data
		 */
		extractScopeData( scopeId ) {
			const scopeElement = document.getElementById( scopeId );
			if ( !scopeElement ) return {};

			const data = {};
			const rows = scopeElement.querySelectorAll( '.data-table-row, tr' );

			rows.forEach( row => {
				const cells = row.querySelectorAll( 'td, .data-table-cell' );
				if ( cells.length >= 2 ) {
					const key = cells[ 0 ].textContent?.trim();
					const value = cells[ 1 ].textContent?.trim();
					if ( key && value ) {
						data[ key ] = value;
					}
				}
			} );

			return data;
		},		/**
		 * Detect programming language from file extension
		 * @param {string} filePath - The file path
		 * @returns {string} Language identifier
		 */
		detectLanguage( filePath ) {
			if ( !filePath ) return 'unknown';

			const ext = filePath.split( '.' ).pop()?.toLowerCase();
			const languageMap = {
				'cfc': 'CFML Component',
				'cfm': 'CFML Template',
				'cfs': 'CFML Script',
				'bx': 'BoxLang Component',
				'bxm': 'BoxLang Template',
				'bxs': 'BoxLang Script',
				'java': 'Java',
				'js': 'JavaScript'
			};

			return languageMap[ ext ] || ext || 'unknown';
		},

		/**
		 * Assess error severity based on type and message
		 * @param {string} type - Error type
		 * @param {string} message - Error message
		 * @returns {string} Severity level
		 */
		assessErrorSeverity( type, message ) {
			const criticalKeywords = [ 'database', 'security', 'authentication', 'authorization' ];
			const warningKeywords = [ 'deprecated', 'warning', 'notice' ];

			const lowerType = type.toLowerCase();
			const lowerMsg = message.toLowerCase();

			if ( criticalKeywords.some( keyword => lowerType.includes( keyword ) || lowerMsg.includes( keyword ) ) ) {
				return 'critical';
			}

			if ( warningKeywords.some( keyword => lowerType.includes( keyword ) || lowerMsg.includes( keyword ) ) ) {
				return 'warning';
			}

			return 'error';
		},

		/**
		 * Show AI analysis interface
		 * @param {object} errorContext - The collected error context
		 */
		showAIAnalysis( errorContext ) {
			// Create AI analysis prompt
			const aiPrompt = this.createAIPrompt( errorContext );

			// For now, we'll use a simple approach - open a new window with AI services
			// This can be enhanced to integrate with specific AI APIs later
			const aiOptions = [
				{
					name: 'ChatGPT',
					url: 'https://chat.openai.com/',
					prompt: aiPrompt
				},
				{
					name: 'Claude',
					url: 'https://claude.ai/',
					prompt: aiPrompt
				},
				{
					name: 'GitHub Copilot Chat',
					action: 'copy', // Copy to clipboard for use in VS Code
					prompt: aiPrompt
				}
			];

			this.showAIOptionsModal( aiOptions, aiPrompt );
		},

		/**
		 * Create AI analysis prompt from error context
		 * @param {object} context - Error context
		 * @returns {string} AI prompt
		 */
		createAIPrompt( context ) {
			return `I need help analyzing a ColdBox Framework error. Please provide expert analysis and actionable solutions.

**🚨 EXCEPTION DETAILS**
- **Type**: ${ context.exceptionType }
- **Message**: ${ context.exceptionMessage }
- **Severity**: ${ context.severity }
- **Environment**: ${ context.environment }

**📍 LOCATION & CONTEXT**
- **File**: ${ context.currentFile }
- **Line**: ${ context.currentLine }
- **Language**: ${ context.language }
- **URL**: ${ context.url }

**🎯 COLDBOX FRAMEWORK CONTEXT**
- **Event**: ${ context.event || 'N/A' }
- **Route**: ${ context.route || 'N/A' }
- **Route Name**: ${ context.routeName || 'N/A' }
- **Layout**: ${ context.layout || 'N/A' }
- **View**: ${ context.view || 'N/A' }
- **Module**: ${ context.module || 'N/A' }

**🖥️ SERVER ENVIRONMENT**
- **Host**: ${ context.serverInfo.host }
- **Server**: ${ context.serverInfo.server }
- **Template Path**: ${ context.serverInfo.templatePath }
- **Remote Address**: ${ context.serverInfo.remoteAddress }
- **Browser**: ${ context.serverInfo.browser }

${ context.databaseError ? `
**💾 DATABASE ERROR DETAILS**
- **Datasource**: ${ context.databaseError.datasource }
- **SQL State**: ${ context.databaseError.sqlState }
- **Native Error Code**: ${ context.databaseError.nativeErrorCode }
- **Driver Message**: ${ context.databaseError.driverMessage }
- **SQL Query**:
\`\`\`sql
${ context.databaseError.sql }
\`\`\`
` : '' }

${ Object.keys( context.requestContext.rc || {} ).length > 0 ? `
**📥 REQUEST COLLECTION (RC)**
${ Object.entries( context.requestContext.rc ).map( ( [ key, value ] ) => `- **${ key }**: ${ value }` ).join( '\n' ) }
` : '' }

${ Object.keys( context.requestContext.prc || {} ).length > 0 ? `
**🔒 PRIVATE REQUEST COLLECTION (PRC)**
${ Object.entries( context.requestContext.prc ).slice( 0, 10 ).map( ( [ key, value ] ) => `- **${ key }**: ${ value }` ).join( '\n' ) }
${ Object.keys( context.requestContext.prc ).length > 10 ? '- ... (truncated for brevity)' : '' }
` : '' }

**💻 CODE CONTEXT (Around Line ${ context.currentLine })**
\`\`\`${ context.language.toLowerCase().includes( 'cfml' ) ? 'cfml' : context.language.toLowerCase().includes( 'boxlang' ) ? 'javascript' : 'javascript' }
${ context.codeSnippet || 'No code context available' }
\`\`\`

**📋 STACK TRACE** (First 50 lines)
\`\`\`
${ context.stacktrace.split( '\n' ).slice( 0, 50 ).join( '\n' ) }${ context.stacktrace.split( '\n' ).length > 50 ? '\n... (truncated for brevity)' : '' }
\`\`\`

**❓ ANALYSIS REQUESTED**
As a ColdBox Framework expert, please provide:

1. **🔍 Root Cause Analysis**: What is most likely causing this error?

2. **⚡ Immediate Solutions**: What are the most common and effective fixes for this specific error?

3. **🎯 ColdBox-Specific Considerations**:
   - Are there any ColdBox conventions, settings, or configurations that could be involved?
   - Any framework-specific patterns or anti-patterns that might be causing this?

4. **🛠️ Debugging Strategy**: What specific debugging steps would you recommend to isolate this issue?

5. **🔒 Security & Performance**: Are there any security or performance implications I should consider?

6. **📚 Best Practices**: How can I prevent similar errors in the future? Any ColdBox best practices to follow?

${ context.databaseError ? `
7. **💾 Database-Specific Advice**: What database-specific troubleshooting steps do you recommend for this SQL error?
` : '' }

**🎯 Context**: This is a ${ context.environment } environment running ColdBox Framework. Please provide practical, actionable advice that considers the full context of this error.`;
		},

		/**
		 * Show AI options modal
		 * @param {array} options - Available AI options
		 * @param {string} prompt - The AI prompt
		 */
		showAIOptionsModal( options, prompt ) {
			// Create modal HTML
			const modalHTML = `
				<div class="ai-modal-overlay" id="ai-modal-overlay" style="
					position: fixed;
					top: 0;
					left: 0;
					width: 100%;
					height: 100%;
					background: rgba(0,0,0,0.7);
					display: flex;
					align-items: center;
					justify-content: center;
					z-index: 10000;
					backdrop-filter: blur(3px);
				">
					<div class="ai-modal" style="
						background: #1a1a1a;
						border: 1px solid #333;
						border-radius: 8px;
						padding: 24px;
						max-width: 500px;
						width: 90%;
						color: white;
					">
						<div class="ai-modal-header" style="
							display: flex;
							align-items: center;
							margin-bottom: 20px;
							padding-bottom: 16px;
							border-bottom: 1px solid #333;
						">
							<i data-eva="bulb-outline" data-eva-height="24" data-eva-fill="#7fcbe2" style="margin-right: 12px;"></i>
							<h3 style="margin: 0; color: #7fcbe2;">Ask AI for Help</h3>
							<button onclick="document.getElementById('ai-modal-overlay').remove()" style="
								margin-left: auto;
								background: none;
								border: none;
								color: #999;
								cursor: pointer;
								font-size: 18px;
							">×</button>
						</div>

						<p style="margin-bottom: 20px; color: #ccc; font-size: 14px;">
							Choose how you'd like to get AI assistance with this error:
						</p>

						<div class="ai-options" style="display: flex; flex-direction: column; gap: 12px;">
							${ options.map( option => `
								<button
									onclick="window.aiHelper.handleAIOption('${ option.name }', '${ option.url || '' }', '${ option.action || 'open' }')"
									style="
										display: flex;
										align-items: center;
										padding: 12px 16px;
										background: #2d2d2d;
										border: 1px solid #444;
										border-radius: 6px;
										color: white;
										cursor: pointer;
										transition: all 0.2s;
										text-align: left;
									"
									onmouseover="this.style.background='#3d3d3d'; this.style.borderColor='#7fcbe2'"
									onmouseout="this.style.background='#2d2d2d'; this.style.borderColor='#444'"
								>
									<span style="font-weight: 500;">${ option.name }</span>
									<span style="margin-left: auto; color: #999; font-size: 12px;">
										${ option.action === 'copy' ? 'Copy prompt' : 'Open in new tab' }
									</span>
								</button>
							` ).join( '' ) }
						</div>

						<div class="ai-prompt-preview" style="margin-top: 20px; padding-top: 16px; border-top: 1px solid #333;">
							<label style="display: block; color: #7fcbe2; font-size: 12px; margin-bottom: 8px;">
								Preview of AI Prompt:
							</label>
							<div style="
								background: #0d1117;
								border: 1px solid #333;
								border-radius: 4px;
								padding: 12px;
								max-height: 200px;
								overflow-y: auto;
								font-family: 'Monaco', 'Courier New', monospace;
								font-size: 11px;
								color: #e6e6e6;
								white-space: pre-wrap;
							">${ prompt.substring( 0, 500 ) }${ prompt.length > 500 ? '...' : '' }</div>
						</div>
					</div>
				</div>
			`;

			// Add modal to DOM
			document.body.insertAdjacentHTML( 'beforeend', modalHTML );

			// Initialize icons
			if ( window.eva ) eva.replace();

			// Set up AI helper
			window.aiHelper = {
				prompt: prompt,
				handleAIOption: ( name, url, action ) => {
					if ( action === 'copy' ) {
						// Copy to clipboard
						navigator.clipboard.writeText( prompt ).then( () => {
							alert( `AI prompt copied to clipboard! You can now paste it into ${ name }.` );
						} );
					} else {
						// Open in new tab and copy prompt
						const newWindow = window.open( url, '_blank' );
						navigator.clipboard.writeText( prompt );
						alert( `Opening ${ name }... The AI prompt has been copied to your clipboard - paste it into the chat.` );
					}
					document.getElementById( 'ai-modal-overlay' ).remove();
				}
			};
		}
    };
}
