/**
 * This delegate is useful to interact with the coldbox.system.async.time.DateTimeHelper as your date time helper
 */
component singleton {

	property
		name  ="dateTimeHelper"
		inject="coldbox.system.async.time.DateTimeHelper"
		delegate;

}
