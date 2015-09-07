//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This class is responsible for the first screen in the app (the Login screen).
//  It's possible to realize the login using Udacity credentials or through Facebook API
//  Also, it is possible to be redirected to a website for signing up

// problemas
// - muito codigo repetido
// - nao existe timeout para o caso de 100% packet loss
// -- entre mapview e listview
// -- os botoes adicionados no viewWillAppear
// -- duvida sobre como fazer bom uso da conexao de internet (talvez usando threads)
// - uma custom view poderia ser criada para loading screen
// - overwrite? no app pode fazer isso, mas nao achei nada na rubric nem na especificacao
// - mais informacao sobre as APIs (possiveis codigos de retorno, por exemplo, seriam interessantes
//
// - ERRO: AS LOADING SCREEN DEVEM SAIR QUANDO OCORRE ALGUM ERRO

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	// MARK: - Outlets

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginWithUdacityButton: UIButton!
	
	// MARK: - Class variables
	
	var loadingScreen: LoadingScreen!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		
		/* Configure the UI */
		self.configureUI()
		emailTextField.delegate = self
		passwordTextField.delegate = self
		
		/* Loading screen initialization */
		loadingScreen = LoadingScreen(view: self.view)
	}
	
	// MARK: - Actions
	
	/* Identifies which button was touched and selects the correct login method (Udacity or Facebook) */
	@IBAction func loginButtonTouch(sender: AnyObject) {
		
		loadingScreen.setActive(true)
		
		/* Hides keyboard */
		emailTextField.resignFirstResponder()
		passwordTextField.resignFirstResponder()
		
		/* Selecting the correct login method */
		if sender.tag == ButtonTags.UdacityLoginButtonTag {
			UdacityClient.sharedInstance().authenticateWithUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
				if success {
					self.loadingScreen.setActive(false)
					self.completeLogin()
				} else {
					self.displayError(errorString as? String)
				}
			}
		} else if sender.tag == ButtonTags.FacebookLoginButtonTag {
			// TODO: AUTHENTICATE WITH FACEBOOK
			//UdacityClient.sharedInstance().authenticateWithFacebook()
		} else {
			println("Unidentified button tag")
		}
	}
	
	/* Sign up button. Opens Udacity URL in Safari */
	@IBAction func signUpButtonTouch(sender: AnyObject) {
		let url = NSURL(string: UdacityClient.Constants.SignUpURL)
		UIApplication.sharedApplication().openURL(url!)
	}
	
	// MARK: - TextFieldDelegate methods
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - LoginViewController
	
	/* Login completed: sets loading screen not active and calls next view controller */
	func completeLogin() {
		dispatch_async(dispatch_get_main_queue(), {
			self.emailTextField.text = ""
			self.passwordTextField.text = ""
			let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OTMNavigationController") as! UINavigationController
			self.presentViewController(controller, animated: true, completion: nil)
		})
	}
	
	// MARK: - UI Helper Methods
	
	/* Displays error using alert controller */
	func displayError(errorString: String?) {
		loadingScreen.setActive(false)
		dispatch_async(dispatch_get_main_queue()) {
			if let errorString = errorString {
				let alertController = UIAlertController(title: "Login Failed", message: "An error has ocurred\n" + errorString, preferredStyle: .Alert)
				let DismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
				alertController.addAction(DismissAction)
				self.presentViewController(alertController, animated: true) {}
			}
		}
	}
	
	/* Activates (or deactivates) the loading screen */
//	func loadingScreenSetActive(active: Bool) {
//		dispatch_async(dispatch_get_main_queue()) {
//			// TODO: IMPLEMENT
//			// create activity indicator view
//			// - activity view should hide when stop
//			// change alpha of screen to 0.5
//			// - screen shouldn't be editable
//		}
//	}
	
	/* Performs some UI configuration */
	func configureUI() {
		
		/* Configure background gradient */
		self.view.backgroundColor = UIColor.clearColor()
		let colorTop = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0).CGColor
		let colorBottom = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0).CGColor
		var backgroundGradient = CAGradientLayer()
		backgroundGradient.colors = [colorTop, colorBottom]
		backgroundGradient.locations = [0.0, 1.0]
		backgroundGradient.frame = view.frame
		self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)
		
		/* Text fields text colors */
		emailTextField.textColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		passwordTextField.textColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		
		/* Configure Udacity login button */
		loginWithUdacityButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 17.0)
		loginWithUdacityButton.backgroundColor = UIColor(red: 1.0, green:0.4, blue:0.0, alpha: 1.0)
		loginWithUdacityButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
	}
}
