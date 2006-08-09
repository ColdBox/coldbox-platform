<cfcomponent name="ehOBE" extends="ehutil">

<!--------------------------------------------- CONSTRUCTOR --------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" hint="Constructor" output="false">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

<!--------------------------------------------- PUBLIC --------------------------------------------->
	
	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfset var appreinit = false>
		<cfset var objDriver = "">
		<!--- Init the OBE if needed --->
		<cflock scope="application" type="readonly" timeout="120">
			<cfif not structKeyExists(application,"obeStruct") or not application.obeStruct.inited>
				<cfset appreinit = true>
			</cfif>
		</cflock>		
		<cfif appreinit>
			<cflock scope="application" type="exclusive" timeout="120">
				<cfif not structKeyExists(application,"obeStruct") or 
			 		  not application.obeStruct.inited>
					<cftry>
						<cfset objDriver = createObject("component","obeapi.driver").init(getPlugin("webservices").getWSobj("obe"))>
						<cfset application.obestruct = objDriver.setupOBE()>
						<cfcatch type="any">
							<cfset getPlugin("logger").logError("Initializing OBE",cfcatch)>
							<cfset setValue("event","ehGui.dspError")>
							<cfset getPlugin("messagebox").setMessage("error",getsetting("Initialization_Error")) >
				 			<cfreturn>
						</cfcatch>
					</cftry>						
				</cfif>
			</cflock>
		</cfif>		
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="onRequestStart" access="public" returntype="void" >
		<cfscript>
		//Set the Variables.
		try{
			setValue("ObeVariables", createObject("component","obeapi.driver").getObeSetup());
		}
		catch( Any e ){
			getPlugin("logger").logError("Getting OBE Variables Failed.",e, variables);
			getPlugin("messagebox").setMessage("error",getSetting("GettingOBEVariables_Error"));
			overrideEvent("ehGui.dspError");
			return;
		}
	
		//Maintenance Check Override
		if ( getValue("override","") eq "luis" and not isDefined("client.override") ){
			client.override = true;
		}
		else if (getValue("override","") eq "done"){
			structDelete(client, "override");
		}
		
		//Maintenance Mode Check 
		if ( getValue("ObeVariables").maintenance_mode is "YES" and not isDefined("client.override") ){
			overrideEvent("ehGui.dspMaintenance");
			return;
		}
		//Reinit Check 
		if ( getvalue("reinituser", false) ){
			client.obedataWDDX = "";
		}			
		
		//VERIFY that the user's obeData storage is set, else init User Storage --->
		if ( not isDefined("client.obedataWDDX") or not isWDDX(client.obedataWDDX) or (valueExists("TASLoggedIn") and getvalue("TASLoggedIn",false))){
			//Init The user storage.
			initUser();	
		}//end if client.obedataWDDX Undefined
				
		//Unwddx storage
		fncGetObeData();
		
		//Set Display Variables,Tag Paths, and Branding
		fncSetDisplayEnvironment();	
		
		//Try to Log in the user
		if ( valueExists("TASLoggedIN") and getvalue("TASLoggedIn",false) ){
			fncLoginTA();
		}
		
		//Check TA Timeout
		if (not isDefined("session.TASAuthorized") or not session.TASAuthorized){
			doLogout();
		}
		
		//Refresh WS Flag Call
		if ( getValue("refreshWS",false) ){
			getPlugin("webservices").refreshWS(getPlugin("webservices").getWS("obe"));
			getPlugin("webservices").refreshWS(getPlugin("webservices").getWS("FareSearchV2"));
			getPlugin("webservices").refreshWS(getPlugin("webservices").getWS("PNRV2"));
			getPlugin("webservices").refreshWS(getPlugin("webservices").getWS("TravelAgents"));
			getPlugin("messagebox").setMessage("info", "Webservices Refreshed");
		}
		
		//client check.
		if ( not getValue("obedata.ta_info.Authorized",false) ){
			doLogout();
		}		
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doLogout" access="public" returntype="void" output="false">
		<cfscript>
		structdelete(session,"TASAuthorized");
		DeleteClientVariable("obedataWDDX");
		dspLogout();
		</cfscript>		
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doNewBooking" access="public" returntype="void" output="false">
		<cfscript>
		var obedata = getvalue("obedata");
		reinitUserDataOnly(obedata);
		//Save the WDDX Packet
		fncSaveObeData(obedata);
		dspHome();
		</cfscript>		
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspLogout" access="public" returntype="void" output="false">
		<cfscript>
		setView("tags/logout",true);
		</cfscript>		
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspHome" access="public" returntype="void" output="false">
		<cfscript>		
		var obedata = getValue("obedata");
		//Get OBEWS Reference
		var obeWS = getPlugin("webservices").getWSObj("obe");	
		//Get Driver Reference
		var obeDriver = CreateObject("component","obeapi.driver").init();

		//Booking Number Checker
		fncBookingNumberChecker();
			
		//Get All Resorts
		setValue("rtnResorts", obeDriver.getQuery("qResorts"));		
		
		//If country is already set, then get Departure Gateways for Country
		if ( obedata.room_data.departure_country neq "" ){
			//Get Departure Gateways For Country
			setValue("rtnDepStates",obeDriver.getDepartureGateways(obedata.room_data.departure_country));
		}
		
		//Get US CANADA GATEWAYS
		setValue("rtnUS_CANADAGateways", obeDriver.getQuery("qUS_CANADAGateways"));
		//Get US, CANADA, PUERTO RICO States
		setValue("rtnUSAStates", obeDriver.getDepartureGateways("USA") );
		setValue("rtnPRStates", obeDriver.getDepartureGateways("PUERTO RICO"));
		setValue("rtnCanadaStates", obeDriver.getDepartureGateways("CANADA"));
		
		//Get Gateways when Initialized
		if ( obedata.room_data.departure_state neq "" )
			setValue("rtnDepGateways",obeDriver.getDepartureGateways("",obedata.room_data.departure_state));
		
		//Get ALl Resort Gateways
		setValue("rtnResortAllGateways", obeDriver.getQuery("qResortGateways") );
		
		//Get Resort Gateways if resort choosen already.
		if ( obedata.room_data.resort neq "" ){
			setValue("rtnResortGateways", obeDriver.getResortGateways(obedata.room_data.resort) );
		}
		
		//Set the Current Menu Step
		if ( obedata.menu_data.step1 ){
			obedata.menu_data.currentStep = "STEP1";
			//save obedata
			fncSaveObedata(obedata);
		}
		//Set the Home View
		setView("vwHome");		
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspPolling" access="public" returntype="void" output="false">
		<cfscript>		
		//Thread ID Check
		if ( getValue("obedata.ThreadID",0) eq 0)
			setNextEvent("ehOBE.dspHome");
		//Set the Polling View
		setView("vwPollingwait");		
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doGetAvailability" access="public" returntype="void" output="false">
		<cfscript>
		var inetHost = getPlugin("fileUtilities").getInetHost();
		var obedata = getValue("obedata");
		var obeWS = getPlugin("webservices").getWSObj("obe");
		var tmp_checkindate = "";
		var tmp_departuredate = "";
		var rtnResort = "";
		var ssgFlag = 0;
		var LandAvailability = "";
		var airStartTimer = 0;
		var AirStartTime = 0;					
		var rtnAirAVailability = "";
		var i = 0;
		try{
			
			//Form Checks
			if ( getValue("resortcode",0) eq 0 or getValue("originGateway","") eq "" or
				 getValue("checkin_month",0) eq 0 or getValue("checkin_day",0) eq 0 or 
				 getValue("checkin_year",0) eq 0 or  getValue("adults",0) eq 0 or
				 getValue("departure_month",0) eq 0 or getValue("departure_day",0) eq 0 or 
				 getValue("departure_year",0) eq 0 ){
				getPlugin("Messagebox").setMessage("error","#getSetting("EmptyFormFields_error")#");
				setNextEvent("ehOBE.dspHome");	 
			}
			//Date Compilation for Arrival		
			tmp_checkindate = "#getValue("checkin_month")#/#getValue("checkin_day")#/#getValue("checkin_year")#";
			if ( (isDate(tmp_checkindate) is "NO") or (tmp_checkindate lt dateformat(dateAdd("d",+5,now()), "MM/DD/YYYY"))){
				//set Integrity Errors
				getPlugin("Messagebox").setMessage("error","The check-in date: #tmp_checkindate# entered is not a valid date. Please review your date and try again.");
				setNextEvent("ehOBE.dspHome");
			}
			//Date Compilation for Departure.
			tmp_departuredate = "#getValue("departure_month")#/#getValue("departure_day")#/#getValue("departure_year")#";
			if ( isDate(tmp_departuredate) is "NO" or tmp_departuredate lte tmp_checkindate ){
				//set Integrity Errors
				getPlugin("Messagebox").setMessage("error","The departure date: #tmp_departuredate# entered is not a valid date. Please review your date and try again.");
				setNextEvent("ehOBE.dspHome");
			}
			//Save Demographics Information
			obedata.room_data.check_in_date = tmp_checkindate;
			obedata.room_data.Number_Of_Nights = dateDiff("d",tmp_checkindate, tmp_departuredate);
			obedata.room_data.departure_date = dateFormat(tmp_departuredate, "MM/DD/YYYY");
			obedata.room_data.resort = left(ucase(trim(getValue("resortcode"))),3);
			obedata.room_data.adults = getValue("adults",2);
			obedata.room_data.originGateway = ucase(trim(getToken(getValue("originGateway"),1, ",")));
			//Init Land Children and Infants to 0
			obedata.room_data.Landchildren = 0;
			obedata.room_data.Infants = 0;
			obedata.room_data.children = getValue("children",0);
			
			//Now get the age for each child and set for land 
			if (obedata.room_data.children GT 0){
				//Add child to ObeData
				
				for (i = 1; i lte obedata.room_data.children; i=i+1){
					setValue("obedata.room_data.child_#i#", getvalue("child_#i#"));
					if (getvalue("child_#i#") GTE 2){
						obedata.room_data.Landchildren = IncrementValue(obedata.room_data.Landchildren);
					}
					else{
						obedata.room_data.Infants = IncrementValue(obedata.room_data.Infants);
					}
				}
			}
			
			//Save Resort Information
			rtnResort = obeWS.fncGetResort(obedata.room_data.resort);
			obedata.room_data.resort_country_code = rtnResort.results.qResort.country;
			obedata.room_data.resort_name = rtnResort.results.qResort.name;
			obedata.room_data.resort_type = rtnResort.results.qResort.resort_type;
			obedata.room_data.resort_code = rtnResort.results.qWebResort.resort_code;
			obedata.room_data.resort_description = rtnResort.results.qWebResort.web_description;
			
			//Save Brand Information
			if ( obedata.room_data.resort_type eq "S" )
				obedata.brand = "sandals";
			else
				obedata.brand = "beaches";
			//RP
			if ( obedata.room_data.resort eq "BRP" )
				obedata.brand = "royalplantation";
			//Save Departure Information
			obedata.room_data.departure_gateway = getToken(ucase(getValue("originGateway")),1, ",");
			obedata.room_data.departure_city =  getToken(getValue("originGateway"),1,",");
			
			//Save Air Information
			if ( getValue("air_cb","NO") is "YES" ){
				//Start Air Checks
				if ( getValue("resort_gateway") is "" ){
					getPlugin("Messagebox").setMessage("error","The Resort Gateway is blank, please check your selections.");
					setNextEvent("ehOBE.dspHome");
				}
				if ( getValue("InfantsInLap",0) gt getValue("adults") ){
					getPlugin("Messagebox").setMessage("error","The number of Infants to Carry in Lap exceeds the adult limit. 1 infant per Adult.  Please check your selections.");
					setNextEvent("ehOBE.dspHome");
				}
				//SaveParams
				obedata.air_data.air_included = true;
				obedata.air_data.arrival_gateway = getToken(getValue("resort_gateway"),1,",");
				obedata.air_data.arrival_city = getToken(getValue("resort_gateway"),2,",");
				obedata.air_data.search_by = getValue("air_searchBy","Y");
				obedata.air_data.arrival_date = obedata.room_data.check_in_date;
				obedata.air_data.adultPassengers = getValue("adults",2);
				
				//Check for Blank Data
				if ( not isNumeric(obedata.room_data.children) )
					obedata.room_data.children = 0;
				
				//set children and infants in lap to 0
				obedata.air_data.childrenPassengers = 0;
				obedata.air_data.infantsInLap = 0;
				
				//Get Passengers
				for (i = 1; i lte obedata.room_data.children; i=i+1){
					if (getvalue("child_#i#") GTE 12){
						obedata.air_data.adultPassengers = IncrementValue(obedata.air_data.adultPassengers);
					}
					else if (getvalue("child_#i#") GTE 2){
						obedata.air_data.childrenPassengers = IncrementValue(obedata.air_data.childrenPassengers);
					}
					else{
						if (getValue("Infant_#i#") EQ "YES"){
							obedata.air_data.infantsInLap = IncrementValue(obedata.air_data.infantsInLap);
						}
						else{
							obedata.air_data.childrenPassengers = IncrementValue(obedata.air_data.childrenPassengers);
						}
						//add to obedata
						setValue("obedata.room_data.infant_#i#", getValue("Infant_#i#"));
					}
				}
				
				//check for empty values
				if ( not isNumeric(obedata.air_data.childrenPassengers) )
					obedata.room_data.childrenPassengers = 0;
				
				if ( not isNumeric(obedata.air_data.infantsInLap) )
					obedata.air_data.infantsInLap = 0;
				// check if infants more than adults
				if ( obedata.air_data.infantsInLap gt getValue("adults") ){
					getPlugin("Messagebox").setMessage("error","The number of Infants to Carry in Lap exceeds the adult limit. 1 infant per Adult.  Please check your selections.");
					setNextEvent("ehOBE.dspHome");
				}
				
				// set return date 
				obedata.air_data.return_date = DateAdd('D', obedata.room_data.Number_of_Nights,obedata.room_data.check_in_date);
				// Set Sabre GDS to use as Sabre  if we have infants because as of 6/28/04 we still have problems booking infants with Amadeus 
				obedata.air_data.GDS = getValue("OBEVariables").GDS;
				//get airlines to exclude if GDS is Amadeus and Adapter type is Value Pricer
				if (CompareNoCase(obedata.air_data.GDS, "Amadeus") EQ 0 AND CompareNoCase(getValue("ObeVariables").GDS_Adapter_Type, "VALUEPRICER") EQ 0)
					obedata.Air_data.Carriers = obeWS.fncGetAirlinesToExclude(obedata.room_data.departure_gateway, obedata.air_data.arrival_gateway).Results;
				else
					obedata.Air_data.Carriers = "";
			}// End Save Air Information
			else{
				//Air NOT Requested, Init Air Data.
				obedata.air_data = fncReinitAirStruct();
			}//Air not request.
			
			//Get the Availability ID
			obedata.AvailabilityID = client.CFID & client.CFToken & timeformat(now(),"hhmmssl");
			
			/******************************************/
			//POLLING CHECK
			/******************************************/
			if ( getValue("ObeVariables").Polling_Active eq "YES" ){
				//POLLING CODE
				fncDoPollingRequest(obedata);
				//Polling Request Submitted, go to next screen
				setNextEvent("ehOBE.dspPolling");
			}
			
			//SSG Flag Determination
			if ( obedata.ssg_data.member_id is 0 )
				ssgFlag = -1; //NOT SSG MEMBER
			
			/******************************************/
			//Call the Land Availability Web Service
			/******************************************/
			LandAvailability = obeWS.fncAvailabilityStruct(obedata.AvailabilityID,
														 obedata.room_data.resort,
														 obedata.room_data.departure_gateway,
														 obedata.room_data.Number_Of_Nights,
														 obedata.room_data.check_in_date,
														 obedata.room_data.adults,
														 obedata.room_data.Landchildren,
														 obedata.room_data.rooms,
														 ssgFlag);
			if ( LandAvailability.error ){
				getPlugin("messagebox").setMessage("error","#getSetting('LandAvailability_Error')# <br><br><strong>Diagnostic Data:</strong> <br>#LandAvailability.errorMessage#");
				setNextEvent("ehOBE.dspHome");
			} //end of if statement Error Checks
			else
				obedata.qLandAvailability = LandAvailability.results;
															 	
			/******************************************/
			//Air Availability
			/******************************************/
			if ( getValue("air_cb","NO") is "YES" ){
				try{
					//Timer
					airStartTimer = getTickCount();
					// Set Vars for Air log
					AirStartTime = NOW();					
					//Call Get Air
					rtnAirAVailability = getPlugin("webservices").getWSObj("FareSearchV2").WebAdvancedFareSearchRQ(obedata.AvailabilityID, 
																						obedata.room_data.departure_gateway, 
																						obedata.air_data.arrival_date, 
																						obedata.air_data.arrival_gateway,
																						obedata.air_data.return_date, 
																						"ARRIVAL", 
																						obedata.air_data.search_by, 
																						obedata.air_data.adultPassengers, 
																						obedata.air_data.childrenPassengers, 
																						obedata.air_data.infantsInLap, 
																						obedata.Air_data.Carriers,
																						obedata.air_data.IncludeExcludeAirLines,
																						"", "", 
																						"NEGO", 
																						obedata.air_data.GDS,
																						"STANDALONE",
																						getValue("ObeVariables").GDS_Adapter_Type);
					// Check for errors					
					if (rtnAirAVailability.Error and rtnAirAVailability.results.recordcount is 0){
						//set The warning label
						obedata.air_data.air_warning = 1;
						//Air FAILED Requested, Reinit Air_data
						obedata.air_data = fncReinitAirStruct();
						//Test For what Type of Error
						if (FindNoCase("No Flight", rtnAirAVailability.ErrorMessage) OR 
							FindNoCase("No ITINERARY", rtnAirAVailability.ErrorMessage)){
							getPlugin("Messagebox").setMessage("warning","#getSetting("NoFlights_error")#");
						}
						else	{
							getPlugin("Messagebox").setMessage("error","#getSetting("AirAvailability_error")#<br>#rtnAirAVailability.Error#");
						}
					}//end if Errors in Air availability struct	
					else{
						obedata.air_data.air_warning = 0;
						obedata.qAirAvailability = rtnAirAVailability.results;
					}
					//Check to log Air Request Timer
					if (getValue("ObeVariables").LOG_AIR_REQUEST IS "YES"){
						// Log this call
						obeWS.fncLogAirTime(AirStartTime, NOW(), obedata.air_data.arrival_date, 
											obedata.room_data.departure_gateway, 
											obedata.air_data.return_date , obedata.air_data.arrival_gateway, 
											obedata.air_data.GDS, "AVAILABILITY");
					}//end log air request.		
					try{
						//Time Taken Reports
						if (getValue("ObeVariables").Availability_time_reports is "YES"){
							//Log Time --->
							airTotalTimer = getTickCount() - airStartTimer;
							//Log the Timetaken
							obeWS.fncLogObeTimeTaken(airTotalTimer,obedata.air_data.air_included,inetHost,"AIR_AVAILABILITY");
						}
					}//end try timetaken reports 
					catch(Any e){
						getPlugin("logger").logError("TimeTaken Reports: AIR",e);
					}	
				}//end try Air Availability
				catch(Any e){
					//set The warning label
					obedata.air_data.air_warning = 1;
					//Air FAILED Requested, Reinit Air_data
					obedata.air_data = fncReinitAirStruct();
					getPlugin("Messagebox").setMessage("error","#getSetting("AirAvailability_error")#<br><br>#e.detail# #e.message#");
					getPlugin("logger").logError("Getting Air Availability. #e.detail# #e.message#",e);
				}	
			} //end if air_cb is "YES"			
			
			/******************************************
			Clean Room Data information. For New Availability.
			/******************************************/
			fncPrepareNewAvailability(obedata);
						
			/******************************************/
			//Call Tracking Routines
			/******************************************/
			fncAvailabilityTrackingRoutines(obedata);		
			
			/******************************************
			Insurance Module
			/******************************************/
			fncGetInsurance(obedata);
			
			//Save Step Information
			obedata.menu_data.step2 = true;				
			//WDDX & Save the Structures
			fncSaveObeData(obedata);
							
			//Set The NExt Event.
			setNextEvent("ehOBE.dspAvailability","requote=#getvalue("requoteflag",false)#");
		}//end Try
		catch( Any e ){
			getPlugin("logger").logError("Getting Availability #e.message# #e.detail#",e, e.stackTrace);
			getPlugin("messagebox").setMessage("error","#getSetting("LandAvailability_Error")#:<br><br>#e.Message#<br>#e.Detail#");
			setNextEvent("ehOBE.dspHome");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspAvailability" access="public" returntype="void" output="false">
		<cfscript>
		//INit local variables 
		var obedata = getValue("obedata");
		var obeWS = getPlugin("webservices").getWSObj("obe");
		//Get Driver Reference
		var obeDriver = CreateObject("component","obeapi.driver").init();
		//Air Initialization Variables
		var UserFaresIDS = "";
		var FaresToDisplay = "";
		var LegsInFlights = ArrayNew(1);
		var OutboundInFlights = ArrayNew(1);
		var AirlinesFound = StructNew();
		var AirJamamicaFound = false;
		var i = 0;
		
		//Check the availability array
		if ( not isArray(obedata.qLandAvailability) ){
			getPlugin("messagebox").setMessage("error","#getSetting("CorruptLandAvailability_error")#");
			setNextEvent("ehOBE.dspHome");
		}
		//Land Query Verification
		try{
			//Booking Number Checker
			fncBookingNumberChecker();
			//Step Checker 
			if ( not getValue("obedata.menu_data.step2") )
				setNextEvent("ehOBE.dspHome");	
			else
				obedata.menu_data.currentStep = "STEP2";		
			
			//Air Display Setup
			if ( obedata.air_data.air_included is "YES" ){
				//Air Query Verification
				if ( not isQuery(obedata.qAirAvailability) or obedata.qAirAvailability.recordcount eq 0 ){
					getPlugin("messagebox").setMessage("error","#getSetting("CorruptAirAvailability_error")#");
					setNextEvent("ehOBE.dspHome");
				}
				
				//Get fares that are on Sale and fares to be excluded
				FaresOnSaleStruct = obeWS.fncFaresOnSale(obedata.qAirAvailability);
				
				//Loop Through Air Availability Query to get Legs and Outbound Flights
				for (i=1; i lte obedata.qAirAvailability.recordcount; i=i+1){
					if ( not listFind(UserFaresIDS,obedata.qAirAvailability.Flight_Group_ID[i])) {
						UserFaresIDS = ListAppend(UserFaresIDS, obedata.qAirAvailability.Flight_Group_ID[i]);
						//Init number of legs and number of outbound segments in each Flight group 
						LegsInFlights[obedata.qAirAvailability.Flight_Group_ID[i]] = 0;
						OutboundInFlights[obedata.qAirAvailability.Flight_Group_ID[i]] = 0;
					}	
					if ( Not StructKeyExists(AirlinesFound, obedata.qAirAvailability.AIRLINE_CODE[i]) ){
						if (obedata.qAirAvailability.AIRLINE_CODE[i] IS "JM" )
							AirJamamicaFound = true;
						AirlinesFound["#obedata.qAirAvailability.AIRLINE_CODE[i]#"] = obedata.qAirAvailability.AIRLINE_NAME[i];
					}
					//add to numbr of legs in flight
					LegsInFlights[obedata.qAirAvailability.Flight_Group_ID[i]] = IncrementValue(LegsInFlights[obedata.qAirAvailability.Flight_Group_ID[i]]);
					// If this an outbound segment, then increment number
					if (obedata.qAirAvailability.INBOUND_OUTBOUND[i] IS "O" )
						OutboundInFlights[obedata.qAirAvailability.Flight_Group_ID[i]] = IncrementValue(OutboundInFlights[obedata.qAirAvailability.Flight_Group_ID[i]]);
					// check if we have to display flight for certain airlines	
					if ( getValue("AirLineToSort",0) eq 0 )
						FaresToDisplay = UserFaresIDS;
					else
						if (obedata.qAirAvailability.AIRLINE_CODE[i] IS getValue("AirLineToSort") )
							if (NOT ListFind(FaresToDisplay, obedata.qAirAvailability.Flight_Group_ID[i]) )
								FaresToDisplay = ListAppend(FaresToDisplay, obedata.qAirAvailability.Flight_Group_ID[i]);
				}//end For Loop setup of fare id, legs, outbound.
				
				//Save variables
				setValue("FaresToDisplay", FaresToDisplay);
				setValue("LegsInFlights", LegsInFlights);
				setValue("OutboundInFlights", OutboundInFlights);
				setValue("AirlinesFound", AirlinesFound);
				setValue("AirJamamicaFound", AirJamamicaFound);
				setValue("FaresOnSale", FaresOnSaleStruct.Results);
				setValue("FaresToBeRemoved", FaresOnSaleStruct.FaresToRemoveIDs);
			}//end air setup
			
			//***********************************************
			// Requote Code
			//************************************************
			//Get Resorts
			setValue("rtnResorts", obeDriver.getQuery("qResorts"));
			//If country is already set, then get Departure Gateways for Country
			if ( obedata.room_data.departure_country neq "" ){
				//Get Departure Gateways For Country
				setValue("rtnDepStates",obeDriver.getDepartureGateways(obedata.room_data.departure_country));
			}
			//Get US, CANADA, PUERTO RICO States
			setValue("rtnUSAStates", obeDriver.getDepartureGateways("USA") );
			setValue("rtnPRStates", obeDriver.getDepartureGateways("PUERTO RICO"));
			setValue("rtnCanadaStates", obeDriver.getDepartureGateways("CANADA"));
			//Get Gateways when Initialized
			if ( obedata.room_data.departure_state neq "" )
				setValue("rtnDepGateways",obeDriver.getDepartureGateways("",obedata.room_data.departure_state));
			//Get ALl Resort Gateways
			setValue("rtnResortAllGateways", obeDriver.getQuery("qResortGateways"));
			//Get US CANADA GATEWAYS
			setValue("rtnUS_CANADAGateways", obeDriver.getQuery("qUS_CANADAGateways"));
			//Get Resort Gateways if resort choosen already.
			if ( obedata.room_data.resort neq "" ){
				setValue("rtnResortGateways", obeDriver.getResortGateways(obedata.room_data.resort) );
			}
			//***********************************************
			// END Requote Code
			//************************************************
	
			//WDDX & Save the Structures
			fncSaveObeData(obedata);
			//Set The View
			setView("vwResults");
		}
		catch(Exception e){
			getPlugin("logger").logError("Error in dspAvailability.", e);
			getPlugin("messagebox").setMessage("error","#getSetting("PreparingAvailability_error")#");
			setNextEvent("ehOBE.dspHome");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
		
	<!--- ************************************************************* --->
	<cffunction name="doSaveAvailability" access="public" returntype="void" output="false">
		<cfscript>
		//Get Obe data Structures
		var obedata = getValue("obedata");
		var RoomCat = "";
		if ( not structkeyExists(obedata, "AvailabilityID") ){
			obedata.availabilityID = 0;
		}
		//Check if the ID's are the same, else get the latest availability.		
		if ( CompareNoCase(getvalue("currentAvailabilityID",0),obedata.AvailabilityID) neq 0 ){
			getPlugin("Messagebox").setMessage("warning","You submitted an old availability. The following is your latest request.");
			setNextEvent("ehOBE.dspAvailability");
			abort();
		}
		/******************************************
		Save Room Information
		/******************************************/
		//Check if RB was sent in or not
		if ( getvalue("rb_room_category",0) eq 0 ){
			getPlugin("Messagebox").setMessage("error","The room category was not passed in. Please try again.");
			setNextEvent("ehOBE.dspHome");
		}
		obedata.room_data.room_category = getValue("rb_room_category");
		RoomCat = obedata.room_data.room_category;
		//Get Other Room Data.
		obedata.room_data.savings = evaluate("getValue('rc_#RoomCat#_savings')");
		obedata.room_data.room_description = evaluate("getValue('rc_#RoomCat#_description')");
		obedata.room_data.room_webDescription = evaluate("getValue('rc_#RoomCat#_webDescription')");
		/******************************************
		Totals Save
		/******************************************/
		obedata.room_data.room_total = evaluate("getValue('rc_#RoomCat#_total')");
		obedata.room_data.room_total_base = evaluate("getValue('rc_#RoomCat#_totalBase')");
		obedata.room_data.total_display = obedata.room_data.room_total;		
		
		/******************************************
		Totals & DEFAULTS Numeric Check
		/******************************************/
		if ( evaluate("getValue('rc_#RoomCat#_status')") neq "AVAILABLE" ){
			getPlugin("Messagebox").setMessage("error","The room totals saved were not numeric, please get availability again.");
			setNextEvent("ehOBE.dspHome");
		}				
		/******************************************
		Royal Plantation Plan Saving.
		/******************************************/
		if( obedata.brand eq "royalplantation" ){
			if ( getValue("rp_sec",0) eq 0 ){
				getPlugin("Messagebox").setMessage("error","Invalid form submission detected. Please try again.");
				setNextEvent("ehOBE.dspHome");
			}
			obedata.room_data.rpPlan = getValue("rp_sec");
		}
		/******************************************
		Air Saves
		/******************************************/
		if ( obedata.air_data.air_included is true ){
			if ( getValue("FareSelected",0) eq 0 ){
				getPlugin("Messagebox").setMessage("error","There were no flights detected, please get availability again.");
				setNextEvent("ehOBE.dspHome");
			}
			//Verify Air Saves
			if ( getValue("air_total","") eq "" or not isNumeric(getValue("air_total")) ){
				getPlugin("logger").logError("Air totals not numeric",structnew(),obedata);
				getPlugin("Messagebox").setMessage("error","The air totals saved were not numeric, please get availability again.");
				setNextEvent("ehOBE.dspHome");
			}
			obedata.air_data.FlightGroupID = getValue("FareSelected");
			obedata.air_data.FareSelectedType = getvalue("FareSelectedType_#obedata.air_data.FlightGroupID#"); 
			obedata.air_data.FareSelectedHoldOption = getValue("FareSelectedHoldOption_#obedata.air_data.FlightGroupID#");
			obedata.air_data.air_total = getValue("air_total");
			obedata.room_data.total_display = obedata.room_data.room_total + obedata.air_data.air_total;
		}
		else{
			//obedata.air_data.FaregroupID = 0;
			obedata.air_data.FlightGroupID = 0;
			obedata.air_data.air_total = 0;
			obedata.air_data.air_deposit = 0;
			obedata.room_data.total_display = obedata.room_data.room_total;
		}
		
		/******************************************
		Save SSG Data if necessary
		******************************************/
		obedata.ssg_data.points_accrued = evaluate("getValue('rc_#RoomCat#_pointsAccrued')");			
		obedata.ssg_data.total_before_discount = obedata.room_data.total_display;
		obedata.ssg_data.balance_before_discount = obedata.room_data.balance;
		obedata.ssg_data.signet_apply = evaluate("getValue('rc_#RoomCat#_Signet_Apply')");
		obedata.ssg_data.signet_gain =  evaluate("getValue('rc_#RoomCat#_Signet_Gain')");
		
		/******************************************
		Wedding Free Routines
		/******************************************/
		//check if number of nights >= 5 to approve free weddings --->
		if (obedata.room_data.number_of_nights gte 5)
			obedata.room_data.wedding_free = true;
		else
			obedata.room_data.wedding_free = false;
		/******************************************
		Set New Steps Information
		/******************************************/
		obedata.menu_data.step3 = true;
		//WDDX & Save the Structures
		fncSaveObeData(obedata);
		//Go To NExt Step
		setNextEvent("ehOBE.dspGuestInfo");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspGuestInfo" access="public" returntype="void" output="false">
		<cfscript>
		//Get Driver Reference
		var obeDriver = CreateObject("component","obeapi.driver").init();
		//Get Travel Agents WS Reference
		var	TravelAgentsWS = getPlugin("webservices").getWSObj("TravelAgents");
		var TravelAgentsStruct = StructNew();
		try{
			//Booking Number Checker
			fncBookingNumberChecker();
			//Step Checker 
			if ( not getValue("obedata.menu_data.step3") )
				setNextEvent("ehOBE.dspHome");	
			else
				setValue("obedata.menu_data.currentStep","STEP3");
			
			TravelAgentsStruct = TravelAgentsWS.fncGetTravelAgencyAgents(getvalue("obedata.ta_info.TAAgencyID"),0);
			if (not TravelAgentsStruct.error){
				setvalue("obedata.ta_info.qTravelAgents", TravelAgentsStruct.results);
			}
			
			//WDDX & Save the Structures
			fncSaveObeData(getValue("obedata"));
			//Get Room Category Information For Summary
			setValue("rtn_category_info",getPlugin("webservices").getWSObj("obe").fncGetRoomCategories(getValue("obedata.room_data.resort"), getValue("obedata.room_data.ROOM_CATEGORY")));
			//Check for Air, and get Query of Queries for Summary
			if ( getValue("obedata.air_Data.air_included") is "YES")
				fncSummaryAirQueries();
			//Get US, CANADA, PUERTO RICO States
			setValue("qUsaStates", obeDriver.getStates("USA") );
			setValue("qCanadaStates", obeDriver.getStates("CANADA"));	
			//Set View to Display
			setView("vwGuestInfo");
		}
		catch( Any e ){
			getPlugin("logger").logError("Error on dspGuestInfo", e);
			getPlugin("messagebox").setMessage("error", "#getSetting("unexpected_error")#");
			setNextEvent("ehOBE.dspAvailability");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doSaveGuestInfo" access="public" returntype="void" output="false">
		<cfscript>
		//Get Obe data Structures
		var obedata = getValue("obedata");
		var obeWS = getPlugin("webservices").getWSObj("obe");
		var TravelAgentsWS = getPlugin("webservices").getWSObj("TravelAgents");
		var TravelAgentInfoStruct = "";
		var rtnGetDueCall = "";		
		var ssgInfoStruct = structnew();
		var PointInfoStruct = "";
		/******************************************
		Save Primary Guest Information
		/******************************************/
		obedata.room_data.title = trim(ucase(getValue("title")));
		obedata.room_data.firstname = trim(ucase(getValue("firstname")));
		obedata.room_data.middlename = trim(ucase(getValue("middlename")));
		obedata.room_data.lastname = replacenocase(trim(ucase(getValue("lastname"))),","," ","all");
		obedata.room_data.email = trim(ucase(getValue("email")));
		obedata.room_data.phone = trim(ucase(getValue("phone")));
		obedata.room_data.age = getValue("age");
		/******************************************
		Save Billing Address as primary guest address
		/******************************************/
		obedata.room_data.cc_address = obedata.room_data.address;
		obedata.room_data.cc_state = obedata.room_data.state;
		obedata.room_data.cc_zip = obedata.room_data.zip;
		obedata.room_data.cc_city = obedata.room_data.city;
		obedata.room_data.cc_country = obedata.room_data.country;
		/******************************************
		set travel agent email that confirmation will be sent to
		/******************************************/
		obedata.ta_info.email = getValue("TravelAgencyEmail");
		obedata.ta_info.TAAgentID = getValue("masterAgentID",0);		
		/******************************************
		Save Guest Information
		/******************************************/
		if ( obedata.room_data.adults gt 1){
			obedata.room_data.adult_list = ArrayNew(2);
			//SAVE THE GUESTS INFORMATION IF IT EXISTS
			for ( i=1; i lte (obedata.room_data.adults-1) ; i = i + 1){
				obedata.room_data.adult_list[i][1] = ucase(trim(evaluate("getValue('adult#i#_title')")));
				obedata.room_data.adult_list[i][2] = ucase(trim(evaluate("getValue('adult#i#_firstname')")));
				obedata.room_data.adult_list[i][3] = ucase(trim(evaluate("getValue('adult#i#_middleinitial')")));
				obedata.room_data.adult_list[i][4] = replacenocase(ucase(trim(evaluate("getValue('adult#i#_lastname')"))),","," ","all"	);
				obedata.room_data.adult_list[i][5] = getValue("adult#i#_age");
			}// end for loop
		}//end if adults gt 1
		/******************************************
		Save Children Information
		/******************************************/
		if ( obedata.room_data.children gt 0 ){
			obedata.room_data.child_list = ArrayNew(2);
			//SAVE THE CHILDREN INFORMATION IF IT EXISTS
			for ( i=1; i lte obedata.room_data.children ; i = i + 1){
				//set data
				obedata.room_data.child_list[i][1] = ucase(trim(evaluate("getValue('child#i#_title')")));
				obedata.room_data.child_list[i][2] = ucase(trim(evaluate("getValue('child#i#_firstname')")));
				obedata.room_data.child_list[i][3] = ucase(trim(evaluate("getValue('child#i#_middleinitial')")));
				obedata.room_data.child_list[i][4] = replacenocase(ucase(trim(evaluate("getValue('child#i#_lastname')"))),","," ","all");
				obedata.room_data.child_list[i][5] = evaluate("obedata.room_data.child_#i#");
			}// end for loop
		}//end children gt 0		
		
		//check if ssgnumber is passed in, VALIDATE AND GET POINTS.
		if (trim(getValue("ssgNumber","")) IS NOT ""){
			ssgInfoStruct = obeWS.fncSSGInfoCheck(getValue("ssgNumber"),trim(ucase(getValue("lastname"))));
			//Check for Errros
			if (ssgInfoStruct.error){
				getPlugin("messagebox").setMessage("error","There was an error calling the SSG validation procedures. Please try again.<br><br>Diagnostic Information:<br>#ssgInfoStruct.errorMessage#");
				setNextEvent("ehOBE.dspGuestInfo");
			}
			// mAke sure we have results from checking the account number, if not then make sure all ssg vars are reset
			if (ssgInfoStruct.results.recordcount eq 0){
				fncReinitSSGStruct(obedata);
				//Save data.
				fncSaveObeData(obedata);
				//Show message
				getPlugin("messagebox").setMessage("error","#getSetting("SSGInvalid_Error")#");
				setNextEvent("ehOBE.dspGuestInfo");
			}
			//Get Points
			PointInfoStruct = obeWS.fncGetSSGPoints(getValue("ssgNumber"));			
			if ( PointInfoStruct.error ){
				getPlugin("messagebox").setMessage("error","There was an error calling the SSG points procedures. Please try again. <br><br>Diagnostic Information:<br>#PointInfoStruct.errorMessage#");
				setNextEvent("ehOBE.dspGuestInfo");
			}
			//Set Points.
			obedata.ssg_data.authorized = true;
			obedata.ssg_data.member_id = ssgInfoStruct.results.ultraclub_id;
			obedata.ssg_data.member_fname = ssgInfoStruct.results.first_name;
			obedata.ssg_data.member_lname = ssgInfoStruct.results.last_name;
			obedata.ssg_data.member_email = ssgInfoStruct.results.email;
			obedata.ssg_data.member_points = PointInfoStruct.results.CurrentPoints;
		}
		else{
			fncReinitSSGStruct(obedata);
			//Save data.
			fncSaveObeData(obedata);
		}
			
		// If an agent is selected then 
		if (isNumeric(obedata.ta_info.TAAgentID) and obedata.ta_info.TAAgentID gt 0){
			//Get Travel Agents WS Reference
			TravelAgentInfoStruct = TravelAgentsWS.fncGetTravelAgencyAgents(getvalue("obedata.ta_info.TAAgencyID"),obedata.ta_info.TAAgentID);
			if (not TravelAgentInfoStruct.error){
				obedata.ta_info.first_name = TravelAgentInfoStruct.results.first_name;
				obedata.ta_info.last_name = TravelAgentInfoStruct.results.last_name;
			}
		}
		
		//Validate Promo Code if Found
		if ( obedata.room_data.promo_code neq "" )
			fncValidatePromoCode();
		
		/******************************************
		Get Balance due From WS, Then test For Hold
		Option if available.
		/******************************************/		
		rtnGetDueCall = obeWS.fncGetDue(obedata.room_data.check_in_date,
										 obedata.room_data.LandChildren + obedata.room_data.adults,
										 obedata.room_data.resort,
										 obedata.room_data.room_total,
										 'D','A','T');
		//Check if Call Succeeded
		if ( rtnGetDueCall.error ){
			getPlugin("messagebox").setMessage("error", rtnGetDueCall.errorMessage);
			setNextEvent("ehOBE.dspGuestInfo");
		}
		/******************************************
		Call Succeeded Determine the Balance
		/******************************************/
		obedata.room_data.balance = obedata.room_data.room_total - rtnGetDueCall.results;
		obedata.room_data.deposit_due_amount = rtnGetDueCall.results;
		/******************************************
		SSG Setting for Balance Before Discount
		/******************************************/
		if ( obedata.ssg_data.authorized is true )
			obedata.ssg_data.balance_before_discount = obedata.room_data.balance;
			
		/******************************************
		Get Deposit due Date From WS
		Option if available.
		/******************************************/		
		rtnGetDueCall = obeWS.fncGetDue(obedata.room_data.check_in_date,
										 obedata.room_data.LandChildren + obedata.room_data.adults,
										 obedata.room_data.resort,
										 obedata.room_data.room_total,
										 'D','D','T');
		//Check if Call Succeeded
		if ( rtnGetDueCall.error ){
			getPlugin("messagebox").setMessage("error", rtnGetDueCall.errorMessage);
			setNextEvent("ehOBE.dspGuestInfo");
		}
		// call succeded, then set deposit due date
		obedata.room_data.deposit_Due_Date = rtnGetDueCall.results;
		
		// now check if deposit due date is not today, then set deport due at booking to be 0
		if (obedata.room_data.deposit_Due_Date gt now()){
			obedata.room_data.deposit_amount_due_at_booking = 0;
		}
		
		/******************************************
		Airline Deposit Matrix
		In 400 Increments.
		/******************************************/
		if ( obedata.air_data.air_total is not 0)
			obedata.air_data.air_deposit = obedata.air_data.air_total;
		else
			obedata.air_data.air_deposit = 0.00;

		if (obedata.air_data.AIR_INCLUDED){
		  // Check if air is on sale, then deposit due is at time of booking
		  if (NOT obedata.air_data.FareSelectedHoldOption){
		  		obedata.room_data.deposit_Due_Date = DateFormat(now(), "MM/DD/YYYY");
		  		obedata.room_data.deposit_due_amount = obedata.room_data.deposit_due_amount + obedata.air_data.air_deposit;
		  	}
		  else if(obedata.air_data.air_total is not 0){
		  		if (obedata.air_data.FareSelectedType IS "PUBL"){
		  			obedata.room_data.deposit_Due_Date = DateFormat(dateAdd("d",1,now()), "MM/DD/YYYY");
		  			obedata.room_data.deposit_due_amount = obedata.room_data.deposit_due_amount + obedata.air_data.air_deposit;
		  		}
		  	}
		}
	 			
		/******************************************
		If There's a Balance, then get 
		the balance Due Date for Amount 
		/******************************************/
		if ( obedata.room_data.balance is not 0 ){
			rtnGetDueDateCall = OBEWS.fncGetDue(obedata.room_data.check_in_date,
												 obedata.room_data.LandChildren + obedata.room_data.adults,
												 obedata.room_data.resort,
												 obedata.room_data.room_total,
												 'B','D','T');
			//Check if Call Succeeded
			if ( rtnGetDueDateCall.error ){
				getPlugin("messagebox").setMessage("error", rtnGetDueDateCall.errorMessage);
				setNextEvent("ehOBE.dspGuestInfo");
			} 
			obedata.room_data.balance_due_date = rtnGetDueDateCall.results;
		}//end if balance is not 0	
		else{
			// Full Payment is due at booking
			obedata.room_data.deposit_Due_Date = DateFormat(now(), "MM/DD/YYYY");
	  		obedata.room_data.deposit_due_amount = obedata.room_data.room_total + obedata.air_data.air_deposit;
	  		obedata.room_data.balance_due_date = DateFormat(now(), "MM/DD/YYYY");
		}
				
		/******************************************
		Set New Steps Information
		/******************************************/
		obedata.menu_data.step4 = true;
		//WDDX & Save the Structures
		fncSaveObeData(obedata);
		//Set The Next Event 
		setNextEvent("ehOBE.dspPayment");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspPayment" access="public" returntype="void" output="false">
		<cfscript>
		var obeDriver = CreateObject("component","obeapi.driver").init();
		//Booking Number Checker
		fncBookingNumberChecker();
		//Step Checker 
		if ( not getValue("obedata.menu_data.step4") )
			setNextEvent("ehOBE.dspHome");	
		else
			setValue("obedata.menu_data.currentStep","STEP4");	 
		//Get US, CANADA, PUERTO RICO States
		setValue("qUsaStates", obeDriver.getStates("USA") );
		setValue("qCanadaStates", obeDriver.getStates("CANADA"));	
		//Get Room Category Information For Summary
		setValue("rtn_category_info",getPlugin("webservices").getWSObj("obe").fncGetRoomCategories(getValue("obedata.room_data.resort"), getValue("obedata.room_data.ROOM_CATEGORY")));
		//Check for Air, and get Query of Queries for Summary
		if ( getValue("obedata.air_Data.air_included") is "YES")
			fncSummaryAirQueries();
		//Set The View
		setView("vwPayment");		
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doBooking" access="public" returntype="void" output="false">
		<cfscript>
		//get Obedata reference
		var obedata = getValue("obedata");
		var obeWS = getPlugin("webservices").getWSObj("obe");
		var inetServerName = getPlugin("fileUtilities").getInetHost();
		var criteriaPay = 0;
		var p_name_type = "";
		var rtnTAStruct = "";
		var p_c_first = "";
		var p_c_last = "";
		var master_agency_id = 0;
		var code = "";
		var insertSource = "";
		var TAEmail = "";
		var adult_guests = 0;
		var guest_data = "";
		var adult_data = "";
		var child_data = "";
		var rtnCC = "";
		var rtnBook = "";
		var UsersInfoQryStruct = "";
		var AirStartTime = 0;
		var isAirFarePaid = "No";
		var FareSearchObj = "";
		var PNRObj = "";
		var FareInfoQryStruct = "";
		var PNRRecordLocator = "";
		var PNRCreationError = "";
		var PNRStruct = "";
		var AddAirBookingToDB = "";
		var TempExpDate = "";
		var pagename = "";
		//CC inits
		var InvoiceNumber = 0;
		var isTestRun = "";
		var AuthCode = 0;
		var v_amtl = 0;
		
		
		//Booking Number checker
		fncBookingNumberChecker();
		
		//Availability ID Checker
		if ( not structkeyExists(obedata, "AvailabilityID") ){
			getPlugin("messagebox").setMessage("warning","Mandatory information was corrupted. Please try again. Sorry for the inconvenience.");
			setNextEvent("ehOBE.dspHome","reinituser=1");
		}
		
		//Booking Steps Checker
		if ( obedata.menu_data.step1 neq true or
			 obedata.menu_data.step2 neq true or
			 obedata.menu_data.step3 neq true or
			 obedata.menu_data.step4 neq true){
			getPlugin("messagebox").setMessage("warning","Please make sure you have completed all the steps before booking.");
			setNextEvent("ehOBE.dspHome");
		}
		
		/******************************************
		Process Form Variables To Create Booking.
		Set CC Variables Passed In.
		/******************************************/		
		obedata.ROOM_DATA.CC_TYPE = getvalue("card_type");
		obedata.ROOM_DATA.cc_expirationMonth = getvalue("expires_month");
		obedata.ROOM_DATA.cc_expirationYear = getvalue("expires_year");
		/******************************************
		CC Billing Address Setup
		/******************************************/	
		obedata.room_data.cc_address = getvalue("cc_address","");
		obedata.room_data.cc_city = getvalue("cc_city","");
		obedata.room_data.cc_state = getvalue("cc_state","");
		obedata.room_data.cc_zip = getvalue("cc_zip","");
		obedata.room_data.cc_country = getvalue("cc_country","");
		/******************************************
		Determine Insurance If Choosen 
		/******************************************/		
		if ( trim(getValue("insurance_agree","NO")) is "YES" )
			obedata.room_data.insurance = true;
		else
			obedata.room_data.insurance = false;
		/******************************************
		Determine Wedding if Choosen
		/******************************************/		
		if ( getValue("wedding_free","NO") is "YES" )
			obedata.room_data.wedding_planning = true;
		else
			obedata.room_data.wedding_planning = false;
		/******************************************
		Determine Payment Methods 
		/******************************************/
		setvalue("amount",trim(ucase(getValue("amount"))));	
		if ( getValue("amount") is "FULL" ){
			//Full Payments, calculate from parameters.
			obedata.room_data.amount_to_charge = obedata.room_data.total_display;
			//set amount to charge and to display with insurance
			if ( obedata.room_data.insurance )
				obedata.room_data.amount_to_charge = obedata.room_data.amount_to_charge + obedata.room_data.insurance_amount;
			//set hold option
			obedata.room_data.hold_option = "FULL";
		}//end if amount eq FULL
		else if ( getValue("amount") is "HOLD" ){
			//Hold Option Calculate Amount to Charge
			if ((obedata.room_data.deposit_due_amount) and (obedata.room_data.deposit_Due_Date EQ dateformat(now(),'mm/dd/yyyy'))){
				obedata.room_data.amount_to_charge = obedata.room_data.deposit_due_amount;
			}
			//obedata.room_data.amount_to_charge = obedata.room_data.deposit_due_amount + obedata.air_data.air_deposit;
			//set amount to charge and to display with insurance
			//if ( obedata.room_data.insurance is true )
			//	obedata.room_data.amount_to_charge = obedata.room_data.amount_to_charge + obedata.room_data.insurance_amount;
			//Set the Hold Option
			obedata.room_data.hold_option = "HOLD";
		}//end if amount eq HOLD
		else if ( getValue("amount") is "HOLD_OTHER" ){
			//Check if Other Amount is Numeric
			if ( not isNumeric(getValue("other_amount","")) ){
				//Other Amount is Not Numeric
				getPlugin("messagebox").setMessage("warning","#getsetting("otheramount_error")#");
				setNextEvent("ehOBE.dspPayment");
			}
			//Round Off Other Amount
			setValue("other_amount",numberFormat(getValue("other_amount"),"_____________.__"));
			//Check if in Range of payments 
			//Get Criteria to pay minimum.
			//criteriaPay = obedata.air_data.air_deposit + obedata.room_data.deposit_due_amount;
			criteriaPay = obedata.room_data.deposit_due_amount;
			//Check for Insurance.
			//if ( obedata.room_data.insurance is true )
			//	criteriaPay = criteriaPay + obedata.room_data.insurance_amount;
			//Check bounds.
			if ( getValue("other_amount") lt criteriaPay and (obedata.room_data.deposit_Due_Date EQ dateformat(now(),'mm/dd/yyyy'))){
				//Other Amount is not Valid
				getPlugin("messagebox").setMessage("warning","#getsetting("otheramount_error")#");
				setNextEvent("ehOBE.dspPayment");
			}					
			//Hold Other Amount Calculate Amount To Charge
			obedata.room_data.amount_to_charge = getValue("other_amount");	
			//Set the Hold Options.
			obedata.room_data.hold_option = "HOLD_OTHER";
		}//if amount is HOLD_OTHER
		else{
			//No Payment Amount Found
			getPlugin("messagebox").setMessage("warning","#getSetting("invalidccinformation_error")#");
			setNextEvent("ehOBE.dspPayment");
		}
		
		/******************************************
		Direct Consumer, Cobrand Identification Tests
		Setting of Guests Data into Data Strings
		takes place here.
		/******************************************/		
		try{
			// Set contact info for TA 		
			p_name_type = "T"; 
			p_c_first = obedata.ta_info.first_name;
			p_c_last = obedata.ta_info.last_name;
			master_agency_id = obedata.ta_info.MasterAgencyID;
			code = obedata.ta_info.IATA;
			insertSource = "WEBBOOK_T";
			TAEmail = obedata.ta_info.email;				
			//Set Number Of Guests
			adult_guests = obedata.room_data.adults - 1;				
			/******************************************
			Set the Primary Guest & Guests Data Strings
			/******************************************/	
			//Set Primary Guest Adult Data String.	
			adult_data =   obedata.room_data.title & 
			  			   " ," & obedata.room_data.firstname & 
						   " ," & obedata.room_data.middlename & 
						   " ," & obedata.room_data.lastname & 
						   " ," & obedata.room_data.age & " ,";
						   
			//loop through adult guests and create the adult_data string --->
			for ( i = 1; i lte adult_guests; i = i + 1){
				adult_data = adult_data & 
							 replacenocase(obedata.room_data.adult_list[i][1],","," ","all") & 
							 " ," & replacenocase(obedata.room_data.adult_list[i][2],","," ","all") & 
							 " ," & replacenocase(obedata.room_data.adult_list[i][3],","," ","all") & 
							 " ," & replacenocase(obedata.room_data.adult_list[i][4],","," ","all") & 
							 " ," & obedata.room_data.adult_list[i][5] & " ,";
			} //end for loop creation of data strings.
						
			//set the guest data String = to the adult data stirngs and concatenate guests.
			guest_data = adult_data;					
			/******************************************
			Set Children Data Strings
			/******************************************/		
			if ( obedata.room_data.children gt 0 ){
				//Init Data
				child_data = "";
				for ( i = 1; i lte obedata.room_data.children; i = i + 1 ){
					child_data = child_data & 
								 replacenocase(obedata.room_data.child_list[i][1],","," ","all") & 
								 " ," & replacenocase(obedata.room_data.child_list[i][2],","," ","all") & 
								 " ," & replacenocase(obedata.room_data.child_list[i][3],","," ","all") & 
								 " ," & replacenocase(obedata.room_data.child_list[i][4],","," ","all") & 
								 " ," & obedata.room_data.child_list[i][5] & " ,";
				} //end for loop children data strings				
				//Concatenate the child_data with the guest_data.			
				guest_data = guest_data & child_data;
			} //end if children gt 0			
		} //end try TA and DC data settings.		
		catch( Any e ){
			getPlugin("logger").logError("fncBook.Direct Consumer Cobrand Identification Checks And Data Settings.",e);
			getPlugin("messagebox").setMessage("error","#getSetting("Booking_process_nocharge_error")#<br><br>Diagnostic Information:<br>#e.detail# - #e.message#");
			setNextEvent("ehOBE.dspPayment");		
		} //end of catch
		
		/******************************************
		Data Settings finalized, Book it. Call 
		CC Procedures.
		/******************************************/		
		if (obedata.room_data.amount_to_charge GT 0){
			//Check if payment is enough to cover air
			if (obedata.room_data.amount_to_charge GTE obedata.air_data.air_deposit){
				isAirFarePaid = "YES";
			}
			try{
				//Call fncCreditCard
				rtnCC = obeWS.fncProcessPayment("#obedata.room_data.cc_expirationMonth#",
												"#obedata.room_data.cc_expirationYear#",
												obedata.room_data.Amount_To_Charge,
												"#obedata.room_data.cc_address#",
												"#obedata.room_data.cc_zip#",
												'#getvalue("cc_number")#',
												getvalue("cc_ccvid",0),
												obedata.room_data.cc_type,
												obedata.AvailabilityID,
												"#obedata.room_data.firstname#",
												"#obedata.room_data.lastname#",
												"#obedata.room_data.cc_city#",
												"#obedata.room_data.cc_state#",
												"#obedata.room_data.phone#",
												"#obedata.room_data.email#");
				//Check for CC Errors
				if ( rtnCC.error ){
					getPlugin("messagebox").setMessage("error", "#getSetting("ccmodule_error")# <br><br>Diagnostic Data: #rtnCC.errorMessage#");
					setNextEvent("ehOBE.dspPayment");
				} //end rtnCC error Found.		
				/******************************************
				Check if CC was approved or not.
				/******************************************/		
				if ( rtnCC.results.approved neq "Y" ){
					//Not Approved
					getPlugin("messagebox").setMessage("warning","#getSetting("ccdenied_error")# <br><br>#rtnCC.results.v_message#");
					setNextEvent("ehOBE.dspPayment");
				}
				
				// Payment approved, get conf number
				InvoiceNumber = rtnCC.results.invoice;
				isTestRun = rtnCC.results.testrun;
				AuthCode = rtnCC.results.v_auth_code;
				v_amtl = rtnCC.results.v_amtl;
				
				//Else We got An Approved CREDIT CARD, continue Booking.			
			} //end Try CC Procedures
			catch( Any e ){
				getPlugin("logger").logError("fncBook.CC Procedure Call.",e);
				getPlugin("messagebox").setMessage("error","#getSetting("ccmodule_error")# <br><br>Diagnostic Data: #e.detail# - #e.message#");
				setNextEvent("ehOBE.dspPayment");			
			} //end of catch
		}
		else{
			// Np Payment is submitted, then set vars
			isAirFarePaid = "NO";
			InvoiceNumber = 0;
			isTestRun = 'N';
			AuthCode =  0;
			v_amtl = 0;
		}
		
		/******************************************
		Change Totals and Balances
		/******************************************/
		if ( getValue("amount") is "FULL" ){
			if ( obedata.room_data.insurance )
				obedata.room_data.total_display = obedata.room_data.total_display + obedata.room_data.insurance_amount;
			//Calculate Balances
			obedata.room_data.balance = 0;
			obedata.room_data.deposit_due_amount = 0;
			obedata.room_data.balance_due = "";
		} //end if FULL
		else if ( getValue("amount") is "HOLD" ){
				if ( obedata.room_data.insurance is true )
					obedata.room_data.total_display = obedata.room_data.total_display + obedata.room_data.insurance_amount;
				//Calculate the balances;
				obedata.room_data.balance = obedata.room_data.total_display - obedata.room_data.amount_to_charge;
		} //end if HOLD
		else if ( getValue("amount") is "HOLD_OTHER" ){
					//Calculate Total Display with Insurance if exists.
					if ( obedata.room_data.insurance is true )
						obedata.room_data.total_display = obedata.room_data.total_display + obedata.room_data.insurance_amount;
					//Calculate the Balances.
					obedata.room_data.balance = obedata.room_data.total_display - obedata.room_data.amount_to_charge;
		} //end if HOLD OTHER
		
		//******************************************
		//Call Booking Procedure
		/******************************************/
		
		rtnBook = obeWS.fncBookTA(obedata.AvailabilityID,
								"#dateformat(obedata.room_data.check_in_date, "MM/DD/YYYY")#",
								obedata.room_data.Number_OF_Nights,
								"#obedata.room_data.departure_gateway#",
								obedata.room_data.room_total,
								obedata.room_data.room_total_base,
								obedata.room_data.adults,
								obedata.room_data.Landchildren,
								obedata.room_data.infants,
								"#obedata.room_data.resort#",
								"#obedata.room_data.room_category#",
								"#obedata.room_data.title#",
								"#obedata.room_data.firstname#",
								"#obedata.room_data.lastname#",
								"#obedata.room_data.middlename#",
								"#obedata.room_data.age#",
								//"#dateformat(obedata.room_data.dob, "MM/DD/YYYY")#",
								"#obedata.room_data.address#",
								"#obedata.room_data.city#",
								"#obedata.room_data.state#",
								"#obedata.room_data.country#",
								"#obedata.room_data.zip#",
								"#obedata.room_data.phone#",
								"#obedata.room_data.fax#",
								"#obedata.room_data.email#",
								"#guest_data#",
								"",
								"#p_name_type#",
								"#code#",
								"#p_c_first#",
								"#p_c_last#",
								"#obedata.room_data.cc_type#",
								"#getvalue("cc_number")#",
								"#obedata.room_data.cc_expirationMonth#",
								"#obedata.room_data.cc_expirationYear#",
								"#trim(numberFormat(v_amtl,"9999999999.99"))#",
								"#AuthCode#",
								#InvoiceNumber#,
								obedata.ssg_data.member_id,
								obedata.ssg_data.points_applied,
								obedata.ssg_data.points_accrued,
								"#isTestRun#",
								"#insertSource#",
								"#obedata.room_data.Hold_Option#",
								"",
								"#inetServerName#",
								"#obedata.room_Data.promo_id#",
								"#obedata.room_Data.promo_description#",
								obedata.ta_info.TAAgentID);
			
			//Check for Booking Errors
			if ( rtnBook.error ){
				//Set Errror
				getPlugin("messagebox").setMessage("error","#getSetting("Booking_process_charge_error")#<br><br>Diagnostic Data: #rtnBook.ErrorMessage#");
				setNextEvent("ehOBE.dspPayment");	
			} //end rtnBook error Found	
		
		//set the booking numbers;
		obedata.room_data.Booking_Number = rtnBook.results.BookingNumber;
		obedata.room_data.Confirmation_Number = rtnBook.results.ConfirmationNumber;
		/******************************************
		AIR MODULE TO BOOK AIR.
		/******************************************/	
		if ( obedata.air_data.air_included is true ){
			//Set PNR Locator
			obedata.air_data.PNRRecordLocator = "";							
			//BOOK AIR
			//call fncBuildTraveleresQuery to get a sorted travelers query by type --->	
			try{
				UsersInfoQryStruct = fncBuildTraveleresQuery();
				
				if (UsersInfoQryStruct.error){
					obedata.air_data.air_warning = 1;
					getPlugin("logger").logError("fncBook.Air Booking Engine", structnew() , UsersInfoQryStruct);
					getPlugin("messagebox").setMessage("error","#getsetting("air_oops_error")#: #obedata.room_data.Confirmation_Number#");			
				}
				else{
					AirStartTime = NOW();
					obedata.air_data.air_warning = 0;
					//Get FareSearch Reference
					FareSearchObj = getPlugin("webservices").getWSObj("FaresearchV2");
					PNRObj = getPlugin("webservices").getWSObj("PNRV2");
					//set UserInfoQry back to sorted query
					UsersInfoQry = UsersInfoQryStruct.Results;
					// Get The selected Fare Info
					FareInfoQryStruct = fncGetUserSelectedFare();
					// start processing PNR create
					// Init params to hold PNR record locator and error
					PNRRecordLocator = "";
					PNRCreationError = "";
					PNRStruct = PNRObj.WebPNRCreateRequest(FareInfoQryStruct.Results, UsersInfoQry, 
														   obedata.room_data.Booking_Number, "WebTA");
					if (PNRStruct.Error or Trim(PNRStruct.Results) is ""){
						PNRCreationError = PNRStruct.ErrorMessage;
						getPlugin("logger").logError("fncBook.Air Blank PNR or Error on PNR. Error: #PNRStruct.ErrorMessage#", structnew(),PNRStruct);
						obedata.air_data.air_warning =1;
						getPlugin("messagebox").setMessage("warning","#getsetting("air_oops_error")#: #obedata.room_data.Confirmation_Number#");				
						// Send an email to help desk, yrodriguez@uvi.sandals.com, abarrios@uvi.sandals.com
						fncSendEmailAirErrors(FareInfoQryStruct.Results,UsersInfoQry,obedata.room_data.Confirmation_Number); 
					}
					else
						PNRRecordLocator = Trim(PNRStruct.Results);
					
					//Set PNR Locator
					obedata.air_data.PNRRecordLocator = PNRRecordLocator;
					// Add User fare and flights info to DB
					AddAirBookingToDB = FareSearchObj.AddUserFareInfoToDB(FareInfoQryStruct.Results, obedata.AvailabilityID, PNRRecordLocator,
																		  PNRCreationError, isAirFarePaid, "", "", 
																		  obedata.room_data.booking_number);
					if (AddAirBookingToDB.Error){
						getPlugin("logger").logError("fncBook.Air Add Air To Booking DB", structnew(),AddAirBookingToDB);
						obedata.air_data.air_warning = 1;
						if (NOT PNRStruct.Error AND Trim(PNRStruct.Results) is NOT ""){
							getPlugin("messagebox").setMessage("warning","Your flights were booked successfully.Your air confirmation locator is #PNRRecordLocator#.Please call us or your travel agent to finalize your reservation.");
						}
						// Send an email to help desk, yrodriguez@uvi.sandals.com, abarrios@uvi.sandals.com
						fncSendEmailAirErrors(FareInfoQryStruct.Results,UsersInfoQry,obedata.room_data.Confirmation_Number); 
					}
					else
						obedata.air_data.itinerary_id = AddAirBookingToDB.results;	
										
					//Remove all fares for this user from DB
					FareSearchObj.RemoveTempUserFares(obedata.AvailabilityID, "");
					
					//Add to gold if air is successful
					if (trim(PNRRecordLocator) IS NOT ""){
						//Get the Number of days in the month that expires to set expiration date
						TempExpDate = CreateDate(obedata.ROOM_DATA.cc_expirationYear,obedata.ROOM_DATA.cc_expirationMonth, 1);
						TempDaysInMonth = DaysInMonth(TempExpDate);
						ccExpDate = CreateDate(obedata.room_data.cc_expirationYear, obedata.room_data.cc_expirationMonth,TempDaysInMonth);
						CardName = "#obedata.room_data.FirstName# #obedata.room_data.LastName#";					
						AddInfoToGoldStruct = obeWS.fncBookAir(obedata.room_data.Booking_Number, Trim(PNRRecordLocator), 
											DateFormat(ccExpDate,'MM/DD/YYYY'), obedata.ROOM_DATA.CC_TYPE, getvalue("cc_number"), 
											CardName, obedata.air_data.air_total, AuthCode, InvoiceNumber);
					}	
					if (getValue("ObeVariables.LOG_AIR_REQUEST") IS "YES"){
					// Log this call
						obeWS.fncLogAirTime(AirStartTime, NOW(), obedata.air_data.arrival_date, 
											obedata.room_data.departure_gateway, 
											obedata.air_data.return_date , obedata.air_data.arrival_gateway, 
											obedata.air_data.GDS, "PNR"); 
					}
				}//builders query if
			} //END OF TRY STATEMENT 
			catch(ANY Exception){
				getPlugin("logger").logError("fncBook.Air Booking Engine", Exception, Exception);
				obedata.air_data.air_warning = 1;
				getPlugin("messagebox").setMessage("warning","#getsetting("air_oops_error")#: #obedata.room_data.Confirmation_Number#");				
				// Send an email to help desk, yrodriguez@uvi.sandals.com, abarrios@uvi.sandals.com
				fncSendEmailAirErrors(FareInfoQryStruct.Results,UsersInfoQry,obedata.room_data.Confirmation_Number); 
			} //END OF CATCH STATEMENT air.
		} //end if air included.
		
		/******************************************
		 If email for cunsomer is filled, then send confirmation email
		******************************************/
		if (trim(obedata.room_data.email) is not ""){
			try{
				fncSendMailConfirmations('C',obedata.room_data.email);
			}
			catch (Any Exception ){
				getPlugin("logger").logError("fncBook.Email Confirmations", Exception);
			}
		}
		
		/******************************************
		Send Email Confirmations
		/******************************************/		
		try{
			fncSendMailConfirmations(p_name_type,TAEmail);
		}
		catch (Any Exception ){
			getPlugin("logger").logError("fncBook.Email Confirmations", Exception);
		} //end catch email confirmations
		
		/******************************************
		Send Wedding Emails Confirmations
		/******************************************/		
		try{
			if ( obedata.room_data.wedding_planning is true )
				fncSendWeddingEmail();
		}
		catch (Any Exception ){
			getPlugin("logger").logError("fncBook.SendingWedding Confirmations", Exception);
		} //end catch email confirmations
		
		/******************************************
		Call Insurance Modules.
		/******************************************/	
		try{
			if ( obedata.room_data.insurance is true ){
				//Call Write Insurance Module
				obeWS.fncWriteInsurance(obedata.room_data.Booking_Number,
													  obedata.room_data.insurance_p_res_id,
													  obedata.room_data.insurance_p_sd_id,
													  obedata.room_data.check_in_date,
													  obedata.room_data.adults + obedata.room_data.children,
													  obedata.room_data.insurance_amount / passengers);
			}//end insurance is true		
		} //end try insurance.
		catch (Any Exception ){
			getPlugin("logger").logError("fncBook.Insurance Module Failed", Exception, obedata);
		} //end catch Insurance Modules.
		
		/******************************************
		Sandals Promotional Code Application
		/******************************************/	
		try{		
			if ( obedata.room_data.promo_code_valid is true ){
				//Call Promo Code Write to Gold.
				obeWS.fncWritePromoCodeToGold(obedata.room_data.Booking_Number,
											obedata.room_data.Promo_Code_ID,
											obedata.room_data.Promo_code_discount,
											obedata.room_data.promo_code);
			}
		} //end try promocode write.
		catch (Any Exception ){
			getPlugin("logger").logError("fncBook.Write To Promo Code To Gold Failed.", Exception, obedata);
		} //end catch Insurance Modules.
		
		
		/******************************************
		Profile Tracking Module
		/******************************************/	
		try{
			// check if it was a wedding booking to track the wedding booking and ssg bookings --->
			if ( obedata.room_data.wedding_planning is "YES" )
				pagename = "BOOKING_WEDDING#iif(obedata.ssg_data.authorized is true,"'_SSG'","''")#";
			else
				pagename = "BOOKING#iif(obedata.ssg_data.authorized is true,"'_SSG'","''")#";
			//check if the cookie.SET_SANDALS exist for the search engine tracking --->
			if ( isDefined("cookie.SET_SANDALS") and (cookie.set_sandals is not 0))	{
				CreateObject("component","obeapi.tracking").set_trackhit(cookie.set_sandals,
																					 "BOOKING",
																					 obedata.room_data.total_display);
			}	
			//Call Profile Tracking
			CreateObject("component","obeapi.tracking").ProfileTracking( obedata.room_data.firstname,
																					 obedata.room_data.lastname,
																					 obedata.room_data.email,
																					 pagename,
																					 Cgi.HTTP_REFERER,
																					 "YES",
																					 "BOOKING",
																					 obedata.email_campaign_id);
			
		 } //end try Profile Tracking
		 catch (Any Exception ){
			getPlugin("logger").logError("fncBook.Profile Tracking Failed.",Exception, obedata);
		 } //end catch Profile Tracking.
		
		/******************************************
		 Email Comments to ETS
		/******************************************/	
		try {
			if ( getValue("comments","") neq "" ){
				obedata.room_data.comments = trim(ucase(getValue("comments")));
				fncEmailComments();
			}			
		}
		catch (Any Exception ){
			getPlugin("logger").logError("fncBook.Email Comments to ETS Failed.", Exception);
		} //end catch EmAIL TO ETS
		
		
		/******************************************
		Booking Finished, Clean CC Information.
		/******************************************/	
		obedata.room_data.cc_number = 0;
		obedata.room_data.cc_type = "";
		obedata.room_data.cc_expirationMonth = "";
		obedata.room_data.cc_expirationYear = "";
		//Clear SSG Data
		if ( obedata.ssg_data.authorized is true )
			obedata.ssg_data.booked = true;
		obedata.ssg_data.authorized = false;		
		//Clear Menu Data
		obedata.menu_data.step1 = false;
		obedata.menu_data.step2 = false;
		obedata.menu_data.step3 = false;
		obedata.menu_data.step4 = false;
		obedata.menu_data.currentStep = "CONFIRMATION";
		//WDDX & Save the Structures
		fncSaveObeData(obedata);
		//Set The Next Event 
		setNextEvent("ehOBE.dspConfirmation");		
		</cfscript>		
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="dspConfirmation" access="public" returntype="void" output="false">
		<cfscript>
		if ( getValue("obedata.room_data.Confirmation_number",0) eq 0 ){
			inituser();
			setNextEvent("ehOBE.dspHome");
		}
		//Get Room Category Information For Summary
		setValue("rtn_category_info",getPlugin("webservices").getWSObj("obe").fncGetRoomCategories(getValue("obedata.room_data.resort"), getValue("obedata.room_data.ROOM_CATEGORY")));
		//Check for Air, and get Query of Queries for Summary
		if ( getValue("obedata.air_Data.air_included") is true)
			fncSummaryAirQueries();
		//Set the Confirmation View.
		setView("vwConfirmation");
		//<!--- Check for CFDoc Type --->
		if ( getValue("cfdocType",0) neq 0 )
			setLayout("Layout.CFDocument.cfm");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doFinish" access="public" returntype="void" output="false">
		<cfset initUser()>
		<cflocation url="http://www.sandals.com" addtoken="no">
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="doPollingTest" access="public" returntype="void" hint="Run the Polling Test" output="false">
	<cfscript>
		var obedata = getValue("obedata", structNew());
		var airAvailability = Structnew();
		var landAvailability = ArrayNew(1);
		var rntPollTest = "";
		var rtnPollData = "";
		
		///Thread ID Check
		if ( obedata.ThreadID eq 0)
			setNextEvent("ehOBE.dspHome");			
		//Thread Counter Check
		if ( ((getTickCount()-obedata.ThreadCounter)/1000) gt 40 ){
			//Reinit
			obedata.ThreadID = 0;
			obedata.ThreadCounter = 0;
			//WDDX & Save the Structures
			fncSaveObeData(obedata);
			//Interface Expiration
			getPlugin("messagebox").setMessage("error","#getSetting("PollingThreadTimeout_error")#");
			setNextEvent("ehOBE.dspHome");
		}			
		//Save Flash Redirect
		if ( getValue("noflash",false) eq "true" )
			obedata.noflash = true;
		else
			obedata.noflash = false;
		//WDDX & Save the Structures
		fncSaveObeData(obedata);			
		//Polling Test --->
		rtnPollTest = getPlugin("webservices").getWSObj("obe").fncGetPollingFlag(obedata.ThreadID);
				
		//Test Results --->
		if ( rtnPollTest.results eq "COMPLETE" ){
			//Clear land & Air Availabilities
			obedata.qLandAvailability = ArrayNew(1);
			obedata.qAirAvailability = Structnew();			
			//Test For Land And Air Flags for Availabilty
			rtnPollData = getPlugin("webservices").getWSObj("obe").fncGetPollingData(obedata.ThreadID);
			//Test For Errors
			if (rtnPollData.error){
				getPlugin("messagebox").setMessage("error","#getSetting("LandAvailability_Error")#");
				setNextEvent("ehOBE.dspHome");
			}			
			//Check Land Request Flag
			if ( rtnPollData.results.land_request_flag eq "Y"){
				//Get Land
				landAvailability = rtnPollData.results.landStruct;
				//Test for Errors
				if ( landAvailability.error ){
					getPlugin("messagebox").setMessage("error","#getSetting("LandAvailability_Error")#");
					setNextEvent("ehOBE.dspHome");
				} //end of if statement Error Checks
				else
					obedata.qLandAvailability = duplicate(landAvailability.results);
			}
			else {
				//Land Failed, set error msg and redirect.
				getPlugin("messagebox").setMessage("error","#getSetting("PollingThreadTimeout_Error")#");
				obedata.ThreadID = 0;
				setnextEvent("ehOBE.dspHome");
			}			
			//Check Air Request
			if ( obedata.air_data.air_included ){
				if ( rtnPollData.results.air_request_flag eq "Y" ){
					//Unwddx packet
					airAvailability = rtnPollData.results.airStruct;
					// Check for errors					
					if (airAvailability.Error is not "" and airAvailability.results.recordcount is 0){
						//set The warning label
						obedata.air_data.air_warning = 1;
						//Air FAILED Requested, Reinit Air_data
						obedata.air_data = fncReinitAirStruct();
						//Test For what Type of Error
						if (FindNoCase("No Flight", airAvailability.Error) OR 
							FindNoCase("No ITINERARY", airAvailability.Error)){
							getPlugin("Messagebox").setMessage("warning","#getSetting("NoFlights_Error")#");
						}
						else{
							getPlugin("Messagebox").setMessage("error","#getSetting("AirAvailability_Error")#<br><br>#airAvailability.Error#");
						}
					}//end if Errors in Air availability struct	
					else{
						obedata.air_data.air_warning = 0;
						obedata.qAirAvailability = duplicate(airAvailability.results);
					}	
				}//end if air success
				else{
					getPlugin("Messagebox").setMessage("warning","#getSetting("AirAvailabilityTimeout_error")#");
					obedata.air_data.air_warning = 1;
					//Air FAILED Requested, Reinit Air_data
					obedata.air_data = fncReinitAirStruct();
				}//end air not successfull
			}//end air included			
			//Save Step Information
			obedata.menu_data.step2 = true;
			obedata.ThreadID = 0;
			obedata.ThreadCounter = 0;
			//WDDX & Save the Structures
			fncSaveObeData(obedata);
			//Relocate
			setNextEvent("ehOBE.dspAvailability");
		}//end if complete
		else if ( rtnPollTest.results eq "PENDING" ){
			setNextEvent("ehOBE.dspPolling");//Pending or Incomplete
		}
		else{
			//Not Found, probably thread id retrieved. clean
			obedata.ThreadID = 0;
			obedata.ThreadCounter = 0;
			obedata.menu_data.step2 = false;
			obedata.air_data = fncReinitAirStruct();
			//Prepare New Avaialbility
			fncPrepareNewAvailability(obedata);
			//Clear land & Air Availabilities
			obedata.qLandAvailability = ArrayNew(1);
			obedata.qAirAvailability = Structnew();
			//WDDX & Save the Structures
			fncSaveObeData(obedata);
			//Set expired message.
			getPlugin("Messagebox").setMessage("warning","#getSetting("PollingRequestExpired_Error")#");
			//Relocate
			setNextEvent("ehOBE.dspHome");			
		}	
	</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
<!--------------------------------------------- PRIVATE --------------------------------------------->
			
	<!--- ************************************************************* --->
	<cffunction name="fncSetDisplayEnvironment" access="private" hint="Initialize the user's Display Environment" output="false">
		<cfscript>
		request.browser_type = "ie";
		//set Browser and OS ID's
		if (findNoCase("MAC",cgi.HTTP_USER_AGENT) is 0)
			request.os_type = "wintel";
		else
			request.os_type = "mac";
		if (findNoCase("MSIE",cgi.HTTP_USER_AGENT) is 0)
			request.browser_type = "other";
		
		//Tag Path Code	
		if ( getValue("obedata.brand") eq "beaches")
			request.tagPath = "/ctags/beaches/";
		else
			request.tagPath = "/ctags/sandals/";	
						
		//Set The PathLink to the appropriate Website.
		if (getSetting("environment") eq "DEVELOPMENT"){
			if ( getValue("obedata.brand") eq "royalplantation")
				request.pathLink = "devj2.sandals.com";
			else
				request.pathLink = "devj2.#getValue("obedata.brand")#.com";
		}
		else{
			if ( getValue("obedata.brand") eq "royalplantation")
				request.pathLink = "www.sandals.com";
			else
				request.pathLink = "www.#getValue("obedata.brand")#.com";
		}							
		
		//check for SSL --->
		if (cgi.SERVER_PORT_SECURE eq 1)
			request.pathLink = "https://" & request.pathLink;
		else
			request.pathLink = "http://" & request.pathLink;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncAvailabilityTrackingRoutines" access="private" hint="Quote,Profile,etc Tracking." returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="obedata" required="yes" type="struct">
		<!--- ************************************************************* --->
		<cfscript>
		var TempCall = "";
		var obeWS = getPlugin("webservices").getWSObj("obe");
		try{
			//Log This Quote
			obeWS.fncQuoteLog(arguments.obedata.room_data.resort,arguments.obedata.ssg_data.member_id);
			//Search Engine Tracking
			if ( isDefined("cookie.set_sandals") and cookie.set_sandals is not 0 ){
				CreateObject("component","obeapi.tracking").set_trackhit(cookie.set_sandals, "QUOTE", "");
			}//end of If statement
			//Client First Visit Tracking
			if ( getValue("email","") is not ""){			
				TempCall = CreateObject("component", "obeapi.tracking");
				TempCall.ProfileTracking("",
										 "",
										 "#getValue("email","")#",
										 "QUOTE REQUEST",
										 "#getValue("HTTP_REFERER","")#",
										 "#getValue("mailing_list","")#",
										 "#arguments.obedata.brand#",
										 "#arguments.obedata.room_data.resort#",
										 arguments.obedata.room_data.Number_Of_Nights, 
										 "OBE RESULTS", 
										 arguments.obedata.email_campaign_id);			
				//Populate Structures.
				setValue("obedata.room_data.email",getValue("email","") );
				//Set PersonalInfoFilled to true.
				setValue("obedata.PersonalInfoFilled",true);				
			}
			else{
				//Quote Tracking
				TempCall = CreateObject("component", "obeapi.tracking");
				TempCall.QuoteTrack("#arguments.obedata.room_data.resort_type#",
									 "#arguments.obedata.room_data.resort#",
									 "#arguments.obedata.room_data.Number_Of_Nights#",
									 arguments.obedata.email_campaign_id);
			}
			
		}//end try
		catch( Any e ){
			getPlugin("logger").logError("fncAvailabilityTrackingRoutines.",e);
		}			
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncReinitSSGStruct" access="private" returntype="void" hint="Reinitialize the SSG Data." output="false">
		<cfargument name="obedata" type="struct" required="true">
		<cfscript>
		arguments.obedata.ssg_data.authorized = false;
		arguments.obedata.ssg_data.total_before_discount = 0;
		arguments.obedata.ssg_data.balance_before_discount = 0;
		arguments.obedata.ssg_data.points_applied = 0;
		arguments.obedata.ssg_data.discount = 0;
		arguments.obedata.ssg_data.member_fname = "";
		arguments.obedata.ssg_data.member_lname = "";
		arguments.obedata.ssg_data.member_email = "";
		arguments.obedata.ssg_data.member_id = 0;
		arguments.obedata.ssg_data.member_points = 0;
		arguments.obedata.ssg_data.booked = false;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="reinitUserDataOnly" access="private" returntype="void" hint="Reinit user data.">
		<cfargument name="obedata" required="true" type="struct">
		<cfscript>
		/******************************************
		Initialize Global Variables
		/******************************************/
		arguments.obedata.AvailabilityID = 0;
		arguments.obedata.ThreadID = 0;
		arguments.obedata.PersonalInfoFilled = false;
		arguments.obedata.qLandAvailability = "";
		arguments.obedata.qAirAVailability = "";		
		arguments.obedata.hostname = "http://" & cgi.HTTP_HOST;
		arguments.obedata.FormSubmitAddress = "https://obeta.sandals.com/index.cfm";
		arguments.obedata.brand = "sandals";
		//Get Environment		
		if ( getSetting("ENVIRONMENT") eq "DEVELOPMENT" )
			arguments.obedata.FormSubmitAddress = "index.cfm";	
		/******************************************
		Initialize MENU Data
		/******************************************/
		arguments.obedata.menu_data.step1 = true;
		arguments.obedata.menu_data.step2 = false;
		arguments.obedata.menu_data.step3 = false;
		arguments.obedata.menu_data.step4 = false;
		arguments.obedata.menu_data.currentStep = "STEP1";
		/******************************************
		Initialize AIR Data
		/******************************************/
		arguments.obedata.air_data = fncReinitAirStruct();
		/******************************************
		Initialize SSG Data
		/******************************************/
		arguments.obedata.ssg_data.authorized = false;
		arguments.obedata.ssg_data.total_before_discount = 0;
		arguments.obedata.ssg_data.balance_before_discount = 0;
		arguments.obedata.ssg_data.points_accrued = 0;
		arguments.obedata.ssg_data.points_applied = 0;
		arguments.obedata.ssg_data.signet_apply = "N";
		arguments.obedata.ssg_data.signet_gain = "N";
		arguments.obedata.ssg_data.discount = 0;
		arguments.obedata.ssg_data.member_fname = "";
		arguments.obedata.ssg_data.member_lname = "";
		arguments.obedata.ssg_data.member_email = "";
		arguments.obedata.ssg_data.member_id = 0;
		arguments.obedata.ssg_data.member_points = 0;
		arguments.obedata.ssg_data.booked = false;	
		/******************************************
		Availability Variables
		/******************************************/
		arguments.obedata.room_data.resort = "";
		arguments.obedata.room_data.resort_country_code = "";
		arguments.obedata.room_data.resort_name = "";
		arguments.obedata.room_data.resort_type = "";
		arguments.obedata.room_data.resort_description = "";
		arguments.obedata.room_data.adults = 2;
		arguments.obedata.room_data.Children = 0;
		arguments.obedata.room_data.landChildren = 0;
		arguments.obedata.room_data.infants = 0;
		arguments.obedata.room_data.number_of_nights = 7;
		arguments.obedata.room_data.check_in_date = "#dateformat(dateAdd("d",+5,now()),"MM/DD/YYYY")#";
		arguments.obedata.room_data.departure_date = DateAdd("d",arguments.obedata.room_data.number_of_nights, arguments.obedata.room_data.check_in_date);
		arguments.obedata.room_data.originGateway = "";
		arguments.obedata.room_data.departure_country = "";
		arguments.obedata.room_data.departure_state = "";
		arguments.obedata.room_data.departure_gateway = "";
		arguments.obedata.room_data.departure_city = "";
		arguments.obedata.room_data.rooms = 1;		
		/******************************************
		Choosen Room Variables
		/******************************************/
		arguments.obedata.room_data.rpPlan = "EP";
		arguments.obedata.room_data.savings = 0;
		arguments.obedata.room_data.room_category = "";
		arguments.obedata.room_data.room_description = "";
		arguments.obedata.room_data.adultrate = 0;
		arguments.obedata.room_data.childrate = 0;
		arguments.obedata.room_data.room_webDescription = "";
		arguments.obedata.room_data.promo_description = "";
		arguments.obedata.room_data.promo_id = 0;	
		/******************************************
		Total Variables
		/******************************************/
		arguments.obedata.room_data.total_display = 0;
		arguments.obedata.room_data.room_total = 0;
		arguments.obedata.room_data.room_total_base = 0;
		arguments.obedata.room_data.amount_to_charge = 0;
		arguments.obedata.room_data.hold_Option = "FULL";
		arguments.obedata.room_data.balance = 0;
		arguments.obedata.room_data.balance_due_date = "";
		arguments.obedata.room_data.deposit_Due_Date = "";
		arguments.obedata.room_data.deposit_due_amount = 0;
		arguments.obedata.room_data.deposit_amount_due_at_booking = 0;
		/******************************************
		Promo Code Variables
		/******************************************/
		arguments.obedata.room_data.promo_code = "";
		arguments.obedata.room_data.promo_code_discount = 0;
		arguments.obedata.room_data.promo_code_id = 0;
		arguments.obedata.room_data.promo_code_description = "";
		arguments.obedata.room_data.promo_code_valid = false;		 
		/******************************************
		Insurance Variables
		/******************************************/
		arguments.obedata.room_data.insurance = false;
		arguments.obedata.room_data.insurance_amount = 0;
		arguments.obedata.room_data.insurance_p_res_id = 0;
		arguments.obedata.room_data.insurance_p_sd_id = 0;				
		/******************************************
		Billing Variables
		/******************************************/
		arguments.obedata.room_data.cc_number = 0;
		arguments.obedata.room_data.cc_type = "";
		arguments.obedata.room_data.cc_ccvid = 0;
		arguments.obedata.room_data.cc_expirationMonth = "";
		arguments.obedata.room_data.cc_expirationYear = "";
		arguments.obedata.room_data.cc_address = "";
		arguments.obedata.room_data.cc_state = "";
		arguments.obedata.room_data.cc_zip = "";
		arguments.obedata.room_data.cc_city = "";
		arguments.obedata.room_data.cc_country = "";
		/******************************************
		Info Variables
		/******************************************/
		arguments.obedata.room_data.wedding_planning = false;		
		/******************************************
		Booking Variables
		/******************************************/
		arguments.obedata.room_data.Booking_Number = 0;
		arguments.obedata.room_data.Confirmation_Number = 0;
		arguments.obedata.air_data.PNRRecordLocator = "";
		/******************************************
		Guest Information Variables
		/******************************************/
		arguments.obedata.room_data.adult_list = arrayNew(2);
		arguments.obedata.room_data.infant_list = arrayNew(2);
		arguments.obedata.room_data.child_list = arrayNew(2);
		arguments.obedata.room_data.City = "";
		arguments.obedata.room_data.Address = "";
		arguments.obedata.room_data.Country = "";
		arguments.obedata.room_data.Fax = "";
		arguments.obedata.room_data.Email = "";
		arguments.obedata.room_data.DOB = "";
		arguments.obedata.room_data.age = 0;
		arguments.obedata.room_data.FirstName = "";
		arguments.obedata.room_data.LastName = "";
		arguments.obedata.room_data.MiddleName = "";
		arguments.obedata.room_data.Title = "";
		arguments.obedata.room_data.Phone = "";
		arguments.obedata.room_data.State = "";
		arguments.obedata.room_data.Zip = "";			
		arguments.obedata.room_data.comments = "";	
		/******************************************
		Initialize the first adult array
		/******************************************/
		for (i=1; i lte 5; i=i+1)
			arguments.obedata.room_data.adult_list[1][i] = "";
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="initUser" access="private" returntype="void" hint="Initialize the user's data sectors">
		<cfscript>			
		//Obedata Struct
		var obedata = structnew();
		var i = 0;
		//Session Authorized Check Flag
		session.TASAuthorized = false;			
		//Call to reinit user
		reinitUserDataOnly(obedata);
		/******************************************
		 Initialize the Travel Agency data  
		/******************************************/
		obedata.ta_info.Authorized = false;
		obedata.ta_info.IATA = "";
		obedata.ta_info.Email = "";
		obedata.ta_info.TAAgencyID = 0;
		obedata.ta_info.MasterAgencyID = 0;
		obedata.ta_info.Agency = "";
		obedata.ta_info.Phone = "";
		obedata.ta_info.address = "";
		obedata.ta_info.city = "";
		obedata.ta_info.state = "";
		obedata.ta_info.zip = "";
		obedata.ta_info.country = "";
		obedata.ta_info.referralID = 0;
		obedata.ta_info.first_name = "";
		obedata.ta_info.last_name = "";
		obedata.ta_info.DemoAccount = false;
		obedata.ta_info.isSandalsFloor = false;
		obedata.ta_info.qTravelAgents = queryNew("");
		obedata.ta_info.TAAgentID = 0;
		//Set the obedata in the request collection.
		setValue("obedata",obedata);
		//Save the WDDX Packet
		fncSaveObeData(obedata);
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncBuildTraveleresQuery" access="private" hint="This function will build a query of all travelers and sort it by traveler Type"	returntype="struct">
	<cfscript>
		//Init strcut for return --->
		var ThisReturn = StructNew();
		var obedata = getValue("obedata");
		var UserInfoQry = "";
		var Age = 0;
		var i = 0;
		var j = 0;
		ThisReturn.Results = "";
		ThisReturn.Error = 0;
		ThisReturn.ErrorMessage = "";	
		try{
			//<!--- Get User Info from client variables, and create a query --->
			UserInfoQry = QueryNew("Title, First_Name, last_name, age, type");
			QueryAddrow(UserInfoQry);
			QuerySetCell(UserInfoQry,"Title", obedata.room_data.Title);
			QuerySetCell(UserInfoQry,"first_name", obedata.room_data.FirstName);
			QuerySetCell(UserInfoQry,"Last_name", obedata.room_data.LastName);
			QuerySetCell(UserInfoQry,"age", obedata.room_data.age);
			//QuerySetCell(UserInfoQry,"dob", obedata.room_data.DOB);
			QuerySetCell(UserInfoQry,"type", "ADT");			
			// loop through adult list andd add them to query 
			for (i = 1; i lte ArrayLen(obedata.room_data.adult_list); i = i + 1){
				QueryAddrow(UserInfoQry);
				QuerySetCell(UserInfoQry,"Title", obedata.room_data.adult_list[i][1]);
				QuerySetCell(UserInfoQry,"first_name", obedata.room_data.adult_list[i][2]);
				QuerySetCell(UserInfoQry,"Last_name", obedata.room_data.adult_list[i][4]);
				QuerySetCell(UserInfoQry,"age", obedata.room_data.adult_list[i][5]);
				//QuerySetCell(UserInfoQry,"dob", obedata.room_data.adult_list[i][5]);
				QuerySetCell(UserInfoQry,"type", "ADT");
			}//for adult list		
			for (j = 1; j lte ArrayLen( obedata.room_data.child_list); j = j + 1){
				QueryAddrow(UserInfoQry);
				QuerySetCell(UserInfoQry,"Title", obedata.room_data.child_list[j][1]);
				QuerySetCell(UserInfoQry,"first_name", obedata.room_data.child_list[j][2]);
				QuerySetCell(UserInfoQry,"Last_name", obedata.room_data.child_list[j][4]);
				QuerySetCell(UserInfoQry,"age", obedata.room_data.child_list[j][5]);
				//QuerySetCell(UserInfoQry,"dob", obedata.room_data.child_list[j][5]);
				// Get this child age			
				age = obedata.room_data.child_list[j][5];			
				if (age gte 12)
					QuerySetCell(UserInfoQry,"type", "ADT");
				else if (Age gte 2)
					QuerySetCell(UserInfoQry,"type", "CHD");
				else
					if (evaluate("obedata.room_data.Infant_#j#") is "YES")
						QuerySetCell(UserInfoQry,"type", "INF");
					else{
						QuerySetCell(UserInfoQry,"type", "CHD");
					}
			}//for child list					
		} //END OF TRY
		catch (Any Exception){
			ThisReturn.Error = 1;
			ThisReturn.ErrorMessage = "#Exception.Message#<br>#Exception.Detail#";
			return ThisReturn;
		} //END OF CATCH 		
	</cfscript>
	<!--- Select Users --->
	<cfquery name="ThisReturn.Results" dbtype="query">
		SELECT * from UserInfoQry order by Type
	</cfquery>	
	<cfreturn ThisReturn>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncReinitAirStruct" access="private" returntype="struct" hint="Initialize the air_data struct." output="false">
		<cfscript>
			var air_data = structnew();
			air_data.FlightGroupID = 0;
			air_data.FareSelectedHoldOption = "NO";
			air_data.FareSelectedType = "";
			air_data.air_total = 0;
			air_data.air_warning = 0;
			air_data.air_deposit = 0;
			air_data.air_included = false;
			air_data.arrival_gateway = "";
			air_data.arrival_city = "";
			air_data.search_by = "Y";
			air_data.arrival_date = "";
			air_data.return_date = "";
			air_data.infantsInLap = 0;
			air_data.adultPassengers = 0;
			air_data.childrenPassengers = 0;
			air_data.GDS = "Amadeus";
			air_data.gdsAdapterType = "ValuePricer";
			air_data.itinerary_id = 0;
			air_data.Carriers = "";
			air_data.IncludeExcludeAirLines = "E";
			return air_data;
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncSendEmailAirErrors" access="private" returntype="void" hint="Send Emails for Air Errors">
		<!--- ************************************************************* --->
		<cfargument name="FareInfoQry" 		type="query" 	required="yes">
		<cfargument name="UsersInfoQry" 		type="query" 	required="yes">
		<cfargument name="BookingNumber" 		type="string" 	required="yes">
		<!--- ************************************************************* --->
		<cftry>
			<cfmail from="info@sandals.com" 
					to="#getSetting("AirEmailErrorsMain")#" 
					cc="#getSetting("AirEmailErrors")#" 
					bcc="#getSetting("bugemails")#" 
					subject="Booking Number #Arguments.BookingNumber# Missing Air Booking" 
					type="html" timeout="10">
				<cfinclude template="../includes/Emails/airErrors.cfm">				
			</cfmail>			
			<cfcatch type="any">
				<cfset getPlugin("logger").logError("fncSendEmailAirErrors: #cfcatch.Message#<br>#cfcatch.Detail#", cfcatch)>
			</cfcatch>
		</cftry>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncSendMailConfirmations" returntype="void" access="private" hint="Send Email Booking Confirmations">		
		<!--- ************************************************************* --->
		<cfargument name="pNameType" 		required="yes" 	type="string">
		<cfargument name="taEmail"   		required="yes" 	type="string">
		<!--- ************************************************************* --->			
		<!--- Get Reference --->
		<cfset var obedata = getValue("obedata")>
		<cfset var summaryOutBoundFlights = "">
		<cfset var summaryInBoundFlights = "" >
		<!--- Get Room Category Information For Summary --->
		<cfset var rtn_category_info = getPlugin("webservices").getWSObj("obe").fncGetRoomCategories(obedata.room_data.resort, obedata.room_data.ROOM_CATEGORY)>
		
		<!---Check for Air, and get Query of Queries for Summary --->
		<cfif obedata.air_Data.air_included is "YES" >
			<cfset fncSummaryAirQueries()>
			<cfset summaryOutBoundFlights = getValue("summaryOutBoundFlights")>
			<cfset summaryInBoundFlights = getValue("summaryInBoundFlights")>
		</cfif>
		<!--- Send Direct Consumer Email --->
		<cfif arguments.pNameType is NOT "T">
			<cftry>
				<cfmail to="#obedata.room_data.email#" 
						from="info@sandals.com" 
						type="html" 
						subject="Sandals Booking Confirmation" 
						timeout="15">
					<cfinclude template="../includes/Emails/bookingConfirmations.cfm">
				</cfmail>
				<cfcatch type="any">
					<cfset getPlugin("logger").logError("fncSendMailConfirmations Sending Travel Agents' client Email.", cfcatch, arguments)>
				</cfcatch>
			</cftry>
		</cfif>
		<!--- Cobrand Email Confiramtions --->
		<cfif arguments.pNameType is "T" and len(arguments.taEmail) gt 0>
			<cftry>
				<cfmail to="#Trim(arguments.taEmail)#" 
						from="info@sandals.com" 
						type="html" 
						subject="Sandals & Beaches Booking Confirmation" 
						timeout="15">
					<cfinclude template="../includes/Emails/taConfirmations.cfm">
				</cfmail>	
				<cfcatch type="any">
					<cfset getPlugin("logger").logError("fncSendMailConfirmations Sending Travel Agent Email.", cfcatch, arguments)>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->	
	
	<!--- ************************************************************* --->
	<cffunction name="fncSendWeddingEmail" returntype="void" access="private" hint="Send Email Confirmations For Wedding">		
	<!--- ************************************************************* --->
		<cfset var obedata = getValue("obedata")>
		<cfmail to="#getSetting("WeddingEmailsMain")#" bcc="#getSetting("bugemails")#" from="info@sandals.com" subject="Online Booking - Wedding Planning" timeout="10" type="html">	
			<cfinclude template="../includes/Emails/weddingConfirmations.cfm">
		</cfmail>				
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncEmailComments" returntype="void"  access="private" hint="This function emails the comments to the ESM department.">		
		<cfset var obedata = getValue("obedata")>
		<cfmail to="esm@uvi.sandals.com" from="info@sandals.com" bcc="#getSetting("bugemails")#" subject="Online Booking Engine Comments,Questions,Concerns" timeout="10" type="html">
			<cfinclude template="../includes/Emails/commentsEmail.cfm">	
		</cfmail>		
	<!--- ************************************************************* --->		
	</cffunction>
	<!--- ************************************************************* --->	

	<!--- ************************************************************* --->
	<cffunction name="fncGetInsurance" access="private" returntype="void" hint="Get an availability's request insurance information">
		<cfargument name="obedata" type="struct" required="true">
		<cfscript>
		var passengers = 0;
		var obeWS = getPlugin("webservices").getWSObj("obe");
		var rtninsuranceStruct = "";
		try{
			//Insurance Module
			passengers = arguments.obedata.room_data.adults + arguments.obedata.room_data.children;
			//quote insurance
			rtninsuranceStruct = obeWS.fncGetInsurance(arguments.obedata.room_data.resort, 
												     arguments.obedata.room_data.check_in_date, passengers);
			if ( rtninsuranceStruct.error ){
				getPlugin("messagebox").setMessage("error","There was a problem retrieving insurance information about the availability. Below you will be able to see the diagnostic information about this error. If there are further instructions to follow in order to correct this error, please follow them. If not, try again and if the problem persists please contact us at 1-800-SANDALS in order to correct the problem.  <br><br><strong>Diagnostic Data:</strong> <br>#rtninsuranceStruct.errorMessage#");
				getPlugin("logger").logError("Getting Insurance",rtninsuranceStruct);
				setNextEvent("ehOBE.dspHome");
			} //end of if insurnace error
			/*Check for pAmount to be numeric.
			if ( not isNumeric(rtninsuranceStruct.results.pAmount) ){
				getPlugin("messagebox").setMessage("error","There was a problem retrieving insurance information about the availability. If there are further instructions to follow in order to correct this error, please follow them. If not, try again and if the problem persists please contact us at 1-800-SANDALS in order to correct the problem.");
				setNextEvent("ehOBE.dspHome");
			}*/
			//Save Insurance Information
			arguments.obedata.room_data.insurance_amount = rtninsuranceStruct.results.pAmount;
			arguments.obedata.room_data.insurance_p_res_id = rtninsuranceStruct.results.pResId;
			arguments.obedata.room_data.insurance_p_sd_id = rtninsuranceStruct.results.pSDid;
			}//end try insurance
		catch(Any e){
			getPlugin("messagebox").setMessage("error","There was a problem retrieving insurance information about the availability. Below you will be able to see the diagnostic information about this error. If there are further instructions to follow in order to correct this error, please follow them. If not, try again and if the problem persists please contact us at 1-800-SANDALS in order to correct the problem.  <br><br><strong>Diagnostic Data:</strong> <br>#e.detail#<br>#e.Message#");
			getPlugin("logger").logError("Getting Insurance",e);
			setNextEvent("ehOBE.dspHome");
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncPrepareNewAvailability" access="private" returntype="void" hint="Prepare a new availabilty request.">
		<cfargument name="obedata" required="true" type="struct">
		<cfscript>
		arguments.obedata.room_data.savings = 0;
		arguments.obedata.room_data.room_category = "";
		arguments.obedata.room_data.room_description = "";
		arguments.obedata.room_data.adultrate = 0;
		arguments.obedata.room_data.childrate = 0;
		arguments.obedata.room_data.room_webDescription = "";		
		arguments.obedata.room_data.room_total = 0;
		arguments.obedata.room_data.total_display = 0;			
		arguments.obedata.room_data.adult_list = ArrayNew(2);
		arguments.obedata.room_data.child_list = ArrayNew(2);
		arguments.obedata.room_data.infant_list = ArrayNew(2);
		//New Sets with empty values, to keep consistent look
		arguments.obedata.room_data.promo_description = "";
		arguments.obedata.room_data.promo_id = 0;
		obedata.air_data.FlightGroupID = 0;
		//arguments.obedata.air_data.FareGroupID = 0;
		arguments.obedata.air_data.air_total = 0;		
		arguments.obedata.menu_data.step3 = false;
		arguments.obedata.menu_data.step4 = false;
		arguments.obedata.ssg_data.points_accrued = 0;
		arguments.obedata.ssg_data.points_applied = 0;
		arguments.obedata.ssg_data.discount = 0;
		arguments.obedata.ssg_data.total_before_discount = 0;			
		arguments.obedata.ssg_data.balance_before_discount = 0;
		/******************************************
		Set Adult Arrays
		/******************************************/
		if ( arguments.obedata.room_data.adults gt 1){
			arguments.obedata.room_data.adult_list = ArrayNew(2);
			//Initiate the Arrays
			for ( i=1; i lte (arguments.obedata.room_data.adults-1) ; i = i + 1){
				 arguments.obedata.room_data.adult_list[i][1] = "";
				 arguments.obedata.room_data.adult_list[i][2] = "";
				 arguments.obedata.room_data.adult_list[i][3] = "";
				 arguments.obedata.room_data.adult_list[i][4] = "";
				 arguments.obedata.room_data.adult_list[i][5] = "";
			}
		}
		/******************************************
		Set Children Arrays
		/******************************************/
		if ( arguments.obedata.room_data.children gt 0){
			arguments.obedata.room_data.child_list = ArrayNew(2);
			//Initiate the Arrays
			for ( i=1; i lte (arguments.obedata.room_data.children) ; i = i + 1){
				 arguments.obedata.room_data.child_list[i][1] = "";
				 arguments.obedata.room_data.child_list[i][2] = "";
				 arguments.obedata.room_data.child_list[i][3] = "";
				 arguments.obedata.room_data.child_list[i][4] = "";
				 arguments.obedata.room_data.child_list[i][5] = "";
			}
		}
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncDoPollingRequest" access="private" returntype="void" hint="Run the Polling Procedures" output="false">
		<!--- ************************************************************* --->
		<cfargument name="obedata" type="struct" required="true">
		<!--- ************************************************************* --->
		<cfscript>	
		//Init Variables	
		var rtnStruct = "";
		var ssgFlag = "Y";
		var airFlag = "N";
		var environmentFlag = "P";
		
		//Environment Check
		if ( findnocase("DEV", getSetting("ENVIRONMENT") ) )
			environmentFlag = "D";
	
		//SSG Flag Determination
		if ( arguments.obedata.ssg_data.member_id is 0 )
			ssgFlag = "N"; //NOT SSG MEMBER

		//Air Flag
		if ( obedata.air_data.air_included eq true)
			airFlag = "Y";
		
		/******************************************
		Clean Room Data information. For New Availability.
		/******************************************/
		fncPrepareNewAvailability(arguments.obedata);
			
		//Create A new Polling Request.
		rtnStruct = obeWS.fncCreatePollingRequest(arguments.obedata.AvailabilityID,
												arguments.obedata.room_data.adults,
												arguments.obedata.room_data.landChildren,
												arguments.obedata.room_data.resort,
												arguments.obedata.room_data.infants,
												arguments.obedata.room_data.number_of_nights,
												arguments.obedata.room_data.check_in_date,
												arguments.obedata.room_data.departure_gateway,
												"#arguments.obedata.air_data.arrival_gateway#",
												1, //Rooms
												ssgFlag,
												airFlag,
												"#arguments.obedata.air_data.search_by#",
												arguments.obedata.air_data.childrenPassengers,
												arguments.obedata.air_data.infantsInLap,
												"#arguments.obedata.air_data.GDS#",
												"#getValue('ObeVariables').GDS_Adapter_Type#",
												"#arguments.obedata.air_data.Carriers#",
												"#arguments.obedata.air_data.IncludeExcludeAirLines#",
												arguments.obedata.air_data.adultPassengers,
												"#environmentFlag#");
		if (rtnStruct.error){
			//Log Error
			getPlugin("logger").logError("Error Creating Polling Request", structnew(), rtnStruct);
			getPlugin("messagebox").setMessage("error","#getSetting("LandAvailability_Error")#");
			setNextEvent("ehOBE.dspHome");
		}
		
		/******************************************/
		//Call Tracking Routines
		/******************************************/
		fncAvailabilityTrackingRoutines(arguments.obedata);		
		/******************************************
		Insurance Module
		/******************************************/
		fncGetInsurance(arguments.obedata);
		//Results Successfull set the ThreadID
		arguments.obedata.ThreadID = rtnStruct.results;
		//Start Thread Counter
		arguments.obedata.ThreadCounter = getTickCount();
		//WDDX & Save the Structures
		fncSaveObeData(arguments.obedata);		
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->
		
	<!--- ************************************************************* --->
	<cffunction name="fncGetUserSelectedFare" access="package" returntype="struct" hint="This function will rreturn query info of the selected Fare">
		<cfset var obedata = getValue("obedata")>
		<cfset var rtnStruct = structNew()>
		<cfset rtnStruct.error =0>
		<cfset rtnStruct.errorMessage ="">
		<cfset rtnStruct.Results = queryNew("")>
		<cftry>
			<cfquery name="rtnStruct.Results" dbtype="query">
				SELECT * FROM obedata.qAirAvailability 
				WHERE (Flight_GROUP_ID = #obedata.AIR_DATA.FlightGroupID#)
				ORDER BY INBOUND_OUTBOUND DESC, FLIGHT_ORDER;
			</cfquery>
			<cfcatch type="any">
				<cfset rtnStruct.error = 1>
				<cfset rtnStruct.errorMessage = "An Error has occurred retrieving selected fare information.">
			</cfcatch>
		</cftry>
		<!--- Return Results --->
		<cfreturn rtnStruct> 
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="fncLoginTA" access="private" returntype="void" output="false">
		<cfscript>
		var obedata = getValue("obedata");
		//Set logged in the Session
		session.TASAuthorized = true;
		//Set the ta information
		obedata.ta_info.Authorized = true;
		obedata.ta_info.IATA = getValue("IATA");
		obedata.ta_info.Email= getValue("TAEmail");
		obedata.ta_info.TAAgencyID = getValue("TAAgencyID");
		obedata.ta_info.Masteragencyid = getValue("MasterAgencyID");
		obedata.ta_info.Agency = getValue("Agency");
		obedata.ta_info.Phone = getValue("TAPhone");
		obedata.ta_info.address = getValue("TAAddess");
		obedata.ta_info.city= getValue("TACity");
		obedata.ta_info.state = getValue("TAstate");
		obedata.ta_info.zip = getValue("TAzip");
		obedata.ta_info.country = getValue("TAcountry");
		obedata.ta_info.referralID = getValue("TAWebID");
		obedata.ta_info.first_name = getValue("TAFirstName");
		obedata.ta_info.last_name = getValue("TALastName");
		obedata.ta_info.DemoAccount = getValue("DemoAccount",false);
		if (obedata.ta_info.referralID EQ "108844")
			obedata.ta_info.isSandalsFloor = true;
		//serialize obedata
		fncSaveObedata(obedata);
		//Relocate to start fresh
		setNextEvent("ehOBE.dspHome");
		</cfscript>	
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>