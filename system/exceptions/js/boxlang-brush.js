/**
 * This is the Brush for the BoxLang JVM language.
 * More information about BoxLang can be found at:
 * http://boxlang.io
 *
 * @version
 * 1.0.0
 *
 * @copyright
 * Copyright (C) 2025 BoxLang Development Team
 *
 * @license
 * Apache-2.0
 */
;(function()
{
  // CommonJS
  typeof(require) != 'undefined' ? SyntaxHighlighter = require( 'shCore' ).SyntaxHighlighter : null;

  function Brush()
  {
    // BoxLang Keywords from grammar
    var keywords = 'argumentCollection attributeCollection abstract as assert break case castas catch class component continue default do does extends else final finally for function greater if imp import implements in include instanceof interface is less lock new package param property private public remote required return static switch than thread throw to transaction try var when while';

    // BoxLang Built-in Functions
    var functions = 'Abs Acos aiChat aiChatAsync aiChatRequest aiMessage aiService aiTool ApplicationRestart ApplicationStartTime ApplicationStop Argon2CheckHash ArgonHash ArgonVerify ArrayAppend ArrayAvg ArrayClear ArrayContains ArrayContainsNoCase ArrayDelete ArrayDeleteAt ArrayDeleteNoCase ArrayEach ArrayEvery ArrayFilter ArrayFind ArrayFindAll ArrayFindAllNoCase ArrayFindNoCase ArrayFirst ArrayGetMetadata ArrayIndexExists ArrayInsertAt ArrayIsDefined arrayIsEmpty ArrayLast ArrayLen ArrayMap ArrayMax ArrayMedian ArrayMerge ArrayMid ArrayMin ArrayNew ArrayPop ArrayPrepend ArrayPush ArrayRange ArrayReduce ArrayReduceRight ArrayResize ArrayReverse ArraySet ArrayShift ArraySlice ArraySome ArraySort ArraySplice ArraySum ArraySwap ArrayToList ArrayToStruct ArrayUnshift Ascii Asin Atn Attempt BCryptHash BCryptVerify BinaryDecode BinaryEncode BitAnd BitMaskClear BitMaskRead BitMaskSet BitNot BitOr bitShln bitShrn BitXor BooleanFormat BoxAnnounce BoxAnnounceAsync BoxLangBIFProxy BoxRegisterInterceptionPoints BoxRegisterInterceptor BoxRegisterRequestInterceptor BoxUnregisterInterceptor BoxUnregisterRequestInterceptor Cache CacheFilter CacheNames CacheProviders CacheService CallStackGet CamelCase Canonicalize Ceiling Char CharsetDecode CharsetEncode ClearLocale ClearTimezone CLIClear CLIExit CLIGetArgs CLIRead Compare CompareNoCase Compress ContractPath Cos CreateDate CreateDateTime CreateDynamicProxy CreateGUID CreateObject CreateODBCDate CreateODBCDateTime CreateODBCTime CreateTempDirectory CreateTempFile CreateTime CreateTimeSpan CreateUUID CurrencyFormat DataNavigate DateAdd DateCompare DateConvert DateDiff DateFormat DatePart DateTimeFormat Day DayOfWeek DayOfWeekAsString DayOfWeekShortAsString DayOfYear DaysInMonth DaysInYear DE DebugBoxContexts DecimalFormat DecodeFor DecodeForBase64 DecodeForHTML DecodeForJson DecodeFromURL DecrementValue Decrypt DecryptBinary DirectoryCopy DirectoryCreate DirectoryDelete DirectoryExists DirectoryList DirectoryMove DirectoryRename Dump Duplicate echo EncodeFor encodeForCSS encodeForDN EncodeForHTML encodeForHTMLAttribute encodeForJavaScript encodeForLDAP EncodeForSQL encodeForURL encodeForXML encodeForXMLAttribute encodeForXPath Encrypt EncryptBinary EntityDelete EntityLoad EntityLoadByExample EntityLoadByPK EntityMerge EntityNameArray EntityNameList EntityNew EntityReload EntitySave EntityToQuery esapiDecode esapiEncode Evaluate ExecutorGet ExecutorHas ExecutorList ExecutorNew ExecutorShutdown ExecutorStatus Exp ExpandPath Extract FileAppend FileClose FileCopy FileDelete FileExists FileGetMimeType FileInfo FileIsEOF FileMove FileOpen FileRead FileReadBinary FileReadLine FileSeek FileSetAccessMode FileSetAttribute FileSetLastModified FileSkipBytes FileUpload FileUploadAll FileWrite FileWriteLine Find FindNoCase FindOneOf FirstDayOfMonth Fix Floor FormatBaseN Forward FutureNew GenerateArgon2Hash GenerateBCryptHash GeneratePBKDFKey GenerateSCryptHash GenerateSecretKey GetApplicationMetadata GetBaseTagData GetBaseTagList GetBaseTemplatePath GetBoxContext GetBoxRuntime GetBoxVersionInfo GetCanonicalPath GetClassMetadata GetComponentList GetContextRoot GetCpuUsage GetCurrentTemplatePath GetDirectoryFromPath GetFileFromPath GetFileInfo GetFreeSpace GetFunctionCalledName GetFunctionList GetHardware GetHTTPRequestData GetHTTPTimeString GetIniFile GetJVMFreeMemory GetJVMMaxMemory GetJVMTotalMemory GetLocale GetLocaleDisplayName GetLocaleInfo GetMemoryUsage GetMetaData GetMockServer GetModuleInfo GetModuleList GetNumericDate GetOperatingSystem GetPageContext GetProfileSection GetProfileSections GetProfileString GetReadableImageFormats GetRequestClassLoader GetSafeHTML GetSemver GetSystemFreeMemory GetSystemInfo GetSystemSetting GetSystemTotalMemory GetTempDirectory getTempFile GetTickCount GetTime GetTimezone GetTimezoneInfo GetToken GetTotalSpace GetWriteableImageFormats Hash Hash40 Hmac Hour htmlEditFormat HtmlFooter HtmlHead IIF ImageAddBorder ImageBlur ImageClearRect ImageCopy ImageCrop ImageDrawArc ImageDrawBeveledRect ImageDrawCubicCurve ImageDrawImage ImageDrawLine ImageDrawLines ImageDrawOval ImageDrawPoint ImageDrawQuadraticCurve ImageDrawRect ImageDrawRoundRect ImageDrawText ImageFlip ImageGetBlob ImageGetBufferedImage ImageGetExifMetaData ImageGetExifTag ImageGetHeight ImageGetIPTCMetadata ImageGetIPTCTag ImageGetWidth ImageGrayScale ImageGreyScale ImageInfo ImageNegative ImageNew ImageOverlay ImagePaste ImageRead ImageReadBase64 ImageResize ImageRotate ImageRotateDrawingAxis ImageScaleToFit ImageSetAntiAliasing ImageSetBackgroundColor ImageSetDrawingColor ImageSetDrawingStroke ImageSetDrawingTransparency ImageSharpen ImageShear ImageShearDrawingAxis ImageTranslate ImageTranslateDrawingAxis ImageWrite ImageWriteBase64 IncrementValue InputBaseN Insert Int Invoke IsArray IsBinary IsBoolean IsClosure IsCurrency IsDate IsDateObject IsDebugMode IsDefined IsEmpty IsFileObject IsImage IsImageFile IsInstanceOf IsInThread IsInTransaction IsIPv6 IsJSON IsLeapYear IsLocalHost IsNull IsNumeric IsNumericDate IsObject IsQuery IsSafeHTML IsSimpleValue IsStruct isThreadAlive IsThreadInterrupted IsValid IsWDDX IsWithinTransaction IsXML IsXmlAttribute IsXMLDoc IsXMLElem IsXMLNode IsXMLRoot IsZipFile JavaCast JSONDeserialize JSONPrettify JSONSerialize JSStringFormat KebabCase LCase Left Len ListAppend ListAvg ListChangeDelims ListCompact ListContains ListContainsNoCase ListDeleteAt ListEach ListEvery ListFilter ListFind ListFindNoCase ListFirst ListGetAt ListIndexExists ListInsertAt ListItemTrim ListLast ListLen ListMap ListPrepend ListQualify ListReduce ListReduceRight ListRemoveDuplicates ListRest ListSetAt ListSome ListSort ListToArray ListTrim ListValueCount ListValueCountNoCase LJustify Location Log Log10 LSCurrencyFormat LSIsCurrency LSIsNumeric LSNumberFormat LSParseCurrency LSParseNumber LTrim Max Mid Millisecond Min Minute Month MonthAsString MonthShortAsString Nanosecond Now NullValue NumberFormat ObjectDeserialize ObjectSerialize Offset ORMClearSession ORMCloseAllSessions ORMCloseSession ORMEvictCollection ORMEvictEntity ORMEvictQueries ORMExecuteQuery ORMFlush ORMFlushAll ORMGetHibernateVersion ORMGetSession ORMGetSessionFactory ORMReload PagePoolClear ParagraphFormat ParseCurrency ParseDateTime ParseNumber PascalCase Pi PrecisionEvaluate PreserveSingleQuotes Print Println Quarter QueryAddColumn QueryAddRow QueryAppend QueryClear QueryColumnArray QueryColumnCount QueryColumnData QueryColumnExists QueryColumnList QueryCurrentRow QueryDeleteColumn QueryDeleteRow QueryEach QueryEvery QueryExecute QueryFilter QueryGetCell QueryGetResult QueryInsertAt QueryKeyExists QueryMap QueryNew QueryPrepend QueryRecordCount QueryReduce QueryRegisterFunction QueryReverse QueryRowData QueryRowSwap QuerySetCell QuerySetRow QuerySlice QuerySome QuerySort QueryStringToStruct Rand Randomize RandRange ReEscape ReFind reFindNoCase ReMatch reMatchNoCase RemoveChars RemoveProfileSection RemoveProfileString RepeatString Replace ReplaceList ReplaceListNoCase ReplaceNoCase ReReplace reReplaceNoCase Reverse Right RJustify Round RTrim RunAsync RunThreadInContext SanitizeHTML SchedulerGet SchedulerGetAll SchedulerList SchedulerRestart SchedulerShutdown SchedulerStart SchedulerStats SCryptHash SCryptVerify Second SessionInvalidate SessionRotate SessionStartTime SetEncoding SetLocale SetProfileString SetTimezone Sgn Sin Sleep Slugify SnakeCase SpanExcluding SpanIncluding SQLPrettify Sqr StartMockRequest StringBind StringEach StringEvery StringFilter StringLen StringMap StringReduce StringReduceRight StringSome StringSort StripCR StructAppend StructClear StructCopy StructCount StructDelete StructEach StructEquals StructEvery StructFilter StructFind StructFindKey StructFindValue StructGet StructGetMetadata StructInsert StructIsCaseSensitive structIsEmpty StructIsOrdered StructKeyArray StructKeyExists StructKeyList StructKeyTranslate StructMap StructNew StructReduce StructSome StructSort StructToQueryString StructToSorted StructUpdate StructValueArray SystemCacheClear SystemExecute SystemOutput Tan ThreadInterrupt ThreadJoin ThreadNew ThreadTerminate Throw TimeFormat ToBase64 ToBinary ToModifiable ToNumeric ToScript ToString ToUnmodifiable Trace TransactionCommit TransactionRollback TransactionSetSavepoint TranspileCollectionKeySwap Trim TrueFalseFormat UCase UCFirst URLDecode URLEncodedFormat Val VerifyBCryptHash VerifySCryptHash Week Wrap writeDump WriteLog WriteOutput XMLChildPos XMLElemNew XMLFormat XMLGetNodeType XMLNew XMLParse XMLSearch XMLTransform XMLValidate Year YesNoFormat';

    // BoxLang Components and Special Components
    var components = 'abort application associate boxlangcomponentproxy cache component content cookie dbinfo directory document documentitem documentsection dump examplecomponent execute exit file flush gzip header htmlfooter htmlhead http httpparam include invoke invokeargument location lock log loop mail mailparam mailpart object output param processingdirective procparam procresult query queryparam savecontent setting silent sleep stopwatch storedproc thread throw timer trace transaction wddx xml zip zipparam';

    // Special BoxLang components from grammar
    var specialComponents = 'transaction lock thread abort exit param';

    // Operators and logical constructs
    var operators = 'and or not xor mod eq neq lt le gt ge equal contains instanceof does eqv imp';

    // Boolean literals
    var booleans = 'true false yes no';

    // Null literal
    var nullValue = 'null';

    // Access modifiers and type keywords
    var modifiers = 'public private remote package abstract final static required';

    // Template syntax components (bx: prefixed)
    var templateComponents = 'argument function set return if else elseif try catch finally import while break continue include property rethrow throw switch case defaultcase output query';

	// Variable Scopes
	var variableScopes = 'application arguments attributes caller client cgi form local request server session super url thread this variables';

    this.regexList = [
		// Comments (must be first to avoid conflicts)
      	{ regex: new RegExp('//.*$', 'gm'),                               css: 'comments' },     // single line comments
      	{ regex: new RegExp('/\\*[\\s\\S]*?\\*/', 'gm'),                 css: 'comments' },     // multi-line comments
      	{ regex: new RegExp('<!---[\\s\\S]*?--->', 'gm'),               css: 'comments' },     // BoxLang template comments

		// Template interpolation
		{ regex: new RegExp('#[^#]*#', 'g'),                             css: 'color2' },       // #variable# interpolation

		// Strings (high priority to avoid keyword matches inside strings)
		{ regex: SyntaxHighlighter.regexLib.doubleQuotedString,           css: 'string' },       // double quoted strings
		{ regex: SyntaxHighlighter.regexLib.singleQuotedString,           css: 'string' },       // single quoted strings

		// Built-in Functions
      	{
			regex: new RegExp('(?<!\\.)\\b(' + functions.replace(/\s+/g, '|') + ')\\s*\\(([^)]*)\\)', 'gmi'),
			css: 'functions'
		},

		// BoxLang template components (bx:)
		{ regex: new RegExp('</?bx:(' + components.replace(/\s+/g, '|') + ')\\b', 'gmi'), css: 'keyword' },  // bx: template tags
		{ regex: new RegExp('\\bbx:(' + specialComponents.replace(/\s+/g, '|') + ')\\b', 'gmi'),  css: 'keyword' }, // bx: in code

		// Keywords (highest priority for language constructs)
      	{ regex: new RegExp('\\b(' + keywords.replace(/\s+/g, '|') + ')\\b', 'gmi'),          css: 'keyword' },      // language keywords

		// Modifiers
       { regex: new RegExp('\\b(' + modifiers.replace(/\s+/g, '|') + ')\\b', 'gmi'),         css: 'color1' },       // access modifiers

		// BoxLang Variable Scopes
		{ regex: new RegExp('\\b(' + variableScopes.replace(/\s+/g, '|') + ')\\b', 'gmi'), css: 'color2' },

		// Numbers (after keywords to avoid conflicts)
		{ regex: new RegExp('\\b\\d+\\.\\d+\\b', 'g'),                   css: 'value' },        // float literals
		{ regex: new RegExp('\\b\\d+\\b', 'g'),                          css: 'value' },        // integer literals

		// Operators
		{ regex: new RegExp('\\b(' + operators.replace(/\s+/g, '|') + ')\\b', 'gmi'),         css: 'script' },       // operators

		// Boolean values
		{ regex: new RegExp('\\b(' + booleans.replace(/\s+/g, '|') + ')\\b', 'gmi'),          css: 'color3' },       // boolean literals

		// Null
		{ regex: new RegExp('\\b(' + nullValue + ')\\b', 'gmi'),         css: 'constants' },       // null literal

		// Annotations
		{ regex: new RegExp('@\\w+', 'g'),                               css: 'constants' },       // annotations like @foo

		// Operators (symbols)
		{ regex: new RegExp('(\\+\\+|--|\\+=|-=|\\*=|/=|%=|&=)', 'g'),  css: 'color1' },      // compound assignment
		{ regex: new RegExp('(==|!=|<=|>=|<>|===|!==)', 'g'),           css: 'color1' },      // comparison operators
		{ regex: new RegExp('(\\|\\||&&|\\?:|\\?\\.|\\?\\.)', 'g'),     css: 'color1' },      // logical operators
		{ regex: new RegExp('(\\||&|\\^|~|<<|>>|>>>)', 'g'),            css: 'color1' }       // bitwise operators
    ];
  }

  Brush.prototype = new SyntaxHighlighter.Highlighter();
  Brush.aliases = [ 'boxlang', 'bx' ];

  SyntaxHighlighter.brushes.BoxLang = Brush;

  // CommonJS
  typeof(exports) != 'undefined' ? exports.Brush = Brush : null;
})();