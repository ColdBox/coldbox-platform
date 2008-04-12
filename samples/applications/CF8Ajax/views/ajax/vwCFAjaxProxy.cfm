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

  // Use an asynchronous call to get the employees for the 
  // drop-down employee list from the ColdFusion server.
  var getEmployees = function(){
      // create an instance of the proxy. 
      var e = new cbProxy();
      // Setting a callback handler for the proxy automatically makes
      // the proxy's calls asynchronous.
      e.setCallbackHandler(populateEmployees);
      e.setErrorHandler(myErrorHandler);
  // The proxy getEmployees function represents the CFC
  // getEmployees function.
      e.getEmployees();
  }
  
  // Callback function to handle the results returned by the
  // getEmployees function and populate the drop-down list.
  var populateEmployees = function(res)
  {
      with(document.simpleAJAX){
          var option = new Option();
          option.text='Select Employee';
          option.value='0';
          employee.options[0] = option;
          for(i=0;i<res.DATA.length;i++){
              var option = new Option();
              option.text=res.DATA[i][res.COLUMNS.findIdx('FNAME')]
                  + ' ' + res.DATA[i][[res.COLUMNS.findIdx('LNAME')]];
              option.value=res.DATA[i][res.COLUMNS.findIdx('IDT')];
              employee.options[i+1] = option;
          }
      }    
  }

  // Use an asynchronous call to get the employee details.
  // The function is called when the user selects an employee.
  var getEmployeeDetails = function(id){
  	  document.getElementById('empData').innerHTML = 'Please wait! loading data...<br><br><img src="css/8-1.gif">';	
      var e = new cbProxy();
      e.setCallbackHandler(populateEmployeeDetails);
      e.setErrorHandler(myErrorHandler);
  // This time, pass the employee name to the getEmployees CFC
  // function.
      e.getEmployees(id);
  }
  // Callback function to display the results of the getEmployeeDetails
  // function.
  var populateEmployeeDetails = function(employee)
  {
      var eId = employee.DATA[0][0];
      var efname = employee.DATA[0][1];
      var elname = employee.DATA[0][2];

      document.getElementById('empData').innerHTML = 
      '<span style="width:100px">Employee Id:</span>' 
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
<h2>List of Employees:&nbsp;&nbsp;&nbsp;</h2>
<select name="employee" onChange="getEmployeeDetails(this.value)">
    <script language="javascript">
        getEmployees();
    </script>
</select>
<br><br>
<span id="empData"></span>
</form>

<p><br><br><br><br><br></p>

    
