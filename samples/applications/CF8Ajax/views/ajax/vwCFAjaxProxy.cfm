<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	March 05 2008
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->

<!--- Declare the CF Ajax Proxy HERE --->
<cfajaxproxy cfc="#rc.locColdBoxProxy#" jsclassname="cbProxy">

<!--- JS --->
<script type="text/javascript">
  // Function to find the index in an array of the first entry 
  // with a specific value.
  // It is used to get the index of a column in the column list.
  Array.prototype.findIdx = function(value){
      for (var i=0; i < this.length; i++) {
          if (this[i] == value) {
              return i;
          }
      }
  }

  // Use an asynchronous call to get the Artists for the 
  // drop-down employee list from the ColdFusion server.
  var getArtists = function(){
      // create an instance of the proxy. 
      var e = new cbProxy();
      // Setting a callback handler for the proxy automatically makes
      // the proxy's calls asynchronous.
      e.setCallbackHandler(populateArtists);
      e.setErrorHandler(myErrorHandler);
  // The proxy getArtists function represents the CFC
  // getArtists function.
      e.getArtists();
  }
  
  // Callback function to handle the results returned by the
  // getArtists function and populate the drop-down list.
  var populateArtists = function(res)
  {
      with(document.simpleAJAX){
          var option = new Option();
          option.text='Select Artist';
          option.value='0';
          artist.options[0] = option;
          for(i=0;i<res.DATA.length;i++){
              var option = new Option();
              option.text=res.DATA[i][res.COLUMNS.findIdx('FIRSTNAME')]
                  + ' ' + res.DATA[i][[res.COLUMNS.findIdx('LASTNAME')]];
              option.value=res.DATA[i][res.COLUMNS.findIdx('ARTISTID')];
              artist.options[i+1] = option;
          }
      }    
  }

  // Use an asynchronous call to get the employee details.
  // The function is called when the user selects an employee.
  var getArtistDetails = function(id){
  	  document.getElementById('empData').innerHTML = 'Please wait! loading data...<br><br><img src="css/8-1.gif">';	
      var e = new cbProxy();
      e.setCallbackHandler(populateArtistDetails);
      e.setErrorHandler(myErrorHandler);
  // This time, pass the employee name to the getArtists CFC
  // function.
      e.getArtists(id);
  }
  // Callback function to display the results of the getEmployeeDetails
  // function.
  var populateArtistDetails = function(artist)
  {
      var eId = artist.DATA[0][0];
      var efname = artist.DATA[0][1];
      var elname = artist.DATA[0][2];

      document.getElementById('empData').innerHTML = 
      '<span style="width:100px">Artist ID:</span>' 
      + '<font color="green"><span align="left">' 
      + eId + '</font></span><br>' 
      + '<span style="width:100px">First Name:</span>' 
      + '<font color="green"><span align="left">' 
      + efname + '</font></span><br>' 
      + '<span style="width:100px">Last Name:</span>' 
      + '<font color="green"><span align="left">'     
      + elname + '</font></span><br>';
  }

  // Error handler for the asynchronous functions.
  var myErrorHandler = function(statusCode, statusMsg)
  {
      alert('Status: ' + statusCode + ', ' + statusMsg);
  }
  
</script>
<p>This form get's loaded with data from the coldboxproxy.</p>

<form name="simpleAJAX" method="get">
<h2>List of Artists:&nbsp;&nbsp;&nbsp;</h2>
<select name="artist" onChange="getArtistDetails(this.value)">
    <script language="javascript">
        getArtists();
    </script>
</select>
<br><br>
<span id="empData"></span>
</form>

<p><br><br><br><br><br></p>

    
