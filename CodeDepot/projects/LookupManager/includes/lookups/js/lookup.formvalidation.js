/*
 * jQuery Form Validation plug-in version 1.1.5
 * Last Update : July 13, 2008
 * New features:
 * onError event
 * Add call back support - callback function is called when validation is error, return true form will be submited otherwise not.
 * Error list in the alert msg
 * Alias to field name
 * Select diff html attributes for validation rules instead off using custom html attributes
 *
 * Bug Fixed:
 * now support radio buttons
 * defval to work with LabelIn plugin
 * now support textarea
 *
 * Copyright (c) 2007 E-wave web design
 *   http://www.ewave.com.au/
 *
 * Licensed under the GPL license:
 *   http://www.gnu.org/licenses/gpl.html
 *
 * @requires jQuery v 1.2.1 or later
 * @name	formValidation
 * @usage		$('#form1').formValidation({
 *		newmask : /[0-9]{1}-[0-9]{1}/,	// 1-1
 *		err_class : "invalidInput"
 * });
 * 
 * HTML
 * <form id="form1">
 * <input id="input1" type="text" required="true" mask="email"></input>
 * <input id="input2" type="text" required="true" mask="email" equal="input2"></input>
 * <input type="submit" value="Submit>
 * </form>
 *
 * Description
 * Validate form fields accordiing to 4 keys
 * required - check that text field is not empty. checkbox checked, and select val is not empty
 * equal - checks that field value equal to another field with this id
 * mask - compre value to mask using reg exp
 * defval - ignore default value
 *
 * Prevent Submit and Display alert when not validate and change class of field to invalid class
 * 
 * @param String version
 * 	Plugin Version	
 * 
 * @param String err_class
 * 	invalid input class name	
 * 
 * @param String displayAlert
 * 	display alert when submit form is invalid	
 *  default true
 * 
 * @param String err_message
 * 	alert message	
 * 
 * @param reg-exp email
 * 	email pattern
 * 
 * @param reg-exp domain
 * 	domain pattern
 * 
 * @param reg-exp phone
 * 	phone pattern
 * 
 * @param reg-exp zip
 * 	zip pattern
 * 
 * @param reg-exp numeric
 * 	numeric pattern
 * 
 * @param reg-exp image
 * 	image file name pattern
 * 
 * @param reg-exp pdf
 * 	pdf file name pattern
 * 
 * @param alias, required, mask, equal, defval 
 * 	validation rules map to input attributes 
 * 
 */
if (!window.jQuery) {
	throw("jQuery must be referenced before using formValidation");
} else {
	
	(function() { 
		jQuery.fn.formValidation = function(settings, err_msgs) {
	
		var iForm = this;
		var err_list = '';
	
		settings = jQuery.extend({
			version				: '1.1.2',
			email					:	/^([\w.])+\@(([\w])+\.)[a-zA-Z0-9]{2,}/,
			domain				:	/^(http:\/\/)([\w]+\.){1,}[A-Z]{2,4}\b/gi,
			phone					:	/^\+[0-9]{1,3}\.[1-9]{1,2}\.[0-9]{6,}$/gi,
			zip						:	/^[0-9]{4,}$/gi,
			numeric				:	/^[0-9]+$/gi,
			image					:	/[\w]+\.(gif|jpg|bmp|png|jpeg)$/gi,
			ewvt					:	/[\w]+\.(htm|html|php|txt)$/gi,
			media					:	/[\w]+\.(avi|mov|mpeg|wmv)$/gi,
			pdf						:	/[\w]+\.(pdf)$/gi,
			enable				: false,
			err_class			: "invalidInput",
			err_list			: false,
			alias					:	'name',
			required			: 'required',
			mask					: 'mask',
			equal					: 'equal',
			defval				: 'defval',
			callback			:	'',
			err_message		: "Please fill all required fields! (Marked with red background colour)\n",
			display_alert	: true	//onsubmit if invalid form display an error message
		}, settings);
		
		err_msgs = jQuery.extend({ 
			required	: 'is required',
			mask			: 'Invalid',
			equal			: 'is not equal to'
		}, err_msgs);
		
		return iForm.submit( function () {
				settings['enable'] = true;
				err_list = '';
				var frm = true;
				$(this).find('*').filter("input, select, textarea").each(function() {
					ret = isValid($(this));
					if (!ret)
						frm = ret;
				});
				
				if (frm && (typeof settings['callback'] == 'string' && eval('typeof ' + settings['callback']) == 'function')) // form validation ok and callback function defined
					frm = eval(settings['callback'] + '()'); //call external validation function
				else if (settings['display_alert'])	// error validation and display alert on
						alert(settings['err_message'] + err_list);	// display message
						
				return frm;
			}).find('*').filter("input, select, textarea").each(function() {
			$(this).click(function() {
				isValid($(this));
			}).change(function() {
				isValid($(this));
			}).keyup(function() {
				isValid($(this));
			}).focus(function() {
				isValid($(this));
			}).blur(function() {
				isValid($(this));
			});
		});
			
		function isValid(obj) { // check if field is valid
			if (!settings['enable'])
				return true;
				
			if (required(obj) && mask(obj) && equal(obj)) {
				obj.removeClass(settings['err_class']);
				return true;
			} else {
				obj.addClass(settings['err_class']);
				return false;
			}
		}
		//field is required
		function required(obj) {						
			if (!(obj.attr(settings['required']) == "true"))	//if not required return true
				return true;
	
			if(obj.is("input[@type=checkbox]") || obj.is('input[@type=radio]')) {		//if checkbox and checked	
				if (obj.attr('checked'))
					return true;
			} else if((obj.is("input") || obj.is("select") || obj.is("textarea")) && (!obj.is("button"))) // if not empty
				if (obj.val() != '' && (!(defval(obj))))
					return true;
			
	
	
			if (settings['err_list'])	
				err_list += '- "' + obj.attr(settings['alias']) + '" ' + err_msgs['required'] + '\n';
				
			return false;
		}
		//compare field to mask provided in the extend array
		function mask(obj) { 
			tname = obj.attr('mask');	//read mask name from input field
			if (tname == undefined || obj.val() == '')
				return true;
	
			tmask = settings[obj.attr(settings['mask'])];	// get mask pattern from settings
			
			ret = tmask.test(obj.val());			//test reg exp
			ret1 = tmask.exec(obj.val());		
			if (ret)
				return true;
	
			if (settings['err_list'])
				err_list += '- ' + err_msgs['mask'] + ' "' + obj.attr(settings['alias']) + '"\n';
			
			return false;				
		}
		//copare field to another field read from the equal attribute
		function equal(obj) { 
			tname = obj.attr(settings['equal']);		//get comparison field
			tval = $('#'+tname).val();
			
			if (tname == undefined)
				return true;
			
			if (tval == obj.val())
				return true;
			
			if (settings['err_list'])	
				err_list += '- "' + obj.attr(settings['alias']) + '" ' + err_msgs['equal'] + ' ' + $('#'+tname).attr('alias') + '\n';
			return false;
		}
		//compare field with defval attr, make sure that val was altered
		function defval(obj) { 
			tdefval = obj.attr(settings['defval']);		//get comparison field
			tval = obj.val();
			
			if (tdefval == undefined)
				return false;
			
			if (tval != tdefval)
				return false;
	
			return true;
		}
	}
	})(jQuery); 
}