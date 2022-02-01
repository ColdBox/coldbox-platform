/**
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * ---
 * This utility object takes care of file log rotation
 **/
component accessors="true" {

	/**
	 * Constructor
	 */
	function init(){
		return this;
	}

	/**
	 * Checks the log file size. If greater than framework's settings, then zip and rotate.
	 *
	 * @appender                The appender to rotate with
	 * @appender.docbox_generic coldbox.system.logging.AbstractAppender
	 */
	FileRotator function checkRotation( required appender ){
		var oAppender   = arguments.appender;
		var fileName    = oAppender.getProperty( "fileName" );
		var logFullPath = oAppender.getLogFullPath();

		//  Verify FileSize
		if ( getFileSize( logFullPath ) > ( oAppender.getProperty( "fileMaxSize" ) * 1024 ) ) {
			//  How Many Log Files Do we Have
			var qArchivedLogs = directoryList(
				getDirectoryFromPath( logFullPath ),
				false,
				"query",
				"#filename#*.zip",
				"dateLastModified"
			);

			lock
				name          ="#oAppender.getName()#-logrotation"
				type          ="exclusive"
				timeout       ="#oAppender.getlockTimeout()#"
				throwontimeout="true" {
				//  Should I remove log Files
				if ( qArchivedLogs.recordcount >= oAppender.getProperty( "fileMaxArchives" ) ) {
					var archiveToDelete = qArchivedLogs.directory[ 1 ] & "/" & qArchivedLogs.name[ 1 ];
					//  Remove the oldest one
					fileDelete( archiveToDelete );
				}

				//  Set the name of the archive
				var zipFileName = getDirectoryFromPath( logFullPath ) & fileName & "." & dateFormat(
					now(),
					"yyyymmdd"
				) & "." & timeFormat( now(), "HHmmss" ) & ".zip";

				//  Zip it
				cfzip(
					action    = "zip",
					file      = "#zipFileName#",
					overwrite = "true",
					storepath = "false",
					recurse   = "false",
					source    = "#logFullPath#"
				);
			}
			// end lock

			//  Clean & reinit Log File
			oAppender.removeLogFile();

			//  Reinit The log File
			oAppender.initLoglocation();
		}

		return this;
	}

	/**
	 * Get the filesize of a file.
	 *
	 * @fileName   The target file
	 * @sizeFormat Available formats: [bytes][kbytes][mbytes][gbytes]
	 */
	numeric function getFileSize( required fileName, sizeFormat = "bytes" ){
		// Get size in bytes
		var size = getFileInfo( arguments.fileName ).size;

		if ( arguments.sizeFormat eq "bytes" ) return size;
		if ( arguments.sizeFormat eq "kbytes" ) return ( size / 1024 );
		if ( arguments.sizeFormat eq "mbytes" ) return ( size / 1048576 );
		if ( arguments.sizeFormat eq "gbytes" ) return ( size / 1073741824 );
	}

}
