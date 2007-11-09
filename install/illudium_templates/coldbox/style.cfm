/* OVERALL APPLICATION LINKS */
body{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;	
	height: 100%;
}
hr{
	color: #232332;
}
/* Visual Button Links */
a:link, a:visited{
	font-weight:bold;
	text-decoration:none;
	color: blue;
}
a:hover{
	color: #E58108;
}

/* Tables */
legend{
	font-weight: bold;
}
fieldset{
	background-color: #f5f5f5;
	border: 1px solid #ddd;
	padding: 5px;
}
.tablelisting{
	font-size: 9px;
	border-bottom: 1px solid #cccccc;
}
.tablelisting tr.even{
	background-color: #EFF6FF;
}
.tablelisting tr:hover { background: #E8F2FE }
.tablelisting th {
  text-align: left;
  background-color: #F6F6F6;
  color: #000000;
  border: 1px solid #7D7D7D;
}
input[type=button], input[type=submit], input[type=reset] {
 background: #eee;
 color: #222;
 border: 1px outset #ccc;
 padding: .1em .5em;
 font-size: 12px;
}
input[type=button]:hover, input[type=submit]:hover, input[type=reset]:hover {
 background: #FFFFF0;
 border: 1px inset #ccc;
 cursor: hand;
}
input[type=button][disabled], input[type=submit][disabled],input[type=reset][disabled] {
 background: #f6f6f6;
 border-style: solid;
 color: #999;
}
input[type=text], input[type=password], input[type=checkbox], textarea, select { font-size:11px; border: 1px solid #d7d7d7 }
input[type=text], input[type=password], input[type=checkbox], select { padding: .20em .3em }
input[type=text]:focus, input[type=password]:focus, textarea:focus, input[type=checkbox]:focus, select:focus {
 border: 1px solid #886;
}
.formLayout label {
      float:left;
      color: #333366;
      text-align:right;
      font-weight:bold;
      font-size:11px;
      margin-right:8px;
      display:block;
      width:20em;
      line-height:1.5em;
      }
ul.formLayout {
      clear:both;
      float:left;
      list-style: none;
      padding:0;
      margin:8px 0;
      width:99%;
} 
ul.formLayout li {
     clear:both;
     color:#000;
     padding:0;
     margin:6px 0;
}