//
//  Copyright © 2016 SPORT1 GmbH. All rights reserved.
//

import Mustache

class Mustache {
	class var defaultHtmlErrorPage:String {
		// TODO: add a nice html error page
		return "<html><head></head><body><h1>Error</h1></body></html>"
	}
	/*!
	Generate and return a mustache string with a given template name

	- parameter templateName: mustache template
	- parameter data:         array

	- returns: String
	*/
	class func render(_ templateName: String, data: [String : AnyObject]) -> String? {
		do {
			let template = try Template(named: templateName)
			// add localizer
			let localizer = StandardLibrary.Localizer(bundle: nil, table: nil)
			template.register(Box(localizer), forKey: "localize")
			
			let htmlContent = try template.render(Box(data))
			return htmlContent
		}
		catch {
			return nil
		}
	}
}
