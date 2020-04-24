Element.prototype.documentOffsetTop = function () {
    return this.offsetTop + ( this.offsetParent ? this.offsetParent.documentOffsetTop() : 0 );
};
var codePreviewShow = true;
function toggleCodePreview() {
    var codePreviewContainer = document.querySelector( ".code-preview" );
    var toggleBtnIcon = document.querySelector( ".slideup_row i" );
    console.log(codePreviewContainer);
    if(codePreviewShow){
        codePreviewContainer.classList.add('hidePreview');
        toggleBtnIcon.classList.remove('up');
        toggleBtnIcon.classList.add('down');
    } else {
        codePreviewContainer.classList.remove('hidePreview');  
        toggleBtnIcon.classList.remove('down');      
        toggleBtnIcon.classList.add('up');
    }
    codePreviewShow = !codePreviewShow;
}

function scrollToLine( line ) {
    var selectedLine = codeContainer.querySelector( ".line.number" + line );
    var top = selectedLine.documentOffsetTop() - codeWrapper.offsetHeight / 2;
    codeWrapper.scrollTop = top;
}

function toggleActiveClasses( id ) {
    document.querySelector( ".stacktrace--active" ).classList.remove( "stacktrace--active" );
    document.getElementById( id ).classList.add( "stacktrace--active" );
}

function changeCodePanel( id ) {
    toggleActiveClasses( id );
    var code = document.getElementById( id + "-code" );
    var highlightLine = code.getAttribute( "data-highlight-line" );
    codeContainer.innerHTML = code.innerHTML;
    scrollToLine( highlightLine );
}

function filterScopes(linkEl, filterID ) {
    var links = document.querySelectorAll('div.data-filter a');
    for (var i = 0; i < links.length; i++){
        links[i].classList.remove('active');
    }
    linkEl.classList.add('active');
    var sections = document.querySelectorAll('div.data-table');
    if(filterID != ""){
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.add('hidden');
        }
        document.getElementById(filterID).classList.remove('hidden');
    } else {
        for (var i = 0; i < sections.length; i++){
            sections[i].classList.remove('hidden');
        }
    }
    document.getElementById('request-info-details').scrollTop = 0;
}

var codeWrapper = document.querySelector( ".code-preview" );
var codeContainer = document.getElementById( "code-container" );

Array.from( document.querySelectorAll( ".stacktrace" ) )
    .forEach( function( stackTrace ) {
        stackTrace.addEventListener( "click", function( e ) {
            changeCodePanel( stackTrace.id );
        }, false );
    } );

document.addEventListener( "DOMContentLoaded", function() {
    var initialStackTrace = document.querySelector( ".stacktrace__list .stacktrace" );
    setTimeout(function(){ changeCodePanel( initialStackTrace.id ); }, 500);
} );
