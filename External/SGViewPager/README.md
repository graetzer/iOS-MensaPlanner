# Description #
SGViewPager contains custom UIViewController container, that display the content of child viewcontroller's in a paged scrollview.
There are three implemenations, but the only recent one is [https://github.com/graetzer/SGViewPager/blob/master/SGTabbedPager.swift](SGTabbedPager)
It is designed to look like the tabs in the android ActionBar and works really well for certain use cases.
You can watch a [Demo video on youtube](http://youtu.be/IgrEA3FjGfs)
It's written in swift and should be easy to customize.

For example code look at my [MealPlanner App](https://github.com/graetzer/iOS-MensaPlanner)

-------------------------

There are two more implementations, but they are not very recent. You will likely find the look outdated.
-  SGAnnotatedPagerController: Shows the title of child viewcontroller's at the top, slightly similar to the stream view in the Google+ App

-  SGViewPagerController: Display a UIPageControl at the bottom of the page

# How to use these in your own project #
Just copy either the SGAnnotatedPagerController.* files or the SGViewPagerController.* files in your XCode project.
You don't have to load the viewcontrollers from a xib or a storyboard file, just make sure that the view
has an appropriate size if you use a UINavigationController (416px) or a UITabBarController(411px).

# Example code #
	SGAnnotatedPagerController *annotated = [[SGAnnotatedPagerController alloc]initWithNibName:@"SGAnnotatedPagerController" bundle:nil];
	annotated.title = @"TitleControl";
	for (int i = 0; i < 5; i++) {
 	   SGExampleController *ec = [[SGExampleController alloc] init];
	    ec.title = [NSString stringWithFormat:@"Nr. %d", i+1];
	    [annotated addPage:ec];
	}
	self.window.rootViewController = annotated;
	// ...


For detailed example code look in the SGAppDelegate.m file in the example project

# Licence #
Copyright (c) 2012 Simon Grätzer

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
