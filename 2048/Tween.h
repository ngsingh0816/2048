//
//  Tween.h
//  2048
//
//  Created by Neil on 4/9/14.
//  Copyright (c) 2014 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>

float MDTweenLinear(float time);
float MDTweenEaseInQuadratic(float time);
float MDTweenEaseOutQuadratic(float time);
float MDTweenEaseInOutQuadratic(float time);
float MDTweenEaseInCubic(float time);
float MDTweenEaseOutCubic(float time);
float MDTweenEaseInOutCubic(float time);
float MDTweenEaseInQuartic(float time);
float MDTweenEaseOutQuartic(float time);
float MDTweenEaseInOutQuartic(float time);
float MDTweenEaseInQuintic(float time);
float MDTweenEaseOutQuintic(float time);
float MDTweenEaseInOutQuintic(float time);
float MDTweenEaseInSin(float time);
float MDTweenEaseOutSin(float time);
float MDTweenEaseInOutSin(float time);
float MDTweenEaseInExp(float time);								// 2^10
float MDTweenEaseOutExp(float time);							// 2^10
float MDTweenEaseInOutExp(float time);							// 2^10
float MDTweenEaseInExpX(float time, float base, float exp);		// base^exp
float MDTweenEaseOutExpX(float time, float base, float exp);	// base^exp
float MDTweenEaseInOutExpX(float time, float base, float exp);	// base^exp
float MDTweenEaseInCircle(float time);
float MDTweenEaseOutCircle(float time);
float MDTweenEaseInOutCircle(float time);
float MDTweenEaseInElastic(float time);
float MDTweenEaseOutElastic(float time);
float MDTweenEaseInOutElastic(float time);
float MDTweenEaseInBack(float time);
float MDTweenEaseOutBack(float time);
float MDTweenEaseInOutBack(float time);
float MDTweenEaseInBounce(float time);
float MDTweenEaseOutBounce(float time);
float MDTweenEaseInOutBounce(float time);
