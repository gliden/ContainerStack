# ContainerStack
A library for easy to use animations using layouts.

This "Framework" is just working with Firemonkey.

# How to use this library
First of all add the unit "ContainerStackLib" to your project
## Initialize the class
call this in your mainform unit 
```
TContainerStack.Current.Initialize(Self); 
```
## Add clientforms to the class
call this in your clientform units
  
your clientforms must have a TLayout-Component on it otherwise the whole animation thing wont work
```
TContainerStack.Current.RegisterForm(Self);
```
## Set the first form visible

You can set the first form visible in the constructor of it
```
TContainerStack.Current.ShowFormNoAnimation(Self);
```
or you call this method in the mainform-unit
```
TContainerStack.Current.ShowFormNoAnimation(TestDlg1);
```
## Show a form  with animations
To show a form with an animation you have to call 
```
TContainerStack.Current.ShowForm(TestDlg2, TAnimationStyle.OverlayFromBottom, 0.8);
```
The Parameters:
1. The new dialog wich should be shown
2. The style wich should be used for animation (see below for all animation styles)
3. The animation durration (default 0.2 seconds)

There are some animation styles
* FromRight
* FromLeft
* FromTop
* FromBottom
* OverlayFromBottom
* OverlayFromTop

## Back to previous form
If you just want to go back to your previous form with the corresponding animation and duration call
```
TContainerStack.Current.Back;
```
