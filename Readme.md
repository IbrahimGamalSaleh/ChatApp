# ChatApp
is app to chat with your friends.
using firebase realtime database .
starting with login screen to login an existing user with email and password 
if user not registered he can register his self with user name ,email ,password and his photo
and then enter into chat tableview and send messages and images to friends .
ChatApp uses Coredata to store users and messages 

# Implementation

### LoginViewController:
	using email and password you can login to your account .
	or you can signup for first time by clicking on signup button.
### RegisterViewController:
	by providing your photo , username ,email and password you can create account
	and enter the chatViewController
### ChatViewController:
	it display your messages that you send to your friends and enable you
	to send new messages and photo
### DataController:
	class that enable to use Coredata  and persistent data.
### FirebaseClass:
	containing main API functions to communicate with Firebase.

# How to build

Using cocoa pods install :
	#Uncomment the next line to define a global platform for your project
	platform :ios, '9.0'

	target 'ChatApp' do
 	 # Comment the next line if you don't want to use dynamic frameworks
  	use_frameworks!

 	 # Pods for ChatApp
	pod 'Firebase/Storage'	
	pod 'Firebase/Core'
	pod 'Firebase/Database'
	
	end
	--------
	
	firebase database , storage 

# Requirements

Xcode 9.2
Swift 4.0
Firebase
